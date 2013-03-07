#! /opt/local/bin/ruby1.9

require "psych"
require File.expand_path(File.dirname(__FILE__)) + "/yaml2x"

def write_tag_index_as_html(out, all_charms, get_tags, excluded_tags,
                            extract_tags=lambda {|tag_value| tag_value})
  charms_by_tag = {}
  all_charms.each_pair { |group_name, group_charms|
    group_charms.each_pair { |charm_id, charm|
      tags = get_tags.call(charm)
      if tags
        tags = extract_tags.call(tags)
        tags.each { |tag|
          if !charms_by_tag.has_key?(tag)
            charms_by_tag[tag] = []
          end
          charms_for_tag = charms_by_tag[tag]
          charms_for_tag.push(charm)
        }
      end
    }
  }
  sorted_tags = charms_by_tag.keys.sort.reject { |k| excluded_tags.include?(k) }
  sorted_tags.each { |tag|
    out.print("<h3>", tag, "</h3>\n<ul class='index_items'>\n")
    charms_by_tag[tag].each { |charm|
      output_filename = File.basename(charm.file).sub(/\.yml$/, ".html")

      out.print("<li><a href='#{output_filename}##{charm.safe_group}_#{charm.id}' target='text'>",
                charm.clean_name,
                "</a></li>\n")
    }
    out.print("</ul>\n")
  }
end

def make_html(indir, outdir, outfilename, projectname)
  all_charms = {}

  File.open(outdir + "/framed-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charms</title></head>\n")
    out.print("<frameset cols='20%, 80%'>\n")
    out.print("<frame src='indices-for-", outfilename, "'/>\n")
    out.print("<frame name='text' src='intro.html'/>\n")
    out.print("</frameset></html>\n")
  }

  File.open(outdir + "/intro.html", "w") { |out|
    out.print("<html><head><title>#{projectname}: Charms</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")
    out.print("<h1>#{projectname}: Charms</h1>\n")
    out.print("<p>Click the links to the left to view the Charms.</p>\n")
    out.print("</body></html>\n")
  }

  File.open(outdir + "/indices-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charm Indices</title></head>\n")
    out.print("<frameset rows='15%, 85%'>\n")
    out.print("<frame src='index-selector-for-", outfilename, "'/>\n")
    out.print("<frame name='selected-index' src='index-by-division-for-", outfilename, "'/>\n")
    out.print("</frameset></html>\n")
  }

  File.open(outdir + "/index-selector-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charm Indices</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")
    out.print("<h4>#{projectname}: Charms</h4>\n")
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
    out.print("<html><head><title>#{projectname}: Charms by Division</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")

    Dir[indir + "/?_?_*.yml"].each { |file|
      matches = /([0-9])_([0-9])_([A-Za-z_]+)/.match(file)
      division = matches[1].to_i
      subsec = matches[2].to_i
      if (subsec == 1)
        if (division == 0)
          out.print("<h3>General Charms</h3>")
        elsif (division == 6)
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
      section_filename = file.sub(/\.yml$/, ".html")
      section_filename = section_filename.sub(/^#{indir}/, ".")
      out.print("<a target='text' ",
                "href='#{section_filename}'>#{section_name}</a><br/>\n")

      process_file(file) { |group_name, charms|
        all_charms[group_name] = charms
      }

    }

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-type-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charms by Type</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")

    extract_charm_types = lambda {|charm_type|
      first_type = charm_type[0]
      if first_type.is_a? Array
        charm_type.map {|alt_type| alt_type[0]}
      else
        charm_type[0..0]
      end
    }

    write_tag_index_as_html(out,
                            all_charms,
                            lambda {|charm| charm.type},
                            ["Simple", "Reflexive", "Supplemental"],
                            extract_charm_types)

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-keyword-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charms by Keyword</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")

    write_tag_index_as_html(out,
                            all_charms,
                            lambda {|charm| charm.keys},
                            ["Combo-Basic", "Combo-OK", "None"])

    out.print("</body></html>")
  }

  File.open(outdir + "/index-by-tag-for-" + outfilename, "w") { |out|
    out.print("<html><head><title>#{projectname}: Charms by Tag</title>\n")
    out.print("<link rel='stylesheet' href='protocol23-basic-page.css'/>\n")
    out.print("</head>\n<body>\n")

    write_tag_index_as_html(out,
                            all_charms,
                            lambda {|charm| charm.tags},
                            ["None"])

    out.print("</body></html>")
  }
end

make_html($*[0] ,$*[1], $*[2], $*[3])
