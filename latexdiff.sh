#! /bin/bash
latexdiff Submission_JEB/main_anonymous.tex main_anonymous.tex > diff.tex 
dos2unix diff.tex
pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=diff diff.tex
biber diff
pdflatex -interaction=nonstopmode --extra-mem-top=100000000 -jobname=diff diff.tex
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=diff-compressed.pdf diff.pdf
