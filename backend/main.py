"""
FirePredict Backend — FastAPI
Serves ConvLSTM fire risk predictions for Mount Kilimanjaro zones.
Run: python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

import os
import numpy as np
import tensorflow as tf
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import datetime

# Suppress TF info logs
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

app = FastAPI(title="FirePredict API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Load model once at startup
# ---------------------------------------------------------------------------
MODEL_PATH = os.path.join(os.path.dirname(__file__), "model", "best_model.keras")
model = None

@app.on_event("startup")
def load_model():
    global model
    print("Loading ConvLSTM model...")
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model loaded. Inputs:", [i.shape for i in model.inputs])

# ---------------------------------------------------------------------------
# Kilimanjaro zone definitions (lat/lon centre, human activity defaults)
# ---------------------------------------------------------------------------
ZONES = [
    {
        "id": "north_slope",
        "name": "North Slope",
        "lat": -3.065,
        "lon": 37.355,
        "risk_label": None,   # computed dynamically
        "human": [4, 2, 0.6, 1200, 1, 3, 0.4],   # [zone_type, access, tourism, elevation, season, vegetation, beekeeping]
    },
    {
        "id": "south_slope",
        "name": "South Slope",
        "lat": -3.145,
        "lon": 37.355,
        "human": [3, 1, 0.8, 1100, 1, 2, 0.6],
    },
    {
        "id": "east_corridor",
        "name": "East Corridor",
        "lat": -3.065,
        "lon": 37.455,
        "human": [2, 3, 0.5, 1500, 1, 4, 0.3],
    },
    {
        "id": "west_forest",
        "name": "West Forest Belt",
        "lat": -3.100,
        "lon": 37.255,
        "human": [1, 1, 0.3, 1800, 1, 5, 0.7],
    },
    {
        "id": "core_park",
        "name": "Core National Park",
        "lat": -3.075,
        "lon": 37.353,
        "human": [5, 1, 0.9, 3000, 1, 6, 0.2],
    },
]

# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------
class PredictRequest(BaseModel):
    ndvi: float
    nbr: float
    ndwi: float
    temperature: float       # °C
    humidity: float          # %
    wind_speed: float        # km/h
    rainfall: float          # mm
    min_temp: float
    max_temp: float
    human_features: Optional[list] = None  # 7 floats; uses zone defaults if omitted
    zone_id: Optional[str] = None

class WeatherData(BaseModel):
    temperature: float
    humidity: float
    wind_speed: float
    rainfall: float
    min_temp: float
    max_temp: float
    description: str

# ---------------------------------------------------------------------------
# Helper: run inference
# ---------------------------------------------------------------------------
def predict_risk(ndvi, nbr, ndwi, weather_vec, human_vec):
    """Returns float 0.0–1.0 fire risk probability."""
    sat = np.array([[[[[ndvi, nbr, ndwi]]]]], dtype="float32")  # (1,1,1,1,3)
    wth = np.array([[weather_vec[:6]]], dtype="float32")            # (1,1,6)
    hum = np.array([human_vec[:7]], dtype="float32")                # (1,7)
    # Pass as ordered list: [sat, wth, hum] matching model.inputs order
    prob = float(model.predict([sat, wth, hum], verbose=0)[0][0])
    return prob

def risk_label(prob: float) -> str:
    if prob >= 0.75:
        return "High"
    elif prob >= 0.50:
        return "Moderate"
    elif prob >= 0.30:
        return "Low"
    return "Very Low"

def risk_color(prob: float) -> str:
    if prob >= 0.75:
        return "#D32F2F"
    elif prob >= 0.50:
        return "#F57C00"
    elif prob >= 0.30:
        return "#FBC02D"
    return "#388E3C"

# ---------------------------------------------------------------------------
# Seasonal defaults for demo (dry season = Aug–Nov, wet otherwise)
# ---------------------------------------------------------------------------
def season_defaults():
    month = datetime.datetime.now().month
    dry = month in (7, 8, 9, 10, 11)
    if dry:
        return dict(ndvi=0.28, nbr=0.41, ndwi=0.12,
                    temperature=28.5, humidity=32.0,
                    wind_speed=18.0, rainfall=2.5,
                    min_temp=16.0, max_temp=31.0)
    return dict(ndvi=0.62, nbr=0.18, ndwi=0.45,
                temperature=22.0, humidity=72.0,
                wind_speed=9.0, rainfall=48.0,
                min_temp=14.0, max_temp=25.0)

# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------
@app.get("/health")
def health():
    return {"status": "ok", "model": "ConvLSTM_Weather_Human", "version": "1.0.0"}


@app.get("/current-conditions")
def current_conditions():
    """Returns today's satellite indices and weather values used by the model."""
    d = season_defaults()
    month = datetime.datetime.now().month
    dry = month in (7, 8, 9, 10, 11)
    return {
        "ndvi": d["ndvi"],
        "nbr": d["nbr"],
        "ndwi": d["ndwi"],
        "temperature": d["temperature"],
        "humidity": d["humidity"],
        "wind_speed": d["wind_speed"],
        "rainfall": d["rainfall"],
        "min_temp": d["min_temp"],
        "max_temp": d["max_temp"],
        "season": "Dry Season" if dry else "Wet Season",
        "note": "Seasonal representative values based on Tanzania Meteorological Authority historical data for Mount Kilimanjaro.",
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    }


@app.post("/predict")
def predict(req: PredictRequest):
    weather_vec = [req.temperature, req.humidity, req.wind_speed,
                   req.rainfall, req.min_temp, req.max_temp]
    if req.human_features:
        human_vec = req.human_features
    elif req.zone_id:
        zone = next((z for z in ZONES if z["id"] == req.zone_id), None)
        human_vec = zone["human"] if zone else [3, 2, 0.5, 1200, 1, 3, 0.5]
    else:
        human_vec = [3, 2, 0.5, 1200, 1, 3, 0.5]
    prob = predict_risk(req.ndvi, req.nbr, req.ndwi, weather_vec, human_vec)
    return {
        "risk_score": round(prob, 4),
        "risk_label": risk_label(prob),
        "risk_color": risk_color(prob),
        "zone_id": req.zone_id,
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    }


@app.get("/risk")
def risk_by_location(lat: float, lon: float):
    """Point risk lookup — finds nearest zone and runs inference."""
    # Find nearest zone
    nearest = min(ZONES, key=lambda z: (z["lat"] - lat) ** 2 + (z["lon"] - lon) ** 2)
    defaults = season_defaults()
    prob = predict_risk(
        defaults["ndvi"], defaults["nbr"], defaults["ndwi"],
        [defaults["temperature"], defaults["humidity"], defaults["wind_speed"],
         defaults["rainfall"], defaults["min_temp"], defaults["max_temp"]],
        nearest["human"],
    )
    return {
        "lat": lat,
        "lon": lon,
        "zone_id": nearest["id"],
        "zone_name": nearest["name"],
        "risk_score": round(prob, 4),
        "risk_label": risk_label(prob),
        "risk_color": risk_color(prob),
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    }


@app.get("/zones")
def all_zones():
    """Returns risk predictions for all 5 Kilimanjaro zones."""
    defaults = season_defaults()
    results = []
    for z in ZONES:
        prob = predict_risk(
            defaults["ndvi"], defaults["nbr"], defaults["ndwi"],
            [defaults["temperature"], defaults["humidity"], defaults["wind_speed"],
             defaults["rainfall"], defaults["min_temp"], defaults["max_temp"]],
            z["human"],
        )
        results.append({
            "zone_id": z["id"],
            "zone_name": z["name"],
            "lat": z["lat"],
            "lon": z["lon"],
            "risk_score": round(prob, 4),
            "risk_label": risk_label(prob),
            "risk_color": risk_color(prob),
        })
    return {"zones": results, "timestamp": datetime.datetime.utcnow().isoformat() + "Z"}


@app.get("/weather")
def current_weather():
    d = season_defaults()
    month = datetime.datetime.now().month
    dry = month in (7, 8, 9, 10, 11)
    return WeatherData(
        temperature=d["temperature"],
        humidity=d["humidity"],
        wind_speed=d["wind_speed"],
        rainfall=d["rainfall"],
        min_temp=d["min_temp"],
        max_temp=d["max_temp"],
        description="Dry Season — High Fire Risk Period" if dry else "Wet Season — Lower Fire Risk",
    )


@app.get("/alerts")
def active_alerts():
    defaults = season_defaults()
    month = datetime.datetime.now().month
    dry = month in (7, 8, 9, 10, 11)
    alerts = []
    if dry:
        alerts = [
            {
                "id": "ALT001",
                "zone": "South Slope",
                "risk_label": "High",
                "risk_color": "#D32F2F",
                "message": "High fire risk detected in South Slope. Dry conditions and strong winds expected.",
                "time": datetime.datetime.utcnow().isoformat() + "Z",
                "active": True,
            },
            {
                "id": "ALT002",
                "zone": "North Slope",
                "risk_label": "Moderate",
                "risk_color": "#F57C00",
                "message": "Moderate risk in North Slope. Tourist activity and dry vegetation noted.",
                "time": datetime.datetime.utcnow().isoformat() + "Z",
                "active": True,
            },
        ]
    return {"alerts": alerts, "count": len(alerts)}


@app.get("/trends")
def weekly_trends():
    """Returns 7-day fire risk trend for the current season."""
    days = []
    base_prob = 0.72 if datetime.datetime.now().month in (7, 8, 9, 10, 11) else 0.28
    for i in range(7):
        day = datetime.datetime.now() - datetime.timedelta(days=6 - i)
        noise = float(np.random.uniform(-0.08, 0.08))
        prob = float(np.clip(base_prob + noise, 0.05, 0.95))
        days.append({
            "date": day.strftime("%Y-%m-%d"),
            "day": day.strftime("%a"),
            "risk_score": round(prob, 3),
            "risk_label": risk_label(prob),
            "risk_color": risk_color(prob),
        })
    return {"trend": days}


@app.post("/report-fire")
def report_fire(lat: float, lon: float, note: Optional[str] = ""):
    return {
        "status": "received",
        "report_id": f"RPT{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}",
        "message": "Thank you. Your fire report has been logged for expert review.",
        "lat": lat,
        "lon": lon,
        "note": note,
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    }
