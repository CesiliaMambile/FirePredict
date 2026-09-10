# FirePredict Model Card

## Model Overview

| Property | Value |
|----------|-------|
| **Name** | FirePredict ConvLSTM v1.0 |
| **Task** | Binary classification — Fire / No Fire |
| **Architecture** | ConvLSTM2D + Dense (multi-branch) |
| **Framework** | TensorFlow 2.x / Keras |
| **Training period** | 2015–2025 (10 years) |
| **Study area** | Mount Kilimanjaro, Tanzania |
| **Coordinate centre** | 3.07°S, 37.35°E |
| **Elevation range** | 1,000–5,895 m a.s.l. |

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Accuracy | 98% |

*Evaluated on held-out test set: 2023–2025 (20% of total data)*

---

## Input Features

### Branch 1: Satellite Indices (Sentinel-2)
| Feature | Description | Typical range |
|---------|-------------|---------------|
| NDVI | Normalized Difference Vegetation Index | -1.0 to 1.0 |
| NBR | Normalized Burn Ratio | -1.0 to 1.0 |
| NDWI | Normalized Difference Water Index | -1.0 to 1.0 |

**Interpretation for fire risk:**
- NDVI < 0.30: critically dry vegetation → HIGH risk
- NBR > 0.40: high burn severity potential
- NDWI < 0.20: low surface moisture → HIGH risk

### Branch 2: Meteorological Variables
| Feature | Description | Unit |
|---------|-------------|------|
| temperature | Mean daily temperature | °C |
| humidity | Relative humidity | % |
| wind_speed | Mean wind speed | km/h |
| rainfall | Daily rainfall | mm |
| min_temp | Minimum daily temperature | °C |
| max_temp | Maximum daily temperature | °C |

### Branch 3: Human Activity Features (Novel Contribution)
| Index | Feature | Description |
|-------|---------|-------------|
| 0 | Zone type | Administrative/ecological classification (1–5) |
| 1 | Access difficulty | Road access to zone (1=easy, 5=remote) |
| 2 | Tourism intensity | Normalized tourist presence (0.0–1.0) |
| 3 | Elevation | Zone centre elevation (metres) |
| 4 | Season | Dry=1, Wet=0 |
| 5 | Vegetation density | Land cover density score (1–9) |
| 6 | Beekeeping/burning activity | Open-flame activity proxy (0.0–1.0) |

*Human activity features improve accuracy by +11.4% over satellite+weather alone.*

---

## Training Data

| Source | Period | Records |
|--------|--------|---------|
| Sentinel-2 imagery (Copernicus) | 2015–2025 | ~3,600 scenes |
| TMA weather station records | 2015–2025 | 3,650 daily records |
| NASA FIRMS fire occurrence records | 2015–2025 | Historical fire detections |
| Human activity surveys (UDOM) | 2022–2025 | Field surveys + proxy data |

**Class distribution (training):** 73% no-fire, 27% fire (upsampled from 9% natural rate)

---

## Model Architecture

```
Satellite Input (1,1,1,3)    Weather Input (1,1,6)    Human Input (1,7)
         │                           │                        │
   ConvLSTM2D(32)            LSTM(32)                 Dense(32)
         │                           │                        │
   ConvLSTM2D(64)            Dense(16)                Dense(16)
         │                           │                        │
GlobalAvgPool                        └──────────────┬─────────┘
         │                                          │
         └──────────────────────────────────────────┘
                                    │
                              Concat + Dense(128)
                                    │
                               Dropout(0.3)
                                    │
                              Dense(64, relu)
                                    │
                          Dense(1, sigmoid)
                                    │
                          Risk Score [0.0 – 1.0]
```

---

## Intended Uses

**Appropriate uses:**
- Early warning for forest rangers and fire management authorities
- Community notification systems in fire-prone regions
- Research and educational demonstrations
- Policy planning and resource allocation

**Not appropriate for:**
- Real-time emergency dispatch as sole information source
- Regions significantly different from Mount Kilimanjaro without retraining
- Legal/regulatory decisions without expert human review

---

## Limitations

1. **Geographic specificity**: Trained on Mount Kilimanjaro data; accuracy decreases for other ecosystems without retraining
2. **Temporal lag**: Satellite data (Sentinel-2) has 5-day revisit cycle; predictions may miss rapidly developing conditions
3. **Human activity proxy**: Beekeeping and agricultural burning features are estimated, not measured directly
4. **Class imbalance**: Fire events are rare (9% of days); model may underperform for novel fire patterns
5. **Weather forecasting dependency**: For 5-day forecasts, requires weather forecast data (e.g., ERA5 forecast) as input
6. **Model drift**: Annual retraining recommended as climate patterns change

---

## Ethical Considerations

- Fire prediction affects people's lives and livelihoods — human expert review is always required before action
- Communities near high-risk zones should be engaged as partners, not just alert recipients
- False alarms can cause economic harm (evacuations, closures); calibration is ongoing

---

## Citation

```bibtex
@software{firepredict2026,
  author    = {Mambile, Cesilia},
  title     = {FirePredict: AI-Powered Forest Fire Early Warning System},
  year      = {2026},
  institution = {University of Dodoma (UDOM), Tanzania},
  url       = {https://github.com/CesiliaMambile/FirePredict}
}
```
