# Nuclear Segmentation

MATLAB and Python functions for 2D/3D nuclear segmentation.

## Matlab/
- `nuc_segmentor_local.m` — main segmentation function (local threshold + shape filter)
- `object_separation_2D.m` — watershed-based object separation
- `crop_from_mask.m` — crop image to nuclear mask bounding box
- `insert_crop.m` — insert cropped image back into full frame
- `select_nuclei.m` — interactive nucleus selection GUI

## Test Data
Located in [CostesLab_TestData](https://github.com/svcostes/CostesLab_TestData):
- `SpotDetection/human_blood_53bp1/` — 12 TIF images with DAPI channel for segmentation testing

## Dependencies
Requires DIPimage toolbox for MATLAB.
