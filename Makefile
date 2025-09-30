docs:
	@echo "Documentation index: docs/README.md"
	@ls -R docs | sed 's/^/  /'

open-docs:
	@${EDITOR:-vi} docs/README.md
