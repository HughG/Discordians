#! /opt/local/bin/ruby1.9

require "rexml/document"
require "./yaml2x.rb"

include REXML

class Object
  @@dia_attrs = {}

  def self.dia_attr_accessor accessors
    attr_accessor accessors.keys
    dia_attrs.merge!(accessors)
  end

  def self.dia_type(dia_attr_symbol)
    @@dia_attrs[dia_attr_symbol]
  end
end

def add_attr(node, name)
  yield(node.add_element("dia:attribute", { "name" => name }))
end

def add_typed_attr(node, name, type, value)
  add_attr(node, name) { |a|
    a.add_element("dia:#{type}", { "val" => value})
  }
end

class DiaObject
  dia_attr_accessor {
    :type => None,
    :obj_pos => "point",
    :obj_bb => "rectangle"
  }

  def initialize(type, obj_pos, obj_bb)
    @type = type
    @obj_pos = obj_pos
    @obj_bb = obj_bb
  end

  def add_to_layer(node)
    obj = node.add_element("dia:object", { "type" => type })
    add_attr(obj, :obj_pos)
    add_attr(obj, :obj_bb)
  end

  protected
  def add_attr(obj, attr_sym, attr_value)
    attr_str = attr_sym.to_s
    attr_variable_sym = ("@" + attr_str).to_sym
    add_typed_attr(obj,
                   attr_symbol.to_s,
                   dia_type(attr_symbol),
                   instance_variable_get(attr_variable_sym))
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
