#! /opt/local/bin/ruby1.9

# $KCODE = "u"

def insert_charm(out, charm, file_name_prefix, ma_style_name)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  return if charm['name'][0] == '('[0]
  if charm['name'] == '.'
    charm['text'].each { |para|
      if para[0..1] == "> "
        para[0..1] = ""
        para = "<div style='background-color: silver; border: 2px solid black; padding: 0.5em 1em; margin: 0em 1em; text-style: italic'>\n" + para + "</div>"
      end
      out.print(para)    }
    return
  end

  is_ma = (ma_style_name != nil)
  file_name = file_name_prefix + "__" + charm['name'] + "_wiki.txt"
  File.open(file_name, "w") { |charm_out|
    charm_out.print("{{2e" + (is_ma ? "TMA" : "Sol") + "Charm|\n")
    charm_out.print("|source=Shuuji\n")
    charm_out.print("|trait=#{is_ma ? ma_style_name : charm['trait']}\n")
    charm_out.print("|name=#{charm['name']}\n")
    charm_out.print("|cost=#{charm['cost']}\n")
    charm_out.print("|type=#{charm['type']}\n")
    charm_out.print("|duration=#{charm['dur']}\n")
    charm_out.print("|keywords=#{charm['key']}\n")
    charm_out.print("|essence=#{charm['ess_min']}\n")
    charm_out.print("|min=#{charm['trait_min']}\n")
    dep_index = 1
    deps = charm['dep']
    if !(deps.empty?)
      first = true
      charm['dep'].each { |dep_name|
        charm_out.print("|pc#{dep_index}=#{dep_name}\n")
        dep_index += 1
      }
    end
    charm_out.print("|text=\n")
    charm['text'].each { |para|
      if para[0..1] == "> "
        para[0..1] = ""
        para = "<div style='background-color: silver; border: 2px solid black; padding: 0.5em 1em; margin: 0em 1em; font-style: italic'>\n" + para + "</div>"
      end
      charm_out.print(para)
    }
    charm_out.print("{{Source|[[User:Shuuji|]]}}\n")
    charm_out.print("}}")
  }
end

def insert_file(out, file, file_name_prefix, ma_style_name)
  charm_names = {}
  charm_order = []
  curr_charm = {}
  curr_para = ""

  $stderr << file << "\n"

  IO.foreach(file, encoding: 'iso-8859-1') { |line|
    # Strip DOS line endings
    line.chomp!

    # $stderr << "{" << line << "}\n"

    md = /^([a-z]+): *(.*)$/.match(line)
    if md and md.length == 3
      case md[1]
      when "name"
        insert_charm(out, curr_charm, file_name_prefix, ma_style_name)

        name_split = md[2].split(", ")
        id = name_split[0]
        name = name_split[1].tr('*', ' ')
        curr_charm = { "id" => id, "name" => name }
        if name[0] == "("
          name = name.delete "()"
        end
        charm_names[id] = name
        charm_order << id
        curr_charm["dep"] = []
      when "cost", "type", "key", "dur"
        curr_charm[md[1]] = md[2]
      when "mins"
        curr_charm[md[1]] = md[2]
        mins_md = /(.+) ([0-9]), .+ ([0-9])/.match(md[2])
        curr_charm["trait"] = mins_md[1]
        curr_charm["trait_min"] = mins_md[2]
        curr_charm["ess_min"] = mins_md[3]
      when "dep"
        deps = []
        md[2].split(", ").each { |dep|
          deps = deps.push(charm_names[dep])
        }
        curr_charm["dep"] = deps
      when "text"
        curr_charm["text"] = []
        curr_para = md[2] + "\n"
      end
    else
      if line.empty?
        if not curr_para.empty?
          curr_charm["text"].push(curr_para)
        end
        curr_para = ""
      else
        curr_para += " " + line
      end
    end
  }
  if not curr_para.empty?
    curr_charm["text"].push(curr_para)
  end

  insert_charm(out, curr_charm, file_name_prefix, ma_style_name)

  out.print("\n")
  charm_order.each { |id|
    out.print("{{Charms:#{charm_names[id]}}}\n") if id != "intro"
  }
  out.print("\n")
end

def make_wiki(indir, outdir, outfilename)
#   File.open(outdir + "/" + outfilename, "w") { |out|
#     out.print("<html><head><title>Discordian Charms</title></head>\n")
#     out.print("<style type='text/css'>")
#     out.print("* { font-family: Palatino, Times, serif }")
#     out.print("h1, h2, h3, h4, h5, h6 { font-family: 'American Typewriter', Courier, mono }")
#     out.print("</style></head>\n<body>\n")
#     out.print("<h1>Discordian Charms</h1>\n")

#     Dir[indir + "/?_?_*.txt"].each { |file|
#       section_name = /[0-9]_[0-9]_([A-Za-z_]+)/.match(file)[1].tr('_', " ")
#       pngfile = File.basename(file).sub(/\.txt/, ".png")
#       out.print("<h2>", section_name, "</h2>\n")
#       out.print("<img src='", pngfile, "'/>\n")

#       insert_file(out, file)
#     }

#     out.print("</body></html>")
#   }

#   File.open(outdir + "/framed-" + outfilename, "w") { |out|
#     out.print("<html><head><title>Discordian Charms</title></head>\n")
#     out.print("<frameset cols='15%, 85%'>\n")
#     out.print("<frame src='index-", outfilename, "'/>\n")
#     out.print("<frame name='text' src='intro.html'/>\n")
#     out.print("</frameset></html>\n")
#   }

  File.open(outdir + "/index-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms</title></head>\n")
    out.print("<style type='text/css'>")
    out.print("* { font-family: Palatino, Times, serif }")
    out.print("h1, h2, h3, h4, h5, h6 { font-family: 'American Typewriter', Courier, mono; font-size: small }")
    out.print("</style></head>\n<body>\n")
    out.print("<h2>Discordian Charms</h2>\n")

    Dir[indir + "/?_?_*.txt"].each { |file|
      matches = /([0-9])_([0-9])_([A-Za-z_]+)/.match(file)
      division = matches[1].to_i
      subsec = matches[2].to_i
      if (subsec == 1)
        if (division == 6)
          out.print("<h3>Martial Arts</h3>")
        else
          out.print("<h3>", division,
                   (division == 1) ? "st" :
                   ((division == 2) ? "nd" :
                    ((division == 3) ? "rd" : "th")),
                   " Division</h3>")
        end
      end
      section_name = matches[3].tr('_', " ")
      out.print("<a target='text' href='", section_name, ".html'>",
                section_name, "</a><br/>\n")
      pngfile = File.basename(file).sub(/\.txt/, ".png")

      full_section_name = matches[1] + "_" + matches[2] + "_" + matches[3]
      File.open(outdir + "/" + full_section_name + "_wiki.txt", "w") { |section|
        file_name_prefix = outdir + "/" + full_section_name
        style_name = section_name.gsub(" Style", "")
        insert_file(section, file, file_name_prefix, 
                    (division == 6) ? style_name : nil)
      }

    }

    out.print("</body></html>")
  }
end

make_wiki($*[0] ,$*[1], $*[2])
