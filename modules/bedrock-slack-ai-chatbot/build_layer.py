"""Build the Lambda layer from requirements.txt.

Called by `data "external" "lambda_layer"` on every plan, so HCP Terraform builds the
layer itself and the libraries never have to be committed. The external data source
reads a JSON object from stdout, so pip's own output goes to stderr.
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

MODULE_DIR = Path(__file__).resolve().parent
REQUIREMENTS = MODULE_DIR / "requirements.txt"
LAYER_DIR = MODULE_DIR / ".build" / "lambda_layer"


def main() -> None:
    shutil.rmtree(LAYER_DIR, ignore_errors=True)
    subprocess.run(
        [
            sys.executable,
            "-m",
            "pip",
            "install",
            "--requirement",
            str(REQUIREMENTS),
            "--target",
            str(LAYER_DIR / "python"),
            # Resolve for the Lambda runtime, not for whatever machine runs the plan.
            "--platform",
            "manylinux2014_x86_64",
            "--python-version",
            "3.13",
            "--implementation",
            "cp",
            "--only-binary=:all:",
            # .pyc files differ between runs and would change the layer's hash.
            "--no-compile",
            "--no-cache-dir",
            "--disable-pip-version-check",
            "--quiet",
        ],
        check=True,
        stdout=sys.stderr,
    )
    json.dump({"dir": str(LAYER_DIR)}, sys.stdout)


if __name__ == "__main__":
    main()
