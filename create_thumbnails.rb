require 'rmagick'
require 'markaby'
require 'optparse'

options = {}
opt = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0}.rb [options] image_directory"

  opts.on('-u', '--thumbnail_directory DIRECTORY', 'thumbnail directory') do |u|
    options[:thumbnail_directory] = u
  end

  opts.on('-h', '--thumbnail_height HEIGHT', 'thumbnail height') do |h|
    options[:thumbnail_height] = h.to_i
  end

  opts.on('-w', '--thumbnail_width WEIGHT', 'thumbnail width') do |w|
    options[:thumbnail_width] = w.to_i
  end

  opts.on('-c', '--background_color COLOR', 'background color') do |c|
    options[:background_color] = c
  end

  opts.on('-t', '--crop_top HEIGHT', 'crop vertical') do |ct|
    options[:crop_top] = ct.to_i
  end

  opts.on('-b', '--crop_bottom HEIGHT', 'crop_bottom') do |cb|
    options[:crop_bottom] = cb.to_i
  end

  opts.on('-l', '--crop_left WIDTH', 'crop left') do |cl|
    options[:crop_left] = cl.to_i
  end

  opts.on('-r', '--crop_right WIDTH', 'crop right') do |cr|
    optoins[:crop_right] = cr.to_i
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end
opt.parse!

unless ARGV.length == 1
  puts opt.help
  exit
end

options[:directory] = ARGV.shift
options[:thumbnail_directory] ||= "#{options[:directory]}/thumbnails"
options[:thumbnail_height] ||= 64
options[:thumbnail_width] ||= 64
options[:background_color] ||= 'black'

background = Magick::Image.new(options[:thumbnail_height], options[:thumbnail_width]) do
  self.background_color = options[:background_color]
end

Dir.mkdir(options[:thumbnail_directory]) unless Dir.exist? options[:thumbnail_directory]

html = Markaby::Builder.new

html.html do
  html.head do
    html.title "Picture Index for #{options[:directory]}"
  end

  html.body do
    Dir.foreach(options[:directory]) do |file|
      next unless file =~ /.*\.(jpg|gif|bmp|png|tif|tga)$/i

      full_filename = "#{options[:directory]}/#{file}"
      thumbnail_filename = "#{options[:thumbnail_directory]}/#{file}"

      image = Magick::Image.read(full_filename).first

      image.crop!(Magick::SouthGravity, image.columns, image.rows - options[:crop_top]) unless options[:crop_top].nil?
      image.crop!(Magick::NorthGravity, image.columns, image.rows - options[:crop_bottom]) unless options[:crop_bottom].nil?
      image.crop!(Magick::WestGravity, image.columns - options[:crop_right], image.rows) unless options[:crop_right].nil?
      image.crop!(Magick::EastGravity, image.columns - options[:crop_left], image.rows) unless options[:crop_left].nil?

      image.change_geometry("#{options[:thumbnail_width]}x#{options[:thumbnail_height]}") do |cols, rows, img|
        img.resize!(cols, rows)
        composite = background.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
        composite.write thumbnail_filename
      end

      html.div style: 'padding:1em; float:left; text-align:center' do
        a href: full_filename do
          html.img src: thumbnail_filename, align: :center
        end
        p do
          small file
        end
      end
    end
  end
end

print html
