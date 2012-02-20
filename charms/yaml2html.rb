#! /opt/local/bin/ruby1.9

require "psych"
require "./yaml2x"

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    out.print("<a name='#{charm.id}'/>\n")
    out.print("<h3>#{charm.name}</h3>\n<p>")
    out.print("<b>Cost:</b> #{charm.cost}; ")
    out.print("<b>Mins:</b> #{charm.mins}; ")
    out.print("<b>Type:</b> #{charm.type}<br/>")
    out.print("<b>Keywords:</b> #{charm.keys}<br/>")
    out.print("<b>Duration:</b> #{charm.dur}<br/>")
    out.print("<b>Prerequisite Charms:</b> ")
    deps = charm.deps
    if deps.empty?
      out.print("None")
    else
      charm.deps.map {|d| charms[d].name}.join(", ")
    end
    out.print("</p>\n")
  end
#   charm.text.each { |para|
#     out.print("<p>#{para}</p>\n")
#   }
  out.print("<p>#{charm.text}</p>\n")
end

if __FILE__ == $PROGRAM_NAME
  puts $PROGRAM_NAME + "..."
  filename = "./output_yaml/1_3_Martial_Arts.yml"
#  filename = "./output_yaml/3_5_War.yml"
  process_file(filename) { |group_name, charms|
    charms.each_value { |charm|
      insert_charm($stdout, group_name, charms, charm)
    }
  }
end
