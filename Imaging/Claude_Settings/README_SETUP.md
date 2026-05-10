# Costes Lab — Image Analysis Environment Setup Guide

Welcome to the lab's image analysis pipeline. This guide will get you up and running
on both **Google Colab** (cloud, no installation needed) and your **local machine**
(Ubuntu recommended, required for large datasets and interactive 3D visualization).

---

## Quick Overview

| Feature | Google Colab | Local Machine |
|---|---|---|
| Setup effort | None | ~30 min |
| GPU access | Free (T4), limited hours | Your GPU, unlimited |
| 3D viewer | Plotly (browser-based) | Plotly + napari (full GUI) |
| Large datasets | Via Google Drive or stream | Direct filesystem |
| Recommended for | Learning, prototyping, sharing | Production analysis |

---

## Part 1 — Google Colab Setup

### Step 1: Access the notebooks

All lab notebooks are hosted at (private — requires access):
**https://github.com/svcostes/CostesLab/tree/master/Imaging**

You need a GitHub account and lab access. Contact Sylvain to be added as a collaborator.

**Method A — Colab's built-in GitHub browser (recommended):**

1. Go to [colab.research.google.com/github](https://colab.research.google.com/github)
2. Check **"Include Private Repos"**
3. Sign in to GitHub and authorize Colab
4. Navigate to `svcostes/CostesLab` → `Imaging` → open any notebook

This is the easiest method. You'll need to do the GitHub authorization once.

**Method B — Clone via Personal Access Token (for local runtime or Drive):**

First, create a GitHub Personal Access Token:
1. Go to [github.com/settings/tokens](https://github.com/settings/tokens) → Generate new token (classic)
2. Select scope: `repo` (full repo access)
3. Copy the token — you won't see it again

Store it in Colab Secrets (🔑 icon in left sidebar) with the name `GITHUB_TOKEN`.
Then in any notebook, clone the repo with:

```python
from google.colab import userdata
token = userdata.get('GITHUB_TOKEN')
!git clone https://{token}@github.com/svcostes/CostesLab.git
# Notebooks are in CostesLab/Imaging/
```

Your token is never visible in the notebook code. Each student uses their own token.

### Step 2: Connect to a runtime

- **Free GPU (recommended):** Runtime → Change runtime type → T4 GPU → Save
- **Local runtime (if you have a local GPU setup):** see Part 3 below

### Step 3: Organize your data on Google Drive

All notebooks expect your project data to live inside a folder called **`Colab Notebooks`**
in the root of your Google Drive. You can use real folders or soft links (shortcuts).

```
MyDrive/
└── Colab Notebooks/
    ├── OSD-366 Foci Analysis/     ← real folder or shortcut
    ├── Nishigaya Caspase/         ← real folder or shortcut
    └── My New Project/
```

To create a shortcut to an existing Drive folder:
right-click the folder in Drive → "Organize" → "Add shortcut" → place it in `Colab Notebooks`.

### Step 4: Select your project in the notebook

Every notebook starts with **two standard cells** — you only ever change one number:

**Cell 1** — mounts Drive and lists all available projects automatically:
```python
import os
from pathlib import Path

IS_COLAB = "COLAB_GPU" in os.environ or "COLAB_RELEASE_TAG" in os.environ

if IS_COLAB:
    from google.colab import drive
    drive.mount('/content/mnt')
    PROJECTS_ROOT = Path('/content/mnt/MyDrive/Colab Notebooks')
else:
    PROJECTS_ROOT = Path.home() / 'Documents'

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

**Cell 2** — set `PROJECT_INDEX` to the number next to your project in the list above:
```python
PROJECT_INDEX = 0   # ← change this number
DATA_ROOT = PROJECTS_ROOT / projects[PROJECT_INDEX]
print(f"DATA_ROOT = {DATA_ROOT}")
```

That's it. Never hardcode a path — everything in the notebook flows from `DATA_ROOT`.

### Step 5: Install packages

Each notebook has an install cell at the top. Run it once per session:

```python
!pip install diplib spotmax tifffile czifile ipywidgets plotly
```

Colab sessions reset when idle — you'll need to re-run the install cell each time
you reconnect. This takes about 1–2 minutes.

### Step 6: Enable interactive widgets

If ipywidgets sliders don't appear, run:

```python
from google.colab import output
output.enable_custom_widget_manager()
```

---

## Part 2 — Local Machine Setup (Ubuntu)

### Step 1: Clone the lab repository

You need a GitHub Personal Access Token (see Colab setup, Step 1, Method B above).

```bash
# Replace YOUR_TOKEN with your personal access token
git clone https://YOUR_TOKEN@github.com/svcostes/CostesLab.git
cd CostesLab/Imaging
```

Or store the token in an environment variable so it's never visible in commands:
```bash
export GITHUB_TOKEN=your_token_here   # add to ~/.bashrc
git clone https://${GITHUB_TOKEN}@github.com/svcostes/CostesLab.git
cd CostesLab/Imaging
```

### Step 2: Prerequisites

- Ubuntu 20.04 or 22.04 (Windows via WSL2 also works)
- Python 3.10 or 3.11
- NVIDIA GPU with CUDA 11.8+ (optional but recommended)
- ~5 GB free disk space for packages

### Step 3: Install Python

Check your Python version:
```bash
python3 --version
```

If you don't have Python 3.10+, install it:
```bash
sudo apt update
sudo apt install python3.11 python3.11-venv python3-pip
```

### Step 4: Create a virtual environment

Always use a virtual environment — it keeps lab packages isolated:

```bash
# Create environment (do this once)
python3.11 -m venv ~/costes_lab_env

# Activate it (do this every time you open a terminal)
source ~/costes_lab_env/bin/activate

# You should see (costes_lab_env) in your prompt
```

### Step 5: Install core packages

```bash
pip install --upgrade pip

# Core image analysis
pip install diplib spotmax tifffile czifile

# Visualization
pip install plotly napari[all]

# Notebook environment
pip install jupyterlab ipywidgets

# Data access and utilities
pip install requests pandas numpy scipy scikit-image tqdm awscli

# Microscopy formats
pip install czifile bioformats-python
```

### Step 6: Install GPU support (if you have an NVIDIA GPU)

Check your CUDA version first:
```bash
nvidia-smi
```

Then install PyTorch matching your CUDA version (example for CUDA 12.1):
```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

For AI subtasks (optional, install when needed):
```bash
pip install monai          # 3D UNet, sliding window inference
pip install n2v            # Noise2Void self-supervised denoising
pip install csbdeep        # CARE content-aware image restoration
```

### Step 7: Install JupyterLab extensions

```bash
pip install jupyterlab-widgets    # enables ipywidgets in JupyterLab
jupyter lab build                 # may take a few minutes
```

### Step 8: Organize your data locally

Place your project data inside your **`Documents`** folder — this works on Ubuntu, macOS,
and Windows without any configuration:

```
~/Documents/
├── OSD-366 Foci Analysis/
├── Nishigaya Caspase/
└── My New Project/
```

The notebooks automatically detect this location via `Path.home() / 'Documents'` and list
what's inside. You just set `PROJECT_INDEX` to pick your project — no paths to configure.

### Step 9: Launch JupyterLab

```bash
source ~/costes_lab_env/bin/activate
jupyter lab
```

This opens JupyterLab in your browser at `http://localhost:8888`.
Your notebooks will run locally — same `.ipynb` files as Colab.

---

## Part 3 — Connecting Colab to Your Local Machine

This is the most powerful setup: use Colab's browser interface while running
code on your local GPU with access to your local files.

### Step 1: Install the Colab local runtime package

```bash
source ~/costes_lab_env/bin/activate
pip install jupyter_http_over_ws
jupyter server extension enable --py jupyter_http_over_ws
```

### Step 2: Start your local Jupyter server

```bash
source ~/costes_lab_env/bin/activate
jupyter notebook \
  --NotebookApp.allow_origin='https://colab.research.google.com' \
  --port=8888 \
  --NotebookApp.port_retries=0 \
  --no-browser
```

Copy the URL shown (starting with `http://localhost:8888/?token=...`).

### Step 3: Connect Colab to your local server

1. Open your notebook in Colab
2. Click the dropdown arrow next to "Connect" (top right)
3. Select "Connect to local runtime"
4. Paste the URL from Step 2
5. Click Connect

You are now running Colab notebooks on your local GPU with access to local files.
`DATA_ROOT` will automatically point to your local data directory.

---

## Part 4 — Accessing NASA OSDR Data

The lab uses data from NASA's Open Science Data Repository (OSDR) at osdr.nasa.gov.

### Option A: Stream directly in the notebook (small batches)

```python
import requests, zipfile, io

study_id = "OSD-366"
zip_file  = "LSDS-111_immunostaining_B6C3F2_P235_E3_B6C3_FEMALE_1_Raw_Images.zip"
url = f"https://osdr.nasa.gov/geode-py/ws/studies/{study_id}/download?file={zip_file}&version=1"

response = requests.get(url)
z = zipfile.ZipFile(io.BytesIO(response.content))
# Access files inside: z.read("E3_006_002_FITC.ics")
```

### Option B: Download via AWS S3 (large datasets — recommended)

OSDR data is mirrored on a public AWS S3 bucket. No account needed.

Install AWS CLI (one time):
```bash
pip install awscli
```

List what's available for a study:
```bash
aws s3 ls --no-sign-request s3://nasa-osdr/OSD-366/ --recursive
```

Download an entire study to your local drive:
```bash
aws s3 sync --no-sign-request s3://nasa-osdr/OSD-366/ ~/data/OSD-366/
```

This is **much faster** than HTTP downloads and can be paused and resumed.

### Option C: Via Google Drive (Colab, pre-staged)

If you have already downloaded OSDR data, copy it to Google Drive.
Then access it at `/content/mnt/MyDrive/OSD-366/` after mounting Drive.

---

## Part 5 — Supported Image Formats

The lab's `load_volume()` function handles these formats automatically:

| Format | Extension | Notes |
|---|---|---|
| TIFF stack | `.tif`, `.tiff` | Most common, single and multi-page |
| ICS/IDS pair | `.ics` + `.ids` | DIPimage / Bio-Formats format |
| Zeiss CZI | `.czi` | Requires `czifile` package |
| NIfTI | `.nii`, `.nii.gz` | MRI/CT format, sometimes used |

Always load images through `load_volume(path)` — never use format-specific code directly.

---

## Part 6 — Troubleshooting

**ipywidgets sliders don't show on Colab:**
```python
from google.colab import output
output.enable_custom_widget_manager()
```

**napari won't open locally:**
```bash
# Make sure Qt is installed
pip install PyQt5
# Or try PyQt6
pip install PyQt6
```

**diplib import error:**
```bash
pip install diplib --upgrade
# diplib requires Python 3.8+ and a 64-bit system
```

**"Cannot connect to local runtime" in Colab:**
- Make sure your local Jupyter server is running
- Check that port 8888 is not blocked by a firewall
- Try a different port: replace `8888` with `8889` in both the server command and Colab URL

**Out of memory on Colab:**
- Use Runtime → Disconnect and delete runtime, then reconnect
- Colab Pro gives access to high-RAM runtimes (25 GB)
- For large datasets, always use AWS S3 sync + local runtime instead

**AWS CLI not found:**
```bash
pip install awscli
# Or on Ubuntu:
sudo apt install awscli
```

---

## Summary Cheat Sheet

```
COLAB SETUP (per session):
  1. Runtime → T4 GPU
  2. Run Cell 1: mounts Drive, lists projects in MyDrive/Colab Notebooks/
  3. Run Cell 2: set PROJECT_INDEX to your project number
  4. Run: !pip install diplib spotmax tifffile czifile plotly ipywidgets
  5. Run your analysis cells

DATA ORGANIZATION:
  Colab  → MyDrive/Colab Notebooks/Your Project/   (real folder or shortcut)
  Local  → ~/Documents/Your Project/               (same name, any OS)
  → notebooks find it automatically, you just set PROJECT_INDEX

LOCAL SETUP (one time):
  0. git clone https://${GITHUB_TOKEN}@github.com/svcostes/CostesLab.git
     cd CostesLab/Imaging
  1. python3.11 -m venv ~/costes_lab_env
  2. source ~/costes_lab_env/bin/activate
  3. pip install diplib spotmax tifffile czifile plotly napari[all] jupyterlab ipywidgets
  4. Put project data in ~/Documents/Your Project/
  5. jupyter lab

CONNECT COLAB TO LOCAL MACHINE:
  1. pip install jupyter_http_over_ws
  2. jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --no-browser
  3. In Colab: Connect → Connect to local runtime → paste URL

OSDR DATA:
  - Single file: requests.get(osdr_url) → zipfile
  - Large batch: aws s3 sync --no-sign-request s3://nasa-osdr/OSD-366/ ~/Documents/OSD-366/
```

---

*Questions? Contact the lab or open an issue on the lab GitHub (collaborators only):*
*https://github.com/svcostes/CostesLab*
*Imaging notebooks: https://github.com/svcostes/CostesLab/tree/master/Imaging*
*Last updated: May 2026*
