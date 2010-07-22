#! /opt/local/bin/ruby

$KCODE = "u"

def insert_charm(out, charm)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  return if charm['name'][0] == '('[0]
  if charm['name'] == '.'
    charm['text'].each { |para|
      out.print("<p>#{para}</p>\n")
    }
    return
  end

  out.print("<h3>#{charm['name']}</h3>\n<p>")
  out.print("<b>Cost:</b> #{charm['cost']}; ")
  out.print("<b>Mins:</b> #{charm['mins']}; ")
  out.print("<b>Type:</b> #{charm['type']}<br/>")
  out.print("<b>Keywords:</b> #{charm['key']}<br/>")
  out.print("<b>Duration:</b> #{charm['dur']}<br/>")
  out.print("<b>Prerequisite Charms:</b> ")
  deps = charm['dep']
  if deps.empty?
    out.print("None")
  else
    first = true
    charm['dep'].each { |dep_name|
      if first
        first = false
      else
        out.print(", ")
      end
      out.print(dep_name)
    }
  end
  out.print("</p>\n")
  charm['text'].each { |para|
    out.print("<p>#{para}</p>\n")
  }
end

def insert_file(out, file)
  charm_names = {}
  curr_charm = {}

  $stderr << file << "\n"

  IO.foreach(file) { |line|
    md = /^([a-z]+): (.*)$/.match(line)
    if md and md.length == 3
      case md[1]
      when "name"
        insert_charm(out, curr_charm)

        name_split = md[2].split(", ")
        id = name_split[0]
        name = name_split[1].tr('*', ' ')
        curr_charm = { "id" => id, "name" => name }
        charm_names[id] = name.delete "()"
        curr_charm["min_abil"] = ""
        curr_charm["min_ess"] = ""
        curr_charm["dep"] = []
      when "cost", "mins", "type", "key", "dur"
        curr_charm[md[1]] = md[2]
      when "dep"
        deps = []
        md[2].split(", ").each { |dep|
          deps = deps.push(charm_names[dep])
        }
        curr_charm["dep"] = deps
      when "text"
        curr_charm["text"] = [md[2]]
      end
    elsif not line.empty?
      curr_charm["text"].push(line)
    end
  }

  insert_charm(out, curr_charm)
end

def make_html(indir, outdir, outfilename)
  File.open(outdir + "/" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms</title></head>\n")
    out.print("<style type='text/css'>")
    out.print("* { font-family: Palatino, Times, serif }")
    out.print("h1, h2, h3, h4, h5, h6 { font-family: 'American Typewriter', Courier, mono }")
    out.print("</style></head>\n<body>\n")
    out.print("<h1>Discordian Charms</h1>\n")

    Dir[indir + "/?_?_*.txt"].each { |file|
      section_name = /[0-9]_[0-9]_([A-Za-z_]+)/.match(file)[1].tr('_', " ")
      pngfile = File.basename(file).sub(/\.txt/, ".png")
      out.print("<h2>", section_name, "</h2>\n")
      out.print("<img src='", pngfile, "'/>\n")

      insert_file(out, file)
    }

    out.print("</body></html>")
  }

  File.open(outdir + "/framed-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms</title></head>\n")
    out.print("<frameset cols='15%, 85%'>\n")
    out.print("<frame src='index-", outfilename, "'/>\n")
    out.print("<frame name='text' src='intro.html'/>\n")
    out.print("</frameset></html>\n")
  }

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

      File.open(outdir + "/" + section_name + ".html", "w") { |section|
        section.print("<html><head><title>", section_name, "</title></head>\n")
        section.print("<style type='text/css'>")
        section.print("* { font-family: Palatino, Times, serif }")
        section.print("h1, h2, h3, h4, h5, h6 { font-family: 'American Typewriter', Courier, mono }")
        section.print("</style>\n<body>\n")
        section.print("<h1>", section_name, "</h1>\n")
        section.print("<img src='", pngfile, "'/>\n")
        insert_file(section, file)
        section.print("</body></html>")
      }

    }

    out.print("</body></html>")
  }
end

make_html($*[0] ,$*[1], $*[2])
