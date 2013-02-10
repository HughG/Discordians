#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require File.expand_path(File.dirname(__FILE__)) + "/yaml2x.rb"

def make_pretty_type(charm_type)
  pretty_type = charm_type[0]
  if charm_type.length > 1
    pretty_type += " (" + charm_type[1] + ")"
  end
  return pretty_type
end

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    out.puts("[[#{charm.safe_group}_#{charm.id}]]")
    out.puts("===== #{charm.clean_name}")
    mins = charm.mins.map { |min| min.join(" ") }.join(", ")
    first_type = charm.type[0]
    pretty_type = nil
    types_for_index = nil
    if first_type.is_a? Array
      pretty_type = charm.type.map { |t| make_pretty_type(t) }.join(", or ")
      types_for_index = charm.type.map {|alt_type| alt_type[0]}
    else
      pretty_type = make_pretty_type(charm.type)
      types_for_index = charm.type[0..0]
    end
    out.puts("[role=\"noindent\"]")
    # Add index entry for interesting types
    interesting_types = types_for_index.reject {
      |t| ["Simple", "Reflexive", "Supplemental"].include?(t)
    }
    interesting_types.each { |type|
      out.print("indexterm:[charm-by-type, #{type}, #{charm.clean_name} (#{charm.group})]")
    }
    # Add index entry for any interesting keywords
    interesting_keys = charm.keys.reject {
      |k| ["Combo-Basic", "Combo-OK", "None"].include?(k)
    }
    interesting_keys.each { |key|
      out.print("indexterm:[charm-by-keyword, #{key}, #{charm.clean_name} (#{charm.group})]")
    }
    # Add index entry for each tag
    if charm.tags then
      charm.tags.each { |tag|
        out.print("indexterm:[charm-by-tag, #{tag}, #{charm.clean_name} (#{charm.group})]")
      }
    end
    # Need to have no line break after the last use of the indexterm macro, or
    # we get a space at the start of the paragraph.
    out.print("indexterm:[charm, #{charm.clean_name} (#{charm.group})]")
    out.puts("*Cost:* #{charm.cost}; " +
             "*Mins:* #{mins}; " +
             "*Type:* #{pretty_type} +")
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
  end
  out.puts
  # We never want explict line breaks in Charm text, so automagically escape
  # any '+' at the end of a line.
  fixed_text = charm.text.gsub(/\+\s*$/,'&#x2b;')
  out.puts(fixed_text)
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

    process_file(filename) { |group, charms, layouts|
      outfile.puts("indexterm:[-, Charms, #{division_name}, #{group.name}]")
      outfile.puts('[options="pgwide"]')
      imgfilename = File.basename(filename).sub(/\.yml/, ".{charm-image-ext}")
      outfile.puts("image::{image-dir}#{imgfilename}[#{group.name} Charm Tree]")
      outfile.puts

      outfile.puts("==== " + group.name)
      outfile.puts

      # We never want explict line breaks in CharmGroup text, so automagically
      # escape any '+' at the end of a line.
      fixed_text = group.text && group.text.gsub(/\+\s*$/,'&#x2b;')
      outfile.puts(fixed_text)
      outfile.puts

      charms.each_value { |charm|
        insert_charm(outfile, group.name, charms, charm)
      }
    }
  }
end
