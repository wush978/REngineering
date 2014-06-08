all : index.html

%.html : %.Rmd
	Rscript -e "library(slidify);slidify('$<')"

publish:
	Rscript -e "library(slidify);publish_github('REngineering', 'wush978')"

clean :
	rm index.html index.md .cache/*
