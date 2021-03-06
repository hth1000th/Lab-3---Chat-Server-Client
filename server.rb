require 'socket'

class Server
  def initialize
    @server = TCPServer.new 2000
    @user_list = Hash.new
    connected
  end

# to connect server with each client
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
        commands(username, client)
      end
    end
  end

# commands executed for client
  def commands(username, client)
    loop do
      command = client.gets.chomp
      other_user = Array.new
      message = Array.new
      # broadcast message
      if command[0..9] == "broadcast "
        message.push(*command[10..-1])
        broadcast(username, client, message.join(""))
      # send username message
      elsif command[0..4] == "send "
        command[5..-1].split("").each do |c|
          if c == " "
            break
          else
            other_user.push(c)
          end
        end
        message.push(*command[5..-1])
        message[0].slice!(0..other_user.length)
        send(username, client, other_user.join(""), message.join(""))
      # show the userlist for current clients
      elsif command == "userlist"
        userlist(username, client)
      # to disconnect client from server
      elsif command == "disconnect"
        disconnect(username, client)
      # if the command from client is incorrect
      else
        client.puts "Wrong input!"
      end
    end
  end

  def broadcast(username, client, message)
    puts "BROADCAST #{message}"
    client.puts "SENT"
    @user_list.each do |other_username, other_client|
      if other_client != client
        other_client.puts "BROADCASTED #{username}: #{message}"
        puts "RECEIVED"
      end
    end
  end

  def send(username, client, other_user, message)
    puts "SEND #{other_user} #{message}"
    @user_list.each do |u, c|
      if other_user == u && message != NIL
        client.puts "SENT"
        @user_list[other_user].puts "SENTFROM #{username} #{message}"
        puts "RECEIVED"
      end
    end
  end

  def userlist(username, client)
    @user_list.each do |u, c|
      if username == u
        client.puts "My username: #{u}"
      else
        client.puts "Other client: #{u}"
      end
    end
  end

  def disconnect(username, client)
    puts "DISCONNECT"
    client.puts "DISCONNECTED"
    @user_list.each do |u, c|
      if username != u
        @user_list[u].puts "DISCONNECTED #{username}"
        puts "RECEIVED"
      end
      @user_list.delete(username)
    end
    client.close
  end

  def stopping
    server_cmd = gets.chomp
    if server_cmd == "stopping"
      puts "this is stopping"
      @user_list.each do |u, c|
        @user_list[u].puts "STOPPING"
        @user_list[u].close
      end
      @server.close
    end
  end
end

s = Server.new
