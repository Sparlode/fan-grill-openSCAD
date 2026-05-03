import sys
import os
import logging
import subprocess
from pathlib import Path

# Add src to the path so we can import scripts
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src')))

from scripts import generate_doe

def test_setup_logging(tmp_path):
    # Set the output dir for the log file
    output_dir = tmp_path / "dist" / "doe_study_v1"
    
    # Run the setup_logging function that we will implement
    generate_doe.setup_logging(str(output_dir))
    
    # Get the root logger
    logger = logging.getLogger()
    
    # Ensure there are at least two handlers (console and file)
    assert len(logger.handlers) >= 2
    
    # Check that one handler is a FileHandler pointing to pipeline.log
    file_handlers = [h for h in logger.handlers if isinstance(h, logging.FileHandler)]
    assert len(file_handlers) >= 1
    
    log_file_path = file_handlers[0].baseFilename
    assert log_file_path.endswith("pipeline.log")
    
    # Clean up handlers so we don't affect other tests
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)

def test_generate_doe_logging(caplog, tmp_path, monkeypatch):
    # Set up dummy config and paths
    caplog.set_level(logging.INFO)
    
    # Mock find_openscad
    monkeypatch.setattr(generate_doe, "find_openscad", lambda: "dummy_openscad_path")
    
    # Mock os.path.exists for the script check
    original_exists = os.path.exists
    def mock_exists(path):
        if path == "src/scripts/generate_doe.py":
            return True
        return original_exists(path)
    monkeypatch.setattr(os.path, "exists", mock_exists)
    
    # Run setup_logging
    output_dir = tmp_path / "dist" / "doe_study_v1"
    generate_doe.setup_logging(str(output_dir))
    
    # Run generate_doe. It should fail later on subprocess, but we can capture initial logs
    # Or we can just mock print and see if any print is called? No, we just ensure logging.info is used.
    # We can mock subprocess to not fail.
    def mock_run(*args, **kwargs):
        pass
    monkeypatch.setattr(subprocess, "run", mock_run)
    
    # Mock json reading
    import json
    def mock_load(*args, **kwargs):
        return {
            "doe_study": {
                "study_name": "Mock Study",
                "test_matrix": [
                    {"id": "case_1", "overrides": {"param1": 10}}
                ]
            }
        }
    monkeypatch.setattr(json, "load", mock_load)
    
    # Mock open for config reading and case_scad writing
    import builtins
    original_open = builtins.open
    class MockFile:
        def __init__(self, *args, **kwargs): pass
        def read(self, *args, **kwargs): return ""
        def write(self, *args, **kwargs): pass
        def __enter__(self): return self
        def __exit__(self, *args, **kwargs): pass

    def mock_open_file(file, mode='r', *args, **kwargs):
        if 'config.json' in str(file) or 'case_1.scad' in str(file):
            return MockFile()
        return original_open(file, mode, *args, **kwargs)
    monkeypatch.setattr(builtins, "open", mock_open_file)
    
    # Execute generate_doe
    generate_doe.generate_doe("dummy_openscad_path")
    
def test_generate_error_report(caplog, tmp_path, monkeypatch):
    caplog.set_level(logging.INFO)
    monkeypatch.setattr(generate_doe, "find_openscad", lambda: "dummy_openscad_path")
    
    original_exists = os.path.exists
    def mock_exists(path):
        if path == "src/scripts/generate_doe.py": return True
        return original_exists(path)
    monkeypatch.setattr(os.path, "exists", mock_exists)
    
    output_dir = tmp_path / "dist" / "doe_study_v1"
    generate_doe.setup_logging(str(output_dir))
    
    import json
    def mock_load(*args, **kwargs):
        return {
            "doe_study": {
                "study_name": "Mock Study",
                "test_matrix": [
                    {"id": "case_pass", "overrides": {"param1": 1}},
                    {"id": "case_fail", "overrides": {"param1": 2}}
                ]
            }
        }
    monkeypatch.setattr(json, "load", mock_load)
    
    def mock_export(openscad_path, scad_file, img_dir, export_dir, case_id, overrides=None):
        if case_id == "case_fail":
            return False
        return True
    monkeypatch.setattr(generate_doe, "export_case_assets", mock_export)
    
    failed_cases_captured = []
    
    import builtins
    original_open = builtins.open
    class MockFile:
        def __init__(self, name=""): self.name = name
        def read(self, *args, **kwargs): return ""
        def write(self, content, *args, **kwargs):
            if "failed_cases.json" in self.name:
                failed_cases_captured.append(content)
        def __enter__(self): return self
        def __exit__(self, *args, **kwargs): pass

    def mock_open_file(file, mode='r', *args, **kwargs):
        if 'config.json' in str(file) or '.scad' in str(file) or 'failed_cases.json' in str(file):
            return MockFile(name=str(file))
        return original_open(file, mode, *args, **kwargs)
    monkeypatch.setattr(builtins, "open", mock_open_file)
    
    def mock_run(*args, **kwargs): pass
    monkeypatch.setattr(subprocess, "run", mock_run)
    
    generate_doe.generate_doe("dummy_openscad_path")
    
    # failed_cases_captured will have strings written to it by json.dump
    written_data = "".join(failed_cases_captured)
    assert "case_fail" in written_data

