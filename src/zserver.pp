{
+-----------------------------------------------+------------+
| Модуль zserver 1.1                            | 17.02.2006 |
+-----------------------------------------------+------------+
| Описание:                                                  |
|   В модуле содержится класс для создания сервера на основе |
|   TCP соединений                                           |
|                                                            |
| Использование:                                             |
|   Модуль предназначен для коммерческого и некоммерческого  |
|   использования.                                           |
|   Вы имеете право использовать и/или модифицировать модуль |
|   по своему усмотрению. Вы не имеете права распространять  |
|   этот модуль в измененном виде.                           |
|                                                            |
| Автор:                                                     |
|   Alexander N Zubakov                                      |
|                                                            |
| © 2006 Alexander N Zubakov                                 |
|   All Rights Reserved                                      |
+------------------------------------------------------------+
}
unit zserver;

interface

{$INCLUDE compilers.inc}

uses sysutils
{$IFDEF FPC}, Sockets{$ENDIF}
{$IFDEF DELPHI}, synsock{$ENDIF} // Synapse
;

const
  packet_size = 56000;
  
type


    TzServer = class(TObject)
private
    sAddr                       : {$IFDEF DELPHI}TVarSin{$ELSE}TINetSockAddr{$ENDIF};
    MainSocket                  : {$IFDEF DELPHI}TSocket{$ELSE}longint{$ENDIF};

    conn                        : array of longint;
    ip                          : array of string;
    ccount                      : longint;
    csock                       : longint;

public
    constructor Create( aIp: string; port: word );

    function    Connect : longint;
    procedure   Disconnect( socket_index : longint );
    procedure   Stop;

    procedure   sWrite( str : string );
    function    sRead : string;
    
    procedure   select( socket_index : longint );
    function    getip( socket_index : longint ) : string;

    end;

implementation

constructor TzServer.Create( aIp: string; port: word );
begin
    inherited Create;
    ccount := 0;

    {$IFDEF DELPHI}
    MainSocket := synsock.socket( AF_INET, SOCK_STREAM, 0 );

    SetVarSin( sAddr, aIp, IntToStr( Port ), AF_INET, IPPROTO_TCP, SOCK_STREAM, true );

    bind( MainSocket, saddr );
    listen( MainSocket, 1 );

    {$ELSE}
    MainSocket := fpsocket(AF_INET, SOCK_STREAM, 0);

    saddr.Family := AF_INET;
    saddr.Port   := htons(port);
    saddr.Addr   := LongWord( StrToNetAddr(aIp) );

    fpbind( MainSocket, @saddr, SizeOf( saddr ) );
    fplisten( MainSocket, 1 );
    {$ENDIF}
end;

{$IFDEF DELPHI}
function TzServer.Connect : longint;
var
    sock     : TSocket;
begin
    sock := synsock.accept( MainSocket, sAddr );

    if sock <> -1 then
    begin
      inc(ccount);
      setLength(conn, ccount);
      setLength(ip, ccount);

      ip[ccount - 1] := GetSinIP( sAddr );
      conn[ccount - 1] := sock;
      csock := sock;
    end;

    Result := ccount - 1;
end;
{$ELSE}
function TzServer.Connect : longint;
var
    sock     : longint;
    sAddrSize: longint;
begin
    sAddrSize := SizeOf(sAddr);
    sock := fpaccept( MainSocket, @sAddr, @sAddrSize );

    if sock <> -1 then
    begin
      inc(ccount);
      setLength(conn, ccount);
      setLength(ip, ccount);

      ip[ccount - 1] := NetAddrToStr(in_addr(sAddr.Addr));
      conn[ccount - 1] := sock;
      csock := sock;
    end;

    Result := ccount - 1;
end;
{$ENDIF}

procedure TzServer.Disconnect( socket_index : longint );
begin
    if socket_index < ccount then
      CloseSocket(conn[socket_index]);
end;
  
procedure TzServer.Stop;
var
    i: cardinal;
begin
    if ccount > 0 then
      for i := 0 to ccount - 1 do CloseSocket( conn[i] );

    {$IFDEF DELPHI}
    shutdown( MainSocket, 2 );
    {$ELSE}
    fpshutdown( MainSocket, 2 );
    {$ENDIF}

    CloseSocket( MainSocket );
end;

procedure TzServer.select( socket_index : longint );
begin
    if socket_index < ccount then
      csock := conn[socket_index];
end;

function TzServer.getip( socket_index : longint ) : string;
begin
    if socket_index < ccount then
      Result := ip[socket_index]
    else
      Result := '';
end;

procedure TzServer.sWrite( str : string );
var
    i: cardinal;
    s: integer;
begin
    s := Length( str );
    if s < packet_size then 
      i := s 
    else 
      i := packet_size;

    while s > 0 do
    begin
      {$IFDEF DELPHI}
      send( csock, PChar( str ), i, 0 );
      {$ELSE}
      fpsend( csock, PChar( str ), i, 0 );
      {$ENDIF}

      delete( str, 1, i ); 

      s := s - packet_size;
      if s < packet_size then i := s;
    end;
end;
  
function TzServer.sRead : string;
var
    buf  : string;
    count: integer;
begin
    setLength( buf, packet_size );

    {$IFDEF DELPHI}
    count := recv( csock, PChar( buf ), packet_size, 0 );
    {$ELSE}
    count := fprecv( csock, PChar( buf ), packet_size, 0 );
    {$ENDIF}

    setLength( buf, count );
    Result := buf;
end;

end.
