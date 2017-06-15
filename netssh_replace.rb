require 'net/ssh'
require 'optparse'

options = {}

opt = OptionParser.new do |opts|
  opts.banner = 'Usage: net_ssh_replace.rb [options]' \
                'hostname.com file search_string replacement_string'

  opts.on('-u', '--username USERNAME', 'username') { |u| options[:username] = u }
  opts.on('-p', '--password PASSWORD', 'password') { |p| options[:password] = p }
  opts.on('-o', '--port PORT', 'port') { |o| options[:port] = o }
  opts.on('-h', '--help', 'username') do
    puts opts.help
    exit
  end
end
opt.parse!

unless ARGV.length == 4
  puts opt.help
  exit
end

options[:hostname] = ARGV.shift
options[:filename] = ARGV.shift
options[:search_string] = ARGV.shift
options[:replacement_string] = ARGV.shift

options[:port] ||= 22

options[:username] ||= 'root'
options[:password] ||= ''

Net::SSH.start(options[:hostname],
               options[:username],
               password: options[:password]) do |ssh|
  channel = ssh.open_channel do |ch|
    ch.exec "vim #{options[:filename]} -c '%s/#{options[:search_string]}/#{options[:replacement_string]}/g' " \
            "-c 'wq!'" do |ch, success|
      raise "could not execute command" unless success

      # "on_data" is called when the process writes something to stdout
      ch.on_data do |_c, data|
        $stdout.print data
      end

      # "on_extended_data" is called when the process writes something to stderr
      ch.on_extended_data do |_c, _type, data|
        $stderr.print data
      end

      ch.on_close { puts "done!" }
    end
  end
  channel.wait
  ssh.loop
end
