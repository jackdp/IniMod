program IniMod;

{
  Jacek Pazera
  https://www.pazera-software.com
  https://github.com/jackdp

  ----------------------------------------------------
  IniMod - Console application for managing INI files.
  ----------------------------------------------------

  Compile using FPC 3.2.0 or newer. Older FPC versions may have a character encoding problem.
}

{$IFDEF FPC}{$mode objfpc}{$H+}{$ENDIF}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads} cthreads, {$ENDIF}{$ENDIF}
  SysUtils,
  LazUTF8,
  JPL.Console,
  IM.App in 'IM.App.pas',
  IM.Types in 'IM.Types.pas',
  IM.Procs in 'IM.Procs.pas';

var
  App: TApp;

{$IFDEF MSWINDOWS}
// Na Linuxie czasami wyskakuje EAccessViolation
//procedure MyExitProcedure;
//begin
//  if Assigned(App) then
//  begin
//    App.Done;
//    //FreeAndNil(App);
//  end;
//end;
{$ENDIF}


{$R *.res}

begin
  {$IFDEF FPC}
    {$IF DECLARED(UseHeapTrace)}
	  GlobalSkipIfNoLeaks := True; // supported as of debugger version 3.2.0
    {$ENDIF}
  {$ENDIF}

  App := TApp.Create;
  try

    try

      //{$IFDEF MSWINDOWS}App.ExitProcedure := @MyExitProcedure;{$ENDIF}
      App.Init;
      App.Run;
      if Assigned(App) then App.Done;



    except
      on E: Exception do
      begin
        Writeln(E.ClassName, ': ', E.Message);
        if GetLastOSError <> 0 then Writeln('OS Error No. ', GetLastOSError, ': ', SysErrorMessage(GetLastOSError));
        ExitCode := TConsole.ExitCodeError;
      end;
    end;

  finally
    if Assigned(App) then FreeAndNil(App);
  end;

end.


