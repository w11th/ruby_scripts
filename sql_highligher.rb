require 'multi'
require 'smulti'

class SQL
  def keyword_regex
    /^(SELECT|FROM|WHERE|ORDER\s+BY|INSERT\s+INTO|UPDATE|INNER|OUTER|LEFT|RIGHT|JOIN|AS|ON|CREATE|TABLE|VIEW|SEQUENCE|FUNCTION|TRIGGER)$/ix
  end

  def logical_regex
    /^AND|OR|NOT$/i
  end

  def types_regex
    /^CHAR|VARCHAR|TINYTEXT|TEXT|BLOB|MEDIUMTEXT|MEDIUMBLOB|LONGTEXT|LONGBLOB|BLOB|INTEGER|TINYINT|SMALLINT|MEDIUMINT|INT|BIGINT|FLOAT|DOUBLE|DECIMAL|DATE|DATETIME|TIMESTAMP|TIME|ENUM|SET$/ix
  end

  LITERAL_COLOR = '#0e6e6e'.freeze
  LOGICAL_COLOR = '#8e4e2e'.freeze
  TYPE_COLOR = '#9eaeae'.freeze

  def initialize(in_sql)
    @sql = in_sql
    @output = ''
    smulti :parse, /[\s,\(\)\n]+/ do |match, remainder|
      @output << match
      parse remainder
    end
    smulti :parse, /;/ do |match, remainder|
      @output << "#{match}<br>"
      parse remainder
    end
    smulti :parse, /$/ do |_match, _remainder|
      @output
    end
    smulti :parse, /[^0-9"'(),]+/ do |match, _remainder|
      if keyword_regex.match(match)
        @output << "<b>#{match.upcase}</b>"
      elsif logic_regex.match(match)
        @output << "<font color=\"#{LOGICAL_COLOR}\">#{match.upcase}</font>"
      elsif types_regex.match(match)
        @output << "<font color=\"#{TYPE_COLOR}\">#{match.upcase}</font>"
      else
        @output << "<i>#{match}</i>"
      end
    end

    smulti :parse, /["']/ do |match, remainder|
      @string_delimiter = match
      @output << "<font color=\"#{LITERAL_COLOR}\">#{match}"
      string_parse remainder
    end

    smulti :parse, /[0-9]/ do |match, remainder|
      @output << "<font color=\"#{LITERAL_COLOR}\">"
      number_parse "#{match}#{remainder}"
    end

    smulti :string_parse, /[^'"]+/ do |match, remainder|
      @output << match
      string_parse remainder
    end

    smulti :string_parse, /['"]/ do |match, remainder|
      if match == @string_delimiter
        @output << "#{match}</font>"
        parse remainder
      else
        @output << match
        string_parse remainder
      end
    end

    smulti :string_parse, /$/ do |match, remainder|
      @output
    end

    smulti :number_parse, /[0-9.]+/ do |match, remainder|
      @output << match
      number_parse remainder
    end

    smulti :number_parse, /[^0-9.]/ do |match, remainder|
      @output << '</font>'
      parse "#{match}#{remainder}"
    end

    smulti :number_parse, /$/ do |match, remainder|
      @output
    end
  end

  def highlight
    parse(@sql)
  end
end

puts '<pre>'

STDIN.read.each_line do |line|
  puts SQL.new(line).highlight
end

puts '</pre>'
