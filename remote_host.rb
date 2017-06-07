require 'net/ssh'
class RemoteHost
  def initialize(host, user = 'root', options = {})
    @host = host
    @user = user
    @options = options
  end

  def last_logins
    logins = []
    exec do |ssh|
      result = ''
      ssh.exec!('last') do |_channel, stream, data|
        result << data if stream == :stdout
      end
      result.split("\n").each do |line|
        line.chomp!
        fields = [line[0, 9], line[9, 13], line[22, 17], line[39..-1]]
        next if fields.include?(nil)
        logins << fields.map(&:strip)
      end
    end
    logins
  end

  private

  def exec
    Net::SSH.start(@host, @user, @options) do |ssh|
      yield ssh
    end
  end
end
