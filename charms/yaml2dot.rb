#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require "./yaml2x"

def beads(bead, no_bead, count)
  bead_array = ([bead] * count) + ([no_bead] * (5 - count))
  bead_array.join(" ")
end

def insert_charm(out, section_name, charms, charm)
  #p charm

  return if charm.name == "."

  min_ess = ""
  min_att = ""
  if charm.mins
    essence = charm.mins['Essence']
    if essence.nil?
      essence = charm.mins['Ess']
    end
    min_ess = beads("•", "¤", essence.to_i)
    min_att = beads("•", "¤", charm.mins[section_name].to_i)
  end
  deps = charm.deps
  has_deps = (deps and not deps.empty?)
  charm_name = if has_deps then charm.name else charm.name.upcase end
  charm_name.gsub!(/\>/, '\\n')
  out.puts("\t#{charm.id} [label=\"{#{min_ess}|#{charm_name}|#{min_att}}\"];")
  if has_deps
    deps.each { |dep|
      out.print("\t", dep, " -> ", charm.id, ";\n")
    }
  else
  end
end

if __FILE__ == $PROGRAM_NAME
#  puts $PROGRAM_NAME + "..."
  filename = $*[0]
  outfilename = $*[1]

  File.open(outfilename, "w") { |outfile|
    outfile.puts("digraph foo {")
    outfile.puts("\tnode [shape=Mrecord,fontname=Palatino,fontsize=10,width=1.9,height=1,fixedsize];")

    process_file(filename) { |group_name, charms, layouts|
      charms.each_value { |charm|
        insert_charm(outfile, group_name, charms, charm)
      }
    }

    outfile.puts("}")
  }
end
