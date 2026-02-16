VENV := .venv
RENDERCV := $(VENV)/bin/rendercv

install-tools:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --quiet "rendercv[full]"
	@echo "rendercv installed. Run: source .venv/bin/activate"

# Usage: make render FILE=templates/David_Alecrim_CV.yaml
render:
	@test -n "$(FILE)" || (echo "Usage: make render FILE=<path>"; exit 1)
	@BASENAME=$$(basename $(FILE)); \
	cp $(FILE) ./$$BASENAME && \
	$(RENDERCV) render ./$$BASENAME && \
	rm ./$$BASENAME
