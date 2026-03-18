# MATLAB Pipeline Notes

## Purpose
This directory contains the original CINDERELLA MATLAB implementation, preserved during Python migration.

## Primary Scripts
- `CINDERELLA.m`: Monte Carlo tournament simulation and bracket visualization.
- `ReTrainMain.m`: End-to-end rebuild of data artifacts and models.
- `DataManager.m`: source data ingestion and feature table creation.
- `TrainingDataGen.m`: training matrix generation.
- `RegressionModelTrain.m`, `DeepNetworkTrainer.m`: model training.

## Directory Dependencies
- Raw data: `../DATA`
- Models: `../Models`
- Local MATLAB artifacts: `./RawData.mat`, `./TrainingData.mat`

## Run Instructions
1. Set MATLAB current folder to this directory (`CINDERELLA/MATLAB`).
2. Run:
   ```matlab
   CINDERELLA
   ```

## Retraining Flow
```matlab
ReTrainMain
CINDERELLA
```

## Migration Context
This directory is intentionally stable while Python parity is developed in `../PYTHON`.
