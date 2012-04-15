D=output
MAINFILE=charms.html

#W=output_wiki
#MAINWIKI=charms_wiki.txt

INPUT=$(wildcard ./*.yml)
HTML=$(INPUT:.yml=.html)
ASC=$(INPUT:.yml=.asc)
SVG=$(INPUT:.yml=.svg)
PNG=$(INPUT:.yml=.png)
CONFIG=asciidoc/* asciidoc/docbook-xsl/* fop/* ../fonts/goudy-3.1/*

export FOP_HYPHENATION_PATH=fop/offo-hyphenation-binary/fop-hyph.jar

all: destdir html # charms-pdf wiki

html: $D/$(MAINFILE)

charms-pdf: $D/charms.pdf

wiki: $W/$(MAINWIKI)

.PHONY: clean tmpclean

.PRECIOUS: $D/%.png $D/%.asc

clean:
	-rm -rf $D # $W

tmpclean:
	-rm -rf ./*~ $D/*~ # $W/*~

destdir:
	mkdir -p $D
#	mkdir -p $W

$D/%.dot: %.yml yaml2dot.rb
	./yaml2dot.rb $< $@

$D/%.asc: %.yml yaml2asciidoc.rb
	./yaml2asciidoc.rb $< $@

$D/%.html: $D/%.asc $D/%.png
	asciidoc --attribute=image-dir=./ --attribute=charm-image-ext=png $<

#$D/%.pdf: $D2/%.asc $D/%.png
#	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $<

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/%.svg: %.yml
	./yaml2svg.rb $< $@

$D/$(MAINFILE): makehtml.rb intro.html style.css discordians.css $(HTML:./%=$D/%) $(PNG:./%=$D/%)
	./makehtml.rb . $D $(MAINFILE)
	touch $D/$(MAINFILE)
	cp -f intro.html $D/intro.html
	cp -f style.css $D/style.css
	cp -f discordians.css $D/discordians.css

$D/charms.pdf: charms.asc charms-docinfo.xml $(CONFIG) $(ASC:./%=$D/%) $(SVG:./%=$D/%)
	cp charms.asc $D/charms.asc
	cp charms-docinfo.xml $D/charms-docinfo.xml
	a2x -vv -k --asciidoc-opts "--conf-file=asciidoc/docbook45.conf --attribute=image-dir=$D/ --attribute=charm-image-ext=svg" -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl --fop-opts "-c fop/fop.xconf -d" $D/charms.asc
	osascript show_pdf.scpt `pwd`/$D/charms.pdf

test.pdf: test.asc test-docinfo.xml $(CONFIG)
	a2x -vv -k --asciidoc-opts "--conf-file=asciidoc/docbook45.conf" -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl --fop-opts "-c fop/fop.xconf -d" test.asc
	osascript show_pdf.scpt `pwd`/test.pdf

#$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
#	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
