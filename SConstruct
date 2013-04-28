import imp, os, string, sys

print "@ start"

env = Environment()
# Add the parent environment's path to our search path for tools.
env.Append(ENV = { 'PATH' : os.getenv('PATH') })

# Load machine-specific config, if it exists.  This can override defaults.
LOCAL_CONFIG_FULL_PATH = os.path.join('SConsLocal', 'Config.py')
if os.path.isfile(LOCAL_CONFIG_FULL_PATH):
    from SConsLocal.Config import Config
    Config(env)
    print "@ read local config"

print "@ done local config"

def default_executable_from_path(env, tool_key, tool_name=None):
    if tool_name is None:
        tool_name = string.lower(tool_key)
    # Could call env.SetDefault, but instead we check whether the tool_key
    # is present, to avoid searching the path if it is.
    if not tool_key in env:
        tool_path = env.WhereIs(tool_name)
        if tool_path is not None:
            env[tool_key] = tool_path

for exe in ['RUBY', 'DOT', 'XSLT', 'ASCIIDOC', 'A2X']:
    default_executable_from_path(env, exe)

print "@ done default tools"

def make_add_script_dependency_emitter(script_key):
    def add_script_dependency(target, source, env):
        return target, (source + [env[script_key]])
    return add_script_dependency

env['PROTOCOL23'] = 'tools/protocol23'

# ### Locations
# # Tools
# PROTOCOL23=tools/protocol23
# # Input
# CONF_IN=src/conf
# FONTS_IN=src/fonts
# HTML_IN=src/text/html
# CHARMS_IN=src/text/charms
# BOOK_IN=src/text/book
# # Output / Intermediate
# OUT=out
# HTML_OUT=$(OUT)/html
# IMG_OUT=$(OUT)/images
# PDF_OUT=$(OUT)/pdf
# DRAC_OUT=$(OUT)/drac
# BBCODE_OUT=$(OUT)/bbcode
# STATS_OUT=$(OUT)/stats
# ASC_MED=$(OUT)/asciidoc
# DOT_MED=$(OUT)/dot
# #WW_WIKI_OUT=$(OUT)/ww_wiki

# ### Tools
# MKDIR=mkdir -p
# RM=rm -rf
# CP=cp -f
# TOUCH=touch
# SHOW_PDF=/usr/bin/osascript tools/show_pdf.scpt
# DESCRIBE_GIT_STATUS=./tools/version-info/describe-git-status.bash
# COPY_IF_MISSING_OR_DIFF=./tools/version-info/copy-if-missing-or-diff.bash
# VERSION_STAMP_DOCINFO=./tools/version-info/version-stamp-docinfo.xslt
# PROTOCOL23_DEPS=$(PROTOCOL23)/yaml2x.rb

# ### Files
# HTML_MAIN=charms.html
# #MAINWIKI=charms_wiki.txt
# CHARMS_IN_LIST=$(wildcard $(CHARMS_IN)/*.yml)
# BOOK_IN_LIST=$(wildcard $(BOOK_IN)/*.asc)
# HTML=$(CHARMS_IN_LIST:.yml=.html)
# ASC=$(CHARMS_IN_LIST:.yml=.asc)
# SVG=$(CHARMS_IN_LIST:.yml=.svg)
# PNG=$(CHARMS_IN_LIST:.yml=.png)
# DRAC=$(CHARMS_IN_LIST:.yml=_drac.html)
# BBCODE=$(CHARMS_IN_LIST:.yml=_bbcode.txt)
# CONFIG=$(CONF_IN)/asciidoc/* $(CONF_IN)/asciidoc/docbook-xsl/* $(CONF_IN)/fop/* $(FONTS_IN)/goudy-3.1/*

print "@ done other env config"

VariantDir('build', 'src', duplicate=0)

print "@ called VariantDir"

env.Install('distrib', Glob('*.pdf'))

print "@ called install"


# include project.mk

# all: html book

# $(HTML_OUT):
# 	$(MKDIR) $(HTML_OUT)
# $(IMG_OUT):
# 	$(MKDIR) $(IMG_OUT)
# $(PDF_OUT):
# 	$(MKDIR) $(PDF_OUT)
# $(STATS_OUT):
# 	$(MKDIR) $(STATS_OUT)
# $(DRAC_OUT):
# 	$(MKDIR) $(DRAC_OUT)
# $(BBCODE_OUT):
# 	$(MKDIR) $(BBCODE_OUT)
# $(ASC_MED):
# 	$(MKDIR) $(ASC_MED)
# $(DOT_MED):
# 	$(MKDIR) $(DOT_MED)

# html: $(HTML_OUT)/$(HTML_MAIN)
# book: $(PDF_OUT)/$(PROJECT_NAME).pdf
# test-pdf: $(PDF_OUT)/test.pdf
# drac: $(DRAC:$(CHARMS_IN)/%=$(DRAC_OUT)/%)
# bbcode: $(BBCODE:$(CHARMS_IN)/%=$(BBCODE_OUT)/%)
# stats: $(STATS_OUT)/stats.txt
# #wiki: $(WW_WIKI_OUT)/$(MAINWIKI)

# $(PROTOCOL23)/yaml2dot.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/yaml2asciidoc.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/yaml2svg.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/yaml2stats.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/yaml2dracula.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/yaml2bbcode.rb: $(PROTOCOL23)/yaml2x.rb
# $(PROTOCOL23)/makehtml.rb: $(PROTOCOL23)/yaml2x.rb

# .PHONY: clean tmpclean $(OUT)/version_info.in.txt

# .PRECIOUS: $(IMG_OUT)/%.png $(IMG_OUT)/%.svg $(ASC_MED)/%.asc $(DOT_MED)/%.dot

#clean:
#	-$(RM) $(OUT)
#
# TODO 2013-03-10 hughg: SCons says it auto-cleans, but will it really remove the output dir?

# tmpclean:
# 	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~

env['YAML2DOT'] = os.path.join(env['PROTOCOL23'], 'yaml2dot.rb')
build_dot = Builder(
    action = '$RUBY $YAML2DOT $SOURCE $TARGET',
    suffix = 'dot',
    src_suffix = 'yml'
)
env.Append(BUILDERS = {'YamlToDot' : build_dot})
#env.YamlToDot('build/text/charms/1_1_Athletics', 'src/text/charms/1_1_Athletics')
# TODO 2013-03-10 hughg: Factor in script deps and output dir.

env['YAML2ASC'] = os.path.join(env['PROTOCOL23'], 'yaml2asciidoc.rb')
build_asc = Builder(
    action = '$RUBY $YAML2ASC $SOURCE $TARGET',
    suffix = 'asc',
    src_suffix = 'yml',
    emitter = make_add_script_dependency_emitter('YAML2ASC')
)
env.Append(BUILDERS = {'YamlToAsc' : build_asc})
# TODO 2013-03-10 hughg: Factor in script deps and output dir.

#$(HTML_OUT)/%.html: $(ASC_MED)/%.asc $(IMG_OUT)/%.png $(HTML_OUT)
#	$(ASCIIDOC) --attribute=image-dir=../images/ --attribute=charm-image-ext=png --out-file=$@ $<

# # build_html = Builder(
# #     '$ASCIIDOC --attribute=image-dir=../images/ --attribute=charm-image-ext=png --out-file=$TARGET $SOURCE',
# #     suffix='html',
# #     src_suffix='asc'
# # )
# TODO 2013-03-10 hughg: Factor in tool dep, PNG dep, images dir, and output dir.

#$(IMG_OUT)/%.png: $(DOT_MED)/%.dot $(IMG_OUT)
#	$(DOT) -Tpng $< >$@

build_png = Builder(
    action = '$DOT -Tpng $SOURCE >$TARGET',
    suffix = 'dot',
    src_suffix = 'yml'
)
env.Append(BUILDERS = {'DotToPng' : build_png})
#env.DotToPng('build/text/charms/1_1_Athletics', 'src/text/charms/1_1_Athletics')
# TODO 2013-03-10 hughg: Factor in tool dep and output dir.

#$(IMG_OUT)/%.svg: $(CHARMS_IN)/%.yml $(PROTOCOL23)/yaml2svg.rb $(PROTOCOL23_DEPS) $(IMG_OUT)
#	$(RUBY) $(PROTOCOL23)/yaml2svg.rb $< $@

# # build_svg = Builder(
# #     '$RUBY $PROTOCOL23/yaml2svg.rb $SOURCE $TARGET',
# #     suffix='svg',
# #     src_suffix='yml'
# # )
env['YAML2SVG'] = os.path.join(env['PROTOCOL23'], 'yaml2svg.rb')
build_svg = Builder(
    action = '$RUBY $YAML2SVG $SOURCE $TARGET',
    suffix = 'svg',
    src_suffix = 'yml'
)
env.Append(BUILDERS = {'YamlToSvg' : build_svg})

# TODO 2013-03-10 hughg: Factor in script deps and output dir.

#$(DRAC_OUT)/%_drac.html: $(CHARMS_IN)/%.yml $(PROTOCOL23)/yaml2dracula.rb $(PROTOCOL23_DEPS) $(DRAC_OUT)
#	$(RUBY) $(PROTOCOL23)/yaml2dracula.rb $< $@

# # build_drac = Builder(
# #     '$RUBY $PROTOCOL23/yaml2dracula.rb $SOURCE $TARGET',
# #     suffix='_drac.html',
# #     src_suffix='yml'
# # )
# TODO 2013-03-10 hughg: Factor in script deps and output dir.
# TODO 2013-03-10 hughg: Will the suffix bit work, since it's not preceded by '.'?
# Could use 'X.drac.html', I suppose.

#$(BBCODE_OUT)/%_bbcode.txt: $(CHARMS_IN)/%.yml $(PROTOCOL23)/yaml2bbcode.rb $(PROTOCOL23_DEPS) $(BBCODE_OUT)
#	$(RUBY) $(PROTOCOL23)/yaml2bbcode.rb $< $@
# # build_dot = Builder(
# #     '$RUBY $PROTOCOL23/yaml2bbcode.rb $SOURCE $TARGET',
# #     suffix='_bbcode.txt',
# #     src_suffix='yml'
# # )
# TODO 2013-03-10 hughg: Factor in script deps and output dir.
# TODO 2013-03-10 hughg: Will the suffix bit work, since it's not preceded by '.'?
# Could use 'X.bbcode.txt', I suppose.

# This is a .PHONY target so that we always check the working copy status,
# which may have changed if an untracked file has been created or similar.
# $(OUT)/version_info.in.txt:
# 	$(DESCRIBE_GIT_STATUS) >$@

# The update script only touches the ".txt" file if it differs from the
# ".in.txt" file.  That way, we can be sure we always update the version info,
# but we only force other things to build if it the version info has really
# changed.
#$(OUT)/version_info.txt: $(OUT)/version_info.in.txt
#	$(COPY_IF_MISSING_OR_DIFF) $< $@
#
# hughg: This isn't needed with SCons, because it'll only rebuild downstream from
# version_info.txt if the file's contents actually changed, by MD5 :-)

#$(BOOK_IN)/%-docinfo.xml: $(BOOK_IN)/$(@:.xml=.in.xml) $(OUT)/version_info.txt $(VERSION_STAMP_DOCINFO)
#	$(XSLT) --param version-info "'`cat $(OUT)/version_info.txt`'" $(VERSION_STAMP_DOCINFO) $(@:.xml=.in.xml) >$@
# TODO 2013-03-10 hughg: Builder for this will be trickier ...

# $(HTML_OUT)/$(HTML_MAIN): $(PROTOCOL23)/makehtml.rb $(PROTOCOL23_DEPS) $(HTML_IN)/protocol23-basic-page.css $(HTML_IN)/protocol23-charm-page.css $(HTML:$(CHARMS_IN)/%=$(HTML_OUT)/%) $(PNG:$(CHARMS_IN)/%=$(IMG_OUT)/%) $(HTML_OUT)
# 	$(PROTOCOL23)/makehtml.rb $(CHARMS_IN) $(HTML_OUT) $(HTML_MAIN) $(PROJECT_NAME)
# 	$(CP) $(HTML_IN)/protocol23-basic-page.css $(HTML_OUT)
# 	$(CP) $(HTML_IN)/protocol23-charm-page.css $(HTML_OUT)

################################################################
# PDF

env['CHARM_DIR'] = \
    os.path.abspath(os.path.join('build', 'text', 'charms')) + os.sep
OFFO_HYPHENATION_JAR = 'tools/fop/offo-hyphenation-binary/fop-hyph.jar'
env['ENV']['FOP_HYPHENATION_PATH'] = OFFO_HYPHENATION_JAR

# Custom emitter to add dependencies on config files etc.
EXTRA_PDF_SOURCES = [
    OFFO_HYPHENATION_JAR,
    Glob('src/conf/asciidoc/*'),
    Glob('src/conf/asciidoc/docbook-xsl/*'),
    Glob('src/conf/fop/*'),
    Glob('src/fonts/*/*')
    ]
def a2x_emitter(target, source, env):
    return target, (source + EXTRA_PDF_SOURCES)

build_pdf = Builder(
#    action = 'set',
    action = '$A2X -vv -k --asciidoc-opts "--conf-file=src/conf/asciidoc/docbook45.conf --attribute=image-dir=$CHARM_DIR --attribute=charm-image-ext=svg --attribute=charm-dir=$CHARM_DIR" -f pdf --fop --xsl-file=src/conf/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c src/conf/fop/fop.xconf -d" -D ${TARGET.dir} $SOURCE',
    suffix = 'pdf',
    src_suffix = 'asc',
    emitter = a2x_emitter
)
env.Append(BUILDERS = {'AscToPdf' : build_pdf})

book = env.AscToPdf('build/text/book/Discordians')

# Really I should have a custom Scanner for Discordians.asc which works out
# the dependencies backwards, but I'll just forward-chain for now.
Depends(book, 'src/text/book/Discordians-docinfo.xml')
Depends(book, Glob('src/text/book/*.asc'))
charms_yml = Glob('src/text/charms/*.yml')
charms_yml_in_build = [str(f).replace('src', 'build') for f in charms_yml]
charms_asc = Flatten(map(env.YamlToAsc, charms_yml_in_build))
Depends(book, charms_asc)
charms_svg = Flatten(map(env.YamlToSvg, charms_yml_in_build))
Depends(book, charms_svg)

# Show the PDF after it builds.
env.AddPostAction(book, "$SHOW_PDF " + str(book[0].abspath))



#$(STATS_OUT)/stats.txt: $(CHARMS_IN_LIST) $(PROTOCOL23)/yaml2stats.rb $(PROTOCOL23_DEPS) $(STATS_OUT)
#	$(PROTOCOL23)/yaml2stats.rb $@ $(CHARMS_IN_LIST)
# # charms_in_list = ???
# # stats_output_dir = ???
# # Stats('$(STATS_OUT)/stats.txt', Split("""
# #   charms_in_list
# #   $(PROTOCOL23)/yaml2stats.rb
# #   $(PROTOCOL23_DEPS)
# #   stats_output_dir
# # """)

#$(WW_WIKI_OUT)/$(MAINWIKI): 6_1_Whirling_Dervish_Style.txt ./makewiki.rb
#	./makewiki.rb . $(WW_WIKI_OUT) $(MAINWIKI)
