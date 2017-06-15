require 'pdf/writer'
require 'net/sftp'
require 'optparse'

options = {}
opt = OptionParser.new do |opts|
  opts.banner = 'Usage: net_ssh_replace.rb [options]' \
                'hostname.com file search_string replacement_string'

  opts.on('-u', '--username USERNAME', 'username') { |u| options[:username] = u }
  opts.on('-p', '--password PASSWORD', 'password') { |p| options[:password] = p }
  opts.on('-o', '--port PORT', 'port') { |o| options[:port] = o }
  opts.on('-O', '--order FIELDNAME', 'fieldname') { |f| options[:sortcolumn] = f }
  opts.on('-s', '--sort ASC_OR_DESC', 'sort') { |s| options[:sortorder] = s }
  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts.help
    exit
  end
end
opt.parse!

options[:hostname] = ARGV.shift
options[:directories] = ARGV

options[:username] ||= 'root'
options[:password] ||= ''
options[:sortcolumn] ||= 'filename'
options[:port] ||= 25

pdf_document = PDF::Writer.new

Net::SFTP.start(options[:hostname], options[:username], password: options[:password]) do |sftp|
  options[:directories].each do |directory|
    pdf_document.select_font 'Times-Roman'
    pdf_document.text(["Directory #{directory} on host #{options[:hostname]}"], font_size: 32)
    table_data = []
    sftp.dir.foreach(directory) do |file|
      next if file.name =~ /^\.+$/
      table_data << { "name" => file.name,
                      "size" => file.attributes.size,
                      "mtime" => file.attributes.mtime }

    end

    table_data.sort! do |row1, row2|
      if options[:sortorder] == 'ASC'
        row1[options[:sortcolumn]] <=> row2[options[:sortcolumn]]
      else
        row2[options[:sortcolumn]] <=> row1[options[:sortcolumn]]
      end
    end

    table_data.collect do |row|
      row['mtime'] = Time.at(row['mtime']).strftime('%m/%d/%y')
    end

    pdf_document.move_pointer 20

    require 'PDF/SimpleTable'
    table = PDF::SimpleTable.new
    table.shade_color = Color::RGB::Grey90
    table.position = :left
    table.orientation = 30
    table.data = table_data
    table.column_order = %w[name size mtime]
    table.render_on pdf_document

    pdf_document.move_pointer 50
  end
end

pdf_document.save_as 'output.pdf'
