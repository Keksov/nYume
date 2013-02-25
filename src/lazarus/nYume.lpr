program nYume;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  , nYumeSrv in '../nYumeSrv.pp'
  , zserver in '../zserver.pp'
  , cfgfile in '../cfgfile.pp'
  , shell in '../shell.pp'
;

type

  { nYume }

  nYume = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ nYume }

procedure nYume.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  StartServer();

  // stop program loop
  Terminate;
end;

constructor nYume.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor nYume.Destroy;
begin
  inherited Destroy;
end;

procedure nYume.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: nYume;
begin
  Application:=nYume.Create(nil);
  Application.Title:='nYume http server';
  Application.Run;
  Application.Free;
end.

