DOC_DIR= .

.PHONY: doc

doc:
	cd $(DOC_DIR) && pdflatex doc.tex
	make cleanTex

cleanTex:
	rm -fv $(DOC_DIR)/*.aux $(DOC_DIR)/*.log $(DOC_DIR)/*.fls $(DOC_DIR)/*.out $(DOC_DIR)/*.fdb_latexmk