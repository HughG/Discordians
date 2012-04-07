#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

def make_style hash
  hash.map {|k,v| "#{k}: #{v}"}.join "; "
end

def make_path arr
  arr.map {|c| "#{c[0]},#{c[1]}"}.join " "
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i

  File.open(outfilename, "w") { |outfile|
    doc = Document.new
    doc << XMLDecl.new("1.0", "utf-8")
    doc << DocType.new("svg", 'PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/PR-SVG-20010719/DTD/svg10.dtd"')
    svg = doc.add_element("svg")
    svg.add_namespace("http://www.w3.org/2000/svg")
    svg.add_namespace("xlink", "http://www.w3.org/1999/xlink")
    box = svg.add_element("g")
    poly = box.add_element "polygon", {
      "style" => make_style({
        "fill" => "#fae88a",
        "fill-opacity" => "0",
        "stroke" => "#dcc593",
        "stroke-width" => "0.015",
      }),
      "points" => make_path([[0,4], [18,4], [14,0], [84,0]])
    }
#     poly
#     add_typed_attr(diagramdata, "background", "color", "#ffffff")
#     layer = svg.add_element "dia:layer", {
#       "name" => "Background",
#       "visible" => "true",
#       "active" => "true"
#     }
#     obj = DiaObject.new("Geometric - Perfect Square",
#                         "3.58226,9.2875",
#                         "3.53226,9.2375;7.34476,13.1738")
#     obj.add_to_layer(layer)

    doc.write(outfile, 1)

#     outfile.puts(":doctype: book")
#     outfile.puts(":themedir: ..")
#     outfile.puts(":theme: discordians")
#     outfile.puts(":linkcss:")
#     outfile.puts

#     xml.favorites do 
#       favorites.each do | name, choice |
#         xml.favorite( choice, :item => name )
#       end
#     end


    process_file(filename) { |group_name, charms|
#       outfile.puts("indexterm:[-, Charms, #{division_name}, #{group_name}]")
#       outfile.puts('[options="pgwide"]')
#       pngfilename = File.basename(filename).sub(/\.yml/, ".png")
#       outfile.puts("image::./output/#{pngfilename}[#{group_name} Charm Tree]")
#       outfile.puts

#       outfile.puts("==== " + group_name)
#       outfile.puts

#       charms.each_value { |charm|
#         insert_charm(outfile, group_name, charms, charm)
#       }
    }
  }
end
