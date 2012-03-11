D=output
MAINFILE=charms.html

#W=output_wiki
#MAINWIKI=charms_wiki.txt

INPUT=$(wildcard ./*.yml)
HTML=$(INPUT:.yml=.html)
PNG=$(INPUT:.yml=.png)

all: destdir $D/$(MAINFILE) # $W/$(MAINWIKI)

.PHONY: clean tmpclean

.PRECIOUS: $D/%.png

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
	asciidoc $<

$D/%.pdf: $D2/%.asc $D/%.png
	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $<

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/$(MAINFILE): intro.html style.css $(HTML:./%=$D/%) $(PNG:./%=$D/%)
	touch $D/$(MAINFILE)
	-#./makehtml.rb . $D $(MAINFILE)
	cp -f intro.html $D/intro.html
	cp -f style.css $D/style.css

#$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
#	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
