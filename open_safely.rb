require 'fileutils'
require 'tempfile'

class File
  def self.open_safely(path)
    result = nil
    temp_path = nil
    Tempfile.open("#{$0}-#{path.hash}") do |f|
      result = yield f
      temp_path = f.path
    end
    FileUtils.move(temp_path, path)
    result
  end
end
