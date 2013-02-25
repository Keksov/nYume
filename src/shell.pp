unit shell;

{$INCLUDE compilers.inc}

{$IFDEF FPC}
    {$MODE OBJFPC}
    {$SMARTLINK ON}
{$ENDIF}

interface
  var
    //Путь к интерпретатору скриптов командной строки
    PathToShell: string = '/bin/sh';

  //Модифицирует окружение путем добавления переменной
  //с именем name и значением value
  //Изменения касаются ТОЛЬКО исполняемой команды
  procedure addEnv(name, value: string);

  //Очищает все переменные окружения, установленные
  //процедурой addEnv
  procedure clearEnv;
  
  //Выполняет процесс/программу/команду оболочки command_
  //Возвращает код завершения процесса
  function cmd(command_: string): integer;
  
  //Выполняет процесс/программу/команду оболочки command_ и
  //возвращает весь консольный вывод выполняемой программы
  function command(command_: string): string;

implementation

uses {$IFDEF DELPHI}windows,{$ENDIF}sysutils;

var
  LocalEnv  : string  = {$ifndef mswindows}'env '{$else}''{$endif};
  changedEnv: boolean = false;
    
procedure addEnv(name, value: string);
begin
    LocalEnv := LocalEnv + {$ifndef mswindows}
      name + '="' + value + '" ';
    {$else}
      'set ' + name + '=' + value + #13#10;
    {$endif}
    
    changedEnv := true;
end;

{$IFDEF DELPHI}
function ExecuteProcess( const Path: AnsiString; const ComLine: AnsiString) : Integer;
var
    fullExeName   : string;
    creationFlags : DWORD;
    waitRes       : integer;
    exeDir        : string;
    startInfo     : TStartupInfo;
    procInfo      : TProcessInformation;

begin
    Result        := 1;

    exeDir        := '.\';
    fullExeName   := Path;
    creationFlags := CREATE_NEW_PROCESS_GROUP;

    // Set up members of the STARTUPINFO structure.
    ZeroMemory( @startInfo, sizeof( TStartupInfo ) );
    startInfo.cb := SizeOf( TStartupInfo );

    // Set up members of the PROCESS_INFORMATION structure.
    ZeroMemory( @procInfo, sizeof( TProcessInformation ) );

    startInfo.dwFlags := startInfo.dwFlags or STARTF_USESTDHANDLES;

    if ( not CreateProcess(
          nil                   // lpApplicationName
        , PChar( fullExeName )  // lpCommandLine
        , nil                   // lpProcessAttributes
        , nil                   // lpThreadAttributes
        , true                  // bInheritHandles
        , creationFlags         // dwCreationFlags
        , nil                   // lpEnvironment
        , PChar( exeDir )       // lpCurrentDirectory
        , startInfo             // lpStartupInfo
        , procInfo              // lpProcessInformation
    ) ) then exit;

    repeat
        waitRes := WaitForSingleObject( procInfo.hProcess, 100 );
    until ( waitRes <> WAIT_TIMEOUT );

    GetExitCodeProcess( procInfo.hProcess, DWord( Result ) );

    if ( procInfo.hProcess <> 0 ) then
    begin
       CloseHandle( procInfo.hProcess );
       procInfo.hProcess := 0;
    end;

    if ( procInfo.hThread <> 0 ) then
    begin
        CloseHandle( procInfo.hThread );
        procInfo.hThread := 0;
    end;

end;
{$ENDIF}

procedure clearEnv;
begin
    LocalEnv  := {$ifndef mswindows}'env '{$else}''{$endif};
    changedEnv:= false;
end;

function cmd(command_: string): integer;
var
    fname: string;
    f    : text;
begin
    fname := {$ifndef mswindows}'tmp_JKfjCGeh__cmd.sh'{$else}'tmp_JKfjCGeh__cmd.bat'{$endif};

    randomize;
    while FileExists(fname) do
      fname := '_' + IntToStr(random(10000)) + fname;

    Assign(f, fname);
      Rewrite(f);
      {$ifdef mswindows}Writeln(f, '@echo off');{$endif}
      if changedEnv then Write(f, LocalEnv);
      Writeln(f, command_);
    Close(f);

    {$IFDEF DELPHI}
    Result := {$ifdef mswindows}ExecuteProcess('./' + fname, ''){$else}ExecuteProcess(PathToShell, fname){$endif};
    {$ELSE}
    Result := {$ifdef mswindows}ExecuteProcess('./' + fname, ''){$else}ExecuteProcess(PathToShell, fname){$endif};
    {$ENDIF}

    Erase(f);
end;

function command(command_: string): string;
var
    f    : file;
    buf  : AnsiString;
    count: integer;
    fname: string;

begin
    fname := 'tmp_JKfjCGeh__pipe.txt';

    randomize;
    while FileExists(fname) do
      fname := fname + IntToStr(random(10000)) + '.txt';

    cmd(command_ + {$ifdef mswindows}'>'{$else}' > '{$endif} + fname);
    Assign(f, fname);
    Reset(f, 1);

    Result := '';
    SetLength(buf, 4096);
    count := 0;
    while not eof(f) do
    begin
      BlockRead(f, PChar(buf)^, 4096, count);
      if count < 4096 then buf := copy(buf, 1, count);
      Result := Result + buf;
    end;

    Close(f);
    Erase(f);
end;

end.
