### Basic Usage

junixsocket supports the [Java Socket API](https://docs.oracle.com/javase/8/docs/api/java/net/Socket.html). `AFUNIXSocket` and `AFUNIXServerSocket` work just like their AF_INET (TCP/IP) Socket counterparts — they extend `java.net.Socket` and `java.net.ServerSocket` respectively.

## Connecting to an existing AF_UNIX Socket

    File socketFile = new File("/path/to/your/socket");
    AFUNIXSocket sock = AFUNIXSocket.newInstance();
    sock.connect(new AFUNIXSocketAddress(socketFile));

## Creating a new AF_UNIX Server Socket

    File socketFile = new File("/path/to/your/socket");
    AFUNIXServerSocket server = AFUNIXServerSocket.newInstance();
    server.bind(new AFUNIXSocketAddress(socketFile));

### Complete Examples

junixsocket provides working demos for:

  * plain Unix Domain Socket client/server communication
  * RMI-over-Unix-Socket.
  * MySQL-over-Unix-Socket.

### Caveats

## Maximum path length

At the system-level, the maximum length of the pathname referring to a Unix domain socket is restricted and may vary from one OS to another. Currently, junixsocket limits the maximum pathname length to 103 bytes (this may mean less characters, depending on the encoding). If the maximum length is exceeded an Exception is thrown.

It is recommended to use short pathnames whenever possible.

## Security

Unix domain server sockets are created with read-write privileges for everybody on the sytem, just like TCP/IP sockets are accessible for local users.

If you want to restrict access to a particular user or group, simply create the socket in a directory that has proper access restrictions.

## Ports

Whereas TCP/IP sockets point to ports at particular Internet addresses, AF_UNIX sockets point to special files on the local file system. The notion of "port" is not necessary in this case.

However, we need ports for RMI. This is why `AFUNIXSocketAddress` also supports them.

Port support may also come handy in other situations, especially when an existing application expects a particular port on a Socket. Please be aware that specifying a particular port number has no effect for non-RMI connections.
