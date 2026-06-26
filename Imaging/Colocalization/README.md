# Colocalization

Implementation of the NCI colocalization algorithm (Costes et al. 2004).

## Matlab/NCI_coloc/
- `NCI_coloc.m` — main colocalization function
- `pearson.m` — Pearson correlation coefficient
- `ppiterative.m` — iterative threshold finding
- `randomize.m` — pixel randomization for statistical testing
- `autocor.m` — autocorrelation
- `overlap.c` / `overlapC.c` — C implementations for speed

## Reference
Costes SV et al. *Automatic and Quantitative Measurement of Protein-Protein 
Colocalization in Live Cells.* Biophysical Journal, 2004.

## Test Data
Located in [CostesLab_TestData](https://github.com/svcostes/CostesLab_TestData):
- `Colocalization/CFP_YFP_test/` — 21 TIF images, CFP/YFP channel pairs
  for colocalization algorithm validation

## Dependencies
Requires DIPimage toolbox for MATLAB.
Compiled C extensions (overlap.dll/.mexa64) needed for full performance.
