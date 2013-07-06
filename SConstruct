import imp, os, string, sys

# See "Help" section at the end for some orientation.

################################################################
# Boostrapping

env = Environment()

# Building the book is slow, so don't build anything by default.
Default(None)

if len(COMMAND_LINE_TARGETS) == 0 and not GetOption('help'):
    print "Type 'scons -h' for a list of build targets and options."

AddOption(
    "--verbose",
    dest = 'verbose',
    action = 'store_true',
    help = 'Show verbose build information.'
)

def ShowParseProgress(message):
    if GetOption('verbose'):
        print "protocol23: " + message

################################################################


ShowParseProgress("start")

# Add the parent environment's path to our search path for tools.
env.Append(ENV = { 'PATH' : os.getenv('PATH') })

# Load machine-specific config, if it exists.  This can override defaults.
LOCAL_CONFIG_FULL_PATH = os.path.join('SConsLocal', 'Config.py')
if os.path.isfile(LOCAL_CONFIG_FULL_PATH):
    from SConsLocal.Config import Config
    Config(env)
    ShowParseProgress("read local config")

ShowParseProgress("considered local config")

# Load project-specific config, if it exists.  This can override defaults.
PROJECT_CONFIG_FULL_PATH = os.path.join('SConsProject', 'Config.py')
if os.path.isfile(PROJECT_CONFIG_FULL_PATH):
    from SConsProject.Config import Config
    Config(env)
    ShowParseProgress("read project config")

ShowParseProgress("considered project config")

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

ShowParseProgress("done default tools")

env['PROTOCOL23'] = 'src/protocol23/tools/yaml'
env['YAML2X'] = os.path.join(env['PROTOCOL23'], 'yaml2x.rb')

# SCons isn't smart enough to follow the dependency from each script to
# "yaml2x.rb", so we have to add that explicitly.  Ideally this would be done
# with a custom scanner to read the Ruby scripts recursively for dependencies.
def make_add_script_dependency_emitter(script_key):
    def add_script_dependency(target, source, env):
        return target, (source + [env[script_key], env['YAML2X']])
    return add_script_dependency

PROTOCOL23_CSS_IN = 'src/protocol23/text/html/'
PROTOCOL23_CSS_OUT = 'build/text/charms/'
PROTOCOL23_PAGE_CSS_FILE = 'protocol23-charm-page.css'
PROTOCOL23_BASIC_CSS_FILE = 'protocol23-basic-page.css'
PROTOCOL23_PAGE_CSS_SOURCES = [PROTOCOL23_CSS_IN + PROTOCOL23_PAGE_CSS_FILE]
PROTOCOL23_PAGE_CSS_TARGETS = [PROTOCOL23_CSS_OUT + PROTOCOL23_PAGE_CSS_FILE]
PROTOCOL23_BASIC_CSS_SOURCES = [PROTOCOL23_CSS_IN + PROTOCOL23_BASIC_CSS_FILE]
PROTOCOL23_BASIC_CSS_TARGETS = [PROTOCOL23_CSS_OUT + PROTOCOL23_BASIC_CSS_FILE]
protocol23_page_css_targets = map(
    lambda t, s: env.Command(t, s, Copy("$TARGET", "$SOURCE")),
    PROTOCOL23_PAGE_CSS_TARGETS,
    PROTOCOL23_PAGE_CSS_SOURCES
    )
protocol23_basic_css_targets = map(
    lambda t, s: env.Command(t, s, Copy("$TARGET", "$SOURCE")),
    PROTOCOL23_BASIC_CSS_TARGETS,
    PROTOCOL23_BASIC_CSS_SOURCES
    )

# Record charm input file paths (and equivalent paths in the output dir).
env['CHARMS_IN'] = 'src/text/charms/'
charms_yml = Glob(env['CHARMS_IN'] + '*.yml')
##print "charms_yml: ", [str(f) for f in charms_yml]
env['CHARMS_OUT'] = env['CHARMS_IN'].replace('src/', 'build/')
# NOTE 2013-06-30 HughG: We don't use "Glob(env['CHARMS_IN'] + '*.yml')"
# to define charms_yml_in_build, because there are no *.yml files in the
# output directory, so Glob will return an empty collection.  We just want
# a list of hypothetical filenames, to be modified elsewhere later.
charms_yml_in_build = [str(f).replace('src/', 'build/') for f in charms_yml]
##print "charms_yml_in_build: ", charms_yml_in_build

def add_protocol23_builder(
    builder_name,
    script_name,
    file_suffix
):
    env_var_name = script_name.upper()
    env[env_var_name] = os.path.join(env['PROTOCOL23'], script_name + '.rb')
    builder = Builder(
        action = ('$RUBY $%s $SOURCE $TARGET' % env_var_name),
        suffix = file_suffix,
        src_suffix = 'yml',
        emitter = make_add_script_dependency_emitter(env_var_name)
        )
    env.Append(BUILDERS = {builder_name : builder})
    # We can't just map the "builder" object directly as a method.  We have to
    # retrieve it as a property from "env", because there's lots of magic
    # in there somewhere.
    outputs = Flatten(map(env.__dict__[builder_name], charms_yml_in_build))
    ##print "Output for", builder_name, ":", map(str, outputs)
    return outputs


ShowParseProgress("done other env config")


# Build into a separate directory called "build".  We leave the default SCons
# behaviour of copying source files into the build directory, because we need
# that for AsciiDoc's "docinfo" feature to work, since we're generating part
# of the docinfo (the git version info) on the fly.
VariantDir('build', 'src')
# Clean the build directory whenever we're cleaning anything.  Otherwise
# empty dirs are left behind.
Clean('.', 'build')

ShowParseProgress("called VariantDir")


env.Install('distrib', Glob('*.pdf'))

ShowParseProgress("called Install")

################################################################

# .PHONY: clean tmpclean $(OUT)/version_info.in.txt

#clean:
#	-$(RM) $(OUT)
#
# TODO 2013-03-10 hughg: SCons says it auto-cleans, but will it really remove the output dir?

# tmpclean:
# 	-$(RM) src/*~ src/*/*~ $(OUT)/*~ $(OUT)/*/*~

################################################################
# Per-Charm-Tree DOT (from YML)

charms_dot = add_protocol23_builder('YamlToDot', 'yaml2dot', 'dot')

################################################################
# Per-Charm-Tree ASC (from YML)

charms_asc = add_protocol23_builder('YamlToAsc', 'yaml2asciidoc', 'asc')

################################################################
# Per-Charm-Tree PNG (from DOT)

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

charms_svg = add_protocol23_builder('YamlToSvg', 'yaml2svg', 'svg')

################################################################
# Per-Charm-Tree dracula-based HTML (from YML)
#
# This produces a stand-alone HTML file which uses the "dracula" JavaScript
# library to produce a simple draggable representation of the Charm tree,
# for trying out specific layouts for PDF, to be encoded in the YAML files.

charms_drac_html = \
    add_protocol23_builder('YamlToDracHtml', 'yaml2dracula', 'drac.html')

# Extra rules to add dependencies on JavaScript libraries.  We use Requires
# instead of Depends because we don't actually need to re-build the HTML for
# JS changes.
DRAC_FILE_PATTERN = 'protocol23/tools/dracula/*'
EXTRA_DRAC_SOURCES = Glob('src/' + DRAC_FILE_PATTERN)
EXTRA_DRAC_TARGETS = Glob('build/' + DRAC_FILE_PATTERN)
drac_targets = map(
    lambda t, s: env.Command(t, s, Copy("$TARGET", "$SOURCE")),
    EXTRA_DRAC_TARGETS,
    EXTRA_DRAC_SOURCES
    )
for d in charms_drac_html:
    Requires(d, drac_targets)

drac_alias = env.Alias('drac', charms_drac_html)

################################################################
# Per-Charm-Tree BBCode text (from YML)
#
# For posting to the Exalted Forums :-)

charms_bbcode = \
    add_protocol23_builder('YamlToBBCode', 'yaml2bbcode', 'bbcode.txt')
bbcode_alias = env.Alias('bbcode', charms_bbcode)


################################################################
# HTML

def html_emitter(target, source, env):
    script_dep_emitter = make_add_script_dependency_emitter('MAKEHTML')
    extra_targets = []
    for t in target:
        t_dir = str(t.dir)
        t_name = str(t.name)
        for prefix in [
            "index-by-division",
            "index-by-keyword",
            "index-by-tag",
            "index-by-type",
            "index-selector",
            "indices"
        ]:
            extra_targets.append(os.path.join(t_dir, prefix + "-for-" + t_name))
        extra_targets.append(os.path.join(t_dir, "intro.html"))
    return script_dep_emitter((target + extra_targets), source, env)

# NOTE 2013-06-30 hughg: The "${TARGET.file}" trick is documented in the man
# page under "Variable Substitution", but not in the user guide.

env['MAKEHTML'] = os.path.join(env['PROTOCOL23'], 'makehtml.rb')
build_html_main = Builder(
    action = '$RUBY $MAKEHTML $CHARMS_IN $CHARMS_OUT ${TARGET.file} $PROJECT_NAME',
    emitter = html_emitter
)
env.Append(BUILDERS = {'BuildHtmlMain' : build_html_main})
env['HTML_TARGET'] = '${CHARMS_OUT}charms.html'
html = env.BuildHtmlMain(
    env['HTML_TARGET'],
    charms_yml
)
html_alias = env.Alias('html', env['HTML_TARGET'])

# We also need to make the per-page HTML, and grab the overall CSS file.  We
# use Requires instead of Depends because we don't actually need to re-build
# the overall HTML if just the per-page HTML changes (e.g., if the script for
# generating the per-page HTML changes).
Requires(html, charms_html)
Requires(html, protocol23_basic_css_targets)


################################################################
# Version control information (for inclusion in PDF)

version_info_in = env.Command(
    'build/version_info.in.txt',
    [],
    './src/protocol23/tools/version-info/describe-git-status.bash >$TARGET'
)
# AlwaysBuild really means "always build if directly or indirectly specified
# as a target".  The point is that it ignores the up-to-date status of its
# inputs, when it's run.
AlwaysBuild(version_info_in)

# Whenever we generate the version info, read the line (minus line ending)
# into the 'env' construction environment, so the doc_info builder can use it.
def read_version_info_action(target, source, env):
    f = open(str(target[0]), 'r')
    try:
        env['VERSION_INFO'] = f.readline().rstrip()
        return None
    finally:
        f.close()
env.AddPostAction(version_info_in, read_version_info_action)

# This copy command produces the file which the PDF target actually depends on.
# The target file here isn't used directly, it's just used as an up-to-date
# check to trigger a re-build of the docinfo.xml.  This works because the SCons
# Copy does nothing if source and target have the same MD5, so this won't force
# the PDF to rebuild unless the source control info really has changed :-)
version_info = env.Command(
    'build/version_info.txt',
    version_info_in,
    Copy("$TARGET", "$SOURCE")
)

env['VERSION_STAMP_DOCINFO']='./src/protocol23/tools/version-info/version-stamp-docinfo.xslt'
doc_info = env.Command(
    'build/text/book/${PROJECT_NAME}-docinfo.xml',
    'src/text/book/${PROJECT_NAME}-docinfo.in.xml',
    '$XSLT --param version-info "\'$VERSION_INFO\'" $VERSION_STAMP_DOCINFO $SOURCE >$TARGET'
)
Depends(doc_info, version_info)


################################################################
# PDF

env['CHARM_DIR'] = \
    os.path.abspath(os.path.join('build', 'text', 'charms')) + os.sep
OFFO_HYPHENATION_JAR = 'src/protocol23/tools/fop/offo-hyphenation-binary/fop-hyph.jar'
env['ENV']['FOP_HYPHENATION_PATH'] = OFFO_HYPHENATION_JAR

# Custom emitter to add dependencies on config files etc.
EXTRA_PDF_SOURCES = [
    OFFO_HYPHENATION_JAR,
    Glob('src/protocol23/conf/asciidoc/*'),
    Glob('src/protocol23/conf/asciidoc/docbook-xsl/*'),
    Glob('src/protocol23/conf/fop/*'),
    Glob('src/protocol23/fonts/*/*'),
    Glob('build/text/book/*.asc')
    ]

def a2x_emitter(target, source, env):
    extra_targets = []
    for t in target:
        t_dir = str(t.dir)
        (t_base, t_ext) = os.path.splitext(str(t.name))
        extra_targets.append(os.path.join(t_dir, t_base + ".fo"))
        extra_targets.append(os.path.join(t_dir, t_base + ".xml"))
    return (target + extra_targets), (source + EXTRA_PDF_SOURCES)

env['A2X_VERBOSE'] = '-vv' if GetOption('verbose') else ''
build_pdf = Builder(
    action = '$A2X $A2X_VERBOSE -k --asciidoc-opts "--conf-file=src/protocol23/conf/asciidoc/docbook45.conf --attribute=image-dir=$CHARM_DIR --attribute=charm-image-ext=svg --attribute=charm-dir=$CHARM_DIR" -f pdf --fop --xsl-file=src/protocol23/conf/asciidoc/docbook-xsl/fo.xsl --fop-opts "-c src/protocol23/conf/fop/fop.xconf -d" -D ${TARGET.dir} $SOURCE',
    suffix = 'pdf',
    src_suffix = 'asc',
    emitter = a2x_emitter
)
env.Append(BUILDERS = {'AscToPdf' : build_pdf})

PDF_TARGET_WITHOUT_EXT = 'build/text/book/${PROJECT_NAME}'
env['PDF_TARGET'] = PDF_TARGET_WITHOUT_EXT + ".pdf"
book = env.AscToPdf(PDF_TARGET_WITHOUT_EXT)
book_alias = env.Alias('book', env['PDF_TARGET'])
pdf_alias = env.Alias('pdf', env['PDF_TARGET'])

# Add other dependencies.  Here we really do want Depends, not Requires, since
# we need to rebuild the PDF if any of these things change.
#
# Really I should have a custom Scanner for ${PROJECT_NAME}.asc which works out
# the dependencies backwards, but I'll just forward-chain using "*.asc" for now.
Depends(book, env.subst('build/text/book/${PROJECT_NAME}-docinfo.xml'))
Depends(book, charms_asc)
Depends(book, charms_svg)
Depends(book, doc_info)

# Show the PDF after it builds.
env.AddPostAction(book, "$SHOW_PDF " + str(book[0].abspath))

################################################################
# Stats on the Charms

def stats_emitter(target, source, env):
    script_dep_emitter = make_add_script_dependency_emitter('YAML2STATS')
    extra_targets = [
        os.path.join(str(t.dir), "division_" + str(t.name)) \
            for t in target
    ]
    return script_dep_emitter((target + extra_targets), source, env)

# NOTE 2013-06-30 hughg: Can't just use add_protocol23_builder here because
# there's one target an multiple sources, so the target comes first.  Might
# refactor all scripts to be target-first, or use an options, one day.
env['YAML2STATS'] = os.path.join(env['PROTOCOL23'], 'yaml2stats.rb')
build_stats = Builder(
    action = '$RUBY $YAML2STATS $TARGET $SOURCE',
    emitter = stats_emitter
)
env.Append(BUILDERS = {'BuildStats' : build_stats})
env['STATS_TARGET'] = '${CHARMS_OUT}stats.txt'
stats = env.BuildStats(
    env['STATS_TARGET'],
    charms_yml
)
stats_alias = env.Alias('stats', env['STATS_TARGET'])

################################################################

#$(WW_WIKI_OUT)/$(MAINWIKI): 6_1_Whirling_Dervish_Style.txt ./makewiki.rb
#	./makewiki.rb . $(WW_WIKI_OUT) $(MAINWIKI)

################################################################

env.Alias('charms', [
    html_alias,
    drac_alias,
    stats_alias,
    bbcode_alias
])

env.Alias('all', [
    html_alias,
    drac_alias,
    book_alias,
    stats_alias,
    bbcode_alias
])

ShowParseProgress("set up all targets")

################################################################
# Help.  (This comes at the end so we can include output path details.)

Help(env.subst("""
Type 'scons <options> <build target[s]>' for one or more of these Build Targets.

Options:
    --verbose   Show verbose build information.

Build Targets:

    html    An HTML frameset showing all Charms with tree diagrams.
              ${HTML_TARGET}

    drac    HTML files with draggable Charm trees, for choosing layouts.
              ${CHARMS_OUT}*.drac.html

    pdf
    book    The whole book as a PDF (slow).
              $PDF_TARGET

    stats   Statistics about the Charms.
              $STATS_TARGET

    bbcode  Charms in BBCode format, for posting to the Exalted Forums.
              ${CHARMS_OUT}*.bbcode.txt

    charms  Targets covering just Charms: html, drac, stats, bbcode.

    all     All of the above.

Type 'scons -c .' to clean everything, including empty build directories.
""", raw = 1)) # 'raw = 1' preserves whitespace

################################################################
