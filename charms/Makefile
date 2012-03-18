D=output
MAINFILE=charms.html

#W=output_wiki
#MAINWIKI=charms_wiki.txt

INPUT=$(wildcard ./*.yml)
HTML=$(INPUT:.yml=.html)
ASC=$(INPUT:.yml=.asc)
PNG=$(INPUT:.yml=.png)
CONFIG=asciidoc/docbook-xsl/* fop/* ../fonts/goudy-3.1/*

all: destdir $D/$(MAINFILE) # $W/$(MAINWIKI)

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
	asciidoc --theme discordians $<

#$D/%.pdf: $D2/%.asc $D/%.png
#	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $<

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/$(MAINFILE): makehtml.rb intro.html style.css discordians.css $(HTML:./%=$D/%) $(PNG:./%=$D/%)
	./makehtml.rb . $D $(MAINFILE)
	touch $D/$(MAINFILE)
	cp -f intro.html $D/intro.html
	cp -f style.css $D/style.css
	cp -f discordians.css $D/discordians.css

$D/charms.pdf: charms.asc $(CONFIG) $(ASC:./%=$D/%)
	cp charms.asc $D/charms.asc
	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $D/charms.asc

test.pdf: test.asc $(CONFIG)
	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl --fop-opts "-c fop/fop.xconf -d" test.asc
	osascript show_pdf.scpt

#$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
#	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
