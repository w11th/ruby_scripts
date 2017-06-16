require 'zip'

usage = <<~EOF
  usage: #{$PROGRAM_NAME} zipfile [filename]
  prints out one file or all files from a zip file.
EOF

if ARGV.length.zero?
  puts usage
  exit
end

zipfile = ARGV.shift
filename = nil
filename = ARGV.shift unless ARGV.empty?

def print_file(filename, fs)
  puts filename
  puts "=" * filename.length
  puts fs.file.read(filename)
end

Zip::ZipFile.open(zipfile) do |fs|
  print_file filename, fs if filename

  fs.dir.foreach('/') do |fname|
    print_file fname, fs
  end
end
