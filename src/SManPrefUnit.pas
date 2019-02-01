// PL/SQL Developer Plug-In framework
// Copyright 2006 Allround Automations
// support@allroundautomations.com
// http://www.allroundautomations.com

unit SManPrefUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, PlugInIntf, Grids, ValEdit, ExtCtrls,SManLogUnit;

type
  TSManPrefsForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    vlePropertyList: TValueListEditor;
    mHint: TMemo;
    procedure vlePropertyListSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure vlePropertyListSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SManPrefsForm: TSManPrefsForm;
  PropertyList : TStringList;

type
   TProperties  = (pSManIndicatorTop=-3, pSManIndicatorLeft=-2, pSManLastMessageCustomComponentCmd=-1, pSManSchema=0,pSManPlugingAPI,pSManWorkingObjectDirectory,pSManWorkingComponentDirectory,pSManMakeBAK, pSManExportOnCompile, pSManAfterObjectExportCmd, pSManAfterComponentExportCmd, pSManCustomComponentCmd, pSManNeedMessageCustomComponentCmd, pSManCompareCmd, pSManTempDirectory);
const
   cHint1:string='You can use replaceable parameter: %COMPONENT%';
   cHint2:string='You can use replaceable parameters: %COMPONENT%, %OBJECTNAME%';
   cHint3:string='You can use replaceable parameters: %1, %2';
   PropertiesKeys : array[TProperties] of string = (
    'SManIndicatorTop',
    'SManIndicatorLeft',
    'SManLastMessageCustomComponentCommand',
    'SManSchema',
    'SManPlugingAPI',
    'SManWorkingObjectDirectory',
    'SManWorkingComponentDirectory',
    'SManMakeBAK',
    'SManExportOnCompile',
    'SManAfterObjectExportCmd',
    'SManAfterComponentExportCmd',
    'SManCustomComponentCmd',
    'SManNeedMessageCustomComponentCmd',
    'SManCompareCmd',
    'SManTempDirectory');
   PropertiesTitles : array[TProperties] of string = (
     'SManIndicatorTop',
     'SManIndicatorLeft',
     'SManLastMessageCustomComponentCommand',
     'SMan schema',
     'SMan pluging API package',
     'Working object directory',
     'Working component directory',
     'Store BAK files (Y/N)',
     'Export after object compile (Y/N)',
     'Command after object export',
     'Command after component export',
     'Component custom command',
     'Show message window for component custom command (Y/N)',
     'Compare command template',
     'Directory for temp files');
var
   PropertiesHints : array[TProperties] of string = (
     'SManIndicatorTop',
     'SManIndicatorLeft',
     'SManLastMessageCustomComponentCommand',
     'Name of schema',
     'Name of package',
     'Working folder to save exports per ojbects'#13#10+'You can use replaceable parameters: %COMPONENT%, %OBJECTNAME%',
     'Working folder to save export for component'#13#10+'You can use replaceable parameter: %COMPONENT%',
     'Store BAK files (Y/N)',
     'Export after object compile (Y/N)',
     'Command to be executed after object export'#13#10''+'You can use replaceable parameters: %COMPONENT%, %OBJECTNAME%',
     'Command to be executed after component export'#13#10''+'You can use replaceable parameter: %COMPONENT%',
     'Component custom command'#13#10''+'You can use replaceable parameter: %COMPONENT%, %MSG%',
     'Show message window for component custom command (Y/N)',
     'Compare command template'#13#10''+'You can use replaceable parameters: %1, %2',
     'Directory for temp files'#13#10''+'You can use replaceable parameter: %COMPONENT%');
   cpropYes:string='Y';
   cpropNo:string='Y';
procedure EditPreferences;
procedure ReadPreferences;
procedure SavePreferences;
implementation

//uses SManUnit,SManLogUnit;

{$R *.DFM}
procedure ReadPreferences;
var
  aProperty: TProperties;
  aKey, aValue:string;
begin
  LogMessage('SMP:ReadPreferences');

   PropertyList := TStringList.Create;
   for aProperty := Low(aProperty) to High(aProperty) do
   begin
     aKey:= PropertiesKeys[aProperty];
     aValue:='';
     aValue:=IDE_GetPrefAsString(PlugInID, '', PChar(aKey), PChar(aValue));
     if length(aValue)>0 then
     begin
        PropertyList.Values[aKey]:= aValue;
     end
     {else
     begin
        PropertyList.Values[aKey]:='';
     end};
     //PropertyList.Append(aKey+'='+ aValue');
     LogMessage('Loaded '+aKey+'='+aValue);
   end;
   LogMessage('PropertyList.Count='+IntToStr(PropertyList.Count));
end;

procedure SavePreferences;
var
  aProperty: TProperties;
  aKey, aValue:string;
begin
  LogMessage('SMP:SavePreferences');
   if PropertyList <> nil then
   for aProperty := Low(aProperty) to High(aProperty) do
   begin
     aKey:= PropertiesKeys[aProperty];
     aValue:=PropertyList.Values[aKey];
     IDE_SetPrefAsString(PlugInID, '', PChar(aKey), PChar(aValue));
     LogMessage('Saved '+aKey+'='+aValue);
   end;
end;

procedure EditPreferences;
var
  aProperty: TProperties;
  aKey, aValue, aTitle :string;
begin
  LogMessage('SMP:EditPreferences');
  SManPrefsForm := TSManPrefsForm.Create(Application);
  with SManPrefsForm do
  begin
     mHint.Text:='You can use replaceable parameters:';
     mHint.Lines.Add('%COMPONENT% - current/selected component code');
     mHint.Lines.Add('%OBJECTNAME% - current/selected object name');
    //Edit1.Text := IntToStr(Pref1);
    //Edit2.Text := Pref2;
    if PropertyList = nil then ReadPreferences;
    LogMessage('PropertyList.Count='+IntToStr(PropertyList.Count));
    //vlePropertyList.Strings:=PropertyList;
    //to avoid issue with empty value
    for aProperty := pSManSchema to High(aProperty) do
    begin
      aKey:= PropertiesKeys[aProperty];
      aValue:=PropertyList.Values[aKey];
      aTitle:= PropertiesTitles[aProperty];
      //vlePropertyList.Values[aKey]:=aValue;
      //vlePropertyList.Cells[0,Integer(aProperty)+1]:=aTitle;
      //vlePropertyList.Cells[1,Integer(aProperty)+1]:=aValue;
      //vlePropertyList.Keys[Integer(aProperty)]:=aTitle;
      vlePropertyList.Values[aTitle]:=aValue;
    end;

    LogMessage('vlePropertyList='+vlePropertyList.Strings.CommaText);
    if ShowModal = mrOK then
    begin
       for aProperty := pSManSchema to High(aProperty) do
       begin
        aKey:= PropertiesKeys[aProperty];
        aTitle:= PropertiesTitles[aProperty];
        aValue:= vlePropertyList.Values[aTitle];
        PropertyList.Values[aKey]:= aValue;
       end; 
      //PropertyList.Clear;
      //PropertyList.AddStrings(vlePropertyList.Strings);
      SavePreferences;
      // Store preferences
      //Pref1 := StrToInt(Edit1.Text);
      //Pref2 := Edit2.Text;
      //IDE_SetPrefAsInteger(PlugInID, '', 'Pref1', Pref1);
      //IDE_SetPrefAsString(PlugInID, '', 'Pref2', PChar(Pref2));
    end;

    Free;
  end;
  SManPrefsForm := nil;
end;

procedure TSManPrefsForm.vlePropertyListSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
    CanSelect:=true;
    if ACol=1 then 
    mHint.Text:=PropertiesHints[TProperties(ARow-1)];
end;

procedure TSManPrefsForm.vlePropertyListSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
    //mHint.Text:=PropertiesHints[TProperties(ARow)];
end;

end.
