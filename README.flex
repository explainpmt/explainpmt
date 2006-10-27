= Building the Flex interface

To build the Flex interface, you need to use the Flex 2 Builder application 
or the Flex 2 SDK. Building requires at least build 150681 of the mxmlc flex
compiler.

To build using the command line compiler, simply execute

  rake flex

from the project directory. To build the debugging version of the interface,
execute

  rake flex DEBUG=true

= Using the Flex interface

To access the flex interface, start the server and navigate to
http://myhost.example.com/bin/explainpmt.html