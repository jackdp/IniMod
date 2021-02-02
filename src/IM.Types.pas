unit IM.Types;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, Types;


type

  TAppColors = record
    Command, Desc, Example, Section, Key, Value,
    Comment, Symbol: string;
    procedure Init;
  end;

  TAppParams = record
    Section: string;          // -s, --section
    Key: string;              // -k, --key
    NewKeyName: string;       // -kn, --new-key-name
    Value: string;            // -v, --value
    Comment: string;          // -c, --comment
    CommentPadding: integer;  // -x
    Silent: Boolean;          // --silent
    Encoding: TEncoding;      // no option. TODO: add Encoding to options
    Files: TStringDynArray;   // the list of file names/masks
    GithubUrl: string;        // stores the GitHub repo URL
    RecurseDepth: integer;    // -rd, --recurse-depth
  end;


var
  AppParams: TAppParams;
  AppColors: TAppColors;

implementation





procedure TAppColors.Init;
begin
  Command := 'lightblue';
  Desc := 'lightgray';
  Example := 'white';
  Section := 'lime';
  Key := 'yellow';
  Value := 'cyan';
  Comment := 'fuchsia';
  Symbol := 'darkgray';
end;

end.
