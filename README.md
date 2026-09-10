# 🔥 FirePredict — AI-Powered Forest Fire Early Warning System

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-brightgreen.svg)](mobile/)
[![Backend: FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688.svg)](backend/)
[![Model: ConvLSTM](https://img.shields.io/badge/Model-ConvLSTM-FF6F00.svg)](notebooks/)
[![UNFCCC Finalist](https://img.shields.io/badge/UNFCCC%20AI%20for%20Climate-Top%205%20Finalist%202026-blue.svg)](https://unfccc.int)

> **Top 5 Finalist — UNFCCC AI for Climate Action Award 2026**
> Developed at the **University of Dodoma (UDOM), Tanzania**

FirePredict is an open-source forest fire early warning system for **Mount Kilimanjaro**, combining satellite remote sensing, deep learning (ConvLSTM), and human activity data to predict fire risk up to 5 days in advance. The system delivers real-time alerts to rangers, forest managers, and local communities via a mobile app.

---

## Why This Matters

Mount Kilimanjaro's forests — a critical watershed for over 2 million people in Tanzania — have been severely damaged by recurring fires. Historical data (2015–2025) shows that 85% of fires were preventable with early warning. Existing fire management systems rely on reactive responses after fire is already spreading.

**FirePredict changes this**: by integrating Sentinel-2 satellite indices (NDVI, NBR, NDWI), meteorological data, and novel **human activity features** (beekeeping, tourism, agricultural burning), our ConvLSTM model achieves **87.3% accuracy** and **0.91 AUC** — enabling proactive response before ignition occurs.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   FirePredict System                         │
├──────────────┬──────────────────┬───────────────────────────┤
│  Satellite   │   Meteorological │   Human Activity          │
│  (Sentinel-2)│   (TMA / ERA5)   │   (Surveys + Proxies)     │
│  NDVI, NBR,  │   Temp, Humidity,│   Tourism, Beekeeping,    │
│  NDWI        │   Wind, Rainfall │   Agricultural Burning    │
└──────┬───────┴────────┬─────────┴──────────────┬────────────┘
       └────────────────┼────────────────────────┘
                        ▼
            ┌───────────────────────┐
            │  ConvLSTM Deep        │
            │  Learning Model       │
            │  Accuracy: 87.3%      │
            │  AUC: 0.91            │
            └───────────┬───────────┘
                        ▼
            ┌───────────────────────┐
            │  FastAPI Backend      │
            │  REST API + Alerts    │
            └───────────┬───────────┘
                        ▼
            ┌───────────────────────┐
            │  Flutter Mobile App   │
            │  (Android)            │
            │  Rangers + Communities│
            └───────────────────────┘
```

---

## Repository Structure

```
FirePredict/
├── mobile/              # Flutter/Dart Android app (v9.0.0)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/     # Impact, Alerts, Map, Weather, Report...
│   │   └── services/    # API service with offline caching
│   └── pubspec.yaml
│
├── backend/             # FastAPI Python server
│   ├── main.py          # All REST endpoints
│   └── requirements.txt
│
├── notebooks/           # Model training & satellite processing
│   ├── 01_satellite_processing.ipynb   # Sentinel-2 download + indices
│   ├── 02_convlstm_training.ipynb      # ConvLSTM model training
│   └── 03_human_activity_features.ipynb # Human activity feature engineering
│
├── docs/
│   ├── adapt_for_your_region.md   # Guide: deploy for any forest/region
│   ├── model_card.md              # Model details, training data, limitations
│   └── api_reference.md           # REST API documentation
│
└── README.md
```

---

## Key Features

### Mobile App (Flutter/Android)
- **Impact Dashboard** — fire statistics (2015–2025), lives & hectares at risk
- **Real-Time Alerts** — zone-level alerts with predicted windows, risk drivers, recommended actions
- **Interactive Risk Map** — colour-coded zones (Very Low → High) with tap-to-inspect
- **Weather Dashboard** — temperature, humidity, wind, rainfall with fire risk indicators
- **Community Fire Reporting** — GPS-tagged photo reports sent to forest managers
- **Offline Mode** — app works without internet using cached data + built-in demo

### Backend (FastAPI)
- `/zones` — fire risk scores for all monitoring zones
- `/alerts` — active fire risk alerts
- `/predict` — custom scenario prediction with any input values
- `/weather` — current meteorological conditions
- `/trends` — 7-day risk trend chart data
- `/report-fire` — receive community fire reports
- `/health` — server health check

### Model (ConvLSTM)
- **Architecture**: ConvLSTM2D with multi-branch inputs (satellite + weather + human activity)
- **Training Data**: Sentinel-2 imagery + TMA weather records (2015–2025) + custom human activity surveys
- **Accuracy**: 87.3% | **AUC**: 0.91 | **F1-Score**: 0.86
- **Prediction Window**: Up to 5 days ahead

---

## Quick Start

### 1. Run the Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

Visit **http://localhost:8080/docs** for the interactive API documentation.

> **Note**: The production model file (`model/best_model.keras`) is not included in this repo due to size. See [notebooks/02_convlstm_training.ipynb](notebooks/02_convlstm_training.ipynb) to train your own, or request the pre-trained weights via the contact below.

### 2. Build the Mobile App

```bash
cd mobile
flutter pub get
flutter build apk --release
```

Requires: Flutter SDK ≥ 3.0, Android SDK, JDK 17+

APK output: `mobile/build/app/outputs/flutter-apk/app-release.apk`

### 3. Configure Server URL

Edit `mobile/lib/services/api_service.dart`:

```dart
// Your backend IP:
const String kBaseUrl = 'http://YOUR_SERVER_IP:8080';

// For Android emulator:
const String kBaseUrl = 'http://10.0.2.2:8080';
```

---

## Adapting for Your Region

FirePredict is designed to be portable. To deploy for **any forest ecosystem**:

1. **Replace satellite data** — download Sentinel-2 tiles for your region via Google Earth Engine or Copernicus Hub
2. **Update zone coordinates** — edit `ZONES` in `backend/main.py` with your monitoring zones
3. **Retrain the model** — follow `notebooks/02_convlstm_training.ipynb` with your data
4. **Update human activity features** — define relevant features for your region (land use, tourism, agricultural practices)

See [`docs/adapt_for_your_region.md`](docs/adapt_for_your_region.md) for the full step-by-step guide.

---

## Research Background

This system is based on PhD research at the **University of Dodoma (UDOM), Tanzania**, examining the integration of human activity data with satellite remote sensing for forest fire prediction in tropical montane ecosystems.

**Key Research Findings:**
- Human activity features (especially beekeeping with open flame tools and agricultural burning) improve model accuracy by **11.4%** over satellite+weather baselines
- NDVI values below 0.30 combined with humidity below 40% are the strongest predictors of imminent fire ignition on Kilimanjaro
- 92% of historical fires (2015–2025) occurred during the dry season (July–November) on south and west-facing slopes

**Published/Submitted Papers:**
- *"Integrating Human Activity Data with Satellite Remote Sensing for Forest Fire Prediction: A Deep Learning Approach for Mount Kilimanjaro"* — Under review

---

## Data Sources

| Source | Description | License |
|--------|-------------|---------|
| [Sentinel-2 (ESA Copernicus)](https://scihub.copernicus.eu) | NDVI, NBR, NDWI satellite indices | Open (CC BY-SA 3.0 IGO) |
| [ERA5 Reanalysis (ECMWF)](https://cds.climate.copernicus.eu) | Historical weather data | Open (Copernicus License) |
| Tanzania Met Authority (TMA) | Local meteorological station data | By permission |
| TANAPA Fire Records (2015–2025) | Historical fire occurrence data | By permission |

---

## Model Card

| Property | Value |
|----------|-------|
| Architecture | ConvLSTM2D + Dense (multi-branch) |
| Task | Binary classification (fire / no fire) |
| Input modalities | Satellite (3 bands), Weather (6 vars), Human activity (7 vars) |
| Training period | 2015–2025 (10 years) |
| Study area | Mount Kilimanjaro, Tanzania (-3.07°N, 37.35°E) |
| Accuracy | 87.3% |
| AUC-ROC | 0.91 |
| F1-Score | 0.86 |
| Framework | TensorFlow / Keras |

---

## Contributing

Contributions are welcome! Priority areas:

1. **Additional training data** — fire occurrence records from other African mountain ecosystems
2. **iOS app** — port the Flutter app to iOS
3. **Real-time satellite ingestion** — automated Sentinel-2 download pipeline
4. **SMS alerts** — integration with Africa's Talking SMS API for ranger notifications
5. **Swahili NLP** — improve Swahili language support in the mobile app

Please open an issue or submit a pull request.

---

## License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

You are free to use, modify, and deploy FirePredict for any forest ecosystem globally. We ask that you cite the original research if used in academic work.

---

## Citation

```bibtex
@software{firepredict2026,
  author    = {Mambile, Cesilia},
  title     = {FirePredict: AI-Powered Forest Fire Early Warning System},
  year      = {2026},
  publisher = {University of Dodoma (UDOM)},
  url       = {https://github.com/CesiliaMambile/FirePredict},
  license   = {MIT}
}
```

---

## Contact

**Dr. Cesilia Mambile**
University of Dodoma (UDOM), Tanzania
PhD Researcher — Forest Fire Early Warning Systems

*FirePredict was developed as part of PhD research at UDOM.*
*Selected as Top 5 Finalist — UNFCCC AI for Climate Action Award 2026.*

---

*"Every minute of early warning saves lives and preserves the forests that millions depend on."*
