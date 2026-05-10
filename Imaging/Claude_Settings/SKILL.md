# Costes Lab — Bioimage Analysis Skill
# Claude reads this before writing any code for this lab.
# Lab GitHub: https://github.com/svcostes/CostesLab

---

## Identity & Philosophy

This skill governs all code written for **Sylvain Costes' lab** (NASA Ames / OSDR imaging studies).
The lab works on 3D fluorescence microscopy, DNA damage foci detection, and radiation biology.

**Core philosophy:**
- Classical image processing first (wavelet, diplib, morphology). AI is optional and modular.
- All detection must work natively in 3D at arbitrary volume size and anisotropy. Never force images to a fixed size.
- AI is used only for specific subtasks (denoising, artefact rejection, segmentation of complex structures) operating on small fixed-size patches *after* classical detection — never as the primary detector.
- Open source only. No proprietary tools.
- Every notebook must run both on Google Colab (cloud GPU) and locally (Ubuntu + GPU) with minimal changes.

---

## Environment Detection & Project Selection

**Every notebook must start with exactly this two-cell block. No exceptions.**

### Cell 1 — Environment detection and project listing

```python
import os
from pathlib import Path

# ── Environment detection ──────────────────────────────────────────────────
IS_COLAB = "COLAB_GPU" in os.environ or "COLAB_RELEASE_TAG" in os.environ

if IS_COLAB:
    from google.colab import drive
    drive.mount('/content/mnt')
    PROJECTS_ROOT = Path('/content/mnt/MyDrive/Colab Notebooks')
else:
    # Works on Ubuntu, macOS, and Windows — ~/Documents resolves correctly on all
    PROJECTS_ROOT = Path.home() / 'Documents'

# ── List available projects (directories and symlinks) ────────────────────
projects = sorted([
    p.name for p in PROJECTS_ROOT.iterdir()
    if p.is_dir() or p.is_symlink()
])

print(f"Environment : {'Colab' if IS_COLAB else 'Local'}")
print(f"Projects root: {PROJECTS_ROOT}")
print(f"\nAvailable projects:")
for i, name in enumerate(projects):
    print(f"  [{i}] {name}")
```

### Cell 2 — Project selection

```python
# ── Set PROJECT_INDEX to the number shown next to your project above ───────
PROJECT_INDEX = 0
DATA_ROOT = PROJECTS_ROOT / projects[PROJECT_INDEX]
print(f"DATA_ROOT = {DATA_ROOT}")
```

**Rules:**
- Never hardcode a path like `/content/mnt/MyDrive/Some Project/`. Always use `DATA_ROOT`.
- `PROJECT_INDEX` is the only line a student ever needs to change.
- Use a plain integer index, not a widget — widgets break "Run All" workflows.
- On Colab, soft links inside `Colab Notebooks/` are followed correctly by `is_symlink()`.
- On local machines, `~/Documents` resolves to the correct Documents folder on Ubuntu, macOS, and Windows automatically via `Path.home()`.
- All subsequent paths in the notebook derive from `DATA_ROOT`, e.g.:
  ```python
  raw_dir    = DATA_ROOT / 'Raw_Images'
  output_dir = DATA_ROOT / 'Outputs'
  output_dir.mkdir(exist_ok=True)
  ```

---

## Visualization — Plotly as Default

**Plotly is the default visualizer for both environments.**
napari is available locally as an optional upgrade for interactive annotation.

### Always use this fork pattern:

```python
def show_volume(volume, spots=None, title="Volume"):
    """
    Display a 3D volume with optional spot overlay.
    Uses Plotly on both Colab and local (default).
    Pass use_napari=True locally for full interactive viewer.
    """
    import plotly.graph_objects as go
    import numpy as np

    # Downsample for rendering (display only — spots stay at full resolution)
    max_dim = 128
    factors = [max(1, s // max_dim) for s in volume.shape]
    vol_ds = volume[::factors[0], ::factors[1], ::factors[2]]

    z, y, x = np.mgrid[
        0:volume.shape[0]:factors[0],
        0:volume.shape[1]:factors[1],
        0:volume.shape[2]:factors[2]
    ]

    fig = go.Figure()
    fig.add_trace(go.Volume(
        x=x.flatten(), y=y.flatten(), z=z.flatten(),
        value=vol_ds.flatten(),
        isomin=float(np.percentile(vol_ds, 50)),
        isomax=float(np.percentile(vol_ds, 99.5)),
        opacity=0.1,
        surface_count=15,
        colorscale='Greys',
        showscale=False,
        name='Volume'
    ))

    if spots is not None:
        # spots: array of shape (N, 3) with [z, y, x] coordinates
        spots = np.array(spots)
        fig.add_trace(go.Scatter3d(
            x=spots[:, 2], y=spots[:, 1], z=spots[:, 0],
            mode='markers',
            marker=dict(size=4, color='red', opacity=0.8),
            name='Spots'
        ))

    fig.update_layout(title=title, scene=dict(
        xaxis_title='X', yaxis_title='Y', zaxis_title='Z'
    ))
    fig.show()


def show_volume_napari(volume, spots=None, title="Volume"):
    """
    Optional: napari viewer for local use only.
    Call explicitly when deep interactive exploration is needed.
    """
    if IS_COLAB:
        print("napari not available on Colab. Using Plotly instead.")
        return show_volume(volume, spots, title)
    import napari
    viewer = napari.Viewer(title=title)
    viewer.add_image(volume, name='Volume')
    if spots is not None:
        import numpy as np
        viewer.add_points(np.array(spots), size=5, face_color='red', name='Spots')
    return viewer
```

### For z-slice scrolling on Colab (ipywidgets):

```python
import ipywidgets as widgets
from IPython.display import display
import matplotlib.pyplot as plt

def show_zstack(volume, spots=None, cmap='gray', vmin=None, vmax=None):
    """Interactive z-slice viewer using ipywidgets. Works on Colab and local."""
    vmin = vmin or float(volume.min())
    vmax = vmax or float(volume.max())

    def update(z=0):
        fig, ax = plt.subplots(figsize=(6, 6))
        ax.imshow(volume[z], cmap=cmap, vmin=vmin, vmax=vmax)
        if spots is not None:
            import numpy as np
            s = np.array(spots)
            in_plane = s[np.abs(s[:, 0] - z) < 1.5]
            ax.scatter(in_plane[:, 2], in_plane[:, 1],
                       c='red', s=20, linewidths=0.5, edgecolors='white')
        ax.set_title(f"Z = {z} / {volume.shape[0]-1}")
        ax.axis('off')
        plt.tight_layout()
        plt.show()

    slider = widgets.IntSlider(min=0, max=volume.shape[0]-1, step=1,
                                description='Z slice:')
    widgets.interact(update, z=slider)
```

---

## Image Processing Stack

### Preprocessing — diplib first

```python
import diplib as dip

def preprocess_volume(volume, sigma_background=10.0, anisotropy=(1.0, 1.0, 3.0)):
    """
    Standard preprocessing pipeline.
    anisotropy: (z, y, x) voxel size ratios — correct before filtering.
    """
    img = dip.Image(volume.astype('float32'))

    # Background subtraction via large Gaussian
    background = dip.Gauss(img, sigmas=[sigma_background]*3)
    img = img - background

    # Clip negatives
    img = dip.Clip(img, 0, None)

    return np.array(img)
```

### Spot Detection — Classical (primary approach)

**Preferred: wavelet-based (à trous / starlet transform)**
Each wavelet scale corresponds to a spatial frequency band — equivalent to a multiscale
likelihood ratio test (connects directly to Bhanu & Jones 2001, Pattern Recognition).

```python
def detect_spots_wavelet(volume, scales=(1, 2), anisotropy=(1.0, 1.0, 3.0),
                          threshold_sigma=3.0):
    """
    3D spot detection via à trous wavelet transform.
    Works at arbitrary volume size and anisotropy.
    No fixed-size requirement. No AI needed.

    scales: wavelet scales to combine (1=fine, 2=medium spots)
    threshold_sigma: detection threshold in units of background sigma
    anisotropy: (z, y, x) voxel size for PSF-matched filtering
    """
    import diplib as dip
    import numpy as np

    img = dip.Image(volume.astype('float32'))

    # Compute wavelet planes via à trous (successive Gaussian differences)
    wavelet_planes = []
    prev = img
    for scale in range(1, max(scales) + 2):
        # Scale sigma adjusted for anisotropy
        sigma = [2**scale / a for a in anisotropy]
        smoothed = dip.Gauss(prev, sigmas=sigma)
        if scale in scales:
            wavelet_planes.append(np.array(prev) - np.array(smoothed))
        prev = smoothed

    # Combine selected scales
    combined = np.sum(wavelet_planes, axis=0)

    # Threshold: mean + threshold_sigma * std (robust, no fixed value)
    bg_mean = np.mean(combined[combined > 0])
    bg_std  = np.std(combined[combined > 0])
    threshold = bg_mean + threshold_sigma * bg_std

    # Local maxima detection via diplib
    binary = dip.Image(combined > threshold)
    labeled = dip.Label(binary)
    measurements = dip.MeasurementTool.Measure(labeled, dip.Image(combined),
                                                ['Center', 'MaxVal', 'Size'])

    spots = []
    for obj in measurements.Objects():
        center = measurements['Center'][obj]
        spots.append({
            'z': center[2], 'y': center[1], 'x': center[0],
            'intensity': float(measurements['MaxVal'][obj][0]),
            'size': float(measurements['Size'][obj][0])
        })

    return spots


def detect_spots_spotmax(volume, voxel_size_zyx=(300, 100, 100)):
    """
    Alternative: SpotMAX pipeline for full 3D Gaussian fitting and quantification.
    Use when subpixel localization and intensity quantification are needed.
    pip install spotmax
    """
    # SpotMAX integration — see spotmax documentation for full pipeline
    # https://github.com/SchmollerLab/SpotMAX
    raise NotImplementedError("SpotMAX integration — configure per dataset")
```

### AI Subtasks — Optional, Patch-Based

AI operates on small patches *after* classical detection. Never on full volumes.
Size constraint disappears because patches are always small and fixed.

```python
def denoise_volume(volume, model='care'):
    """
    Optional denoising before detection.
    'noise2void': self-supervised, no clean images needed (pip install n2v)
    'care': requires clean/noisy pairs (pip install csbdeep)
    """
    raise NotImplementedError(f"Configure {model} model per dataset")


def classify_spots(spots, volume, patch_size=(16, 32, 32)):
    """
    Optional: classify detections as true spots vs artefacts.
    Extracts small patches at each detected location — no size constraint.
    Train a simple CNN or use MONAI with SlidingWindowInferer for segmentation.
    """
    raise NotImplementedError("Train classifier on your annotated spots")
```

---

## Supported File Formats

Always detect format automatically:

```python
def load_volume(path):
    """
    Load 3D volume from common microscopy formats.
    Returns: numpy array, shape (Z, Y, X) or (C, Z, Y, X)
    """
    import os
    ext = os.path.splitext(path)[-1].lower()

    if ext in ('.tif', '.tiff'):
        from tifffile import TiffFile
        with TiffFile(path) as tif:
            return tif.asarray()

    elif ext == '.ics':
        # ICS/IDS pair — ids file must be alongside
        ids_path = path.replace('.ics', '.ids')
        return _read_ics_ids(path, ids_path)

    elif ext == '.czi':
        import czifile
        import numpy as np
        with czifile.CziFile(path) as czi:
            return np.squeeze(czi.asarray())

    elif ext in ('.nii', '.gz'):
        import nibabel as nib
        return nib.load(path).get_fdata()

    else:
        raise ValueError(f"Unsupported format: {ext}")


def _read_ics_ids(ics_path, ids_path):
    """Read ICS/IDS image pair (Bio-Formats / DIPimage format)."""
    import numpy as np
    with open(ics_path, 'r') as f:
        lines = f.readlines()
    size_line = next(l for l in lines if l.startswith("layout\tsizes"))
    sizes = list(map(int, size_line.strip().split("\t")[2:]))
    shape = tuple(sizes[1:][::-1])
    with open(ids_path, 'rb') as f:
        raw = f.read()
    return np.frombuffer(raw, dtype=np.float32).reshape(shape)
```

---

## OSDR / NASA Data Access

Three modes, choose based on context:

### Mode 1 — Google Drive (pre-staged data, fastest)
```python
# Files already copied to Drive manually or via prior sync
path = os.path.join(DATA_ROOT, "OSD-366", "E3_006_002_FITC.ics")
volume = load_volume(path)
```

### Mode 2 — OSDR HTTP API (stream single file into memory, no disk write)
```python
import requests, zipfile, io

def osdr_load_from_zip(study_id, zip_filename, inner_path, version=1):
    """Stream a single file from an OSDR zip archive without writing to disk."""
    url = (f"https://osdr.nasa.gov/geode-py/ws/studies/{study_id}/download"
           f"?file={zip_filename}&version={version}")
    response = requests.get(url)
    response.raise_for_status()
    z = zipfile.ZipFile(io.BytesIO(response.content))
    return z.read(inner_path)


def osdr_list_files(study_id):
    """List all files available for a study via OSDR API."""
    url = f"https://osdr.nasa.gov/osdr/data/osd/files/{study_id.replace('OSD-','')}"
    r = requests.get(url).json()
    return [f['file_name'] for f in r.get('study_files', [])]
```

### Mode 3 — AWS S3 (best for large batch — local Ubuntu or Colab)
```python
# List files without downloading:
# aws s3 ls --no-sign-request s3://nasa-osdr/OSD-366/ --recursive

# Sync entire study to local disk (run once):
# aws s3 sync --no-sign-request s3://nasa-osdr/OSD-366/ ./OSD-366/

# In Python (requires awscli or boto3):
def osdr_s3_download(study_id, dest_dir, prefix=""):
    """Download OSDR study files from public AWS S3 bucket."""
    import subprocess
    s3_path = f"s3://nasa-osdr/{study_id}/{prefix}"
    cmd = ["aws", "s3", "sync", "--no-sign-request", s3_path, dest_dir]
    subprocess.run(cmd, check=True)
```

### Batch Download with Concurrency (replaces serial requests.get loop)
```python
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

def batch_download_osdr(url_list, n_workers=8):
    """
    Download multiple OSDR files concurrently.
    Much faster than serial requests.get() in a loop.
    """
    results = {}

    def fetch(url):
        r = requests.get(url)
        r.raise_for_status()
        return url, r.content

    with ThreadPoolExecutor(max_workers=n_workers) as executor:
        futures = {executor.submit(fetch, url): url for url in url_list}
        for future in tqdm(as_completed(futures), total=len(futures)):
            url, content = future.result()
            results[url] = content

    return results
```

### OSDR Metadata Parsing (robust approach)
```python
def load_osdr_metadata(meta_zip_path, assay_keyword='cellular-imaging'):
    """
    Load ISA-Tab metadata from OSDR metadata zip.
    Works from Google Drive path or local path.
    """
    import zipfile, pandas as pd

    with zipfile.ZipFile(meta_zip_path, 'r') as z:
        target = [f for f in z.namelist() if assay_keyword in f][0]
        with z.open(target) as f:
            df = pd.read_csv(f, sep='\t')

    df.columns = df.columns.str.strip()
    return df


def get_zip_urls(plate, well, metadata_df, study_id="OSD-366", version=1):
    """
    Look up raw and processed zip URLs for a given plate/well.
    Returns (raw_zip_name, raw_url, proc_zip_name, proc_url).
    """
    search_str = f"{plate}_{well}"
    matches = metadata_df[
        metadata_df.apply(lambda row: search_str in str(row.values), axis=1)
    ]
    if matches.empty:
        raise ValueError(f"No metadata match for {search_str}")

    row = matches.iloc[0]
    base = f"https://osdr.nasa.gov/geode-py/ws/studies/{study_id}/download?file="
    ver  = f"&version={version}"

    raw_name  = row.iloc[-2].strip()
    proc_name = row.iloc[-1].strip()

    return raw_name, base + raw_name + ver, proc_name, base + proc_name + ver
```

---

## Measurement & Reporting

Use diplib for per-object measurements. Do not depend on napari for quantification.

```python
import diplib as dip
import pandas as pd

def measure_objects(labeled_volume, intensity_volume, features=None):
    """
    Measure properties of labeled objects using diplib.
    Works in 3D natively at any volume size.

    features: list of diplib measurement names
              defaults to common morphology + intensity set
    """
    if features is None:
        features = ['Size', 'Center', 'Mean', 'MaxVal', 'Perimeter',
                    'SolidArea', 'Roundness', 'Elongation']

    lbl = dip.Label(dip.Image(labeled_volume.astype('uint32')))
    img = dip.Image(intensity_volume.astype('float32'))
    msr = dip.MeasurementTool.Measure(lbl, img, features)

    rows = []
    for obj in msr.Objects():
        row = {'object_id': obj}
        for feat in features:
            vals = msr[feat][obj]
            if len(vals) == 1:
                row[feat] = float(vals[0])
            else:
                for i, v in enumerate(vals):
                    row[f"{feat}_{i}"] = float(v)
        rows.append(row)

    return pd.DataFrame(rows)
```

---

## Package Installation Reference

### Colab (run at top of notebook)
```python
!pip install diplib spotmax tifffile czifile ipywidgets plotly
# Optional AI tools:
# !pip install monai n2v csbdeep
```

### Local Ubuntu (one-time setup — see README_SETUP.md)
```bash
pip install diplib spotmax tifffile czifile ipywidgets plotly napari[all]
# Optional AI tools:
pip install monai n2v csbdeep
```

---

## Key Rules for Claude

1. **Never force a volume to a fixed size.** If a function requires fixed size, it goes in the AI patch pipeline only, with explicit patch extraction.
2. **Detection is always 3D.** No 2.5D tricks (processing z-slices independently).
3. **Plotly is the default visualizer.** napari is offered as an optional local alternative, never required.
4. **Measurements come from diplib**, not napari or skimage (unless diplib cannot do it).
5. **AI modules are stubs** until the user explicitly asks to implement them — don't fill them in speculatively.
6. **Batch loops use ThreadPoolExecutor** for I/O-bound work, never bare serial `requests.get()` loops.
7. **Every notebook starts** with the environment detection block and DATA_ROOT pattern.
8. **OSDR data access** uses the three-mode pattern (Drive / HTTP / S3) depending on context.
9. **File format loading** always goes through `load_volume()` — never inline format-specific code.
10. **Wavelet detection is preferred** over DoG/LoG for spot detection — it connects to the lab's published methodology (Bhanu & Jones 2001).
