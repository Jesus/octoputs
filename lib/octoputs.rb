require 'octoputs/puma_http11'
require 'socket'

def log(event, details = '')
  puts "%12s | %-16s | %s" % [
    Time.now.strftime("%H:%M %S.%L"),
    event,
    details
  ]
end

class Octoputs
  HOST = '127.0.0.1'
  PORT = 3000

  def initialize(app)
    @app = app
  end

  # This may block until the whole request is read
  def read_request(fd)
    parser = Puma::HttpParser.new
    env = {}
    n_bytes = 0

    until parser.finished?
      begin
        read_bytes = fd.read_nonblock(1024)
        n_bytes = parser.execute(env, read_bytes, n_bytes)
      rescue Errno::EAGAIN
        IO.select [fd]
        retry
      rescue EOFError
        return :closed
      end
    end

    env
  end

  def write_response(fd, result)
    status, headers, body = result

    begin
      case status
      when 200
        fd.write("HTTP/1.1 200 OK\r\n")
      else
        raise NotImplementedError, "Status code #{status} not yet implemented"
      end

      headers.each do |key, value|
        fd.write("#{key}: #{value}\r\n")
      end

      # Note: We may be sending this header twice if it was set by the app too
      fd.write("Content-Length: #{body.size}\r\n")

      fd.write("\r\n")
      fd.write(body)
    rescue Errno::EPIPE
      # Client lost...
    ensure
      fd.close
    end
  end

  def handle_request(fd)
    request_id = "fd:#{fd.fileno}"
    log("#{request_id} start")

    # Read the whole request and parse it
    request = read_request(fd)
    if request == :closed
      log("#{request_id} closed")
      return
    end

    log(
      "#{request_id} parsed",
      request.values_at('REQUEST_METHOD', 'REQUEST_PATH').join(' ')
    )

    # Execute the Rack application
    result = @app.call(request)

    # Write the result of the application back to the browser
    write_response(fd, result)

    log("#{request_id} done", "status: #{result.first}")
  end

  def listen
    server = TCPServer.new(HOST, PORT)
    server.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true

    # Note: I've explored changing the value of the backlog. I was expecting
    #       that when the amount of concurrent requests is higher than the
    #       allowed backlog of the listening server the connections would start
    #       being rejected, however they seem to be kept waiting.
    #
    #       Even weirder, seems like connections are quickly accepted but take
    #       longer to be read, which is very confusing.
    #
    #       Also in some cases they're being closed but I'm not sure at what
    #       point of the request lifecycle. This never happens when concurrency
    #       in the benchmarking tool is set to something smaller than backlog.
    server.listen 10

    loop do
      sockets, = IO.select [server], nil, nil, 0

      if sockets
        sockets.each do |socket|
          fd = socket.accept_nonblock
          handle_request(fd)
        end
      end
    end
  end
end
