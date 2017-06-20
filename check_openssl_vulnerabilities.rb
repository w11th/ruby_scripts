require 'xmlsimple'
require 'net/http'
require 'yaml'

my_version = ARGV[0]

url = 'http://www.openssl.org/news/vulnerabilities.xml'

xml_data = Net::HTTP.get_response(URI.parse(url)).body
data = XmlSimple.xml_in(xml_data)

data['issue'].each do |vulnerability|
  outstring = ''
  affected = false

  vulnerability['affects']&.each do |affect|
    affected = true if affect['version'] == my_version
  end

  if affected
    outstring << "from #{vulnerability['reported'][0]['source']}" unless vulnerability['reported'].nil?
    outstring << "from #{vulnerability['advisory'][0]['url']}" unless vulnerability['advisory'].nil?
  end

  puts "Advisory #{outstring}" unless outstring.empty?
end
