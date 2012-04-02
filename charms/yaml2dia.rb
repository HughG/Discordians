#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

def add_attr(node, name)
  yield(node.add_element("dia:attribute", { "name" => name }))
end

def add_typed_attr(node, name, type, value)
  add_attr(node, name) { |a|
    a.add_element("dia:#{type}", { "val" => value})
  }
end

class DiaObject
  attr_accessor :type, :obj_pos, :obj_bb

  def initialize(type, obj_pos, obj_bb)
    @type = type
    @obj_pos = obj_pos
    @obj_bb = obj_bb
  end

  def add_to_layer(node)
    obj = node.add_element("dia:object", { "type" => type })
    add_typed_attr(obj, "obj_pos", "point", obj_pos)
    add_typed_attr(obj, "obj_bb", "rectangle", obj_bb)
  end
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i

  File.open(outfilename, "w") { |outfile|
    doc = Document.new
    doc << XMLDecl.new("1.1", "utf-8")
    diagram = doc.add_element("dia:diagram")
    diagram.add_namespace("dia", "http://www.lysator.liu.se/~alla/dia/")
    diagramdata = diagram.add_element("dia:diagramdata")
    add_typed_attr(diagramdata, "background", "color", "#ffffff")
    layer = diagram.add_element "dia:layer", {
      "name" => "Background",
      "visible" => "true",
      "active" => "true"
    }
    obj = DiaObject.new("Geometric - Perfect Square",
                        "3.58226,9.2875",
                        "3.53226,9.2375;7.34476,13.1738")
    obj.add_to_layer(layer)

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
