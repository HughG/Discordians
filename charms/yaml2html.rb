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

if __FILE__ == $PROGRAM_NAME
  puts $PROGRAM_NAME + "..."
  filename = "./output_yaml/1_3_Martial_Arts.yml"
  File.open filename do |f|
    docs = Psych.parse_stream(f).children
    docs.each { |doc| p doc.to_ruby }
  end
end
