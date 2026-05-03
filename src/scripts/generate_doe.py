import json
import subprocess
import os
import shutil
import logging
from pathlib import Path

# @file generate_doe.py
# @brief Automation script for generating DoE geometry and unified visual assets.
# @note Refactored to consolidate outputs into images/ and exports/ folders.

def setup_logging(output_dir):
    """Configures the logging module to output to both console and a log file."""
    log_file = os.path.join(output_dir, "pipeline.log")
    
    # Ensure directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Setup basic configuration
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ],
        force=True
    )

def find_openscad():
    """Attempts to find the OpenSCAD executable."""
    path = shutil.which("openscad")
    if path: return path
    win_path = "C:\\Program Files\\OpenSCAD\\openscad.exe"
    if os.path.exists(win_path): return win_path
    return None

def export_case_assets(openscad_path, scad_file, img_dir, export_dir, case_id, overrides=None):
    """Generates STL and multi-view PNGs for a specific case."""
    cameras = {
        "TOP": "--camera=0,0,0,0,0,0,250",
        "FRONT": "--camera=0,0,0,90,0,0,250",
        "RIGHT": "--camera=0,0,0,90,0,90,250"
    }

    try:
        # Generate STL in exports/
        stl_path = os.path.join(export_dir, f"{case_id}.stl")
        cmd_base = [openscad_path, "-o", stl_path]
        if overrides:
            for p, v in overrides.items():
                val = f"\"{v}\"" if isinstance(v, str) else str(v)
                cmd_base.extend(["-D", f"{p}={val}"])
        cmd_base.append("-D")
        cmd_base.append("$preview=false")
        cmd_base.append(scad_file)
        subprocess.run(cmd_base, check=True, capture_output=True)

        # Generate PNG Views in images/
        for view, cam in cameras.items():
            png_path = os.path.join(img_dir, f"{case_id}_{view}.png")
            img_cmd = [openscad_path, "-o", png_path, "--imgsize=1024,1024", "--colorscheme=Solarized", cam]    
            if overrides:
                for p, v in overrides.items():
                    val = f"\"{v}\"" if isinstance(v, str) else str(v)
                    img_cmd.extend(["-D", f"{p}={val}"])
            img_cmd.append("-D")
            img_cmd.append("$preview=false")
            img_cmd.append(scad_file)
            subprocess.run(img_cmd, check=True, capture_output=True)
            
        return True
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to generate assets for case {case_id}: {e}")
        return False

def generate_doe(openscad_path):
    doe_file = "src/config.json"
    output_dir = "dist/doe_study_v1"
    img_dir = os.path.join(output_dir, "images")
    export_dir = os.path.join(output_dir, "exports")
    model_file = "src/cad/rotor/fan_rotor_eng.scad"

    for d in [img_dir, export_dir]:
        Path(d).mkdir(parents=True, exist_ok=True)

    with open(doe_file, 'r') as f:
        config_data = json.load(f)
        doe_data = config_data.get('doe_study', {})

    logging.info(f"--- Starting Design Exploration Study: {doe_data.get('study_name', 'Unknown')} ---")
    
    # Generate Blueprint once
    logging.info("Generating Hybrid Blueprint...")
    drawing_path = os.path.join(img_dir, "fan_grill_blueprint.png")
    blueprint_cmd = [openscad_path, "-o", drawing_path, "--imgsize=2048,1536", "--camera=0,0,0,0,0,0,250",
           "-D", "render_mode=\"BLUEPRINT\"", "-D", "$preview=false", "src/cad/stator/fan_grill_eng.scad"]
    try:
        subprocess.run(blueprint_cmd, check=True, capture_output=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to generate blueprint: {e}")

    failed_cases = []

    for case in doe_data['test_matrix']:
        case_id = case['id']
        overrides = case['overrides']
        logging.info(f"Generating Case: {case_id}...")
        
        success = export_case_assets(openscad_path, model_file, img_dir, export_dir, case_id, overrides)
        if not success:
            failed_cases.append(case_id)

        case_scad = os.path.join(export_dir, f"{case_id}.scad")
        with open(case_scad, 'w') as f:
            f.write(f"// Automated Case: {case_id}\n")
            for p, v in overrides.items():
                val = f"\"{v}\"" if isinstance(v, str) else str(v)
                f.write(f"{p} = {val};\n")
            # Path from dist/doe_study_v1/exports/ to src/cad/rotor/fan_rotor_eng.scad
            f.write("include <../../../src/cad/rotor/fan_rotor_eng.scad>\n")

    if failed_cases:
        failed_report = os.path.join(output_dir, "failed_cases.json")
        with open(failed_report, 'w') as f:
            json.dump(failed_cases, f, indent=4)
        logging.warning(f"DoE completed with {len(failed_cases)} failures. See {failed_report}")
    else:
        logging.info("DoE completed successfully with no failures.")

if __name__ == "__main__":
    if not os.path.exists("src/scripts/generate_doe.py"):
        logging.error("Script must be run from the project root.")
    else:
        path = find_openscad()
        if path:
            # Wipe old study outputs to ensure clean state
            study_dir = "dist/doe_study_v1"
            if os.path.exists(study_dir):
                shutil.rmtree(study_dir)
            
            setup_logging(study_dir)
            generate_doe(path)
        else:
            logging.error("OpenSCAD not found.")
