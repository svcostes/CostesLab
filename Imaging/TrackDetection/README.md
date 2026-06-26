# Track Detection

Two distinct types of track analysis:

## Matlab/ParticleTrack/
Analysis of high-LET particle tracks (Fe, C ions) through nuclei.
Measures foci distribution along particle tracks and computes Rdna/Rgrad statistics.

Key functions:
- `find_track.m` — automatic track direction detection
- `track_analysis.m` — interactive track drawing + foci distance measurement
- `track_analysis_nonuc.m` — track analysis without nuclear segmentation
- `randomize_track5.m` — statistical randomization (Rdna, Rgrad computation)
- `import_auto_track.m` — batch import of automatically detected tracks
- `read_track.m` — load and visualize track data

Dependencies: `multiprofile.m`, `import_line_scan.m`, `randomize_track2/3.m`

## Matlab/FociMotion/
Tracking individual foci movement in live imaging (Bitplane/Imaris output).

Key functions:
- `load_spot_track.m` — load Imaris spot tracking Excel output, compute MSD and velocity

## Test Data
Located in [CostesLab_TestData](https://github.com/svcostes/CostesLab_TestData):
- `TrackDetection/ppt_112807/` — ICS/IDS/TIF images for track detection testing

## Dependencies
Requires DIPimage toolbox for MATLAB.
