### Tools
MKDIR=mkdir -p
RM=rm -rf
CP=cp -f
TOUCH=touch
ASCIIDOC=asciidoc
A2X=a2x
DOT=/Applications/Graphviz.app/Contents/MacOS/dot
SHOW_PDF=osascript show_pdf.scpt

### Locations
# Tools
SCRIPTS=tools/protocol23
# Input
CONF_IN=src/conf
FONTS_IN=src/fonts
CHARMS_IN=src/text/charms
# Output / Intermediate
#D=out
OUT=out
HTML_OUT=$(OUT)/html
IMG_OUT=$(OUT)/images
PDF_OUT=$(OUT)/PDF
ASC_MED=$(OUT)/asciidoc
DOT_MED=$(OUT)/dot

HTML_MAIN=charms.html

#W=output_wiki
#MAINWIKI=charms_wiki.txt

CHARMS_IN_LIST=$(wildcard $(CHARMS_IN)/*.yml)
SCRIPTS_LIST=$(wildcard $(SCRIPTS)/*.rb)
HTML=$(CHARMS_IN_LIST:.yml=.html)
ASC=$(CHARMS_IN_LIST:.yml=.asc)
SVG=$(CHARMS_IN_LIST:.yml=.svg)
PNG=$(CHARMS_IN_LIST:.yml=.png)
CONFIG=$(CONF_DIR)/asciidoc/* $(CONF_DIR)/asciidoc/docbook-xsl/* $(CONF_DIR)/fop/* $(FONTS_IN)/goudy-3.1/*

export FOP_HYPHENATION_PATH=tools/fop/offo-hyphenation-binary/fop-hyph.jar

all: html # charms-pdf wiki

$(HTML_OUT):
	$(MKDIR) $(HTML_OUT)
$(IMG_OUT):
	$(MKDIR) $(IMG_OUT)
$(ASC_MED):
	$(MKDIR) $(ASC_MED)
$(DOT_MED):
	$(MKDIR) $(DOT_MED)

html: $(HTML_OUT) $(HTML_OUT)/$(HTML_MAIN)

#charms-pdf: destdir $D/charms.pdf

#wiki: destdir $W/$(MAINWIKI)

.PHONY: clean tmpclean

.PRECIOUS: $(IMG_OUT)/%.png $(ASC_MED)/%.asc $(DOT_MED)/%.dot

clean:
	-$(RM) $(OUT) # $W

tmpclean:
	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~ # $W/*~

#destdir:
#	mkdir -p $D
##	mkdir -p $W

$(DOT_MED)/%.dot: $(CHARMS_IN)/%.yml $(SCRIPTS_LIST) $(DOT_MED)
	$(SCRIPTS)/yaml2dot.rb $< $@

$(ASC_MED)/%.asc: $(CHARMS_IN)/%.yml $(SCRIPTS_LIST) $(ASC_MED)
	$(SCRIPTS)/yaml2asciidoc.rb $< $@

$(HTML_OUT)/%.html: $(ASC_MED)/%.asc $(IMG_OUT)/%.png $(HTML_OUT)
	$(ASCIIDOC) --attribute=image-dir=./ --attribute=charm-image-ext=png --out-file=$@ $<

#$D/%.pdf: $D2/%.asc $D/%.png
#	$(A2X) -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $<

$(IMG_OUT)/%.png: $(DOT_MED)/%.dot $(IMG_OUT)
	$(DOT) -Tpng $< >$@

$(IMG_OUT)/%.svg: $(CHARMS_IN)/%.yml $(SCRIPTS_LIST) $(IMG_OUT)
	$(SCRIPTS)/yaml2svg.rb $< $@

$(HTML_OUT)/$(HTML_MAIN): $(SCRIPTS_LIST) $(CHARMS_IN)/intro.html $(CHARMS_IN)/style.css $(CHARMS_IN)/discordians.css $(HTML:$(CHARMS_IN)/%=$(HTML_OUT)/%) $(PNG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(HTML_OUT)
	$(SCRIPTS)/makehtml.rb . $(HTML_OUT) $(HTML_MAIN)
	$(TOUCH) $(HTML_OUT)/$(HTML_MAIN)
	$(CP) $(CHARMS_IN)/intro.html $(HTML_OUT)
	$(CP) $(CHARMS_IN)/style.css $(HTML_OUT)
	$(CP) $(CHARMS_IN)/discordians.css $(HTML_OUT)

$(PDF_OUT)/charms.pdf: charms.asc charms-docinfo.xml $(CONFIG) $(ASC:./%=$D/%) $(SVG:./%=$D/%) $(PDF_OUT)
#	$(CP) charms.asc $(OUT)
#	$(CP) charms-docinfo.xml $(OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=asciidoc/docbook45.conf --attribute=image-dir=$(IMG_OUT)/ --attribute=charm-image-ext=svg" -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl --fop-opts "-c fop/fop.xconf -d" -D $(PDF_OUT) charms.asc
	$(SHOW_PDF) `pwd`/$(PDF_OUT)/charms.pdf

$(PDF_OUT)/test.pdf: test.asc test-docinfo.xml $(CONFIG) $(PDF_OUT)
#	$(CP) test.asc $(OUT)
#	$(CP) test-docinfo.xml $(OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=asciidoc/docbook45.conf" -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl --fop-opts "-c fop/fop.xconf -d" -D $(PDF_OUT) test.asc
	$(SHOW_PDF) `pwd`/$(PDF_OUT)/test.pdf

#$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
#	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
