#! /opt/local/bin/ruby

require "dotlib.rb"

Dir["?_?_*.txt"].each { |file|
  makedot(file, file.sub(/\.txt/, '.dot'))
}
