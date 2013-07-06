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

def unwrap_paragraphs(text)
  fixed_text = text.gsub(/\n{2,2}/,"QQQQ")
  fixed_text = fixed_text.gsub(/\n{1,1}/," ")
  fixed_text = fixed_text.gsub(/QQQQ/,"\n\n")
  fixed_text
end

def insert_charm(out, section_name, charms, charm)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.is_placeholder
  if charm.name != '.'
    out.puts("[b]#{charm.clean_name}[/b]")
    out.print("[SPOILER]")
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
    out.puts("[b]Cost:[/b] #{charm.cost}; " +
             "[b]Mins:[/b] #{mins}; " +
             "[b]Type:[/b] #{pretty_type}")
    out.puts("[b]Keywords:[/b] #{charm.keys.join(', ')}")
    out.puts("[b]Duration:[/b] #{charm.dur}")
    out.print("[b]Prerequisite Charms:[/b] ")
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
                    "[b]#{d}[/b]"
                  end
                }.join(", "))
    end
    out.puts
  end
  out.puts
  out.puts(unwrap_paragraphs(charm.text))
  out.puts("[/SPOILER]")
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
    process_file(filename) { |group, charms, layouts|
      outfile.puts("[size=7][b]" + group.name + "[/b][/size]")
      outfile.puts

      if group.text then
        outfile.puts(unwrap_paragraphs(group.text))
        outfile.puts
      end

      charms.each_value { |charm|
        insert_charm(outfile, group.name, charms, charm)
      }
    }
  }
end
