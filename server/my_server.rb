require 'socket'

module MessageTasks
  def break_apart(request)
    request = request.gsub("\r", "").split("\n")
    request[0] = request[0].split(" ")

    request
  end

  def check_request(request)
    response = nil
    puts "REQ: #{request}"
    case
    when request[0].lengh != 3
      response = "HTTP/1.1 400 Bad Request\r\n"
    when !["HTTP/1.1", "HTTP/1.0"].include? request[2].upcase
      response = "HTTP/1.1 505 HTTP Version not supported\r\n"
    when request[2].upcase == "HTTP/1.1"
      cnt = 0
      request.each { |field| (field.downcase.start_with? "host:") ? cnt+=1 : nil }
      if cnt == 0
        response = "HTTP/1.1 400 Bad Request\r\n"
      end
    end

    response
  end

  def format_response(resource, header)
    if resource.nil?
      response = "HTTP/1.1 404 Not Found"
    else
      response = "HTTP/1.1 200 OK\r\n#{gen_datetime}\r\nContent-Type:text/plain\r\nContent-Length:#{resource.length}\r\n"
      response = header ? response : "#{response}\r\n#{resource}\r\n"
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

    response = get_response(@request)

    response
  end

  def get_response(request)
    response = nil
    case request[0]
    when "HEAD"
      response = get(request[1], true)
    when "GET"
      response = get(request[1], false)
    when "PUT"
      put
    else
      response = "#{request[2]} 501 Not Implemented\r\n"
    end

    response
  end

  def gen_datetime
    Time.now.gmtime.strftime("%a, %d %b %Y %T GMT")
  end

  def get(resource, header)
    resource = Dir.pwd.concat(resource)
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


class SimpleServer
  def initialize(port)
    @server = TCPServer.open(port)
  end

  def start(server)
    loop {
      client  = server.accept
      request = client.gets
      handler = RequestHandler(request)

      response = handler.process_request

      client.puts response
      client.close
    }
  end
end

# Only start the server if toplevel
if __FILE__ == $0
  server = SimpleServer.new(2000)
  server.start
end
