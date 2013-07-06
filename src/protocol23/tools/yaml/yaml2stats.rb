#! /opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require "psych"
require File.expand_path(File.dirname(__FILE__)) + "/yaml2x.rb"

class DivisionStats
  attr_accessor \
    :number,
    :total

  def initialize(number)
    @number = number
    @total = 0
  end
end

class GroupStats
  attr_accessor \
    :number,
    :name,
    :total

  def initialize(number, name)
    @number = number
    @name = name
    @total = 0
  end
end


if __FILE__ == $PROGRAM_NAME
  outfilename = $*.shift
  division_stats_map = Hash.new { |h,k| DivisionStats.new(k) }
  group_stats_map = Hash.new { |h,k| Hash.new() }

  $*.each { |infilename|
    matches = /([0-9])_([0-9])_.*/.match(infilename)
    division_number = matches[1].to_i
    group_number = matches[2].to_i

    process_file(infilename) { |group, charms, layouts|
      real_charms = charms.select {|k,v| v.name[0] != '('}
      real_charms_count = real_charms.length

      # Pull out division_group_stats_map and then put it back in separately,
      # to take advantage of Ruby's Hash default value mechanism.
      division_group_stats_map = group_stats_map[division_number]
      division_group_stats = division_group_stats_map.fetch(group_number) {|key|
        GroupStats.new(group_number, group.name)
      }
      division_group_stats.total += real_charms_count
      division_group_stats_map[group_number] = division_group_stats
      group_stats_map[division_number] = division_group_stats_map

      # Likewise for the division_stats_map.
      division_stats = division_stats_map.fetch(division_number) { |key|
        DivisionStats.new(division_number)
      }
      division_stats.total += real_charms_count
      division_stats_map[division_number] = division_stats
    }
  }

  File.open(outfilename, "w") { |outfile|
    group_stats_map.each { |division_number, division_group_stats_map|
      division_group_stats_map.each { |group_number, group_stats|
        outfile.puts [
                      division_number,
                      group_number,
                      group_stats.total,
                      group_stats.name
                     ].join(",")
      }
    }
  }

  extname = File.extname(outfilename)
  basename = File.basename(outfilename, extname)
  dirname = File.dirname(outfilename)
  division_outfilename = File.join(dirname, "division_" + basename + extname)
  File.open(division_outfilename, "w") { |outfile|
    division_stats_map.each { |division_number, division_stats|
      outfile.puts [
                    division_number,
                    division_stats.total
                   ].join(",")
    }
  }
end
