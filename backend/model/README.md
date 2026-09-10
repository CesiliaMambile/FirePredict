# Model Weights

The trained ConvLSTM model file (`best_model.keras`) is not included in this repository due to file size constraints.

## Options

### Option 1: Train Your Own Model

Follow the step-by-step training notebook:
```
notebooks/02_convlstm_training.ipynb
```

This notebook guides you through:
- Downloading Sentinel-2 satellite data for your region
- Preparing training data (satellite + weather + human activity)
- Training the ConvLSTM model
- Evaluating and saving the trained model

### Option 2: Request Pre-Trained Weights

To request the pre-trained model weights for Mount Kilimanjaro:
- Contact: Dr. Cesilia Mambile, University of Dodoma (UDOM)
- The model was trained on 2015–2025 data specific to Mount Kilimanjaro

### Option 3: Run in Demo Mode

The backend works without a model file — it falls back to seasonal heuristics for demonstrations. The mobile app also has built-in demo data and works fully offline.

## Model Architecture

```
Input 1: Satellite (1,1,1,3) — NDVI, NBR, NDWI
Input 2: Weather (1,1,6)     — Temp, Humidity, Wind, Rain, Min/Max Temp
Input 3: Human (1,7)         — Zone type, access, tourism, elevation, season, vegetation, beekeeping

→ ConvLSTM2D (32 filters)
→ ConvLSTM2D (64 filters)
→ GlobalAveragePooling
→ Dense(128) + Dropout
→ Dense(64)
→ Dense(1, sigmoid) → Fire Risk Score [0.0 – 1.0]
```

Training Accuracy: **98%**
