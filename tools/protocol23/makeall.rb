#! /opt/local/bin/ruby

require File.expand_path(File.dirname(__FILE__)) + "/dotlib.rb"

Dir["?_?_*.txt"].each { |file|
  makedot(file, file.sub(/\.txt/, '.dot'))
}
