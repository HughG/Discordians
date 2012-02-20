#! /opt/local/bin/ruby1.9

require "psych"
require "./yaml2x"

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    # out.puts("<a name='#{charm.id}'/>\n")
    out.puts("== #{charm.name}")
    out.puts("*Cost:* #{charm.cost}; " +
             "*Mins:* #{charm.mins}; " +
             "*Type:* #{charm.type} +")
    out.puts("*Keywords:* #{charm.keys.join(', ')} +")
    out.puts("*Duration:* #{charm.dur} +")
    out.print("*Prerequisite Charms:* ")
    deps = charm.deps
    if deps.empty?
      out.print("None")
    else
      out.print(charm.deps.map {|d| charms[d].name}.join(", "))
    end
    out.puts(" +")
  end
#   charm.text.each { |para|
#     out.puts("<p>#{para}</p>\n")
#   }
  out.puts
  out.puts("#{charm.text}")
  out.puts
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = "./output_yaml/1_3_Martial_Arts.yml"
#  filename = "./output_yaml/3_5_War.yml"

  outfile = $stdout

  process_file(filename) { |group_name, charms|
    outfile.puts("= " + group_name)
    outfile.puts(":doctype: book")
    outfile.puts

    charms.each_value { |charm|
      insert_charm(outfile, group_name, charms, charm)
    }
  }
end
