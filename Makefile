Portland: R/Portland.Rmd R/Portland.R
	cd R; R --vanilla -e 'source("Portland.R")'

.PHONY: data

.PHONY2: clean

clean:
	rm -vf ./*.md
