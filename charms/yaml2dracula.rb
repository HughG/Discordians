#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require "./yaml2x"

def beads(bead, no_bead, count)
  bead_array = ([bead] * count) + ([no_bead] * (5 - count))
  bead_array.join(" ")
end

def insert_charm(out, section_name, charms, charm)
  #p charm

  return if charm.name == "."

  deps = charm.deps
  has_deps = (deps and not deps.empty?)
  #charm_name = if has_deps then charm.name else charm.name.upcase end
  #charm_name.gsub!(/\>/, '\\n')
  #out.puts("\t#{charm.id} [label=\"{#{min_ess}|#{charm_name}|#{min_att}}\"];")
  if has_deps
    deps.each { |dep|
      out.puts "g.addEdge(\"#{dep}\", \"#{charm.id}\", {\"directed\": true});"
    }
  else
  end
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  File.open(outfilename, "w") { |outfile|
    outfile.puts """
<html><head>
<meta http-equiv='content-type' content='text/html; charset=ISO-8859-1'></head><body><header>
    <script type='text/javascript' src='dracula/raphael-min.js'></script>
    <script type='text/javascript' src='dracula/graffle.js'></script>
    <script type='text/javascript' src='dracula/graph.js'></script>
    <script type='text/javascript'>
<!--

var redraw;
var height = 600;
var width = 600;

/* only do all this when document has finished loading (needed for RaphaelJS */
window.onload = function() {

    var g = new Graph();
"""

    process_file(filename) { |group_name, charms|
      charms.each_value { |charm|
        insert_charm(outfile, group_name, charms, charm)
      }
    }

    outfile.puts """

    /* layout the graph using the Spring layout implementation */
    var layouter = new Graph.Layout.Spring(g);
    layouter.layout();
    
    /* draw the graph using the RaphaelJS draw implementation */
    var renderer = new Graph.Renderer.Raphael('canvas', g, width, height);
    renderer.draw();
    
    redraw = function() {
        layouter.layout();
        renderer.draw();
    };
};

-->
    </script>
</header>

<div id='canvas'></div>
<button id='redraw' onclick='redraw();'>redraw</button>

</body></html>
"""
  }
end
