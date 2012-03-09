#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require "./yaml2x"

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    # out.puts("<a name='#{charm.id}'/>\n")
    out.puts("==== #{charm.name}")
    mins = charm.mins.map { |min| min.join(" ") }.join(", ")
    type = charm.type[0]
    if charm.type.length > 1
      type += " (" + charm.type[1] + ")"
    end
    out.puts("*Cost:* #{charm.cost}; " +
             "*Mins:* #{mins}; " +
             "*Type:* #{type} +")
    out.puts("*Keywords:* #{charm.keys.join(', ')} +")
    out.puts("*Duration:* #{charm.dur} +")
    out.print("*Prerequisite Charms:* ")
    deps = charm.deps
    if deps.empty?
      out.print("None")
    else
      out.print(charm.deps.map {|d| charms[d].name.delete("()")}.join(", "))
    end
    out.puts(" +")
  end
  out.puts
  out.puts("#{charm.text}")
  out.puts
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  File.open(outfilename, "w") { |outfile|
    outfile.puts(":doctype: book")
    outfile.puts

    process_file(filename) { |group_name, charms|
      outfile.puts("=== " + group_name)
      outfile.puts

      charms.each_value { |charm|
        insert_charm(outfile, group_name, charms, charm)
      }
    }
  }
end
