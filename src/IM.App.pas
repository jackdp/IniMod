unit IM.App;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}


interface

uses
  Classes, SysUtils,
  JPL.Console, JPL.ConsoleApp, JPL.CmdLineParser, JPL.TStr, JPL.Conversion, JPL.FileSearcher,
  IM.Types, IM.Procs;

type


  TApp = class(TJPConsoleApp)
  private

  public
    procedure Init;
    procedure Run;
    procedure Done;

    procedure RegisterOptions;
    procedure ProcessOptions;

    procedure PerformMainAction;

    procedure DisplayHelpAndExit(const ExCode: integer);
    procedure DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
    procedure DisplayBannerAndExit(const ExCode: integer);
    procedure DisplayMessageAndExit(const Msg: string; const ExCode: integer);

  end;



implementation





{$region '                    Init                              '}

procedure TApp.Init;
const
  SEP_LINE = '-------------------------------------------------';
begin

  AppName := 'IniMod';
  MajorVersion := 1;
  MinorVersion := 0;
  Self.Date := EncodeDate(2021, 02, 02);
  FullNameFormat := '%AppName% %MajorVersion%.%MinorVersion% [%OSShort% %Bits%-bit] (%AppDate%)';
  Description := 'Console application for managing INI files.';
  Author := 'Jacek Pazera';
  HomePage := 'https://www.pazera-software.com/products/inimod/';
  HelpPage := HomePage;

  AppParams.GithubUrl := 'https://github.com/jackdp/IniMod';
  LicenseName := 'Freeware, Open Source';
  License := 'This program is completely free. You can use it without any restrictions, also for commercial purposes.' + ENDL +
    'The program''s source files are available at ' + AppParams.GithubUrl + ENDL +
    'Compiled binaries can be downloaded from ' + HomePage;

  AppParams.Value := '';
  AppParams.Section := '';
  AppParams.Key := '';
  AppParams.NewKeyName := '';
  AppParams.Comment := '';
  AppParams.CommentPadding := 0;
  SetLength(AppParams.Files, 0);
  AppParams.Encoding := TEncoding.UTF8;
  AppParams.Silent := False;
  AppParams.RecurseDepth := 0;

  AppColors.Init;

  {$IFDEF MSWINDOWS}
  TrimExtFromExeShortName := True;
  {$ENDIF}


  HintBackgroundColor := TConsole.clLightGrayBg;
  HintTextColor := TConsole.clBlackText;
  WarningBackgroundColor := TConsole.clDarkMagentaBg;
  WarningTextColor := TConsole.clLightGrayText;

  //-----------------------------------------------------------------------------

  TryHelpStr := ENDL + 'Try <color=white,black>' + ExeShortName + ' --help</color> for more information.';

  ShortUsageStr :=
    ENDL +
    'Usage: ' + ExeShortName +
    ' <color=' + AppColors.Command + '>COMMAND</color> FILES OPTIONS' +
    ENDL +
    'Options are case-insensitive. Options and values in square brackets are optional.' + ENDL +
    'All parameters that do not start with the "-" or "/" sign are treated as file names/masks.' + ENDL +
    'Options and input files can be placed in any order, but -- (double dash followed by space) ' +
    'indicates the end of parsing options and all subsequent parameters are treated as file names/masks.';



  ExtraInfoStr :=
    ENDL +
    'FILES - Any combination of file names/masks.' + ENDL +
    '        Eg.: file.ini *config*.ini "long file name.ini"' +
    ENDL + SEP_LINE + ENDL +
    'EXIT CODES' + ENDL +
    '  ' + CON_EXIT_CODE_OK.ToString + ' - OK - no errors.' + ENDL +
    '  ' + CON_EXIT_CODE_SYNTAX_ERROR.ToString + ' - Syntax error.' + ENDL +
    '  ' + CON_EXIT_CODE_ERROR.ToString + ' - Other error.';

  ExamplesStr := '';

end;
{$endregion Init}





{$region '                    Run & Done                               '}
procedure TApp.Run;
begin
  inherited;

  RegisterOptions;
  Cmd.Parse;
  ProcessOptions;
  if Terminated then Exit;

  PerformMainAction; // <----- the main procedure
end;

procedure TApp.Done;
begin
  SetLength(AppParams.Files, 0);
  if (ExitCode <> 0) and (not AppParams.Silent) then Writeln('ExitCode: ', ExitCode);
end;

{$endregion Run & Done}


{$region '                    RegisterOptions                   '}
procedure TApp.RegisterOptions;
const
  MAX_LINE_LEN = 110;
var
  Category: string;
  esn: string;
  sc: string;
  sFile: string;
begin

  {$IFDEF MSWINDOWS} Cmd.CommandLineParsingMode := cpmCustom; {$ELSE} Cmd.CommandLineParsingMode := cpmDelphi; {$ENDIF}
  Cmd.UsageFormat := cufWget;
  Cmd.AcceptAllNonOptions := True; // All non options are treated as file names
  Cmd.IgnoreCase := True;

  esn := ChangeFileExt(ExeShortName, '');
  sFile := 'FILES';


  // ------------ Registering commands -----------------

  Cmd.RegisterCommand('w', 'Write', 1, False,
    'Writes a key value. ' + esn + ' w ' + sFile + ' -s Section -k Key -v Value'
  );

  Cmd.RegisterCommand('r', 'Read', 1, False,
    'Reads and displays the value of a key. ' + esn + ' r ' + sFile + ' -s Section -k Key'
  );

  Cmd.RegisterCommand('rnk', 'RenameKey', 1, False,
    'Renames the key. ' + esn + ' rnk ' + sFile + ' -s Section -k OldKeyName -kn NewKeyName'
  );

  Cmd.RegisterCommand('rmk', 'RemoveKey', 1, False,
    'Removes the key. ' + esn + ' rmk ' + sFile + ' -s Section -k Key'
  );

  Cmd.RegisterCommand('rms', 'RemoveSection', 1, False,
    'Removes the given section. ' + esn + ' rms ' + sFile + ' -s Section'
  );

  Cmd.RegisterCommand('ras', 'RemoveAllSections', 1, False,
    'Removes all sections. ' + esn + ' ras ' + sFile
  );

  Cmd.RegisterCommand('rs', 'ReadSection', 1, False,
    'Displays section keys and values. ' + esn + ' rs ' + sFile + ' -s Section'
  );

  Cmd.RegisterCommand('rk', 'ReadKeys', 1, False,
    'Displays section keys. ' + esn + ' rk ' + sFile + ' -s Section'
  );

  Cmd.RegisterCommand('ls', 'ListSections', 1, False,
    'Displays the names of all sections. ' + esn + ' ls ' + sFile
  );

  Cmd.RegisterCommand('wsc', 'WriteSectionComment', 1, False,
    '' + esn + ' wsc ' + sFile + ' -s Section -c Comment [-x NUM]'
  );

  Cmd.RegisterCommand('rsc', 'RemoveSectionComment', 1, False,
    '' + esn + ' rsc ' + sFile + ' -s Section'
  );

  Cmd.RegisterCommand('wfc', 'WriteFileComment', 1, False,
    'Adds one line to the file comment. ' + esn + ' wfc ' + sFile + ' -c Comment [-x NUM]'
  );

  Cmd.RegisterCommand('rfc', 'RemoveFileComment', 1, False,
    'Clears file comment. ' + esn + ' rfc ' + sFile + ''
  );




  // ------------ Registering options -----------------

  Category := 'main';

  Cmd.RegisterOption('s', 'section', cvtRequired, False, False, 'Section name.', 'NAME', Category);
  Cmd.RegisterOption('k', 'key', cvtRequired, False, False, 'Key name.', 'NAME', Category);
  Cmd.RegisterOption('kn', 'new-key-name', cvtRequired, False, False, 'Key name.', 'NAME', Category);
  Cmd.RegisterOption('v', 'value', cvtRequired, False, False, 'Key value.', 'STR', Category);
  Cmd.RegisterOption('c', 'comment', cvtRequired, False, False, 'Section or file comment.', 'STR', Category);
  Cmd.RegisterShortOption('x', cvtRequired, False, False, 'Padding spaces (for comments). NUM - a positive integer.', 'NUM', Category);
  Cmd.RegisterOption(
    'rd', 'recurse-depth', cvtRequired, False, False, 'Recursion depth when searching for files. NUM - a positive integer.', 'NUM', Category
  );
  Cmd.RegisterLongOption('silent', cvtNone, False, False, 'Do not display some messages.', '', Category);

  Category := 'info';
  Cmd.RegisterOption('h', 'help', cvtNone, False, False, 'Show this help.', '', Category);
  Cmd.RegisterShortOption('?', cvtNone, False, True, '', '', '');
  Cmd.RegisterLongOption('version', cvtNone, False, False, 'Show application version.', '', Category);
  Cmd.RegisterLongOption('license', cvtNone, False, False, 'Display program license.', '', Category);
  {$IFDEF MSWINDOWS}
  Cmd.RegisterLongOption('home', cvtNone, False, False, 'Opens program home page in the default browser.', '', Category);
  Cmd.RegisterLongOption('github', cvtNone, False, False, 'Opens the GitHub page with the program''s source files.', '', Category);
  {$ENDIF}



  // ----------------- Colors --------------------

  sc := Cmd.CommandsUsageStr('  ', 140, '   ', 10);
  sc := TStr.ReplaceFirst(sc, 'w,   Write', '<color=' + AppColors.Command + '>w</color>,   <color=' + AppColors.Command + '>Write</color>', True);
  sc := TStr.ReplaceFirst(
    sc, 'wsc, WriteSectionComment', '<color=' + AppColors.Command + '>wsc</color>, <color=' + AppColors.Command + '>WriteSectionComment</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'rsc, RemoveSectionComment', '<color=' + AppColors.Command + '>rsc</color>, <color=' + AppColors.Command + '>RemoveSectionComment</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'rmk, RemoveKey', '<color=' + AppColors.Command + '>rmk</color>, <color=' + AppColors.Command + '>RemoveKey</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'rms, RemoveSection', '<color=' + AppColors.Command + '>rms</color>, <color=' + AppColors.Command + '>RemoveSection</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'ras, RemoveAllSections', '<color=' + AppColors.Command + '>ras</color>, <color=' + AppColors.Command + '>RemoveAllSections</color>', True
  );
  sc := TStr.ReplaceFirst(sc, 'r,   Read', '<color=' + AppColors.Command + '>r</color>,   <color=' + AppColors.Command + '>Read</color>', True);
  sc := TStr.ReplaceFirst(sc, 'rnk, RenameKey', '<color=' + AppColors.Command + '>rnk</color>, <color=' + AppColors.Command + '>RenameKey</color>', True);
  sc := TStr.ReplaceFirst(sc, 'rs,  ReadSection', '<color=' + AppColors.Command + '>rs</color>,  <color=' + AppColors.Command + '>ReadSection</color>', True);
  sc := TStr.ReplaceFirst(sc, 'rk,  ReadKeys', '<color=' + AppColors.Command + '>rk</color>,  <color=' + AppColors.Command + '>ReadKeys</color>', True);
  sc := TStr.ReplaceFirst(
    sc, 'ls,  ListSections', '<color=' + AppColors.Command + '>ls</color>,  <color=' + AppColors.Command + '>ListSections</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'wfc, WriteFileComment', '<color=' + AppColors.Command + '>wfc</color>, <color=' + AppColors.Command + '>WriteFileComment</color>', True
  );
  sc := TStr.ReplaceFirst(
    sc, 'rfc, RemoveFileComment', '<color=' + AppColors.Command + '>rfc</color>, <color=' + AppColors.Command + '>RemoveFileComment</color>', True
  );

  sc := TStr.ReplaceAll(sc, 's Section', '<color=' + AppColors.Section + '>s Section</color>', False);
  sc := TStr.ReplaceAll(sc, 'k Key', '<color=' + AppColors.Key + '>k Key</color>', True);
  sc := TStr.ReplaceAll(sc, 'k OldKeyName', '<color=' + AppColors.Key + '>k OldKeyName</color>', True);
  sc := TStr.ReplaceAll(sc, 'kn NewKeyName', '<color=' + AppColors.Key + '>kn NewKeyName</color>', True);
  sc := TStr.ReplaceAll(sc, 'v Value', '<color=' + AppColors.Value + '>v Value</color>', True);
  sc := TStr.ReplaceAll(sc, 'c Comment', '<color=' + AppColors.Comment + '>c Comment</color>', True);

  sc := TStr.ReplaceFirst(sc, ' w ' + sFile, ' <color=' + AppColors.Command + '>w</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' wsc ' + sFile, ' <color=' + AppColors.Command + '>wsc</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rsc ' + sFile, ' <color=' + AppColors.Command + '>rsc</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rmk ' + sFile, ' <color=' + AppColors.Command + '>rmk</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rms ' + sFile, ' <color=' + AppColors.Command + '>rms</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' ras ' + sFile, ' <color=' + AppColors.Command + '>ras</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' r ' + sFile, ' <color=' + AppColors.Command + '>r</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rnk ' + sFile, ' <color=' + AppColors.Command + '>rnk</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rs ' + sFile, ' <color=' + AppColors.Command + '>rs</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rk ' + sFile, ' <color=' + AppColors.Command + '>rk</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' ls ' + sFile, ' <color=' + AppColors.Command + '>ls</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' wfc ' + sFile, ' <color=' + AppColors.Command + '>wfc</color> ' + sFile, True);
  sc := TStr.ReplaceFirst(sc, ' rfc ' + sFile, ' <color=' + AppColors.Command + '>rfc</color> ' + sFile, True);

  sc := TStr.ReplaceAll(sc, esn, '<color=white>' + esn + '</color>', True);


  UsageStr :=
    ENDL +
    'COMMANDS' + ENDL + sc + ENDL + ENDL +
    'MAIN OPTIONS' + ENDL + Cmd.OptionsUsageStr('  ', 'main', MAX_LINE_LEN, '   ', 30) + ENDL + ENDL +
    'INFO' + ENDL + Cmd.OptionsUsageStr('  ', 'info', MAX_LINE_LEN, '   ', 30);

end;
{$endregion RegisterOptions}


{$region '                    ProcessOptions                    '}
procedure TApp.ProcessOptions;
var
  x, i: integer;
  s: string;
begin

  //------------------------------------ Help ---------------------------------------
  if (ParamCount = 0) or ParamExists('--help') or ParamExists('-h') or (Cmd.IsLongOptionExists('help')) or (Cmd.IsOptionExists('?')) then
  begin
    DisplayHelpAndExit(TConsole.ExitCodeOK);
    Exit;
  end;


  //---------------------------------- Home -----------------------------------------
  {$IFDEF MSWINDOWS}
  if Cmd.IsLongOptionExists('home') or ParamExists('--home') then
  begin
    GoToHomePage;
    Terminate;
    Exit;
  end;

  if Cmd.IsOptionExists('github') or ParamExists('--github') then
  begin
    GoToUrl(AppParams.GithubUrl);
    Terminate;
    Exit;
  end;
  {$ENDIF}


  //------------------------------- Version ------------------------------------------
  if Cmd.IsOptionExists('version') or ParamExists('--version') then
  begin
    DisplayMessageAndExit(AppFullName, TConsole.ExitCodeOK);
    Exit;
  end;


  //------------------------------- Version ------------------------------------------
  if Cmd.IsLongOptionExists('license') or ParamExists('--license') then
  begin
    TConsole.WriteTaggedTextLine('<color=white,black>' + LicenseName + '</color>');
    DisplayLicense;
    Terminate;
    Exit;
  end;


  // ---------------------------- Invalid options -----------------------------------
  if Cmd.ErrorCount > 0 then
  begin
    DisplayShortUsageAndExit(Cmd.ErrorsStr, TConsole.ExitCodeSyntaxError);
    Exit;
  end;


  AppParams.Silent := Cmd.IsLongOptionExists('silent');

  if Cmd.IsOptionExists('s') then AppParams.Section := Trim(Cmd.GetOptionValue('s'));      // Section
  if Cmd.IsOptionExists('k') then AppParams.Key := Trim(Cmd.GetOptionValue('k'));          // Key
  if Cmd.IsOptionExists('kn') then AppParams.NewKeyName := Trim(Cmd.GetOptionValue('kn')); // New key name (for RenameKey)
  if Cmd.IsOptionExists('v') then AppParams.Value := Cmd.GetOptionValue('v');              // Key value
  if Cmd.IsOptionExists('c') then AppParams.Comment := Cmd.GetOptionValue('c');            // File or section comment

  // Comment padding
  if Cmd.IsOptionExists('x') then
  begin
    s := Trim(Cmd.GetOptionValue('x'));
    x := 0;
    if (not TryStrToInt(s, x)) or (x < 0) then
    begin
      DisplayError('Invalid value for option "x": ' + s);
      DisplayHint('Expected positive integer');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
      Exit;
    end;
    AppParams.CommentPadding := x;
  end;

  // Recursion depth
  if Cmd.IsOptionExists('rd') then
  begin
    s := Trim(Cmd.GetOptionValue('rd'));
    x := 0;
    if (not TryStrToInt(s, x)) or (x < 0) then
    begin
      DisplayError('Invalid value for option "rd": ' + s);
      DisplayHint('Expected positive integer');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
      Exit;
    end;
    AppParams.RecurseDepth := x;
  end;



  //---------------------------- Unknown Params (file names/masks) --------------------------
  for i := 0 to Cmd.UnknownParamCount - 1 do
  begin
    s := StripQuotes(Cmd.UnknownParams[i].ParamStr);
    if s = '' then Continue;
    s := ExpandFileName(s);
    SetLength(AppParams.Files, Length(AppParams.Files) + 1);
    AppParams.Files[High(AppParams.Files)] := s;
  end;


end;

{$endregion ProcessOptions}




{$region '                    PerformMainAction                     '}
procedure TApp.PerformMainAction;
var
  i, xFileCount: integer;
  fName, sFileCount, clFile, uCommand: string;
  slFiles: TStringList;
  fs: TJPFileSearcher;

  function CheckCommand(const CommandShortName, CommandLongName: string): Boolean;
  begin
    Result := (UpperCase(CommandLongName) = uCommand) or (UpperCase(CommandShortName) = uCommand);
  end;

  procedure CheckSection;
  begin
    if AppParams.Section = '' then
    begin
      DisplayError('The SECTION name was not specified!');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
    end;
  end;

  procedure CheckKey;
  begin
    if AppParams.Key = '' then
    begin
      DisplayError('The KEY name was not specified!');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
    end;
  end;

  procedure CheckNewKeyName;
  begin
    if AppParams.NewKeyName = '' then
    begin
      DisplayError('The NewKeyName was not specified!');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
    end;
  end;

  procedure CheckComment;
  begin
    // Zakładam, że użytkownik może podać pusty komentarz: -c ""
    if not Cmd.IsOptionExists('c') then
    begin
      DisplayError('The COMMENT was not specified!');
      ExitCode := TConsole.ExitCodeSyntaxError;
      Terminate;
    end;
  end;

begin
  if Terminated then Exit;

  slFiles := TStringList.Create;
  try

    slFiles.Sorted := True;
    slFiles.Duplicates := dupIgnore;

    fs := TJPFileSearcher.Create;
    try

      for i := 0 to High(AppParams.Files) do
      begin
        fName := AppParams.Files[i];
        //if (not IsFileMask(fName)) and (not FileExists(fName)) then
        //begin
        //  if not AppParams.Silent then DisplayWarning('Warning: Input file "' + fName + '" does not exists!');
        //end
        //else
        fs.AddInput(fName, AppParams.RecurseDepth);
      end;

      fs.Search;
      fs.GetFileList(slFiles);

    finally
      fs.Free;
    end;

    xFileCount := slFiles.Count;

    if xFileCount = 0 then
    begin
      if not AppParams.Silent then DisplayHint('No INI files found.');
      Exit;
    end;

    uCommand := UpperCase(Cmd.CommandValue);

    clFile := 'white';
    sFileCount := itos(xFileCount);

    for i := 0 to slFiles.Count - 1 do
    begin

      fName := slFiles[i];

      if not AppParams.Silent then
        TConsole.WriteTaggedTextLine('Processing file ' + itos(i + 1) + '/' + sFileCount + ' : <color=' + clFile + '>' + fName + '</color>');



      // ---------------- Write key value --------------------
      if CheckCommand('w', 'Write') then
      begin
        CheckSection;
        CheckKey;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine(
            'Writing: [<color=' + AppColors.Section + '>' + AppParams.Section + '</color>] ' +
            '<color=' + AppColors.Key + '>' + AppParams.Key + '</color>' +
            '<color=' + AppColors.Symbol + '>=</color>' +
            '<color=' + AppColors.Value + '>' + AppParams.Value + '</color>'
          );
        WriteIniValue(fName, AppParams.Section, AppParams.Key, AppParams.Value, AppParams.Encoding);
      end

      // ------------------ Read key value -----------------
      else if CheckCommand('r', 'Read') then
      begin
        CheckSection;
        CheckKey;
        if Terminated then Exit;
        DisplayIniValue(fName, AppParams.Section, AppParams.Key, AppParams.Encoding);
      end

      // --------------- Rename key ------------
      else if CheckCommand('rnk', 'RenameKey') then
      begin
        CheckSection;
        CheckKey;
        CheckNewKeyName;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine(
            'Renaming key: <color=' + AppColors.Key + '>' + AppParams.Key + '</color>' +
            '<color=' + AppColors.Symbol + '> -> </color><color=' + AppColors.Key + '>' + AppParams.NewKeyName + '</color>'
        );
        RenameIniKey(fName, AppParams.Section, AppParams.Key, AppParams.NewKeyName, AppParams.Encoding);
      end

      // --------------- Remove key ------------
      else if CheckCommand('rmk', 'RemoveKey') then
      begin
        CheckSection;
        CheckKey;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Removing key: <color=' + AppColors.Key + '>' + AppParams.Key + '</color>');
        RemoveIniKey(fName, AppParams.Section, AppParams.Key, AppParams.Encoding);
      end

      // --------------- Remove section ------------
      else if CheckCommand('rms', 'RemoveSection') then
      begin
        CheckSection;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Removing section: <color=' + AppColors.Section + '>' + AppParams.Section + '</color>');
        RemoveIniSection(fName, AppParams.Section, AppParams.Encoding);
      end

      // --------------- Remove all sections ------------
      else if CheckCommand('ras', 'RemoveAllSections') then
      begin
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Removing all sections.');
        RemoveIniAllSections(fName, AppParams.Encoding);
      end

      // --------------- Read section keys and values ------------
      else if CheckCommand('rs', 'ReadSection') then
      begin
        CheckSection;
        if Terminated then Exit;
        DisplayIniSection(fName, AppParams.Section, AppParams.Encoding);
      end

      // -------------- Read section keys -------------------
      else if CheckCommand('rk', 'ReadKeys') then
      begin
        CheckSection;
        if Terminated then Exit;
        DisplayIniSectionKeys(fName, AppParams.Section, AppParams.Encoding);
      end

      // ------------------ Write file comment -------------------
      else if CheckCommand('wfc', 'WriteFileComment') then
      begin
        CheckComment;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Writing file comment: <color=' + AppColors.Comment + '>' + AppParams.Comment + '</color>');
        WriteIniFileComment(fName, AppParams.Comment, AppParams.Encoding, AppParams.CommentPadding);
      end

      // ------------------ Remove file comment -------------------
      else if CheckCommand('rfc', 'RemoveFileComment') then
      begin
        if not AppParams.Silent then TConsole.WriteTaggedTextLine('Removing file comment.');
        RemoveIniFileComment(fName, AppParams.Encoding);
      end

      // ------------------ Write section comment -------------------
      else if CheckCommand('wsc', 'WriteSectionComment') then
      begin
        CheckSection;
        CheckComment;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Writing section comment: <color=' + AppColors.Comment + '>' + AppParams.Comment + '</color>');
        WriteIniSectionComment(fName, AppParams.Section, AppParams.Comment, AppParams.Encoding, AppParams.CommentPadding);
      end

      // ------------------ Remove section comment -------------------
      else if CheckCommand('rsc', 'RemoveSectionComment') then
      begin
        CheckSection;
        if Terminated then Exit;
        if not AppParams.Silent then
          TConsole.WriteTaggedTextLine('Removing section comment: [<color=' + AppColors.Section + '>' + AppParams.Section + '</color>]');
        RemoveIniSectionComment(fName, AppParams.Section, AppParams.Encoding);
      end

      else if CheckCommand('ls', 'ListSections') then
      begin

        ListIniSections(fName, AppParams.Encoding);
      end;


      if not AppParams.Silent then Writeln;

    end; // for i


  finally
    slFiles.Free;
  end;


end;
{$endregion PerformMainAction}


{$region '                    Display... procs                  '}
procedure TApp.DisplayHelpAndExit(const ExCode: integer);
begin
  DisplayBanner;
  DisplayShortUsage;

  DisplayUsage;
  DisplayExtraInfo;

  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayShortUsageAndExit(const Msg: string; const ExCode: integer);
begin
  if Msg <> '' then Writeln(Msg);
  DisplayShortUsage;
  DisplayTryHelp;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayBannerAndExit(const ExCode: integer);
begin
  DisplayBanner;
  ExitCode := ExCode;
  Terminate;
end;

procedure TApp.DisplayMessageAndExit(const Msg: string; const ExCode: integer);
begin
  Writeln(Msg);
  ExitCode := ExCode;
  Terminate;
end;


{$endregion Display... procs}



end.
