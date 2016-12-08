require 'socket'

module MessageTasks
  def break_apart(request)
    # Just in case the server recieves other fields (host), or a newline, we first split on
    # newline, and then break apart the first line by spaces and return it.
    request = request.gsub("\r", "").split("\n")
    request[0] = request[0].split(" ")

    request[0]
  end

  def check_request(request)
    response = nil
    puts "REQ: #{request}"
    case
    when request.length != 3
      response = "HTTP/1.1 400 Bad Request\r\n"
    when !(["HTTP/1.1", "HTTP/1.0"].include? request[2].upcase)
      response = "HTTP/1.1 505 HTTP Version not supported\r\n"
    end

    response
  end

  def format_response(resource, type, http)
    case
    when resource.nil?
      response = "#{http} #{type=="GET" ? "404" : "400"} Not Found"
    when (["GET", "HEAD"].include? type)
      response = "#{http} 200 OK\r\n#{gen_datetime}\r\nContent-Type:text/plain\r\nContent-Length:#{resource.length}\r\n"
      response = type=="HEAD" ? response : "#{response}\r\n#{resource}\r\n"
    end
  end

  def gen_datetime
    Time.now.gmtime.strftime("%a, %d %b %Y %T GMT")
  end
end


class SimpleServer
  def initialize(port)
    @server = TCPServer.open(port)
  end

  def start
    loop {
      client  = @server.accept
      request = client.gets
      handler = RequestHandler.new(request)

      response = handler.process_request

      client.puts response
      client.close
    }
  end
end


class RequestHandler

  include MessageTasks

  def initialize(request)
    @request = break_apart(request)
  end

  def process_request
    response = check_request(@request)
    return response unless response.nil?

    response = get_response
    puts "RESP1: #{response}"
    response = format_response(response, @request[0], @request[2])
    puts "RESP2: #{response}"
    response
  end

  def get_response
    response = nil
    case @request[0]
    when "HEAD"
      response = get(true)
    when "GET"
      response = get(false)
    when "PUT"
      put
    else
      response = "#{@request[2]} 501 Not Implemented\r\n"
    end

    response
  end

  def get(header)
    resource = Dir.pwd.concat(@request[1])
    if File.exist?(resource)
      resource = File.open(resource, "r") { |file| file.read }
      resource = resource.length if header
    else
      resource = nil
    end

    resource
  end

  def put
    nil
  end
end

# Only start the server if toplevel
if __FILE__ == $0 || true
  server = SimpleServer.new(2000)
  server.start
end
