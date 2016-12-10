# simple_webserver_and_client
A simple web server and client that communicate with each other.

### Server
Starts server on port 2000
```shell
SimpleServer.new(2000).start
```

### Client

Making a GET request.

```shell
SimpleClient.new.connect("http://localhost:2000/index.html", "GET")
200 OK
<html>
  <body>
    <h1>Welcome to my Home Page</h1>
  </body>
</html>
 => true 
```

Making a HEAD request
```shell
SimpleClient.new.connect("http://localhost:2000/index.html", "HEAD")
200 OK 1.1
 => true
```

Making a POST request
```shell
data = {:Person=>{:name=>'Joe Bloggs', :email=>'joe.bloggs1@yahoo.com'}}
SimpleClient.new.connect("http://localhost:2000/index.html", "HEAD", :data=>data)
303 See Other 1.1
200 OK 1.1
<html>
  <body>
    <h1>Thanks for Posting!</h1>
    <h2>Here's what we got from you:</h2>
    <ul>
      <li>Person:-</li>
      <ul>
        <li>name: Joe Bloggs</li>
        <li>email: joe.bloggs1@yahoo.com</li>
      </ul>
    </ul>
  </body>
</html>
 => true 
```

Using verbose mode
```shell
SimpleClient.new.connect("http://localhost:2000/index.html", "GET", :verbose=>true)
http_version: 1.1
code: 200
message: OK
header:
	date: Sat, 10 Dec 2016 20:21:38 GMT
	server: Simple-Server
	connection: Close
	content-type: text/html
	content-length: 71
read: true
uri: 
decode_content: true
socket: 
body_exist: true
<html>
  <body>
    <h1>Welcome to my Home Page</h1>
  </body>
</html>
 => true 
```
