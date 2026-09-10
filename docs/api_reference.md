# FirePredict API Reference

Base URL: `http://YOUR_SERVER_IP:8080`

Interactive docs (Swagger UI): `http://YOUR_SERVER_IP:8080/docs`

---

## Endpoints

### GET /health
Check server and model status.

**Response:**
```json
{ "status": "ok", "model": "ConvLSTM_Weather_Human", "version": "1.0.0" }
```

---

### GET /zones
Returns fire risk predictions for all monitoring zones.

**Response:**
```json
{
  "zones": [
    {
      "zone_id": "south_slope",
      "zone_name": "South Slope",
      "lat": -3.145,
      "lon": 37.355,
      "risk_score": 0.823,
      "risk_label": "High",
      "risk_color": "#D32F2F"
    }
  ],
  "timestamp": "2026-09-10T08:00:00Z"
}
```

Risk labels: `"High"` (≥0.75) | `"Moderate"` (≥0.50) | `"Low"` (≥0.30) | `"Very Low"` (<0.30)

---

### GET /alerts
Returns active fire risk alerts.

**Response:**
```json
{
  "alerts": [
    {
      "id": "ALT001",
      "zone": "South Slope",
      "risk_label": "High",
      "risk_color": "#D32F2F",
      "message": "High fire risk detected...",
      "time": "2026-09-10T08:00:00Z",
      "active": true
    }
  ],
  "count": 1
}
```

---

### POST /predict
Run a custom fire risk prediction.

**Request body:**
```json
{
  "ndvi": 0.28,
  "nbr": 0.41,
  "ndwi": 0.12,
  "temperature": 28.5,
  "humidity": 32.0,
  "wind_speed": 18.0,
  "rainfall": 2.5,
  "min_temp": 16.0,
  "max_temp": 31.0,
  "zone_id": "south_slope",
  "human_features": null
}
```

**Response:**
```json
{
  "risk_score": 0.8231,
  "risk_label": "High",
  "risk_color": "#D32F2F",
  "zone_id": "south_slope",
  "timestamp": "2026-09-10T08:00:00Z"
}
```

---

### GET /risk?lat=&lon=
Point risk lookup — finds nearest zone and runs inference.

**Parameters:** `lat` (float), `lon` (float)

**Response:**
```json
{
  "lat": -3.1,
  "lon": 37.35,
  "zone_id": "south_slope",
  "zone_name": "South Slope",
  "risk_score": 0.8231,
  "risk_label": "High",
  "risk_color": "#D32F2F",
  "timestamp": "2026-09-10T08:00:00Z"
}
```

---

### GET /weather
Current meteorological conditions.

**Response:**
```json
{
  "temperature": 28.5,
  "humidity": 32.0,
  "wind_speed": 18.0,
  "rainfall": 2.5,
  "min_temp": 16.0,
  "max_temp": 31.0,
  "description": "Dry Season — High Fire Risk Period"
}
```

---

### GET /current-conditions
Full current conditions including satellite indices.

**Response:**
```json
{
  "ndvi": 0.28,
  "nbr": 0.41,
  "ndwi": 0.12,
  "temperature": 28.5,
  "humidity": 32.0,
  "wind_speed": 18.0,
  "rainfall": 2.5,
  "min_temp": 16.0,
  "max_temp": 31.0,
  "season": "Dry Season",
  "timestamp": "2026-09-10T08:00:00Z"
}
```

---

### GET /trends
7-day fire risk trend data.

**Response:**
```json
{
  "trend": [
    { "date": "2026-09-04", "day": "Thu", "risk_score": 0.724, "risk_label": "High", "risk_color": "#D32F2F" },
    { "date": "2026-09-05", "day": "Fri", "risk_score": 0.741, "risk_label": "High", "risk_color": "#D32F2F" }
  ]
}
```

---

### POST /report-fire?lat=&lon=&note=
Submit a community fire report.

**Parameters:** `lat` (float), `lon` (float), `note` (string, optional)

**Response:**
```json
{
  "status": "received",
  "report_id": "RPT20260910080000",
  "message": "Thank you. Your fire report has been logged for expert review.",
  "lat": -3.1,
  "lon": 37.35,
  "timestamp": "2026-09-10T08:00:00Z"
}
```
