require 'net/http'
require 'uri'
require 'json'

class SimpleClient
  def connect(site, method, data:nil, verbose:nil)
    site = URI.parse(site)

    @path     = site.request_uri
    @method   = method.upcase
    @data     = data
    @verbose  = verbose
    @response = nil

    @http = Net::HTTP.new(site.host, site.port)

    client_action
    return if @response.nil?
    verbose_output if verbose

    output_response
  end

  def client_action
    case @method
    when "GET"
      @response = @http.get(@path)
    when "POST"
      @response = @http.post(@path, @data.to_json)s
    when "HEAD"
      @response = @http.head(@path)
    else
      puts "Unsupported method: #{@method}"
    end
  end

  def output_response
    puts "#{@response.code} #{@response.message}" unless @verbose

    print @response.body
  end

  def verbose_output
    @response.instance_variables.each do |var|
      if var == :@header
        puts "header:"
        @response.header.each { |key, value| puts "\t#{key}: #{value}" }
      else
        puts "#{var[1..-1]}: #{@response.instance_variable_get(var)}" unless var == :@body
      end
    end
  end
end

if __FILE__ == $0 || true
  path = "http://localhost:2000/index.html"
  method = "POST"
  data = {:Person=>{:name=>'Joe Bloggs', :email=>'joe.bloggs1@yahoo.com'}}

  SimpleClient.new.connect(path, method, :data=>data, :verbose=>true)
end
