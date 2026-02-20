---
name: dataverse-upload-zip
description: Upload files to Harvard Dataverse via ZIP archive to bypass WAF restrictions. Use when direct uploads of R, Stata, or other code files fail with 403 Forbidden.
---

# Dataverse ZIP Upload Workaround

## Problem

Harvard Dataverse uses AWS WAF (Web Application Firewall) that blocks direct API uploads of certain file types, particularly:
- `.R` files (R scripts)
- `.do` files (Stata scripts)

Direct uploads return `403 Forbidden` from `awselb/2.0`.

## Solution

Package files in a ZIP archive. Dataverse automatically extracts ZIPs and preserves the internal directory structure.

## Implementation

### Step 1: Create ZIP with Proper Structure

The ZIP's internal structure becomes the Dataverse directory structure:

```bash
# Create ZIP from parent directory to preserve full path
cd /path/to/parent
zip -r upload.zip \
  project-name/code/1_data-cleaning/*.R \
  project-name/code/1_data-cleaning/*.do \
  project-name/code/2_analysis/*.R \
  project-name/code/2_analysis/*.do \
  project-name/README.md
```

ZIP contents should look like:
```
project-name/
├── README.md
└── code/
    ├── 1_data-cleaning/
    │   ├── script1.R
    │   └── script2.do
    └── 2_analysis/
        ├── analysis1.R
        └── analysis2.do
```

### Step 2: Upload WITHOUT directoryLabel

**Critical:** Do NOT specify a `directoryLabel` when uploading the ZIP. This preserves the internal ZIP structure.

```python
import requests
import json

url = "https://dataverse.harvard.edu/api/datasets/:persistentId/add"
params = {"persistentId": "doi:10.7910/DVN/XXXXXX"}
headers = {"X-Dataverse-key": API_TOKEN}

# Empty JSON to preserve ZIP's internal structure
json_data = json.dumps({})

with open("upload.zip", "rb") as f:
    files = {
        "file": ("upload.zip", f),
        "jsonData": (None, json_data, "application/json"),
    }
    response = requests.post(url, params=params, headers=headers, files=files)

if response.status_code == 200:
    data = response.json()
    print(f"Files added: {len(data['data']['files'])}")
```

### Step 3: Clean Up

Delete the temporary ZIP after upload:
```bash
rm upload.zip
```

## Common Mistakes

### Wrong: Specifying directoryLabel with ZIP
```python
# DON'T DO THIS - files will be placed incorrectly
json_data = json.dumps({"directoryLabel": "some-path"})
```

This causes Dataverse to add the directoryLabel AS A PREFIX to the ZIP's internal paths, resulting in wrong locations.

### Wrong: Creating ZIP from wrong directory
```bash
# DON'T DO THIS - loses directory structure
cd project-name/code
zip -r upload.zip *.R *.do
```

Files will end up flat without subdirectories.

## Verification

After upload, verify directory structure:
```python
response = requests.get(
    "https://dataverse.harvard.edu/api/datasets/:persistentId/",
    params={"persistentId": DOI},
    headers={"X-Dataverse-key": API_TOKEN}
)
data = response.json()

for f in data["data"]["latestVersion"]["files"]:
    directory = f.get("directoryLabel", "(root)")
    filename = f.get("label", f["dataFile"]["filename"])
    print(f"{directory}/{filename}")
```

## Full Example

```python
import subprocess
import requests
import json
import os

def upload_via_zip(local_root, doi, api_token, file_patterns):
    """
    Upload files to Dataverse via ZIP to bypass WAF.

    Args:
        local_root: Path to project root
        doi: Dataset DOI (e.g., "doi:10.7910/DVN/XXXXXX")
        api_token: Dataverse API token
        file_patterns: List of glob patterns relative to local_root
    """
    zip_path = os.path.join(local_root, "_upload.zip")
    project_name = os.path.basename(local_root)
    parent_dir = os.path.dirname(local_root)

    # Create ZIP from parent directory
    cmd = ["zip", "-r", zip_path] + [
        f"{project_name}/{p}" for p in file_patterns
    ]
    subprocess.run(cmd, cwd=parent_dir, check=True)

    # Upload
    url = "https://dataverse.harvard.edu/api/datasets/:persistentId/add"
    params = {"persistentId": doi}
    headers = {"X-Dataverse-key": api_token}

    with open(zip_path, "rb") as f:
        files = {
            "file": ("_upload.zip", f),
            "jsonData": (None, json.dumps({}), "application/json"),
        }
        response = requests.post(url, params=params, headers=headers, files=files)

    # Clean up
    os.remove(zip_path)

    if response.status_code == 200:
        return response.json()["data"]["files"]
    else:
        raise Exception(f"Upload failed: {response.status_code}")

# Usage
files = upload_via_zip(
    local_root="/path/to/my-project",
    doi="doi:10.7910/DVN/XEUYCZ",
    api_token="your-token",
    file_patterns=[
        "code/**/*.R",
        "code/**/*.do",
        "README.md"
    ]
)
print(f"Uploaded {len(files)} files")
```

## Notes

- ZIP extraction happens server-side, so all file types inside work
- Dataverse recognizes file types correctly after extraction
- MD5 checksums are computed for extracted files
- Creates a DRAFT version that must be published manually
