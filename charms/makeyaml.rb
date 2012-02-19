#! /opt/local/bin/ruby1.9

# $KCODE = "u" # not in ruby 1.9

# TODO: Convert excellencies and intro paras
# TODO: Handle block-quoted paras
# TODO: Handle other keywords, especially review!
# TODO: Handle escape single/double quotes in, e.g., names, refs, etc.
# TODO: Split Duration at " or "?

def make_list(array)
  '[' + array.join(', ') + ']'
end

def make_map(array)
  '{' + array.map {|i| i.join(': ')}.join(', ') + '}'
end

def insert_long_list(out, name, array)
    if not array.empty?
      out.puts("#{name}:")
      array.each { |i| out.puts("- #{i}") }
    end
end

def insert_charm(out, section_name, charm, charms)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  return if charm['name'][0] == '('[0]
  if charm['name'] != '.'
    out.puts("--- !Charm")
    out.puts("Section: #{charm['section']}")
    out.puts("Id: #{charm['id']}")
    out.puts("Name: \"#{charm['name']}\"")
    out.puts("Cost: #{charm['cost']}") # SPLIT
    out.puts("Mins: #{make_map charm['mins']}")
    type_parts = charm['type'].split(' (')
    type_parts.map! { |t| t.delete '()' }
    if type_parts.length == 1
      type_parts << ""
    end
    out.puts("Type: #{make_map [type_parts]}") # SPLIT?
    out.puts("Keywords: #{make_list charm['key']}")
    out.puts("Duration: #{charm['dur']}")
    out.puts("Prerequisites: #{make_list charm['dep']}")
    insert_long_list(out, "References", charm['ref'])
    insert_long_list(out, "Reviews", charm['review'])
    insert_long_list(out, "Updates", charm['update'])

    charm_full_name = section_name.downcase[0..2] + "-" + charm['id']
    charms[charm_full_name] = charm
  end
  out.puts("Text: |")
  charm['text'].each { |para|
    if para[0][0..1] == "> "
      para[0][0..1] = ""      
      out.puts("  ****")
      para.each { |line|
        out.puts("  #{line.strip}")
      }
      out.puts("  ****")
    else
    para.each { |line|
      out.puts("  #{line}")
    }
    end
    out.puts("  ")
  }
end

def insert_file(out, file, section_name, charms)
  charm_names = {}
  curr_charm = {}
  curr_para = ""

  $stderr << file << "\n"

  IO.foreach(file, "\r\n", mode: "rb", encoding: "iso-8859-1") { |line|
    # Strip DOS line endings
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
        curr_charm["ref"] = []
        curr_charm["review"] = []
        curr_charm["update"] = []
        curr_charm["section"] = section_name
        curr_refs = []
      when "cost", "type", "dur"
        curr_charm[md[1]] = md[2]
      when "mins", "dep", "key", "tag"
        curr_charm[md[1]] = md[2].split(", ").map! { |i| i.split(" ") }
      when "ref", "review", "update"
        curr_charm[md[1]] << md[2]
      when "text"
        curr_charm["text"] = []
        curr_para = [md[2]]
      else
        $stderr << "Unknown keyword: " << line
        exit -1
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
