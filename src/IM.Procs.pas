unit IM.Procs;

{$mode Delphi}

interface

uses
  Classes, SysUtils, JPL.IniFile, JPL.TStr, JPL.Console, JPL.Conversion, IM.Types;


function ParamExists(ParamStrValue: string): Boolean;
function IsFileMask(const FileName: string): Boolean;

procedure DisplayIniValue(const IniFileName, Section, Key: string; Encoding: TEncoding);
procedure DisplayIniSectionKeys(const IniFileName, Section: string; Encoding: TEncoding);
procedure DisplayIniSection(const IniFileName, Section: string; Encoding: TEncoding);
procedure WriteIniValue(const IniFileName, Section, Key, Value: string; Encoding: TEncoding);
procedure WriteIniFileComment(const IniFileName: string; Comment: string; Encoding: TEncoding; PaddingSpaces: integer = 0);
procedure RemoveIniFileComment(const IniFileName: string; Encoding: TEncoding);
procedure WriteIniSectionComment(const IniFileName, Section: string; Comment: string; Encoding: TEncoding; PaddingSpaces: integer = 0);
procedure RemoveIniSectionComment(const IniFileName, Section: string; Encoding: TEncoding);
procedure RenameIniKey(const IniFileName, Section, OldKeyName, NewKeyName: string; Encoding: TEncoding);
procedure RemoveIniKey(const IniFileName, Section, Key: string; Encoding: TEncoding);
procedure RemoveIniSection(const IniFileName, Section: string; Encoding: TEncoding);
procedure RemoveIniAllSections(const IniFileName: string; Encoding: TEncoding);
procedure ListIniSections(const IniFileName: string; Encoding: TEncoding);


implementation


function ParamExists(ParamStrValue: string): Boolean;
var
  i: integer;
begin
  Result := False;
  ParamStrValue := UpperCase(ParamStrValue);
  for i := 1 to ParamCount do
    if UpperCase(ParamStr(i)) = ParamStrValue then
    begin
      Result := True;
      Break;
    end;
end;

function IsFileMask(const FileName: string): Boolean;
begin
  Result := TStr.Contains(FileName, '*') or TStr.Contains(FileName, '?');
end;

{$region '                                 DisplayIniValue                                  '}
procedure DisplayIniValue(const IniFileName, Section, Key: string; Encoding: TEncoding);
var
  s: string;
  Ini: TJPIniFile;
  IniSection: TJPIniSection;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;

    IniSection := Ini.GetSection(Section, False);
    if not Assigned(IniSection) then Exit;

    if not IniSection.KeyExists(Key) then
    begin
      Writeln('Key "' + Key + '" does not exists!');
      Exit;
    end;

    s := IniSection.ReadString(Key, '');
    if s <> '' then TConsole.WriteTaggedTextLine('<color=' + AppColors.Value + '>' + s + '</color>');
  finally
    Ini.Free;
  end;
end;
{$endregion DisplayIniValue}

{$region '                                 DisplayIniSectionKeys                               '}
procedure DisplayIniSectionKeys(const IniFileName, Section: string; Encoding: TEncoding);
var
  s: string;
  i: integer;
  Ini: TJPIniFile;
  sl: TStringList;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  sl := TStringList.Create;
  try
    Ini.UpdateFileOnExit := False;

    if not Ini.SectionExists(Section) then
    begin
      if not AppParams.Silent then Writeln('Section "' + Section + '" does not exists!');
      Exit;
    end;

    Ini.ReadSection(Section, sl);
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      if s <> '' then TConsole.WriteTaggedTextLine('<color=' + AppColors.Key + '>' + s + '</color>');
    end;

  finally
    sl.Free;
    Ini.Free;
  end;
end;
{$endregion DisplayIniSectionKeys}

{$region '                                 DisplayIniSection                                '}
procedure DisplayIniSection(const IniFileName, Section: string; Encoding: TEncoding);
var
  Key, Value: string;
  i: integer;
  Ini: TJPIniFile;
  sl: TStringList;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  sl := TStringList.Create;
  try
    Ini.UpdateFileOnExit := False;
    Ini.ReadSection(Section, sl);

    for i := 0 to sl.Count - 1 do
    begin
      Key := sl[i];
      Value := Ini.ReadString(Section, Key, '');
      TConsole.WriteTaggedTextLine(
        '<color=' + AppColors.Key + '>' + Key + '</color><color=' + AppColors.Symbol + '>=</color><color=' + AppColors.Value + '>' + Value + '</color>'
      );
    end;

  finally
    sl.Free;
    Ini.Free;
  end;
end;
{$endregion DisplayIniSection}

{$region '                                 WriteIniValue                                   '}
procedure WriteIniValue(const IniFileName, Section, Key, Value: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := True;
    Ini.WriteString(Section, Key, Value);
  finally
    Ini.Free;
  end;
end;
{$endregion WriteIniValue}

{$region '                  WriteIniFileComment               '}
procedure WriteIniFileComment(const IniFileName: string; Comment: string; Encoding: TEncoding; PaddingSpaces: integer = 0);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := True;
    if PaddingSpaces > 0 then Comment := StringOfChar(' ', PaddingSpaces) + Comment;
    Ini.Sections[0].WriteComment(Comment, True);
  finally
    Ini.Free;
  end;
end;
{$endregion WriteIniFileComment}

{$region '                   RemoveIniFileComment                '}
procedure RemoveIniFileComment(const IniFileName: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := True;
    Ini.ClearIniComment;
  finally
    Ini.Free;
  end;
end;
{$endregion RemoveIniFileComment}

{$region '                  WriteIniSectionComment               '}
procedure WriteIniSectionComment(const IniFileName, Section: string; Comment: string; Encoding: TEncoding; PaddingSpaces: integer = 0);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := True;
    if PaddingSpaces > 0 then Comment := StringOfChar(' ', PaddingSpaces) + Comment;
    Ini.WriteComment(Section, Comment, True);
  finally
    Ini.Free;
  end;
end;
{$endregion WriteIniSectionComment}

{$region '                  RemoveIniSectionComment                     '}
procedure RemoveIniSectionComment(const IniFileName, Section: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;
    if Ini.RemoveSectionComment(Section, True) then Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;
{$endregion RemoveIniSectionComment}

{$region '                       RenameIniKey                          '}
procedure RenameIniKey(const IniFileName, Section, OldKeyName, NewKeyName: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
  IniSection: TJPIniSection;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;
    if not Ini.SectionExists(Section) then Exit;
    IniSection := Ini.GetSection(Section, False);

    if not IniSection.KeyExists(OldKeyName) then
    begin
      if not AppParams.Silent then Writeln('Cannot rename: Key "' + OldKeyName + '" does not exists!');
      Exit;
    end;

    if IniSection.KeyExists(NewKeyName) then
    begin
      if not AppParams.Silent then Writeln('Cannot rename: Key "' + NewKeyName + '" already exists!');
      Exit;
    end;

    if IniSection.RenameKey(OldKeyName, NewKeyName) then Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;
{$endregion RenameIniKey}

{$region '                                 RemoveIniKey                                   '}
procedure RemoveIniKey(const IniFileName, Section, Key: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;

    if not Ini.KeyExists(Section, Key) then
    begin
      if not AppParams.Silent then Writeln('Cannot remove: Key "' + Key + '" does not exists!');
      Exit;
    end;

    if Ini.DeleteKey(Section, Key) then Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;
{$endregion RemoveIniKey}

{$region '                                 RemoveIniSection                                   '}
procedure RemoveIniSection(const IniFileName, Section: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;

    if not Ini.SectionExists(Section) then
    begin
      if not AppParams.Silent then
        Writeln('Cannot remove: Section "' + Section + '" does not exists!');
      Exit;
    end;

    Ini.EraseSection(Section);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;
{$endregion RemoveIniSection}

{$region '                                 RemoveIniAllSections                                   '}
procedure RemoveIniAllSections(const IniFileName: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
  SectionName, FileComment, s: string;
  Items: TJPIniSectionItems;
  i: integer;
  sl: TStringList;
begin
  FileComment := '';

  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try

    if Ini.Sections.Count > 0 then
    begin
      SectionName := Ini.Sections[0].Name;
      Items := Ini.GetSectionItems(SectionName);
      for i := 0 to Items.Count - 1 do
      begin
        if Items[i].ItemType = iitComment then
        begin
          s := Items[i].Value;
          if not TStr.StartsWith(';', s) then s := ';' + s;
          FileComment := FileComment + s + ENDL;
        end
        else Break;
      end;
    end;

    Ini.Sections.Clear;
    Ini.UpdateFile;

  finally
    Ini.Free;
  end;


  if FileComment <> '' then
  begin
    sl := TStringList.Create;
    try
      sl.Text := FileComment;
      sl.WriteBOM := True;
      sl.SaveToFile(IniFileName, Encoding);
    finally
      sl.Free;
    end;
  end;
end;
{$endregion RemoveIniAllSections}

{$region '                                 ListIniSections                                   '}
procedure ListIniSections(const IniFileName: string; Encoding: TEncoding);
var
  Ini: TJPIniFile;
  IniSections: TJPIniSections;
  i, x: integer;
begin
  Ini := TJPIniFile.Create(IniFileName, Encoding);
  try
    Ini.UpdateFileOnExit := False;

    IniSections := Ini.Sections;
    x := IniSections.Count - 1;
    if x <= 0 then
    begin
      if not AppParams.Silent then Writeln('The file does not contain any sections.');
      Exit;
    end;

    if not AppParams.Silent then TConsole.WriteTaggedTextLine('Section list (' + itos(x) + '):');

    for i := 1 to IniSections.Count - 1 do
    begin
      TConsole.WriteTaggedTextLine('<color=' + AppColors.Section + '>' + IniSections[i].Name + '</color>');
    end;

  finally
    Ini.Free;
  end;
end;
{$endregion ListIniSections}


end.

