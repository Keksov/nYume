program nYume;

{$APPTYPE CONSOLE}

uses SysUtils
  , nYumeSrv in '..\nYumeSrv.pp'
  , synsock in '..\synsock.pas'
  , zserver in '..\zserver.pp'
  , cfgfile in '..\cfgfile.pp'
  , shell in '..\shell.pp'
;

begin

StartServer();

end.
