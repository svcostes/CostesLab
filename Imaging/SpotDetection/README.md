# Spot / Foci Detection

MATLAB and Python pipelines for detecting fluorescent foci (53BP1, γH2AX, etc.).

## Python/
- `foci_detection_v2.ipynb` — main notebook: wavelet-based foci detection pipeline
  - À trous wavelet transform
  - Nuclear segmentation + cell cycle classification
  - Batch processing with ThreadPoolExecutor
  - Works on local JupyterLab and Google Colab

## Matlab/
- `Spot_Detection_2026/` — current MATLAB pipeline
  - `src/james_spot_detection7.m` — main detection function
  - `src/james_a_trous.m` — à trous wavelet transform
  - `src/wavelet_spot_detection.m` — wavelet-based spot detection
  - `src/nuc_segmentor_local.m` — nuclear segmentation
  - `demo_run_on_tiff.m` — example script
- `params/human_blood_params.txt` — parameters for human blood 53BP1 assay

## Test Data
Located in [CostesLab_TestData](https://github.com/svcostes/CostesLab_TestData):
- `SpotDetection/human_blood_53bp1/` — 12 TIF images, 2-channel DAPI + 53BP1
  - Time course: T_0min to T_240min, 2 replicates each
  - Pixel size: 0.1625 µm/px, 16-bit

## Dependencies
Python: diplib, scipy, scikit-image, scikit-learn, plotly (see requirements.txt)
MATLAB: DIPimage toolbox
