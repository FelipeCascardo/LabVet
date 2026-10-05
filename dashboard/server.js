const http = require('http');
const fs = require('fs');
const path = require('path');

const root = __dirname;
const mime = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8' };

http.createServer((request, response) => {
  const requested = request.url === '/' ? 'index.html' : request.url.split('?')[0].replace(/^\//, '');
  const file = path.resolve(root, requested);
  if (!file.startsWith(root + path.sep)) { response.writeHead(403); return response.end(); }
  fs.readFile(file, (error, content) => {
    if (error) { response.writeHead(404); return response.end('Arquivo não encontrado'); }
    response.writeHead(200, { 'Content-Type': mime[path.extname(file)] || 'application/octet-stream' });
    response.end(content);
  });
}).listen(4173, '127.0.0.1', () => console.log('Dashboard local em http://127.0.0.1:4173'));
