#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require File.expand_path(File.dirname(__FILE__)) + "/yaml2x"

def beads(bead, no_bead, count)
  bead_array = ([bead] * count) + ([no_bead] * (5 - count))
  bead_array.join(" ")
end

def insert_charm(out, trait_name, charms, charm)
  #p charm

  return if charm.name == "."

  min_ess = ""
  min_trait = ""
  if charm.mins
    min_ess = beads("×", "¤", charm.mins['Essence'].to_i)
    min_trait = beads("×", "¤", charm.mins[trait_name].to_i)
  end
  deps = charm.deps
  has_deps = (deps and not deps.empty?)
  charm_name = if has_deps then charm.name else charm.name.upcase end
  charm_name.gsub!(/\>/, '\\n')
  out.puts("\t#{charm.id} [label=<{#{min_ess}|#{charm_name}|#{min_trait}}>];")
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

  File.open(outfilename, "w:UTF-8") { |outfile|
    outfile.puts("digraph foo {")
    outfile.puts("\tnode [shape=Mrecord,fontname=Libertinage,fontsize=10,width=1.9,height=1,fixedsize];")

    process_file(filename) { |group, charms, layouts|
      charms.each_value { |charm|
        insert_charm(outfile, group.trait, charms, charm)
      }
    }

    outfile.puts("}")
  }
end
