#! /opt/local/bin/ruby1.9

# $KCODE = "u" # not in ruby 1.9

# TODO: Handle block-quoted paras
# TODO: Handle other keywords, especially review!

def make_list(array)
  '[' + array.join(', ') + ']'
end

def insert_charm(out, section_name, charm, charms)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  return if charm['name'][0] == '('[0]
  if charm['name'] != '.'
    out.puts("--- !Charm")
    out.puts("Id: #{charm['id']}")
    out.puts("Name: #{charm['name']}")
    out.puts("Cost: #{charm['cost']}") # SPLIT
    out.puts("Mins: #{make_list charm['mins']}")
    type_parts = charm['type'].split(' (')
    type_parts.map! { |t| t.delete '()' }
    out.puts("Type: #{make_list type_parts}")
    out.puts("Keywords: #{make_list charm['key']}")
    out.puts("Duration: #{charm['dur']}")
    out.puts("Prerequisites: #{make_list charm['dep']}")

    charm_full_name = section_name.downcase[0..2] + "-" + charm['id']
    charms[charm_full_name] = charm
  end
  out.puts("Text: |")
  charm['text'].each { |para|
#     if para[0..1] == "> "
#       para[0..1] = ""      
#       para = "<blockquote style='font-style: italic;'>" + para + "</blockquote>"
#     end
    para.each { |line|
      out.puts("  #{line}")
    }
    out.puts
  }
end

def insert_file(out, file, section_name, charms)
  charm_names = {}
  curr_charm = {}
  curr_para = ""

  $stderr << file << "\n"

  # TODO: Fix encoding, for line endings
  IO.foreach(file, "\r\n", mode: "rb", encoding: "iso-8859-1") { |line|
    # Strip DOS line endings
    # line.gsub!("\015", "")

    # $stderr << "{{{" << line << "}}}\n"

    line.chomp!
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
        curr_charm["dep"] = []
        curr_charm["section"] = section_name
      when "cost", "type", "dur", "tag"
        curr_charm[md[1]] = md[2]
      when "mins", "dep", "key"
        curr_charm[md[1]] = md[2].split(", ")
      when "text"
        curr_charm["text"] = []
        curr_para = [md[2]]
      end
    else
      if line.empty?
        if not curr_para.empty?
          curr_charm["text"].push(curr_para)
        end
        curr_para = []
      else
        curr_para << line
      end
    end
  }
  if not curr_para.empty?
    curr_charm["text"].push(curr_para)
  end

  insert_charm(out, section_name, curr_charm, charms)

  out.puts("...")
end

def make_yaml(infilename, outfilename)
  charms = {}

  File.open(outfilename, "w") { |out|
    matches = /([0-9])_([0-9])_([A-Za-z_]+)/.match(infilename)
    section_name = matches[3].tr('_', " ")
    insert_file(out, infilename, section_name, charms)
  }
end

make_yaml($*[0] ,$*[1])
