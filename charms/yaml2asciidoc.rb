#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require "./yaml2x"

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    out.puts("[[#{charm.safe_group}_#{charm.id}]]")
    out.puts("===== #{charm.clean_name}")
    mins = charm.mins.map { |min| min.join(" ") }.join(", ")
    type = charm.type[0]
    if charm.type.length > 1
      type += " (" + charm.type[1] + ")"
    end
    out.puts("[role=\"noindent\"]")
    # Need to have no line break after the indexterm macro, or we get a space
    # at the start of the paragraph.
    out.print("indexterm:[charm, #{charm.clean_name} (#{charm.group})]")
    cost = charm.cost
    if cost == "--" then
      cost = "--&#x200B;"
    end
    out.puts("*Cost:* #{charm.cost}; " +
             "*Mins:* #{mins}; " +
             "*Type:* #{type} +")
    out.puts("*Keywords:* #{charm.keys.join(', ')} +")
    out.puts("*Duration:* #{charm.dur} +")
    out.print("*Prerequisite Charms:* ")
    deps = charm.deps
    if not deps or deps.empty?
      out.print("None")
    else
      out.print(charm.deps.map {|d|
                  dep_charm = charms[d]
                  # dep_charm is None if someone's put in a non-existent Charm
                  # id to indicate that a Charm should have some
                  # as-yet-undecided prerequisite.
                  if dep_charm
                    charms[d].clean_name.delete("()")
                  else
                    "*#{d}*"
                  end
                }.join(", "))
    end
    out.puts
    # out.puts(" +")
  end
  out.puts
  out.puts("#{charm.text}")
  out.puts
end

division_ordinals = ["1st", "2nd", "3rd", "4th", "5th"]
division_names = ["Anchor", "Arrow", "Apple", "Archway", "Anvil"]

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  matches = /([0-9])_.*/.match(outfilename)
  division = matches[1].to_i
  division_name =
    if division < 6 then
      idx = division - 1
      "#{division_ordinals[idx]} Division (#{division_names[idx]})"
    else
      "Martial Arts"
    end

  File.open(outfilename, "w") { |outfile|
#     outfile.puts(":doctype: book")
    outfile.puts(":themedir: ..")
    outfile.puts(":theme: discordians")
    outfile.puts(":linkcss:")
    outfile.puts

    process_file(filename) { |group_name, charms, layouts|
      outfile.puts("indexterm:[-, Charms, #{division_name}, #{group_name}]")
      outfile.puts('[options="pgwide"]')
      imgfilename = File.basename(filename).sub(/\.yml/, ".{charm-image-ext}")
      outfile.puts("image::{image-dir}#{imgfilename}[#{group_name} Charm Tree]")
      outfile.puts

      outfile.puts("==== " + group_name)
      outfile.puts

      charms.each_value { |charm|
        insert_charm(outfile, group_name, charms, charm)
      }
    }
  }
end
