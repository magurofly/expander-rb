#!/usr/bin/env ruby
# coding: UTF-8
require "optparse"
require "securerandom"

PATTERN_STRING_SINGLE = /'(?<content>[^']*)'/
PATTERN_STRING_DOUBLE = /"(?<content>[^"]*)"/
PATTERN_STRING = /#{PATTERN_STRING_SINGLE}|#{PATTERN_STRING_DOUBLE}/
PATTERN_REQUIRE = /^\s*(require(?<relative>_relative)?)\s*(?<feature>#{PATTERN_STRING}|\(\s*\g<feature>\s*\))/

def main
  output = STDOUT
  @paths = []

  OptionParser.new do |opts|
    opts.banner = 'Usage: ruby expander.rb [options] FILES ...'
    opts.on('-o FILE', 'Output to FILE (default: STDOUT)') { |filename| output = File.open(filename, "w") }
    opts.on('-I', '--path PATH', 'Add a path to search library') { |path| @paths << path }
  end.parse! ARGV

  @deps = {}

  source_body = expand_file(ARGF.read)
  source_head = @deps.values.map { |feature| feature.source }.join("\n")
  source = source_head + "\n" + source_body
  output.puts source
end

Dep = Struct.new(:name, :source)

def expand_file(source, base_dir = '.')
  source.gsub(PATTERN_REQUIRE) do |matched|
    matched = PATTERN_REQUIRE.match(matched)
    if (name = require_dep(matched[:content], matched[:relative], base_dir))
      'require_' + name
    else
      matched
    end
  end
end

def require_dep(feature, relative, base_dir)
  return @deps[feature].name if @deps.key? feature
  name = SecureRandom.hex(8)
  if (path = search_feature(feature, relative, base_dir))
    source_body = expand_file(File.read(path), File.dirname(path))
    source = <<-EOF
def require_#{name}
  return false if $".include? '#{name}.rb'
  $" << '#{name}.rb'
  eval <<-__END__
#{source_body}
__END__
  true
end
    EOF
    @deps[feature] = Dep[name, source]
    name
  else
    false
  end
end

def search_feature(feature, is_path, base_dir)
  is_path = true if feature =~ %r"^\.?/"

  if is_path
    feature = File.join(base_dir, feature)
    if File.file? feature
      return feature
    elsif File.file? feature + '.rb'
      return feature + '.rb'
    else
      return false
    end
  end

  (@paths + [base_dir]).each do |path|
    filepath = File.join(path, feature)
    if File.exist? filepath
      return filepath
    elsif File.exist? filepath + '.rb'
      return filepath + '.rb'
    end
  end

  false
end

main
