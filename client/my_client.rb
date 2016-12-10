require 'net/http'
require 'uri'
require 'json'

class SimpleClient
  def connect(site, method, data:nil, verbose:nil)
    @site = URI.parse(site)

    @path     = @site.request_uri
    @method   = method.upcase
    @data     = data
    @verbose  = verbose
    @response = nil

    @http = Net::HTTP.new(@site.host, @site.port)

    client_action
    return if @response.nil?
    verbose_output if verbose

    output_response

    act_on_redirect if @method == "POST"
  end

  def client_action
    case @method
    when "GET"
      @response = @http.get(@path)
    when "POST"
      @response = @http.post(@path, @data.to_json, {"Content-Type"=>"application/json"})
    when "HEAD"
      @response = @http.head(@path)
    else
      puts "Unsupported method: #{@method}"
    end
  end

  def output_response
    puts "#{@response.code} #{@response.message} #{@response.http_version}" unless @verbose
    print @response.body if @response.instance_variable_get(:@body_exist)
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

  def act_on_redirect
    if @response.to_hash.keys.include? "location"
      @site::path = @response.to_hash["location"][0]
      SimpleClient.new.connect(@site.to_s, "GET")
    end
  end
end

if __FILE__ == $0
  path = "http://localhost:2000/index.html"
  method = "POST"
  data = {:Person=>{:name=>'Joe Bloggs', :email=>'joe.bloggs1@yahoo.com'}}

  SimpleClient.new.connect(path, method, :data=>data, :verbose=>true)
end
