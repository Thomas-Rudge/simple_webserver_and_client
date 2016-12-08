require 'net/http'

def client_browser(host, path)
  http = Net::HTTP.new(*host)          # Create a connection
  resource = http.get(path)      # Request the file

  if resource.code == "200"            # Check the status code
    print resource.body
  else
    puts "#{resource.code} #{resource.message}"
  end
end


if __FILE__ == $0 || true
  host = ['localhost', 2000]
  path = '/index.html'

  client_browser(host, path)
end
