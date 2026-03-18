# CINDERELLA
Computational Intelligence with NCAA data for Evaluating Rankings and Learning and Locating Anomalies.

## Repository Layout

```text
CINDERELLA/
  MATLAB/     # legacy MATLAB pipeline (fully retained)
  DATA/       # canonical raw/source data directory
  Models/     # trained MATLAB model artifacts
  PYTHON/     # Python refactor implementation
```

This layout is now active.

## What Changed
- All MATLAB `.m` files and MATLAB-generated `.mat` artifacts were moved into `MATLAB/`.
- Previous `Data/` was promoted to root as `DATA/`.
- Python implementation scaffolding was created under `PYTHON/`.
- MATLAB path handling was updated so scripts resolve `DATA/` and `Models/` correctly after migration.

## MATLAB Pipeline (Current Working Version)

### Entry Points
- `MATLAB/CINDERELLA.m`: run tournament simulation and visualization.
- `MATLAB/ReTrainMain.m`: regenerate data, retrain models, and aggregate.

### Run MATLAB Simulation
1. Open MATLAB.
2. Set current folder to `CINDERELLA/MATLAB`.
3. Run:
   ```matlab
   CINDERELLA
   ```

### Full MATLAB Rebuild + Simulation
```matlab
ReTrainMain
CINDERELLA
```

### MATLAB Notes
- Raw data is read from `CINDERELLA/DATA`.
- Models are read/written in `CINDERELLA/Models`.
- Cached feature/training artifacts (`RawData.mat`, `TrainingData.mat`) are stored under `CINDERELLA/MATLAB`.

## Python Refactor (In Progress)
Detailed plan: `PYTHON_REFACTOR_PLAN.md`

### Implemented So Far
- package scaffolding (`pyproject.toml`, module layout, CLI)
- typed config system (`pydantic` + YAML)
- raw-data ingestion + column validation
- feature-building baseline modules
- baseline training/simulation pipeline wiring
- test scaffolding for key modules

### Python Raw Data Wiring
- `PYTHON/data/raw` is symlinked to `../../DATA`.
- This keeps MATLAB and Python using one shared raw dataset source.

### Python Quick Start
1. Open terminal at `CINDERELLA/PYTHON`.
2. Install package:
   ```bash
   pip install -e .
   ```
3. Run staged pipeline commands:
   ```bash
   cinderella build-data --config configs/default.yaml
   cinderella train --config configs/default.yaml
   cinderella simulate --config configs/default.yaml --n 1000
   ```

## Documentation Index
- `README.md`: repo-level orientation and runbook
- `PYTHON_REFACTOR_PLAN.md`: architecture and migration roadmap
- `MATLAB/README.md`: MATLAB-specific operational notes
- `PYTHON/README.md`: Python implementation details

## Next Refactor Milestones
1. Port full MATLAB `DataManager` feature parity into Python feature modules.
2. Port full 63-game bracket propagation logic (currently baseline round simulation is scaffolded).
3. Add parity tests comparing Python outputs against fixed MATLAB baseline runs.
4. Finalize deep model training parity and model registry metadata.
