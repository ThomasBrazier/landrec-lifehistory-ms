.PHONY: all viewpdf pdf clean

TARGET       = main
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
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=landrec-gradients-ms-compressed.pdf main.pdf

clean:
	rm -f $(TARGET).pdf
	rm -f $(TARGET).{ps,pdf,bcf,run.xml}
	for suffix in dvi aux bbl blg toc ind out brf ilg idx synctex.gz log; do \
		find . -type d -name ".git" -prune -o -type f -name "*.$${suffix}" -print -exec rm {} \;  ; \
	done

bibercache:
	rm -rf $(biber --cache)
