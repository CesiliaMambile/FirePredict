# FirePredict Training Notebooks

These notebooks guide you through the complete FirePredict pipeline — from raw satellite data to a deployed model.

## Notebooks

| Notebook | Description |
|----------|-------------|
| `01_satellite_processing.ipynb` | Download Sentinel-2 data and compute NDVI, NBR, NDWI |
| `02_convlstm_training.ipynb` | Train the ConvLSTM fire risk model |
| `03_human_activity_features.ipynb` | Build and validate human activity feature vectors |

## Requirements

```bash
pip install tensorflow numpy pandas matplotlib scikit-learn geopandas rasterio earthengine-api
```

Or use Google Colab (free GPU available) — each notebook includes a Colab launch badge.

## Order of Execution

1. Run `01_satellite_processing.ipynb` first to prepare data
2. Add your weather data (see instructions inside the notebook)
3. Run `03_human_activity_features.ipynb` to build human activity vectors
4. Run `02_convlstm_training.ipynb` to train the model
5. Save the model to `../backend/model/best_model.keras`
6. Start the backend server

## Data Requirements

Before running the notebooks, you need:
- Google Earth Engine account (free) for Sentinel-2 data
- ERA5 weather data for your study period (free from Copernicus)
- Fire occurrence records (from national fire authority or FIRMS/NASA)

See [`../docs/adapt_for_your_region.md`](../docs/adapt_for_your_region.md) for detailed instructions.
