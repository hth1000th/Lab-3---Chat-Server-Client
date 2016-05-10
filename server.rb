require 'socket'

class Server
  def initialize
    @server = TCPServer.new 2000
    @user_list = Hash.new
    connected
  end

  def connected
    loop do
      Thread.start(@server.accept) do |client|
        client.puts "Enter the username:"
        username = client.gets.chomp
        puts "CONNECT #{username}"
        @user_list.each do |u, c|
          if u == username
            client.puts "FAILED"
            Thread.kill self
          end
        end
        @user_list[username] = client
        client.puts "CONNECTED"
        client.puts "If you want BROADCAST enter 1 or if you want SEND enter 2"
        choice = client.gets.chomp
        if choice == '1'
          broadcast(username, client)
        elsif choice == '2'
          send(username, client)
        else
          client.puts "Wrong input!"
        end
      end
    end
  end

  def broadcast(username, client)
    loop do
      message = client.gets.chomp
      if message[0] == 'e'
        client.close
      end
      puts "BROADCAST #{message}"
      client.puts "SENT"
      @user_list.each do |other_username, other_client|
        if other_client != client
          other_client.puts "BROADCASTED #{username}: #{message}"
          puts "RECEIVED"
        end
      end
    end
  end

  def send(username, client)
    loop do
      client.puts "Enter the username to send the message:"
      other_user = client.gets.chomp
      client.puts "Enter the message:"
      message = client.gets.chomp
      if message[0] == 'e'
        client.close
      end
      puts "SEND #{other_user} #{message}"
      @user_list.each do |u, c|
        if other_user == u && message != NIL
          client.puts "SENT"
          @user_list[other_user].puts "SENTFROM #{username} #{message}"
          puts "RECEIVED"
        end
      end
    end
  end

  def disconnected
  end

  def stopping
  end
end

s = Server.new
