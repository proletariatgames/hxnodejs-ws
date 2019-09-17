package js.npm.ws;
import haxe.extern.EitherType;
import js.node.events.EventEmitter;
import js.node.http.*;
#if haxe4
import js.lib.Error;
#else
import js.Error;
#end

@:enum abstract ServerEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
  /**
    Event: 'connection'
      socket {WebSocket}
      request {http.IncomingMessage}

    Emitted when the handshake is complete. request is the http GET request sent by the client.
    Useful for parsing authority headers, cookie headers, and other information.
  **/
  var Connection:ServerEvent<WebSocket->js.node.http.IncomingMessage->Void> = 'connection';


  /**
    Event: 'error'

        error {Error}

    Emitted when an error occurs on the underlying server.
  **/
  var Error:ServerEvent<Error->Void> = 'error';

  /**
    Event: 'headers'

        headers {Array}
        request {http.IncomingMessage}

    Emitted before the response headers are written to the socket as part of the handshake. This allows you to inspect/modify the headers before they are sent.
  **/
  var Headers:ServerEvent<Array<Dynamic>->js.node.http.IncomingMessage->Void> = 'headers';

  /**
    Event: 'listening'

    Emitted when the underlying server has been bound.
  **/
  var Listening:ServerEvent<Void->Void> = 'listening';
}

/**
  This class represents a WebSocket server.
**/
@:jsRequire("ws", "Server")
extern class Server extends EventEmitter<Server>
{
  /**
    Create a new server instance. One of port, server or noServer must be provided
    or an error is thrown. An HTTP server is automatically created, started, and used
    if port is set. To use an external HTTP/S server instead, specify only server or noServer.
    In this case the HTTP/S server must be started manually. The "noServer" mode allows the
    WebSocket server to be completly detached from the HTTP/S server. This makes it possible,
    for example, to share a single HTTP/S server between multiple WebSocket servers.
  **/
  @:overload(function(options:ServerOptions, callback:IncomingMessage->ServerResponse->Void):Void {})
  public function new(options:ServerOptions);

  public function address():js.node.net.Socket.SocketAdress;

  /**
    Close the HTTP server if created internally, terminate all clients and call callback when done.
    If an external HTTP server is used via the server or noServer constructor options, it must be closed manually.
  **/
  @:overload(function(callback:Void->Void):Void {})
  public function close():Void;

  /**
    Handle a HTTP upgrade request. When the HTTP server is created internally or when the HTTP server is passed via
    the server option, this method is called automatically. When operating in "noServer" mode, this method must be called manually.

    If the upgrade is successful, the callback is called with a WebSocket object as parameter.
  **/
  public function handleUpgrade(request:js.node.http.IncomingMessage, socket:js.node.net.Socket, head:js.node.Buffer, callback:WebSocket->Void):Void;

  /**
    See if a given request should be handled by this server. By default this method validates the pathname of
    the request, matching it against the path option if provided. The return value, true or false, determines
    whether or not to accept the handshake.

    This method can be overridden when a custom handling logic is required.
  **/
  dynamic public function shouldHandle(request:js.node.http.IncomingMessage):Bool;
}

typedef ServerOptions = {

  /**
  The hostname where to bind the server.
  **/
  @:optional var host:String;

  /**
  The port where to bind the server.
  **/
  @:optional var port:Int;

  /**
  The maximum length of the queue of pending connections.
  **/
  @:optional var backlog:Int;

  /**
  A pre-created Node.js HTTP/S server.
  **/
  @:optional var server:EitherType<js.node.http.Server,js.node.https.Server>;

  /**
    A function which can be used to validate incoming connections.

    if verifyClient is provided with two arguments - of which a callback with the following arguments:
      result {Boolean} Whether or not to accept the handshake.
      code {Number} When result is false this field determines the HTTP error status code to be sent to the client.
      name {String} When result is false this field determines the HTTP reason phrase.
      headers {Object} When result is false this field determines additional HTTP headers to be sent to the client.
        For example, { 'Retry-After': 120 }.
  **/
  @:optional var verifyClient:EitherType<
    VerifyClientObject->Bool,
    VerifyClientObject->(Bool->Null<Int>->String->haxe.DynamicAccess<String>->Void)->Void
  >;

  /**
    A function which can be used to handle the WebSocket subprotocols.

    handleProtocols takes two arguments:

        protocols {Array} The list of WebSocket subprotocols indicated by the client
          in the Sec-WebSocket-Protocol header.
        request {http.IncomingMessage} The client HTTP GET request.

    The returned value sets the value of the Sec-WebSocket-Protocol header in the HTTP 101 response.
      If returned value is false the header is not added in the response.

    If handleProtocols is not set then the first of the client's requested subprotocols is used.
  **/
  @:optional var handleProtocols:Array<String>->js.node.http.IncomingMessage->Bool;

  /**
  Accept only connections matching this path.
  **/
  @:optional var path:String;

  /**
  Enable no server mode.
  **/
  @:optional var noServer:Bool;

  /**
  Specifies whether or not to track clients.
  **/
  @:optional var clientTracking:Bool;

  /**
  Enable/disable permessage-deflate.
  **/
  @:optional var perMessageDeflate:EitherType<Bool,PerMessageDeflateArgs>;

  /**
  The maximum allowed message size in bytes.
  **/
  @:optional var maxPayload:Float;
};

typedef PerMessageDeflateArgs = {
  /**
  Whether to use context takeover or not.
  **/
  @:optional var serverNoContextTakeover:Bool;
  /**
  Acknowledge disabling of client context takeover.
  **/
  @:optional var clientNoContextTakeover:Bool;
  /**
  The value of windowBits.
  **/
  @:optional var serverMaxWindowBits:Int;
  /**
  Request a custom client window size.
  **/
  @:optional var clientMaxWindowBits:Int;
  /**
  Additional options to pass to zlib on deflate.
  **/
  @:optional var zlibDeflateOptions:js.node.Zlib.ZlibOptions;
  /**
  Additional options to pass to zlib on inflate.
  **/
  @:optional var zlibInflateOptions:js.node.Zlib.ZlibOptions;
  /**
  Payloads smaller than this will not be compressed. Defaults to 1024 bytes.
  **/
  @:optional var threshold:Int;
  /**
  The number of concurrent calls to zlib. Calls above this limit will be queued. Default 10.
  You usually won't need to touch this option. See this issue for more details.
  **/
  @:optional var concurrencyLimit:Int;
};

typedef VerifyClientObject = {
  /**
  The value in the Origin header indicated by the client.
  **/
  var origin:String;

  /**
  The client HTTP GET request.
  **/
  var req:js.node.http.IncomingMessage;

  /**
  true if req.connection.authorized or req.connection.encrypted is set.
  **/
  var secure:Bool;
};