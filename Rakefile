input_dir = 'document'
output_dir = 'public'

task default: %i[build_directories build_html]

task :build_directories do
  mkdir output_dir unless Dir.exist?(output_dir)
  mkdir input_dir unless Dir.exist?(input_dir)
end

task :build_html do
  require 'bluecloth'

  cd input_dir

  files = FileList['*.c'].to_a

  cd '..'

  files.each do |filename|
    input_file = "#{input_dir}/#{filename}"

    output_file = File.join(output_dir, "#{File.basename(input_file, '.bc')}.html")

    File.open(output_file, 'w').puts BlueCloth.new(File.open(input_file).read).to_html

    puts "processing #{input_file} into #{output_file}"
  end
end
