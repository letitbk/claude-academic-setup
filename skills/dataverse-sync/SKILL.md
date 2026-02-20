---
name: dataverse-sync
description: Sync local repository with Harvard Dataverse archive using the API. Use when uploading, replacing, or deleting files in a Dataverse dataset.
---

# Harvard Dataverse API Sync

## Overview

Sync local files with a Harvard Dataverse dataset using the Native API.

## Key API Endpoints

| Action | Endpoint | Method |
|--------|----------|--------|
| Get dataset metadata | `/api/datasets/:persistentId/?persistentId={DOI}` | GET |
| Add file | `/api/datasets/:persistentId/add?persistentId={DOI}` | POST |
| Replace file | `/api/files/{file_id}/replace` | POST |
| Delete file | `/api/files/{file_id}` | DELETE |

## Authentication

All requests require the `X-Dataverse-key` header with your API token:
```python
headers = {"X-Dataverse-key": "your-api-token"}
```

## Common Operations

### Get Dataset Files
```python
import requests

url = "https://dataverse.harvard.edu/api/datasets/:persistentId/"
params = {"persistentId": "doi:10.7910/DVN/XXXXXX"}
headers = {"X-Dataverse-key": API_TOKEN}

response = requests.get(url, params=params, headers=headers)
data = response.json()
files = data["data"]["latestVersion"]["files"]

for f in files:
    file_id = f["dataFile"]["id"]
    md5 = f["dataFile"].get("md5", "")
    filename = f.get("label", f["dataFile"].get("filename"))
    directory = f.get("directoryLabel", "")
```

### Add File
```python
import json

url = "https://dataverse.harvard.edu/api/datasets/:persistentId/add"
params = {"persistentId": DOI}
headers = {"X-Dataverse-key": API_TOKEN}

json_data = json.dumps({
    "directoryLabel": "path/to/directory",  # Optional
    "categories": [],
})

with open(filepath, "rb") as f:
    files = {
        "file": (filename, f),
        "jsonData": (None, json_data, "application/json"),
    }
    response = requests.post(url, params=params, headers=headers, files=files)
```

### Delete File
```python
url = f"https://dataverse.harvard.edu/api/files/{file_id}"
headers = {"X-Dataverse-key": API_TOKEN}
response = requests.delete(url, headers=headers)
```

### Compare Files Using MD5
```python
import hashlib

def compute_md5(filepath):
    md5_hash = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            md5_hash.update(chunk)
    return md5_hash.hexdigest()
```

## Important Notes

### Draft vs Published
- Changes to a RELEASED dataset create a new DRAFT version
- User must manually publish the draft via web UI
- Publishing creates a new version (v1.0 → v2.0), same DOI

### AWS WAF Restrictions
Harvard Dataverse uses AWS WAF which may block direct uploads of certain file types (`.R`, `.do` files).

**Workaround:** Upload files inside a ZIP archive. See `dataverse-upload-zip` skill.

### Directory Labels
- Files in Dataverse have a `directoryLabel` that defines their folder path
- When uploading, set `directoryLabel` in the JSON metadata
- When uploading ZIPs without a directoryLabel, internal ZIP structure is preserved

### File Replacement Strategy
The `/api/files/{id}/replace` endpoint may return 403 for some file types. Alternative approach:
1. Delete the old file
2. Add the new file with same directoryLabel

## Example Sync Script Structure

```python
def sync(dry_run=True):
    # 1. Fetch current Dataverse files
    dataverse_files = get_dataset_files()  # {path: {id, md5, directoryLabel}}

    # 2. Scan local files
    local_files = get_local_files()  # {path: {local_path, md5}}

    # 3. Compare
    for path, local_info in local_files.items():
        if path in dataverse_files:
            if local_info["md5"] != dataverse_files[path]["md5"]:
                # Modified - replace
                replace_file(...)
        else:
            # New - add
            add_file(...)

    # 4. Find deleted
    for path in dataverse_files:
        if path not in local_files:
            # Deleted - optionally remove
            delete_file(...)
```

## References
- [Dataverse Native API Guide](https://guides.dataverse.org/en/latest/api/native-api.html)
- [Adding Files via API](https://guides.dataverse.org/en/latest/api/native-api.html#add-a-file-to-a-dataset)
