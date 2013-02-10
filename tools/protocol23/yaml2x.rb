#! /opt/local/bin/ruby1.9

require "psych"

class CharmGroup
  yaml_tag "!CharmGroup"
  attr_accessor \
    :name, # string
    :text # string
  attr_writer \
    :trait # string

  def trait
    @trait or @name
  end

  def to_s
    puts @name, @trait, @text
  end
end

class CharmLayout
  yaml_tag "!CharmLayout"
  attr_accessor \
    :grid # array of arrays of Charm#id
end

class Charm
  yaml_tag "!Charm"
  attr_accessor \
    :id,
    :name,
    :group,
    :file,
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

  def clean_name
    return @clean_name unless @clean_name.nil?
    @clean_name = name.gsub(/\>/, " ")
  end

  def multi_line_name
    return @multi_line_name unless @multi_line_name.nil?
    @multi_line_name = name.split(">")
  end

  def safe_group
    return @safe_group unless @safe_group.nil?
    @safe_group = group.gsub(/ /, "_")
  end
end

def process_file(infilename)
  File.open(infilename, mode: "r", encoding: "utf-8") do |infile|
    group = nil
    charms = {}
    layouts = []
    # charms_by_full_id = {}

    docs = Psych.parse_stream(infile).children
    docs.each { |doc|
      obj = doc.to_ruby
      if obj.is_a? CharmGroup
        group = obj
      end
      if obj.is_a? CharmLayout
        layouts << obj
      end
      if obj.is_a? Charm
        charm = obj
        charm.group = group.name
        charm.file = infilename
        # p obj.name
        charms[charm.id] = charm
        # charm_full_id = group.name.downcase[0..2] + "-" + charm.id
        # charms_by_full_id[charm_full_id] = charm
      end
    }
    yield(group, charms, layouts)      
  end
end
