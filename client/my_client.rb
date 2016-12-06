require 'net/http'

def client_browser(host, path)
  http = Net::HTTP.new(host)          # Create a connection
  headers, body = http.get(path)      # Request the file

  if headers.code == "200"            # Check the status code
    print body
  else
    puts "#{headers.code} #{headers.message}"
  end
end

if __FILE__ == $0
  host = 'localhost:2000'
  path = '/index.html'

  client_browser(host, path)
end
