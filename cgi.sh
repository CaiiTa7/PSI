#!/bin/bash

echo -e "Content-type: text/html\n\n<html><body><h1>Hello, CGI!</h1></body></html>" > /usr/local/apache2/cgi-bin/test.cgi
chmod +x /usr/local/apache2/cgi-bin/test.cgi
