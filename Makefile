.PHONY: all viewpdf pdf clean bibercache latexdiff

TARGET       = main
DIFF = diff
SOURCE_FILES = $(TARGET).tex
BIB_FILES    = $(wildcard *.bib)
FIGURES      = $(wildcard figures/*)

# Set the pdf reader according to the operating system
OS = $(shell uname)
ifeq ($(OS), Darwin)
	PDF_READER = open
endif
ifeq ($(OS), Linux)
	PDF_READER = evince
endif

all: pdf

viewpdf: pdf
	$(PDF_READER) $(TARGET).pdf &

pdf: $(TARGET).pdf

$(TARGET).pdf: $(SOURCE_FILES) $(BIB_FILES) $(FIGURES)
	pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=$(TARGET) $(SOURCE_FILES)
	biber $(TARGET)
	pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=$(TARGET) $(SOURCE_FILES) # For biber
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=landrec-gradients-ms-compressed.pdf $(TARGET).pdf


# https://gitlab.com/git-latexdiff/git-latexdiff
git_latexdiff: $(TARGET)_trackchange.pdf

$(TARGET)_trackchange.pdf: $(SOURCE_FILES) $(BIB_FILES) $(FIGURES)
	git latexdiff --latexmk --biber --whole-tree --no-view --exclude-safecmd='cite,citep,citet,citeyear' --output $(TARGET)_trackchange.pdf --main $(TARGET).tex v1 main
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=landrec-gradients-ms-compressed.pdf $(TARGET)_trackchange.pdf


latexdiff: $(DIFF).pdf

$(DIFF).pdf: $(DIFF).tex $(BIB_FILES) $(FIGURES)
	latexdiff main_v1.tex main.tex > $(DIFF).tex 
	dos2unix $(DIFF).tex
	pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=$(DIFF) $(DIFF).tex
	biber $(DIFF)
	pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=$(DIFF) $(DIFF).tex
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=landrec-gradients-ms-compressed.pdf $(DIFF).pdf


clean:
	rm -f $(TARGET).pdf
	rm -f $(DIFF).pdf
	rm -f $(TARGET)_trackchange.pdf
	rm -f $(TARGET).{ps,pdf,bcf,run.xml}
	for suffix in dvi aux bbl blg toc ind out brf ilg idx synctex.gz log; do \
		find . -type d -name ".git" -prune -o -type f -name "*.$${suffix}" -print -exec rm {} \;  ; \
	done

bibercache:
	rm -rf $(biber --cache)
