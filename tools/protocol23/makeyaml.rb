#! /opt/local/bin/ruby1.9

# $KCODE = "u" # not in ruby 1.9

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

def insert_charm(out, group_name, charm, charms)
  return if charm.empty?

  $stderr << '  ' << charm['name'] << "\n"

  if charm['name'] != '.'
    out.puts("--- !Charm")
    out.puts("id: #{charm['id']}")
    out.puts("name: \"#{charm['name']}\"")
    if charm['name'][0] != '('[0]
      out.puts("cost: #{charm['cost']}") # SPLIT
      out.puts("mins: #{make_map charm['mins']}")
      type_parts = charm['type'].split(' (')
      type_parts.map! { |t| t.delete '()' }
      out.puts("type: #{make_list [type_parts]}") # SPLIT?
      out.puts("keys: #{make_list charm['key']}")
      if charm['tag'].length > 0
        out.puts("tags: #{make_list charm['tag']}")
      end
      out.puts("dur: #{charm['dur']}")
      out.puts("deps: #{make_list charm['dep']}")
      insert_long_list(out, "refs", charm['ref'])
      insert_long_list(out, "reviews", charm['review'])
      insert_long_list(out, "updates", charm['update'])
    end

    charm_full_name = group_name.downcase[0..2] + "-" + charm['id']
    charms[charm_full_name] = charm
  end
  return if not charm.has_key?('text') or charm['text'].empty?
  out.puts("text: |")
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

def insert_file(out, file, group_name, charms)
  charm_names = {}
  curr_charm = {}
  curr_para = ""

  $stderr << file << "\n"

  out.puts("--- !CharmGroup")
  out.puts("name: #{group_name}")

  IO.foreach(file,
             mode: "r",
             external_encoding: "iso-8859-1",
             internal_encoding: "utf-8") { |line|
    # Strip DOS line endings
    line.chomp!
    md = /^([a-z]+): *(.*)$/.match(line)
    if md and md.length == 3
      case md[1]
      when "name"
        insert_charm(out, group_name, curr_charm, charms)

        name_split = md[2].split(", ")
        id = name_split[0]
        name = name_split[1].tr('*', ' ')
        curr_charm = { "id" => id, "name" => name }
        if name[0] == "("
          name = name.delete "()"
        end
        charm_names[id] = name
        curr_charm["ref"] = []
        curr_charm["tag"] = []
        curr_charm["review"] = []
        curr_charm["update"] = []
        curr_refs = []
      when "cost", "type", "dur"
        curr_charm[md[1]] = md[2]
      when "mins"
        curr_charm[md[1]] = md[2].split(", ").map! { |i|
          parts = i.split(" ")
          [ parts[0..-2].join(" "), parts[-1] ] # all-but-last, then last
        }
      when "dep", "key", "tag"
        curr_charm[md[1]] = md[2].split(", ")
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

  insert_charm(out, group_name, curr_charm, charms)

  out.puts("...")
end

def make_yaml(infilename, outfilename)
  charms = {}

  File.open(outfilename, "wt", encoding: "utf-8") { |out|
    matches = /([0-9])_([0-9])_([A-Za-z_]+)/.match(infilename)
    group_name = matches[3].tr('_', " ")
    out.puts("# -*- coding: utf-8 -*-") # To keep Emacs happy
    insert_file(out, infilename, group_name, charms)
  }
end

make_yaml($*[0] ,$*[1])
