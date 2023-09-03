import json
from typing import Dict

def read_config(
        file_path: str      
) -> Dict:
    with open(file_path, "r") as f:
        json_content = json.load(f)
    return json_content