#!/usr/bin/env ruby
require 'fileutils'

f = $_
FileUtils.mv(f, f + Time.now.strftime(".%Y%m%dT%H%M%S")) if File.exist?(f) and File.size(f) > 10_485_760
