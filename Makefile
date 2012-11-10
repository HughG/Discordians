### Locations
# Tools
SCRIPTS=tools/protocol23
# Input
CONF_IN=src/conf
FONTS_IN=src/fonts
CHARMS_IN=src/text/charms
BOOK_IN=src/text/book
# Output / Intermediate
OUT=out
HTML_OUT=$(OUT)/html
IMG_OUT=$(OUT)/images
PDF_OUT=$(OUT)/pdf
STATS_OUT=$(OUT)/stats
ASC_MED=$(OUT)/asciidoc
DOT_MED=$(OUT)/dot
#W=output_wiki

### Tools
MKDIR=mkdir -p
RM=rm -rf
CP=cp -f
TOUCH=touch
ASCIIDOC=asciidoc
A2X=a2x
DOT=/Applications/Graphviz.app/Contents/MacOS/dot
SHOW_PDF=osascript tools/show_pdf.scpt

### Files
HTML_MAIN=charms.html
#MAINWIKI=charms_wiki.txt
CHARMS_IN_LIST=$(wildcard $(CHARMS_IN)/*.yml)
BOOK_IN_LIST=$(wildcard $(BOOK_IN)/*.asc)
HTML=$(CHARMS_IN_LIST:.yml=.html)
ASC=$(CHARMS_IN_LIST:.yml=.asc)
SVG=$(CHARMS_IN_LIST:.yml=.svg)
PNG=$(CHARMS_IN_LIST:.yml=.png)
CONFIG=$(CONF_IN)/asciidoc/* $(CONF_IN)/asciidoc/docbook-xsl/* $(CONF_IN)/fop/* $(FONTS_IN)/goudy-3.1/*

export FOP_HYPHENATION_PATH=tools/fop/offo-hyphenation-binary/fop-hyph.jar

all: html # charms-pdf wiki

$(HTML_OUT):
	$(MKDIR) $(HTML_OUT)
$(IMG_OUT):
	$(MKDIR) $(IMG_OUT)
$(PDF_OUT):
	$(MKDIR) $(PDF_OUT)
$(STATS_OUT):
	$(MKDIR) $(STATS_OUT)
$(ASC_MED):
	$(MKDIR) $(ASC_MED)
$(DOT_MED):
	$(MKDIR) $(DOT_MED)

html: $(HTML_OUT)/$(HTML_MAIN)
charms-pdf: $(PDF_OUT)/charms.pdf
book: $(PDF_OUT)/Discordians.pdf
test-pdf: $(PDF_OUT)/test.pdf
stats: $(STATS_OUT)/stats.txt

#wiki: destdir $W/$(MAINWIKI)

$(SCRIPTS)/yaml2dot.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2asciidoc.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2stats.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2svg.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/makehtml.rb: $(SCRIPTS)/yaml2x.rb

.PHONY: clean tmpclean

.PRECIOUS: $(IMG_OUT)/%.png $(IMG_OUT)/%.svg $(ASC_MED)/%.asc $(DOT_MED)/%.dot

clean:
	-$(RM) $(OUT) # $W

tmpclean:
	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~ # $W/*~

$(DOT_MED)/%.dot: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2dot.rb $(DOT_MED)
	$(SCRIPTS)/yaml2dot.rb $< $@

$(ASC_MED)/%.asc: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2asciidoc.rb $(ASC_MED)
	$(SCRIPTS)/yaml2asciidoc.rb $< $@

$(HTML_OUT)/%.html: $(ASC_MED)/%.asc $(IMG_OUT)/%.png $(HTML_OUT)
	$(ASCIIDOC) --attribute=image-dir=../images/ --attribute=charm-image-ext=png --out-file=$@ $<

$(IMG_OUT)/%.png: $(DOT_MED)/%.dot $(IMG_OUT)
	$(DOT) -Tpng $< >$@

$(IMG_OUT)/%.svg: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2svg.rb $(IMG_OUT)
	$(SCRIPTS)/yaml2svg.rb $< $@

$(HTML_OUT)/$(HTML_MAIN): $(SCRIPTS)/makehtml.rb $(CHARMS_IN)/intro.html $(CHARMS_IN)/style.css $(CHARMS_IN)/discordians.css $(HTML:$(CHARMS_IN)/%=$(HTML_OUT)/%) $(PNG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(HTML_OUT)
	$(SCRIPTS)/makehtml.rb $(CHARMS_IN) $(HTML_OUT) $(HTML_MAIN)
	$(TOUCH) $(HTML_OUT)/$(HTML_MAIN)
	$(CP) $(CHARMS_IN)/intro.html $(HTML_OUT)
	$(CP) $(CHARMS_IN)/style.css $(HTML_OUT)
	$(CP) $(CHARMS_IN)/discordians.css $(HTML_OUT)

$(PDF_OUT)/charms.pdf: $(CHARMS_IN)/charms.asc $(CHARMS_IN)/charms-docinfo.xml $(CONFIG) $(ASC:$(CHARMS_IN)/%=$(ASC_MED)/%) $(SVG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(PDF_OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=$(CONF_IN)/asciidoc/docbook45.conf --attribute=image-dir=$(IMG_OUT)/ --attribute=charm-image-ext=svg --attribute=charm-dir=$(CURDIR)/$(ASC_MED)/" -f pdf --fop --xsl-file=$(CONF_IN)/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c $(CONF_IN)/fop/fop.xconf -d" -D $(PDF_OUT) $(CHARMS_IN)/charms.asc
	$(SHOW_PDF) $(CURDIR)/$(PDF_OUT)/charms.pdf

$(PDF_OUT)/Discordians.pdf: $(BOOK_IN)/Discordians.asc $(BOOK_IN)/Discordians-docinfo.xml $(CONFIG) $(BOOK_IN_LIST) $(PDF_OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=$(CONF_IN)/asciidoc/docbook45.conf --attribute=image-dir=$(IMG_OUT)/ --attribute=charm-image-ext=svg --attribute=charm-dir=$(CURDIR)/$(ASC_MED)/" -f pdf --fop --xsl-file=$(CONF_IN)/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c $(CONF_IN)/fop/fop.xconf -d" -D $(PDF_OUT) $(BOOK_IN)/Discordians.asc
	$(SHOW_PDF) $(CURDIR)/$(PDF_OUT)/Discordians.pdf

$(PDF_OUT)/test.pdf: $(CHARMS_IN)/test.asc $(CHARMS_IN)/test-docinfo.xml $(CONFIG) $(PDF_OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=$(CONF_IN)/asciidoc/docbook45.conf" -f pdf --fop --xsl-file=$(CONF_IN)/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c $(CONF_IN)/fop/fop.xconf -d" -D $(PDF_OUT) $(CHARMS_IN)/test.asc
	$(SHOW_PDF) $(CURDIR)/$(PDF_OUT)/test.pdf

$(STATS_OUT)/stats.txt: $(CHARMS_IN_LIST) $(SCRIPTS)/yaml2stats.rb $(STATS_OUT)
	$(SCRIPTS)/yaml2stats.rb $@ $(CHARMS_IN_LIST)

#$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
#	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
