const http = require('http');
const port = 3000;
http.createServer((req, res) => {
  res.end('Hello from Docker Node!');
}).listen(port, () => console.log('Server listening on port', port));

