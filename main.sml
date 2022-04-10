val HttpGetRaw = fn domain =>
  let 
    val socket = INetSock.TCP.socket ()
    val fromHostName = NetHostDB.addr o Option.valOf o NetHostDB.getByName
    val host    = fromHostName domain
    val address = INetSock.toAddr (host, 80)
    val _       = Socket.connect (socket, address)
    val toRawSlice = Word8VectorSlice.full o Byte.stringToBytes
    val _          = Socket.sendVec (
      socket,
      toRawSlice ("\
      \GET / HTTP/1.1\n\
      \Host: " ^ domain  ^ "\n\
      \User-Agent: raw-socket\n\
      \Accept:*/*\r\n\r\n\
      \")
    )
    val response = Socket.recvVec (socket, 1024*1024*1024)
    val _        = Socket.close socket
  in
    Byte.bytesToString response
  end

val xml = (
    Option.valOf
  o #body
  o (fn (v,s) => v)
  o Option.valOf
  o (Http.Response.parse CharVectorSlice.getItem)
  o CharVectorSlice.full
  o HttpGetRaw
) "len.falken.directory"
val _ = print "\n"

val outfile = "test.xml"

val _ = let
  val os = TextIO.openOut outfile
in
  TextIO.output(os, xml);
  TextIO.closeOut os
end

val printTag = UniChar.Vector2String o UniChar.Data2Vector

structure TralectorHooks =
  struct
    open IgnoreHooks

    (* Data held onto while parsing the document                              *)
    type AppData = UniChar.Data list
    (* What the final return data should be - same as the AppData             *)
    type AppFinal = AppData
    val appStart = []

    (* Hook functions are basically (state, info) -> state                    *)
    fun hookStartTag (appData, startTagInfo) = let
        val (_, _, _, tagName, _) = startTagInfo
      in
        print (printTag tagName);
        tagName :: appData
      end
  end

structure TralectorParse :
  sig
    val parse : string -> TralectorHooks.AppFinal
  end
  = struct
    structure Parser = Parse (
      structure Dtd   = Dtd
      structure Hooks = TralectorHooks
      structure ParserOptions = ParserOptions ()
      structure Resolve = ResolveNull
    )
    fun parse uri = Parser.parseDocument (SOME(Uri.String2Uri uri)) NONE TralectorHooks.appStart
  end

val tags = TralectorParse.parse outfile
val _ = print (
  printTag
  (List.foldl (fn (a,b) => List.concat [a,b]) [] tags)
)
