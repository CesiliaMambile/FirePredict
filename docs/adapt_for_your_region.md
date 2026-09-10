# Adapting FirePredict for Your Region

This guide explains how to deploy FirePredict for **any forested area in the world** — not just Mount Kilimanjaro.

---

## Step 1: Define Your Monitoring Zones

Edit `backend/main.py`, replacing the `ZONES` list with your own zones:

```python
ZONES = [
    {
        "id": "zone_1",
        "name": "Your Zone Name",
        "lat": YOUR_LATITUDE,   # decimal degrees
        "lon": YOUR_LONGITUDE,  # decimal degrees
        "human": [3, 2, 0.5, 1200, 1, 3, 0.5],  # see human activity below
    },
    # ... add more zones
]
```

**Human activity vector** (7 values):
| Index | Feature | Range | Description |
|-------|---------|-------|-------------|
| 0 | Zone type | 1–5 | 1=remote forest, 5=park/reserve |
| 1 | Access difficulty | 1–5 | 1=easy road, 5=no access |
| 2 | Tourism intensity | 0.0–1.0 | Tourist presence (0=none, 1=peak) |
| 3 | Elevation (m) | 0–6000 | Zone centre elevation |
| 4 | Season | 0 or 1 | 0=wet season, 1=dry season |
| 5 | Vegetation density | 1–9 | Density score from land cover map |
| 6 | Beekeeping/burning | 0.0–1.0 | Activity with open flame risk |

---

## Step 2: Collect Satellite Data

Use **Google Earth Engine** (free account) to download Sentinel-2 indices for your region:

```javascript
// Google Earth Engine script — NDVI, NBR, NDWI for any region
var region = ee.Geometry.Rectangle([LON_MIN, LAT_MIN, LON_MAX, LAT_MAX]);
var s2 = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
  .filterBounds(region)
  .filterDate('2015-01-01', '2025-12-31')
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20));

var addIndices = function(image) {
  var ndvi = image.normalizedDifference(['B8', 'B4']).rename('NDVI');
  var nbr  = image.normalizedDifference(['B8', 'B12']).rename('NBR');
  var ndwi = image.normalizedDifference(['B8', 'B11']).rename('NDWI');
  return image.addBands([ndvi, nbr, ndwi]);
};

Export.table.toDrive({collection: s2.map(addIndices).select(['NDVI','NBR','NDWI']), ...});
```

Alternatively, download directly from [Copernicus Open Access Hub](https://scihub.copernicus.eu/).

---

## Step 3: Collect Weather Data

**Free sources:**
- [ERA5 Reanalysis (Copernicus)](https://cds.climate.copernicus.eu) — global, daily, 1979–present
- [Open-Meteo](https://open-meteo.com) — free API, no key needed, 10-day history
- [CHIRPS](https://www.chc.ucsb.edu/data/chirps) — daily rainfall, Africa and global

Required variables: `temperature`, `humidity`, `wind_speed`, `rainfall`, `min_temp`, `max_temp`

---

## Step 4: Define Human Activity Features

For your region, identify the key human activities that create fire ignition risk:

| Forest Type | Common High-Risk Activities |
|-------------|---------------------------|
| East Africa montane | Beekeeping (open flame), charcoal burning, agriculture |
| Southeast Asia | Shifting cultivation, palm oil burning |
| Mediterranean | Hikers, vehicle sparks, agricultural burning |
| Amazon | Deforestation burning, ranching |
| Australia | Campfires, power lines, arson |

Map each activity to a 0–1 score based on intensity/frequency in each zone. Use surveys, park records, or proxy data (mobile phone density, road network proximity, land cover change).

---

## Step 5: Retrain the Model

Open `notebooks/02_convlstm_training.ipynb` and update:

```python
# Update data paths for your region
SATELLITE_DATA_PATH = 'data/your_region_sentinel2.csv'
WEATHER_DATA_PATH   = 'data/your_region_weather.csv'
FIRE_RECORDS_PATH   = 'data/your_region_fires.csv'  # from national fire databases

# Update region parameters
STUDY_REGION = 'Your Forest Name'
LATITUDE_CENTER  = YOUR_LAT
LONGITUDE_CENTER = YOUR_LON
```

Then run all cells. The notebook handles:
- Data preprocessing and normalisation
- Temporal train/test split (80/20 chronological)
- ConvLSTM architecture definition
- Training with early stopping
- Model evaluation and export

**Minimum recommended training data:**
- 5+ years of satellite data (ideally 10+)
- At least 20 confirmed fire events (for the positive class)
- Daily weather records for the full period

---

## Step 6: Update the Mobile App

Edit `mobile/lib/services/api_service.dart`:

```dart
// Point to your backend
const String kBaseUrl = 'http://YOUR_SERVER_IP:8080';

// Update demo zone data for your region
const _demoZones = {
  'zones': [
    {'zone_name': 'Your Zone 1', 'lat': YOUR_LAT, 'lon': YOUR_LON,
     'risk_score': 0.75, 'risk_label': 'High', 'risk_color': '#D32F2F'},
    // ...
  ]
};
```

Update zone names throughout the app, particularly in `alerts_screen.dart` and `map_screen.dart`.

---

## Step 7: Deploy

**Minimum server requirements:**
- Python 3.10+
- 4 GB RAM (for TensorFlow model loading)
- 10 GB disk space
- Stable internet for satellite data ingestion

**Recommended deployment:**
- Linux VPS (Ubuntu 22.04) — DigitalOcean, AWS EC2, Google Cloud
- Nginx as reverse proxy
- Gunicorn + Uvicorn workers

```bash
gunicorn main:app -w 2 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8080
```

---

## Support

If you deploy FirePredict for your region, we'd love to hear from you. Open an issue on GitHub or contact Dr. Cesilia Mambile at the University of Dodoma.

*Together we can protect forests globally — one early warning at a time.*
