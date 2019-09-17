package js.npm.ws;
import haxe.extern.EitherType;
import js.node.events.EventEmitter;
#if haxe4
import js.lib.ArrayBuffer;
import js.lib.Error;
#else
import js.html.ArrayBuffer;
import js.Error;
#end

abstract Data(Dynamic)
  from js.node.Buffer
  from String
  from ArrayBuffer
  from Array<js.node.Buffer>
{
  inline public function asBuffer(ws:WebSocket):js.node.Buffer {
    if (ws.binaryType == NodeBuffer) {
      return this;
    } else {
      throw 'Cannot get buffer when bufferType is ${ws.binaryType}';
    }
  }

  inline public function asArrayBuffer(ws:WebSocket):ArrayBuffer {
    if (ws.binaryType == ArrayBuffer) {
      return this;
    } else {
      throw 'Cannot get buffer when bufferType is ${ws.binaryType}';
    }
  }

  inline public function asFragments(ws:WebSocket):Array<js.node.Buffer> {
    if (ws.binaryType == Fragments) {
      return this;
    } else {
      throw 'Cannot get fragments when bufferType is ${ws.binaryType}';
    }
  }

  inline public function isBinary()
  {
    return !Std.is(this, String);
  }

  inline public function asString():String
  {
    if (!Std.is(this, String))
    {
      throw 'Cannot cast $this to String';
    }
    return this;
  }
}

@:enum abstract WebSocketEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T> {
  /**
  Event: 'close'

      code {Number}
      reason {String}

  Emitted when the connection is closed. code is a numeric value indicating the status code explaining
  why the connection has been closed. reason is a human-readable string explaining why the connection has been closed.
  **/
  var Close:WebSocketEvent<Int->String->Void> = 'close';
  /**
  Event: 'error'

      error {Error}

  Emitted when an error occurs.
  **/
  var Error:WebSocketEvent<Error->Void> = 'error';

  /**
  Event: 'message'

      data {String|Buffer|ArrayBuffer|Buffer[]}

  Emitted when a message is received from the server.
  **/
  var Message:WebSocketEvent<Data->Void> = 'message';

  /**
  Event: 'open'

  Emitted when the connection is established.
  **/
  var Open:WebSocketEvent<Void->Void> = 'open';

  /**
  Event: 'ping'

      data {Buffer}

  Emitted when a ping is received from the server.
  **/
  var Ping:WebSocketEvent<js.node.Buffer->Void> = 'ping';

  /**
  Event: 'pong'

      data {Buffer}

  Emitted when a pong is received from the server.
  **/
  var Pong:WebSocketEvent<js.node.Buffer->Void> = 'pong';

  /**
  Event: 'unexpected-response'

      request {http.ClientRequest}
      response {http.IncomingMessage}

  Emitted when the server response is not the expected one, for example a 401 response.
  This event gives the ability to read the response in order to extract useful information.
  If the server sends an invalid response and there isn't a listener for this event, an error is emitted.
  **/
  var UnexpectedResponse:WebSocketEvent<js.node.http.ClientRequest->js.node.http.IncomingMessage->Void> = 'unexpected-response';

  /**
  Event: 'upgrade'

      response {http.IncomingMessage}

  Emitted when response headers are received from the server as part of the handshake.
  This allows you to read headers from the server, for example 'set-cookie' headers.
  **/
  var Upgrade:WebSocketEvent<js.node.http.IncomingMessage->Void> = 'upgrade';
}

@:jsRequire("ws")
extern class WebSocket extends EventEmitter<WebSocket> {

  /**
    Create a new WebSocket instance.
  **/
  @:overload(function(address:EitherType<String, js.node.Url>):Void {})
  @:overload(function(address:EitherType<String, js.node.Url>, protocols:EitherType<String, Array<String>>):Void {})
  public function new(address:EitherType<String,js.node.Url>, protocols:EitherType<String,Array<String>>, options:WebSocketOptions);

  /**
    A string indicating the type of binary data being transmitted by the connection. This should be one of "nodebuffer", "arraybuffer" or "fragments".
    Defaults to "nodebuffer". Type "fragments" will emit the array of fragments as received from the sender, without copyfull concatenation,
    which is useful for the performance of binary protocols transferring large messages with multiple fragments.
  **/
  public var binaryType:BinaryType;

  /**
    The number of bytes of data that have been queued using calls to send() but not yet transmitted to the network.
  **/
  public var bufferedAmount:Int;

  /**
    Initiate a closing handshake.
        code {Number} A numeric value indicating the status code explaining why the connection is being closed.
        reason {String} A human-readable string explaining why the connection is closing.
  **/
  @:overload(function(code:Int):Void {})
  @:overload(function(code:Int, reason:String):Void {})
  public function close():Void;

  /**
    An object containing the negotiated extensions.
  **/
  public var extensions:Dynamic;

  /**
  websocket.ping([data[, mask]][, callback])

      data {Any} The data to send in the ping frame.
      mask {Boolean} Specifies whether data should be masked or not. Defaults to true when websocket is not a server client.
      callback {Function} An optional callback which is invoked when the ping frame is written out.

  Send a ping.
  **/
  @:overload(function(data:Data, mask:Bool):Void {})
  @:overload(function(data:Data):Void {})
  @:overload(function():Void {})
  @:overload(function(data:Data, callback:Error->Void):Void {})
  @:overload(function(callback:Error->Void):Void {})
  public function ping(data:Data, mask:Bool, callback:Void->Void):Void;

  /**
  websocket.pong([data[, mask]][, callback])

      data {Any} The data to send in the pong frame.
      mask {Boolean} Specifies whether data should be masked or not. Defaults to true when websocket is not a server client.
      callback {Function} An optional callback which is invoked when the pong frame is written out.

  Send a pong.
  **/
  @:overload(function(data:Data, mask:Bool):Void {})
  @:overload(function(data:Data):Void {})
  @:overload(function():Void {})
  @:overload(function(data:Data, callback:Error->Void):Void {})
  @:overload(function(callback:Error->Void):Void {})
  public function pong(data:Data, mask:Bool, callback:Void->Void):Void;

  /**
  websocket.protocol

      {String}

  The subprotocol selected by the server.
  **/
  public var protocol:String;

  /**
  websocket.readyState

      {Number}

  The current state of the connection. This is one of the ready state constants.
  **/
  public var readyState:ReadyState;

  /**
  websocket.send(data[, options][, callback])

      data {Any} The data to send.
      options {Object}
          compress {Boolean} Specifies whether data should be compressed or not. Defaults to true when permessage-deflate is enabled.
          binary {Boolean} Specifies whether data should be sent as a binary or not. Default is autodetected.
          mask {Boolean} Specifies whether data should be masked or not. Defaults to true when websocket is not a server client.
          fin {Boolean} Specifies whether data is the last fragment of a message or not. Defaults to true.
      callback {Function} An optional callback which is invoked when data is written out.

  Send data through the connection.
  **/
  @:overload(function(data:Data, options:WebSocketOptions):Void {})
  @:overload(function(data:Data, callback:Error->Void):Void {})
  public function send(data:Data, options:WebSocketOptions, callback:Error->Void):Void;

  /**
  websocket.terminate()

  Forcibly close the connection.
  **/
  public function terminate():Void;

  /**
  websocket.url

      {String}

  The URL of the WebSocket server. Server clients don't have this attribute.
  **/
  public var url:String;
}

typedef WebSocketSendArgs = {
  /**
  Specifies whether data should be compressed or not. Defaults to true when permessage-deflate is enabled.
  **/
  ?compress:Bool,
  /**
  Specifies whether data should be sent as a binary or not. Default is autodetected.
  **/
  ?binary:Bool,
  /**
  Specifies whether data should be masked or not. Defaults to true when websocket is not a server client.
  **/
  ?mask:Bool,
  /**
  Specifies whether data is the last fragment of a message or not. Defaults to true.
  **/
  ?fin:Bool,
}

typedef WebSocketOptions = {
  > js.node.Http.HttpRequestOptions,
  /**
  Timeout in milliseconds for the handshake request.
  **/
  handshakeTimeout:Int,
  /**
  Enable/disable permessage-deflate.
  **/
  perMessageDeflate:EitherType<Bool, Server.PerMessageDeflateArgs>,
  /**
  Value of the Sec-WebSocket-Version header.
  **/
  protocolVersion:Int,
  /**
  Value of the Origin or Sec-WebSocket-Origin header depending on the protocolVersion.
  **/
  origin:String,
}

@:enum abstract ReadyState(Int) to Int {
  /**
 	The connection is not yet open.
  **/
  var CONNECTING = 	0;

  /**
 	The connection is open and ready to communicate.
  **/
  var OPEN = 	1;

  /**
 	The connection is in the process of closing.
  **/
  var CLOSING = 	2;

  /**
 	The connection is closed.
  **/
  var CLOSED = 	3;
}

/**
  A string indicating the type of binary data being transmitted by the connection. This should be one of "nodebuffer", "arraybuffer" or "fragments".
  Defaults to "nodebuffer". Type "fragments" will emit the array of fragments as received from the sender, without copyfull concatenation,
  which is useful for the performance of binary protocols transferring large messages with multiple fragments.
**/
@:enum abstract BinaryType(String) to String {
  var NodeBuffer = 'nodebuffer';
  var ArrayBuffer = 'arraybuffer';
  var Fragments = 'fragments';
}