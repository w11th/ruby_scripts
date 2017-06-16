require 'id3lib'
require 'optparse'

options = {}
options[:set] = {}

opt = OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} file1 file2 file3..."
  opts.on('-s', '--set OPTION=VALUE', 'Sets the ID3 option OPTION to VALUE.') do |ops|
    option, value = ops.split(/=/)
    unless option && value
      puts 'Please set the ID3 in the format OPTION=VALUE'
      exit
    end
    options[:set][option] = value
  end

  opts.on_tail('-h', 'Show this message') do
    puts opts
    exit
  end
end

opt.parse!

if ARGV.empty?
  puts 'Please specify one or more mp3 files to work with.'
  exit
end

ARGV.each do |file|
  tag = ID3Lib::Tag.new(file)
  display = "#{file} - #{tag.title} from #{tag.album} by #{tag.artist}"

  unless options[:set].empty?
    options[:set].each { |key, value| tag.send("#{key}=", value) }
    tag.update!
    display << '...updating...'
  end

  puts display
end
