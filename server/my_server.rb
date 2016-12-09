require 'socket'
require 'json'
require 'securerandom'
require_relative 'message_tasks'

class SimpleServer
  def initialize(port)
    @server = TCPServer.open(port)
  end

  def start
    loop {
      client  = @server.accept
      request = Array.new

      while true
        line = client.gets
        request << line.gsub("\r\n", "")
        break if line == "\r\n"
      end
      # If it's a POST, read in the data using the content-length
      if request[0].upcase.start_with? "POST"
        request.each do |field|
          if field.start_with? "Content-Length"
            request[-1] = client.read(field.match(/\d+/).to_s.to_i)
          end
        end
      end

      handler = RequestHandler.new(request)

      response = handler.handle_request
      puts "#{response}"
      client.puts response
      client.close
    }
  end
end


class RequestHandler

  include MessageTasks

  def initialize(request)
    @request  = request
    @response = nil
    @data     = nil

    break_apart

    @data = (@request.length > 1) ? @request[-1] : @data
    @request = @request[0]
    @request[0].upcase!
  end

  def handle_request
    check_for_errors

    return @response unless @response.nil?

    process_request
    format_response

    @response
  end

  def break_apart
    @request.compact!
    @request[0] = @request[0].split(" ")

    if @request[0][0].upcase == "POST" && @request.length > 1
      @request[-1] = JSON.parse(@request[-1])
    end
  end

  def check_for_errors
    http = (["HTTP/1.1", "HTTP/1.0"].include? @request[2].upcase) ? @request[2] : nil

    case
    when http.nil?
      @response = "HTTP/1.1 505 HTTP Version not supported\r\n#{header_fields()}"
    when @request.length != 3
      @response = "#{http} 400 Bad Request\r\n#{header_fields()}"
    when !(["GET", "HEAD", "POST"].include? @request[0].upcase)
      @response = "#{http} 501 Not Implemented\r\n#{header_fields()}"
    when @request[0] == "POST" && @data.nil?
      @response = "#{http} 422 Unprocessable Entity\r\n#{header_fields()}"
    end
  end

  def process_request
    @request[1] = "/thanks.html" if @request[0] == "POST"
    @request[1] = Dir.pwd.concat(@request[1])

    if File.file? @request[1]
      @response = File.open(@request[1], "r") { |file| file.read }
      @response = @request[1].length if @request[0] == "HEAD"

      create_redirect_page if @request[0] == "POST"
    end
  end

  def create_redirect_page
    new_ele = create_html_ul_array_from_hash(@data)
    new_ele = create_html_ul_string_from_array(new_ele)

    @response.gsub!(/<%=.*%>/, new_ele)

    @request[1] = "/thanks_#{SecureRandom.uuid}.html"
    path = Dir.pwd.concat(@request[1])

    File.open(path, "w") { |file| file.write(@response) }
  end

  def format_response
    case
    when @response.nil?
      if ["GET", "HEAD"].include? @request[0]
        @response = "#{@request[2]} 404 Not Found\r\n#{header_fields()}"
      else
        @response = "#{@request[2]} 500 Internal Server Error\r\n#{header_fields()}"
      end
    when (["GET", "HEAD"].include? @request[0])
      response = "#{@request[2]} 200 OK\r\n"
      response += header_fields()
      response += "Content-Type:text/html\r\nContent-Length:"
      response += "#{(@response.is_a? Integer) ? @response : @response.length}\r\n"

      @response = @request[0]=="HEAD" ? response : "#{response}\r\n#{@response}\r\n"
    when @request[0] == "POST"
      @response = "#{@request[2]} 303 See Other\r\nLocation:#{@request[1]}\r\n#{header_fields}"
    end
  end
end

# Only start the server if toplevel
if __FILE__ == $0
  server = SimpleServer.new(2000)
  server.start
end
