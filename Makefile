### Locations
# Tools
SCRIPTS=tools/protocol23
# Input
CONF_IN=src/conf
FONTS_IN=src/fonts
HTML_IN=src/text/html
CHARMS_IN=src/text/charms
BOOK_IN=src/text/book
# Output / Intermediate
OUT=out
HTML_OUT=$(OUT)/html
IMG_OUT=$(OUT)/images
PDF_OUT=$(OUT)/pdf
DRAC_OUT=$(OUT)/drac
BBCODE_OUT=$(OUT)/bbcode
STATS_OUT=$(OUT)/stats
ASC_MED=$(OUT)/asciidoc
DOT_MED=$(OUT)/dot
#WW_WIKI_OUT=$(OUT)/ww_wiki

### Tools
MKDIR=mkdir -p
RM=rm -rf
CP=cp -f
TOUCH=touch
RUBY=/opt/local/bin/ruby1.9
XSLT=/opt/local/bin/xsltproc
ASCIIDOC=/opt/local/bin/asciidoc
A2X=/opt/local/bin/a2x
DOT=/Applications/Graphviz.app/Contents/MacOS/dot
SHOW_PDF=/usr/bin/osascript tools/show_pdf.scpt
DESCRIBE_GIT_STATUS=./tools/version-info/describe-git-status.bash
COPY_IF_MISSING_OR_DIFF=./tools/version-info/copy-if-missing-or-diff.bash
VERSION_STAMP_DOCINFO=./tools/version-info/version-stamp-docinfo.xslt
PROTOCOL23_DEPS=$(SCRIPTS)/yaml2x.rb

### Files
HTML_MAIN=charms.html
#MAINWIKI=charms_wiki.txt
CHARMS_IN_LIST=$(wildcard $(CHARMS_IN)/*.yml)
BOOK_IN_LIST=$(wildcard $(BOOK_IN)/*.asc)
HTML=$(CHARMS_IN_LIST:.yml=.html)
ASC=$(CHARMS_IN_LIST:.yml=.asc)
SVG=$(CHARMS_IN_LIST:.yml=.svg)
PNG=$(CHARMS_IN_LIST:.yml=.png)
DRAC=$(CHARMS_IN_LIST:.yml=_drac.html)
BBCODE=$(CHARMS_IN_LIST:.yml=_bbcode.txt)
CONFIG=$(CONF_IN)/asciidoc/* $(CONF_IN)/asciidoc/docbook-xsl/* $(CONF_IN)/fop/* $(FONTS_IN)/goudy-3.1/*

export FOP_HYPHENATION_PATH=tools/fop/offo-hyphenation-binary/fop-hyph.jar

include project.mk

all: html book

$(HTML_OUT):
	$(MKDIR) $(HTML_OUT)
$(IMG_OUT):
	$(MKDIR) $(IMG_OUT)
$(PDF_OUT):
	$(MKDIR) $(PDF_OUT)
$(STATS_OUT):
	$(MKDIR) $(STATS_OUT)
$(DRAC_OUT):
	$(MKDIR) $(DRAC_OUT)
$(BBCODE_OUT):
	$(MKDIR) $(BBCODE_OUT)
$(ASC_MED):
	$(MKDIR) $(ASC_MED)
$(DOT_MED):
	$(MKDIR) $(DOT_MED)

html: $(HTML_OUT)/$(HTML_MAIN)
book: $(PDF_OUT)/$(PROJECT_NAME).pdf
test-pdf: $(PDF_OUT)/test.pdf
drac: $(DRAC:$(CHARMS_IN)/%=$(DRAC_OUT)/%)
bbcode: $(BBCODE:$(CHARMS_IN)/%=$(BBCODE_OUT)/%)
stats: $(STATS_OUT)/stats.txt
#wiki: $(WW_WIKI_OUT)/$(MAINWIKI)

$(SCRIPTS)/yaml2dot.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2asciidoc.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2svg.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2stats.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2dracula.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/yaml2bbcode.rb: $(SCRIPTS)/yaml2x.rb
$(SCRIPTS)/makehtml.rb: $(SCRIPTS)/yaml2x.rb

.PHONY: clean tmpclean $(OUT)/version_info.in.txt

.PRECIOUS: $(IMG_OUT)/%.png $(IMG_OUT)/%.svg $(ASC_MED)/%.asc $(DOT_MED)/%.dot

clean:
	-$(RM) $(OUT)

tmpclean:
	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~

$(DOT_MED)/%.dot: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2dot.rb $(PROTOCOL23_DEPS) $(DOT_MED)
	$(RUBY) $(SCRIPTS)/yaml2dot.rb $< $@

$(ASC_MED)/%.asc: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2asciidoc.rb $(PROTOCOL23_DEPS) $(ASC_MED)
	$(RUBY) $(SCRIPTS)/yaml2asciidoc.rb $< $@

$(HTML_OUT)/%.html: $(ASC_MED)/%.asc $(IMG_OUT)/%.png $(HTML_OUT)
	$(ASCIIDOC) --attribute=image-dir=../images/ --attribute=charm-image-ext=png --out-file=$@ $<

$(IMG_OUT)/%.png: $(DOT_MED)/%.dot $(IMG_OUT)
	$(DOT) -Tpng $< >$@

$(IMG_OUT)/%.svg: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2svg.rb $(PROTOCOL23_DEPS) $(IMG_OUT)
	$(RUBY) $(SCRIPTS)/yaml2svg.rb $< $@

$(DRAC_OUT)/%_drac.html: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2dracula.rb $(PROTOCOL23_DEPS) $(DRAC_OUT)
	$(RUBY) $(SCRIPTS)/yaml2dracula.rb $< $@

$(BBCODE_OUT)/%_bbcode.txt: $(CHARMS_IN)/%.yml $(SCRIPTS)/yaml2bbcode.rb $(PROTOCOL23_DEPS) $(BBCODE_OUT)
	$(RUBY) $(SCRIPTS)/yaml2bbcode.rb $< $@

# This is a .PHONY target so that we always check the working copy status,
# which may have changed if an untracked file has been created or similar.
$(OUT)/version_info.in.txt:
	$(DESCRIBE_GIT_STATUS) >$@

# The update script only touches the ".txt" file if it differs from the
# ".in.txt" file.  That way, we can be sure we always update the version info,
# but we only force other things to build if it the version info has really
# changed.
$(OUT)/version_info.txt: $(OUT)/version_info.in.txt
	$(COPY_IF_MISSING_OR_DIFF) $< $@

$(BOOK_IN)/%-docinfo.xml: $(BOOK_IN)/$(@:.xml=.in.xml) $(OUT)/version_info.txt $(VERSION_STAMP_DOCINFO)
	$(XSLT) --param version-info "'`cat $(OUT)/version_info.txt`'" $(VERSION_STAMP_DOCINFO) $(@:.xml=.in.xml) >$@

$(HTML_OUT)/$(HTML_MAIN): $(SCRIPTS)/makehtml.rb $(PROTOCOL23_DEPS) $(HTML_IN)/protocol23-basic-page.css $(HTML_IN)/protocol23-charm-page.css $(HTML:$(CHARMS_IN)/%=$(HTML_OUT)/%) $(PNG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(HTML_OUT)
	$(SCRIPTS)/makehtml.rb $(CHARMS_IN) $(HTML_OUT) $(HTML_MAIN) $(PROJECT_NAME)
	$(TOUCH) $(HTML_OUT)/$(HTML_MAIN)
	$(CP) $(HTML_IN)/protocol23-basic-page.css $(HTML_OUT)
	$(CP) $(HTML_IN)/protocol23-charm-page.css $(HTML_OUT)

$(PDF_OUT)/%.pdf: $(BOOK_IN)/%.asc $(BOOK_IN)/%-docinfo.xml $(CONFIG) $(BOOK_IN_LIST) $(ASC:$(CHARMS_IN)/%=$(ASC_MED)/%) $(SVG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(PDF_OUT)
	$(A2X) -vv -k --asciidoc-opts "--conf-file=$(CONF_IN)/asciidoc/docbook45.conf --attribute=image-dir=$(IMG_OUT)/ --attribute=charm-image-ext=svg --attribute=charm-dir=$(CURDIR)/$(ASC_MED)/" -f pdf --fop --xsl-file=$(CONF_IN)/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c $(CONF_IN)/fop/fop.xconf -d" -D $(PDF_OUT) $(@:$(PDF_OUT)/%.pdf=$(BOOK_IN)/%.asc)
	$(SHOW_PDF) $(CURDIR)/$@

$(STATS_OUT)/stats.txt: $(CHARMS_IN_LIST) $(SCRIPTS)/yaml2stats.rb $(PROTOCOL23_DEPS) $(STATS_OUT)
	$(SCRIPTS)/yaml2stats.rb $@ $(CHARMS_IN_LIST)

#$(WW_WIKI_OUT)/$(MAINWIKI): 6_1_Whirling_Dervish_Style.txt ./makewiki.rb
#	./makewiki.rb . $(WW_WIKI_OUT) $(MAINWIKI)
