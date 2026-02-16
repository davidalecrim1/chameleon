VENV := .venv
PYTHON := $(VENV)/bin/python3
PIP := $(VENV)/bin/pip

ifeq ($(OS),Windows_NT)
	PYTHON := $(VENV)/Scripts/python.exe
	PIP := $(VENV)/Scripts/pip.exe
endif

install-tools:
	python3 -m venv $(VENV)
	$(PIP) install --quiet "rendercv[full]"
	@echo "rendercv installed."

# Usage: make render FILE=templates/david_alecrim_cv.yaml
render:
	@test -n "$(FILE)" || (echo "Usage: make render FILE=<path>"; exit 1)
	$(PYTHON) scripts/render.py $(FILE)
