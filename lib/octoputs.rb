require 'octoputs/puma_http11'
require 'socket'

class Octoputs
  def initialize
    puts Puma::HttpParser.new.inspect
  end

  # def listen
  #   host = "127.0.0.1"
  #   port = 9000
  #
  #   server = TCPServer.new(host, port)
  #   server.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true
  #   server.listen 3
  #
  #   loop do
  #     sockets, = IO.select [server], nil, nil, 0
  #     if sockets
  #       sockets.each do |socket|
  #         fd = socket.accept_nonblock
  #         puts fd.read
  #       end
  #     end
  #     sleep 0.1
  #   end
  # end
end
