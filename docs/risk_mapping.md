# Risk Mapping — Technical Guide

FirePredict's risk map is an open-source, interactive map displaying fire risk zones across Mount Kilimanjaro in real time. This document explains how it works and how to extend or adapt it.

---

## Overview

The risk map combines three components:

1. **Backend zone risk scores** — ConvLSTM model predictions served via the `/zones` API endpoint
2. **Flutter map widget** — `flutter_map` renders zones on OpenStreetMap tiles with colour-coded markers
3. **Offline fallback** — built-in demo zone data ensures the map always displays, even without internet

---

## Zone Definitions

Each monitoring zone is defined in `backend/main.py` with a GPS coordinate, zone metadata, and human activity vector:

```python
ZONES = [
    {
        "id": "south_slope",
        "name": "South Slope",
        "lat": -3.145,
        "lon": 37.355,
        "human": [3, 1, 0.8, 1100, 1, 2, 0.6],
    },
    # ... more zones
]
```

The backend computes a risk score (0.0–1.0) for each zone using current satellite indices and weather data, then returns them via `GET /zones`.

---

## Risk Colour Thresholds

| Score Range | Label | Hex Colour | Display |
|-------------|-------|------------|---------|
| ≥ 0.75 | High | `#D32F2F` | Red circle marker |
| ≥ 0.50 | Moderate | `#F57C00` | Orange circle marker |
| ≥ 0.30 | Low | `#FBC02D` | Yellow circle marker |
| < 0.30 | Very Low | `#388E3C` | Green circle marker |

These thresholds are defined in `backend/main.py` (`risk_label()` and `risk_color()` functions) and interpreted in `mobile/lib/screens/map_screen.dart`.

---

## Mobile App Map Implementation

The map screen (`mobile/lib/screens/map_screen.dart`) uses `flutter_map`:

```dart
FlutterMap(
  options: MapOptions(
    initialCenter: LatLng(-3.07, 37.35),  // Mount Kilimanjaro centre
    initialZoom: 11.0,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    ),
    MarkerLayer(
      markers: zones.map((zone) => Marker(
        point: LatLng(zone['lat'], zone['lon']),
        child: _ZoneMarker(zone: zone),
      )).toList(),
    ),
  ],
)
```

Each marker is colour-coded based on the `risk_color` field from the API response. Tapping a marker shows a popup with the zone name and risk score.

---

## Adding New Zones

### Step 1: Add to the backend

In `backend/main.py`, add a new entry to the `ZONES` list:

```python
{
    "id": "your_zone_id",
    "name": "Your Zone Name",
    "lat": YOUR_LATITUDE,
    "lon": YOUR_LONGITUDE,
    "human": [zone_type, access, tourism, elevation, season, vegetation, burning],
}
```

### Step 2: Update demo data in the app

In `mobile/lib/services/api_service.dart`, add the zone to `_demoZones` so it appears even when offline:

```dart
{'zone_name': 'Your Zone Name', 'lat': YOUR_LAT, 'lon': YOUR_LON,
 'risk_score': 0.5, 'risk_label': 'Moderate', 'risk_color': '#F57C00'},
```

### Step 3: Rebuild the app

```bash
cd mobile
flutter build apk --release
```

---

## Deploying for a Different Region

To adapt the risk map for a different forest or country:

1. **Replace zone coordinates** with your monitoring zones (see above)
2. **Change the map centre** in `map_screen.dart` (`initialCenter` and `initialZoom`)
3. **Update human activity vectors** to reflect land use in your region
4. **Retrain the model** with local satellite and fire data (see `notebooks/`)

The map tiles come from OpenStreetMap — no API key, no cost, works globally.

---

## Data Flow Diagram

```
ConvLSTM Model
      │
      ▼
/zones endpoint (FastAPI)
      │
      ▼
ApiService.getZones() (Flutter)
      │
   ┌──┴──────────────────┐
   │ Online              │ Offline
   │ Live predictions    │ Cached or demo data
   └──┬──────────────────┘
      │
      ▼
MapScreen → flutter_map
      │
      ▼
Colour-coded zone markers on OpenStreetMap
```

---

## Map Dependencies

In `mobile/pubspec.yaml`:

```yaml
dependencies:
  flutter_map: ^7.0.2    # Interactive map widget
  latlong2: ^0.9.0       # Coordinate types
```

No paid API keys are required. Map tiles are served free by OpenStreetMap.

---

## Historical Fire Records on the Map

Historical fire locations (2015–2025, from TANAPA records) are used during model training but are not plotted on the live map in the current version. A future enhancement could add a toggleable historical fire layer to help users see which zones have burned before.

To contribute this feature, see the [Contributing](../README.md#contributing) section.
