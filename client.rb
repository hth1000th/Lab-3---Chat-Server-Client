require 'socket'

class Client
  def initialize
    server = TCPSocket.new 'localhost', 2000
    server.close
  end
end

Client.new
