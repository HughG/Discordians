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

# Load project-specific config, if it exists.  This can override defaults.
PROJECT_CONFIG_FULL_PATH = os.path.join('SConsProject', 'Config.py')
if os.path.isfile(PROJECT_CONFIG_FULL_PATH):
    from SConsProject.Config import Config
    Config(env)
    print "@ read project config"

print "@ done project config"

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

env['PROTOCOL23'] = 'tools/protocol23'
env['YAML2X'] = os.path.join(env['PROTOCOL23'], 'yaml2x.rb')

# SCons isn't smart enough to follow the dependency from each script to
# "yaml2x.rb", so we have to add that explicitly.  Ideally this would be done
# with a custom scanner to read the Ruby scripts recursively for dependencies.
def make_add_script_dependency_emitter(script_key):
    def add_script_dependency(target, source, env):
        return target, (source + [env[script_key], env['YAML2X']])
    return add_script_dependency

PROTOCOL23_CSS_IN = 'src/text/html/'
PROTOCOL23_CSS_OUT = 'build/text/charms/'
PROTOCOL23_PAGE_CSS_FILE = 'protocol23-charm-page.css'
PROTOCOL23_BASIC_CSS_FILE = 'protocol23-basic-page.css'
PROTOCOL23_PAGE_CSS_SOURCES = [PROTOCOL23_CSS_IN + PROTOCOL23_PAGE_CSS_FILE]
PROTOCOL23_PAGE_CSS_TARGETS = [PROTOCOL23_CSS_OUT + PROTOCOL23_PAGE_CSS_FILE]
PROTOCOL23_BASIC_CSS_SOURCES = [PROTOCOL23_CSS_IN + PROTOCOL23_BASIC_CSS_FILE]
PROTOCOL23_BASIC_CSS_TARGETS = [PROTOCOL23_CSS_OUT + PROTOCOL23_BASIC_CSS_FILE]
protocol23_page_css_targets = map(
    lambda t, s: Command(t, s, Copy("$TARGET", "$SOURCE")),
    PROTOCOL23_PAGE_CSS_TARGETS,
    PROTOCOL23_PAGE_CSS_SOURCES
    )
protocol23_basic_css_targets = map(
    lambda t, s: Command(t, s, Copy("$TARGET", "$SOURCE")),
    PROTOCOL23_BASIC_CSS_TARGETS,
    PROTOCOL23_BASIC_CSS_SOURCES
    )


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

# Record charm input file paths (and equivalent paths in the output dir).
charms_in = 'src/text/charms/'
env['CHARMS_IN'] = charms_in
charms_yml = Glob(charms_in + '*.yml')
##print "charms_yml: ", [str(f) for f in charms_yml]
charms_yml_in_build = [str(f).replace('src/', 'build/') for f in charms_yml]
##print "charms_yml_in_build: ", charms_yml_in_build

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


# all: html book

# html: $(HTML_OUT)/$(HTML_MAIN)
# book: $(PDF_OUT)/$(PROJECT_NAME).pdf
# test-pdf: $(PDF_OUT)/test.pdf
# drac: $(DRAC:$(CHARMS_IN)/%=$(DRAC_OUT)/%)
# bbcode: $(BBCODE:$(CHARMS_IN)/%=$(BBCODE_OUT)/%)
# stats: $(STATS_OUT)/stats.txt
# #wiki: $(WW_WIKI_OUT)/$(MAINWIKI)

# .PHONY: clean tmpclean $(OUT)/version_info.in.txt

# .PRECIOUS: $(IMG_OUT)/%.png $(IMG_OUT)/%.svg $(ASC_MED)/%.asc $(DOT_MED)/%.dot

#clean:
#	-$(RM) $(OUT)
#
# TODO 2013-03-10 hughg: SCons says it auto-cleans, but will it really remove the output dir?

# tmpclean:
# 	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~

################################################################
# Per-Charm-Tree DOT (from YML)

env['YAML2DOT'] = os.path.join(env['PROTOCOL23'], 'yaml2dot.rb')
build_dot = Builder(
    action = '$RUBY $YAML2DOT $SOURCE $TARGET',
    suffix = 'dot',
    src_suffix = 'yml',
    emitter = make_add_script_dependency_emitter('YAML2DOT')
)
env.Append(BUILDERS = {'YamlToDot' : build_dot})
charms_dot = Flatten(map(env.YamlToDot, charms_yml_in_build))
##print "charms_dot: ", [str(f) for f in charms_dot]

################################################################
# Per-Charm-Tree ASC (from YML)

env['YAML2ASC'] = os.path.join(env['PROTOCOL23'], 'yaml2asciidoc.rb')
build_asc = Builder(
    action = '$RUBY $YAML2ASC $SOURCE $TARGET',
    suffix = 'asc',
    src_suffix = 'yml',
    emitter = make_add_script_dependency_emitter('YAML2ASC')
)
env.Append(BUILDERS = {'YamlToAsc' : build_asc})
charms_asc = Flatten(map(env.YamlToAsc, charms_yml_in_build))
##print "charms_asc: ", [str(f) for f in charms_asc]

################################################################
# Per-Charm-Tree PNG (from DOT)

#$(IMG_OUT)/%.png: $(DOT_MED)/%.dot $(IMG_OUT)
#	$(DOT) -Tpng $< >$@

build_png = Builder(
    action = '$DOT -Tpng $SOURCE >$TARGET',
    suffix = 'png',
    src_suffix = 'dot'
)
env.Append(BUILDERS = {'DotToPng' : build_png})
charms_png = Flatten(map(env.DotToPng, charms_dot))
##print "charms_png: ", [str(f) for f in charms_png]

################################################################
# Per-Charm-Tree HTML (from ASC; also depends on PNG and unique CSS)

build_html = Builder(
    action = '$ASCIIDOC --attribute=image-dir=./ --attribute=charm-image-ext=png --out-file=$TARGET $SOURCE',
    suffix = 'html',
    src_suffix = 'asc'
)
env.Append(BUILDERS = {'AscToHtml' : build_html})
charms_html = Flatten(map(env.AscToHtml, charms_asc))
##print "charms_html: ", [str(f) for f in charms_html]

# Record the additional dependency of the HTML files on the PNGs.  This relies
# on the fact that there's a 1-to-1 mapping, so we can just use Python's zip.
# We use Requires instead of Depends because we don't actually need to
# re-build the HTML for PNG changes.
for html, png in zip(charms_html, charms_png):
    Requires(html, png)

# Extra rules to add dependencies on CSS files.  We use Requires instead of
# Depends because we don't actually need to re-build the HTML for CSS changes.
for d in charms_html:
    Requires(d, protocol23_page_css_targets)

################################################################
# Per-Charm-Tree SVG (from YML)

#$(IMG_OUT)/%.svg: $(CHARMS_IN)/%.yml $(PROTOCOL23)/yaml2svg.rb $(PROTOCOL23_DEPS) $(IMG_OUT)
#	$(RUBY) $(PROTOCOL23)/yaml2svg.rb $< $@

env['YAML2SVG'] = os.path.join(env['PROTOCOL23'], 'yaml2svg.rb')
build_svg = Builder(
    action = '$RUBY $YAML2SVG $SOURCE $TARGET',
    suffix = 'svg',
    src_suffix = 'yml',
    emitter = make_add_script_dependency_emitter('YAML2SVG')
)
env.Append(BUILDERS = {'YamlToSvg' : build_svg})
charms_svg = Flatten(map(env.YamlToSvg, charms_yml_in_build))
##print "charms_svg: ", [str(f) for f in charms_svg]

################################################################
# Per-Charm-Tree dracula-based HTML (from YML)
#
# This produces a stand-alone HTML file which uses the "dracula" JavaScript
# library to produce a simple draggable representation of the Charm tree,
# for trying out specific layouts for PDF, to be encoded in the YAML files.


env['YAML2DRACULA'] = os.path.join(env['PROTOCOL23'], 'yaml2dracula.rb')
build_drac_html = Builder(
    action = '$RUBY $YAML2DRACULA $SOURCE $TARGET',
    suffix = 'drac.html',
    src_suffix = 'yml',
    emitter = make_add_script_dependency_emitter('YAML2DRACULA')
)
env.Append(BUILDERS = {'YamlToDracHtml' : build_drac_html})
charms_drac_html = Flatten(map(env.YamlToDracHtml, charms_yml_in_build))
##print "charms_drac_html: ", [str(f) for f in charms_drac_html]

# Extra rules to add dependencies on JavaScript libraries.  We use Requires
# instead of Depends because we don't actually need to re-build the HTML for
# JS changes.
DRAC_FILE_PATTERN = 'text/scripts/dracula/*'
EXTRA_DRAC_SOURCES = Glob('src/' + DRAC_FILE_PATTERN)
EXTRA_DRAC_TARGETS = Glob('build/' + DRAC_FILE_PATTERN)
drac_targets = map(
    lambda t, s: Command(t, s, Copy("$TARGET", "$SOURCE")),
    EXTRA_DRAC_TARGETS,
    EXTRA_DRAC_SOURCES
    )
for d in charms_drac_html:
    Requires(d, drac_targets)


################################################################
# Per-Charm-Tree BBCode text (from YML)
#
# For posting to the Exalted Forums :-)

#$(BBCODE_OUT)/%_bbcode.txt: $(CHARMS_IN)/%.yml $(PROTOCOL23)/yaml2bbcode.rb $(PROTOCOL23_DEPS) $(BBCODE_OUT)
#	$(RUBY) $(PROTOCOL23)/yaml2bbcode.rb $< $@
# # build_dot = Builder(
# #     '$RUBY $PROTOCOL23/yaml2bbcode.rb $SOURCE $TARGET',
# #     suffix='_bbcode.txt',
# #     src_suffix='yml'
# # )
# TODO 2013-03-10 hughg: Factor in script deps.
# TODO 2013-03-10 hughg: Will the suffix bit work, since it's not preceded by '.'?
# Could use 'X.bbcode.txt', I suppose.

################################################################

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

################################################################
# HTML

# Custom emitter to add dependencies on config files etc.
env['HTML_OUT'] = env['CHARMS_IN'].replace('src/', 'build/')
env['MAKEHTML'] = os.path.join(env['PROTOCOL23'], 'makehtml.rb')
build_html_main = Builder(
    action = '$RUBY $MAKEHTML $CHARMS_IN $HTML_OUT ${TARGET.file} $PROJECT_NAME'
)
env.Append(BUILDERS = {'BuildHtmlMain' : build_html_main})
html = env.BuildHtmlMain(
    '$HTML_OUT/charms.html',
    charms_yml,
    emitter = make_add_script_dependency_emitter('MAKEHTML')
)

# We also need to make the per-page HTML, and grab the overall CSS file.  We
# use Requires instead of Depends because we don't actually need to re-build
# the overall HTML if just the per-page HTML changes (e.g., if the script for
# generating the per-page HTML changes).
Requires(html, charms_html)
Requires(html, protocol23_basic_css_targets)


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

# Add other dependencies.  Here we really do want Depends, not Requires, since
# we need to rebuild the PDF if any of these things change.
#
# Really I should have a custom Scanner for Discordians.asc which works out
# the dependencies backwards, but I'll just forward-chain using "*.asc" for now.
Depends(book, 'src/text/book/Discordians-docinfo.xml')
Depends(book, Glob('src/text/book/*.asc'))
Depends(book, charms_asc)
Depends(book, charms_svg)

# Show the PDF after it builds.
env.AddPostAction(book, "$SHOW_PDF " + str(book[0].abspath))

################################################################

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

################################################################

#$(WW_WIKI_OUT)/$(MAINWIKI): 6_1_Whirling_Dervish_Style.txt ./makewiki.rb
#	./makewiki.rb . $(WW_WIKI_OUT) $(MAINWIKI)
