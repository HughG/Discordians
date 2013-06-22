#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require File.expand_path(File.dirname(__FILE__)) + "/yaml2x"

def beads(bead, no_bead, count)
  bead_array = ([bead] * count) + ([no_bead] * (5 - count))
  bead_array.join(" ")
end

def add_node(out, trait_name, charms, charm)
  min_trait = 1
  min_ess = 1
  if charm.mins
    min_trait = charm.mins[trait_name].to_i
    min_ess = charm.mins['Essence'].to_i
  end
  out.puts "g.addNode(" +
    "\"#{charm.id}\", " +
    "{\"label\": \"#{charm.id} #{min_trait}/#{min_ess}\"}" +
    ");"
end

def add_edges(out, charms, charm)
  deps = charm.deps
  has_deps = (deps and not deps.empty?)
  if has_deps
    deps.each { |dep|
      out.puts "g.addEdge(\"#{dep}\", \"#{charm.id}\", {\"directed\": true});"
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  filename = $*[0]
  outfilename = $*[1]

  File.open(outfilename, "w") { |outfile|
    outfile.puts """
<html><head>
<meta http-equiv='content-type' content='text/html; charset=ISO-8859-1'></head><body><header>
    <script type='text/javascript' src='../scripts/dracula/raphael-min.js'></script>
    <script type='text/javascript' src='../scripts/dracula/graffle.js'></script>
    <script type='text/javascript' src='../scripts/dracula/graph.js'></script>
    <script type='text/javascript'>
<!--

var redraw;
var height = 600;
var width = 600;

/* only do all this when document has finished loading (needed for RaphaelJS */
window.onload = function() {

    var g = new Graph();
"""

    process_file(filename) { |group, charms|
      charms.each_value { |charm|
        add_node(outfile, group.trait, charms, charm)
      }
      charms.each_value { |charm|
        add_edges(outfile, charms, charm)
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
