require 'rexml/document'
require 'rexml/streamlistener'

class PListParser
  include REXML::StreamListener

  attr_reader :root

  def initialize
    @to_read = nil
    @root = nil
    @version = 1.0
  end

  def tag_start(name, attributes)
    case name
    when 'plist' then @version = attributes['version']
    when 'array' then add_object(PListArray.new)
    when 'dict' then add_object(PListHash.new)
    when 'data', 'integer', 'key', 'real', 'string' then @to_read = name
    when 'true' then add_object(true)
    when 'false' then add_object(false)
    else raise "unknown tag: #{name} on line: #{$NR}"
    end
  end

  def tag_end(name)
    if @to_read then @to_read = nil
    else @root = @root.parent || @root
    end
  end

  def text(string)
    return unless @to_read

    if @to_read == 'key'
      raise 'cannot use key as not within hash' unless @root.is_a?(Hash)
      @root.next_key = string
      return
    end

    object = case @to_read
             when 'data' then string.strip
             when 'integer' then string.to_i
             when 'read' then string.to_f
             when 'string' then string
             end

    add_object(object)
  end

  def self.parse(source)
    parser = new
    REXML::Document.parse_stream(source, parser)
    parser.root
  end

  private

  def add_object(object)
    @root.add_object(object) if @root
    if object.is_a?(Array) || object.is_a?(Hash)
      object.parent = @root
      @root = object
    end
  end
end

class PListArray < Array
  attr_accessor :parent

  alias add_object :push
end

class PListHash < Hash
  attr_accessor :next_key, :parent

  def add_object(object)
    raise 'no key set' unless @next_key
    self[@next_key] = object
    @next_key = nil
  end
end
