#! /opt/local/bin/ruby

$KCODE = "u"

def beads(bead, no_bead, count)
  result = ""
  (1..5).each { |i|
    if i <= count
      result += bead
    elsif i <= 5
      result += no_bead
    end
    if i < 5
      result += " "
    end
  }
  result
end

def makedot(infilename, outfilename)

  charms = []
  deps = []
  curr_charm = {}

  IO.foreach(infilename) { |line|
    md = /^([a-z]+): (.*)$/.match(line)
    if md and md.length == 3
      case md[1]
      when "name"
        name_split = md[2].split(", ")
        curr_charm = { "id" => name_split[0], "name" => name_split[1] }
        curr_charm["min_abil"] = ""
        curr_charm["min_ess"] = ""
        curr_charm["deps"] = ""
      when "mins"
        mins_md = /[A-Za-z]+ ([0-9]), [A-Za-z]+ ([0-9])/.match(md[2])
        if mins_md and mins_md.length == 3
          curr_charm["min_abil"] = beads("•", "¤", mins_md[1].to_i)
          curr_charm["min_ess"] = beads("•", "¤", mins_md[2].to_i)
        end
      when "dep"
        md[2].split(", ").each { |dep|
          deps = deps.push([dep, curr_charm["id"]])
        }
        curr_charm["deps"] = md[2]
      when "text"
        if curr_charm["deps"].empty?
          curr_charm["name"] = curr_charm["name"].upcase
        end
        curr_charm["name"] = curr_charm["name"].sub(/\*/, '\\n')
        charms.push(curr_charm)
      end
    end
  }

  File.open(outfilename, "w") { |out|
    out.print "digraph foo {\n"
    out.print "\tnode [shape=Mrecord,fontname=Palatino,fontsize=10,width=1.9,height=1,fixedsize];"
    charms.each { |charm|
      next if charm["name"] == "."
      out.print(
                "\t", charm["id"], ' [label="{',
                charm["min_ess"], "|",
                charm["name"], "|",
                charm["min_abil"],
                '}"];', "\n"
                )
    }
    deps.each { |dep|
      out.print("\t", dep[0], " -> ", dep[1], ";\n")
    }
    out.print "}\n"
  }
end
