#! /opt/local/bin/ruby

$KCODE = "u"

def insert_charm(out, section_name, charm, charms)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  return if charm['name'][0] == '('[0]
  if charm['name'] != '.'
    out.print("<a name='#{charm['id']}'/>\n")
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

    charm_full_name = section_name.downcase[0..2] + "-" + charm['id']
    charms[charm_full_name] = charm
  end
  charm['text'].each { |para|
    if para[0..1] == "> "
      para[0..1] = ""      
      para = "<blockquote style='font-style: italic;'>" + para + "</blockquote>"
    end
    out.print("<p>#{para}</p>\n")
  }
end

def insert_file(out, file, section_name, charms)
  charm_names = {}
  curr_charm = {}
  curr_para = ""

  $stderr << file << "\n"

  IO.foreach(file) { |line|
    # Strip DOS line endings
    line.gsub!("\015", "")
    md = /^([a-z]+): *(.*)$/.match(line)
    if md and md.length == 3
      case md[1]
      when "name"
        insert_charm(out, section_name, curr_charm, charms)

        name_split = md[2].split(", ")
        id = name_split[0]
        name = name_split[1].tr('*', ' ')
        curr_charm = { "id" => id, "name" => name }
        if name[0] == "("
          name = name.delete "()"
        end
        charm_names[id] = name
        curr_charm["min_abil"] = ""
        curr_charm["min_ess"] = ""
        curr_charm["dep"] = []
        curr_charm["section"] = section_name
      when "cost", "mins", "type", "key", "dur", "tag"
        curr_charm[md[1]] = md[2]
      when "dep"
        deps = []
        md[2].split(", ").each { |dep|
          deps = deps.push(charm_names[dep])
        }
        curr_charm["dep"] = deps
      when "text"
        curr_charm["text"] = []
        curr_para = md[2]
      end
    else
      line.strip!
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

  insert_charm(out, section_name, curr_charm, charms)
end

def write_tag_index_as_html(out, charms, tag_key_name, excluded_tags,
                            extract_tags=lambda {|tag_value| tag_value.split(", ")})
  charms_by_tag = {}
  charms.each_pair { |charm_full_name, charm|
    if charm.has_key?(tag_key_name)
      tags = extract_tags.call(charm[tag_key_name])
      tags.each { |tag|
        if !charms_by_tag.has_key?(tag)
          charms_by_tag[tag] = []
        end
        charms_for_tag = charms_by_tag[tag]
        charms_for_tag.push(charm)
      }
    end
  }
  sorted_tags = charms_by_tag.keys.sort.reject { |k| excluded_tags.include?(k) }
  sorted_tags.each { |tag|
    out.print("<h3>", tag, "</h3><ul class='index_items'>")
    charms_by_tag[tag].each { |charm|
      out.print("<li><a href='", charm["section"], ".html#", charm["id"], "' ",
                "target='text'>",
                charm["name"],
                "</a></li>")
    }
    out.print("</ul>")
  }
end

def make_html(indir, outdir, outfilename)
  charms = {}

  File.open(outdir + "/" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")
    out.print("<h1>Discordian Charms</h1>\n")

    Dir[indir + "/?_?_*.txt"].each { |file|
      section_name = /[0-9]_[0-9]_([A-Za-z_]+)/.match(file)[1].tr('_', " ")
      pngfile = File.basename(file).sub(/\.txt/, ".png")
      out.print("<h2>", section_name, "</h2>\n")
      out.print("<img src='", pngfile, "'/>\n")

      insert_file(out, file, section_name, charms)
    }

    out.print("</body></html>")
  }

  File.open(outdir + "/framed-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms</title></head>\n")
    out.print("<frameset cols='20%, 80%'>\n")
    out.print("<frame src='indices-for-", outfilename, "'/>\n")
    out.print("<frame name='text' src='intro.html'/>\n")
    out.print("</frameset></html>\n")
  }

  File.open(outdir + "/indices-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charm Indices</title></head>\n")
    out.print("<frameset rows='15%, 85%'>\n")
    out.print("<frame src='index-selector-for-", outfilename, "'/>\n")
    out.print("<frame name='selected-index' src='index-by-division-for-", outfilename, "'/>\n")
    out.print("</frameset></html>\n")
  }

  File.open(outdir + "/index-selector-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charm Indices</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")
    out.print("<h4>Discordian Charms</h4>\n")
    out.print("<a target='selected-index' href='index-by-division-for-", outfilename,
              "'>by Division</a><br/>\n")
    out.print("<a target='selected-index' href='index-by-type-for-", outfilename,
              "'>by Type</a><br/>\n")
    out.print("<a target='selected-index' href='index-by-keyword-for-", outfilename,
              "'>by Keyword</a><br/>\n")
    out.print("<a target='selected-index' href='index-by-tag-for-", outfilename,
              "'>by Tag</a><br/>\n")
    out.print("</body></html>\n")
  }

  File.open(outdir + "/index-by-division-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms by Division</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")

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
        section.print("<link rel='stylesheet' href='style.css'/>\n")
        section.print("</head>\n<body>\n")
        section.print("<h1>", section_name, "</h1>\n")
        section.print("<img src='", pngfile, "'/>\n")
        insert_file(section, file, section_name, charms)
        section.print("</body></html>")
      }

    }

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-type-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms by Type</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")

    write_tag_index_as_html(out, charms, "type", ["Simple", "Reflexive", "Supplemental"],
                            lambda {|tag_value| tag_value.split(" (")[0..0]})

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-keyword-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms by Keyword</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")

    write_tag_index_as_html(out, charms, "key", ["Combo-Basic", "Combo-OK", "None"])

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-tag-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>Discordian Charms by Tag</title></head>\n")
    out.print("<link rel='stylesheet' href='style.css'/>\n")
    out.print("</head>\n<body>\n")

    write_tag_index_as_html(out, charms, "tag", ["None"])

    out.print("</body></html>")
  }
end

make_html($*[0] ,$*[1], $*[2])
