# FirePredict — Risk Mapping Tools

Open-source tools for generating and visualising fire risk maps for Mount Kilimanjaro. These tools work **standalone** — no mobile app or backend server required.

---

## Tools Included

| File | Description |
|------|-------------|
| `generate_risk_map.py` | Python script — generates an interactive HTML fire risk map |
| `kilimanjaro_zones.geojson` | GeoJSON file — all 7 monitoring zones with coordinates and metadata |

---

## 1. Interactive HTML Risk Map

### Install

```bash
pip install folium requests
```

### Run

```bash
python generate_risk_map.py
```

### Output

Creates `kilimanjaro_risk_map.html` — open it in any web browser. No internet connection needed after generation.

The map shows all 7 monitoring zones as colour-coded circles:

| Colour | Risk Level | Score |
|--------|-----------|-------|
| 🔴 Red | High | ≥ 0.75 |
| 🟠 Orange | Moderate | ≥ 0.50 |
| 🟡 Yellow | Low | ≥ 0.30 |
| 🟢 Green | Very Low | < 0.30 |

Click any zone circle to see its risk score, description, and conditions.

### Live vs Demo Mode

- **If the FirePredict backend is running** at `http://localhost:8080`, the script fetches live risk scores from the ConvLSTM model
- **If the server is offline**, the script automatically uses built-in demo data — the map always works

To point to a different server, edit line 28 of the script:
```python
BACKEND_URL = "http://YOUR_SERVER_IP:8080"
```

---

## 2. GeoJSON Zone File

`kilimanjaro_zones.geojson` is a standard GIS file containing all 7 monitoring zones.

### Use in QGIS (free GIS software)
1. Open QGIS
2. Drag and drop `kilimanjaro_zones.geojson` onto the map canvas
3. Style by the `risk_label` or `risk_score` field

### Use in Google Earth
1. Rename the file to `kilimanjaro_zones.json`
2. Import via **File → Import**

### Use in Python (geopandas)
```python
import geopandas as gpd
zones = gpd.read_file("kilimanjaro_zones.geojson")
print(zones[["zone_name", "risk_label", "risk_score"]])
zones.plot(column="risk_score", cmap="RdYlGn_r", legend=True)
```

### Use in JavaScript / Leaflet / Mapbox
```javascript
fetch("kilimanjaro_zones.geojson")
  .then(r => r.json())
  .then(data => L.geoJSON(data).addTo(map));
```

### Fields in the GeoJSON

| Field | Type | Description |
|-------|------|-------------|
| `zone_id` | string | Unique identifier |
| `zone_name` | string | Human-readable zone name |
| `elevation_m` | number | Zone centre elevation (metres) |
| `vegetation` | string | Vegetation type |
| `risk_label` | string | High / Moderate / Low / Very Low |
| `risk_score` | number | Model risk score 0.0–1.0 |
| `risk_color` | string | Hex colour for visualisation |
| `notes` | string | Zone-specific fire risk notes |

---

## Adapting for Your Region

To use these tools for a different forest or country:

1. Edit `kilimanjaro_zones.geojson` — replace coordinates and zone names with your monitoring zones
2. Edit `generate_risk_map.py` — update `DEMO_ZONES` and change `BACKEND_URL` to your server
3. Change the map centre (line 96 in the script): `location=[YOUR_LAT, YOUR_LON]`

The tools use OpenStreetMap tiles — free, no API key needed, works anywhere in the world.

---

## Example Output

When you run `python generate_risk_map.py`, you will see:

```
FirePredict — Risk Map Generator
========================================
Server offline or unreachable — using built-in demo data.

Map saved to: C:\...\kilimanjaro_risk_map.html
Open it in any web browser — no server needed.

Zone Summary:
  Zone                   Risk       Score
  ---------------------- ---------- -----
  Machame Route          High       0.82
  Shira Plateau          High       0.71
  Mweka Route            High       0.76
  Rongai Corridor        Moderate   0.55
  Marangu Gate           Low        0.38
  Karanga Valley         Very Low   0.22
  Kilema Area            Very Low   0.16
```

---

## License

MIT License — free to use, modify, and adapt for any region globally.

See [../LICENSE](../LICENSE) for full terms.
