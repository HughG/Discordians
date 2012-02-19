#! /opt/local/bin/ruby1.9

require "psych"

class CharmGroup
  yaml_tag "!CharmGroup"
  attr_accessor \
    :name,
    :text

  def to_s
    puts @name, @text
  end
end

class Charm
  yaml_tag "!Charm"
  attr_accessor \
    :id,
    :name,
    :cost,
    :mins,
    :type,
    :keys,
    :tags,
    :dur,
    :deps,
    :refs,
    :reviews,
    :updates,
    :text
end

def insert_charm(out, section_name, charm, charms)
#  $stderr << '  ' << charm.name << "\n"

  return if charm.name[0] == '('[0]
  if charm.name != '.'
    out.print("<a name='#{charm.id}'/>\n")
    out.print("<h3>#{charm.name}</h3>\n<p>")
    out.print("<b>Cost:</b> #{charm.cost}; ")
    out.print("<b>Mins:</b> #{charm.mins}; ")
    out.print("<b>Type:</b> #{charm.type}<br/>")
    out.print("<b>Keywords:</b> #{charm.keys}<br/>")
    out.print("<b>Duration:</b> #{charm.dur}<br/>")
    out.print("<b>Prerequisite Charms:</b> ")
    deps = charm.deps
    if deps.empty?
      out.print("None")
    else
      charm.deps.map {|d| charms[d].name}.join(", ")
    end
    out.print("</p>\n")
  end
#   charm.text.each { |para|
#     out.print("<p>#{para}</p>\n")
#   }
  out.print("<p>#{charm.text}</p>\n")
end

if __FILE__ == $PROGRAM_NAME
  puts $PROGRAM_NAME + "..."
  filename = "./output_yaml/1_3_Martial_Arts.yml"
#  filename = "./output_yaml/3_5_War.yml"
  File.open filename do |f|
    group_name = ""
    charms = {}
    charms_by_full_id = {}

    docs = Psych.parse_stream(f).children
    #docs.each { |doc| p doc.to_ruby }
    docs.each { |doc|
      obj = doc.to_ruby
      if obj.is_a? CharmGroup
        group_name = obj.name
      end
      if obj.is_a? Charm
        charm = obj
        p obj.name
        charms[charm.id] = charm
        charm_full_id = group_name.downcase[0..2] + "-" + charm.id
        charms_by_full_id[charm_full_id] = charm
      end
    }
    charms.each_value { |charm|
      insert_charm($stdout, group_name, charm, charms)      
    }
  end
end
