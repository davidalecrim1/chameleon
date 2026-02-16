VENV := .venv
RENDERCV := $(VENV)/bin/rendercv

install-tools:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --quiet "rendercv[full]"
	@echo "rendercv installed. Run: source .venv/bin/activate"

# Usage: make render FILE=templates/david_alecrim_cv.yaml
render:
	@test -n "$(FILE)" || (echo "Usage: make render FILE=<path>"; exit 1)
	@BASENAME=$$(basename $(FILE)); \
	STEM=$$(basename $(FILE) .yaml); \
	mkdir -p output; \
	cp $(FILE) ./$$BASENAME && \
	$(RENDERCV) render ./$$BASENAME \
		--pdf-path output/$$STEM.pdf \
		--typst-path output/$$STEM.typ \
		--markdown-path output/$$STEM.md \
		--html-path output/$$STEM.html \
		--png-path output/$$STEM.png; \
	EXIT=$$?; rm ./$$BASENAME; exit $$EXIT
