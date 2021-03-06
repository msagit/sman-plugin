// PL/SQL Developer Plug-In framework
// Copyright 2006 Allround Automations
// support@allroundautomations.com
// http://www.allroundautomations.com

unit SManUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Grids, ExtCtrls, PlugInIntf, SManPrefUnit,SManLogUnit,
  SManIndicatorUnit, SManServerWrapper, SManObjectInformer, ShellTools,
  SManInputMessage;

type
  TDemoForm = class(TForm)
    Panel1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
   TSManPlugin = class (TObject)
    private
    { Private declarations }
  public
    { Public declarations }
    procedure ReloadObjectInfo;
    //--
    procedure ComponentSelected(Sender: TObject);
    procedure ExportObject(Sender: TObject);
    procedure ConfigComponent(Sender: TObject);
    procedure ObjectDetails(Sender: TObject);
    procedure CompareObject(Sender: TObject);
    procedure ExportComponent(Sender: TObject);
    procedure CustomComponentCommand(Sender: TObject);
    procedure IndicatorMoved(Sender: TObject);
  end;
var
  DemoForm: TDemoForm;
  //SManIndicator: TSManIndicatorForm;
  SManPlugin: TSManPlugin;

//var // Some demo preferences, stored in the PL/SQL Developer preference file
//  gObjectType, gObjectOwner, gObjectName, gSubObject: string ;
const // Description of this Plug-In (as displayed in Plug-In configuration dialog)
  cVersion = 'v0.5beta';
  cDesc = 'SMAN Plug-In';
  cAbout = 'SMAN Plug-In '+cVersion+char(13)+char(10)+'Copyright (c) Matsak Sergiy 2016 '+char(13)+char(10)+'matsaks@gmail.com';
type
   TSManActions  = (saShowLog=1,saEditProperties=2,saExtractPreview=3,saRegisterObject=4,saObjectInfo=5,saShowIndicator=6,saExport=7, saResetIndicatorPos=8);
const
   SManActionsTitles : array[TSManActions] of string = ('Show SMan log','Edit SMan Preferences','Preview DDL by SMan', 'Register object to SMan', 'SMan object details', 'Show SMan Indicator', 'Export by SMan', 'Reset Indicator position');

implementation

//uses SManPrefUnit,SManLogUnit;

{$R *.DFM}
procedure TSManPlugin.IndicatorMoved(Sender: TObject);
begin
  PropertyList.Values[PropertiesKeys[pSManIndicatorLeft]]:=IntToStr(SManIndicator.Left);
  PropertyList.Values[PropertiesKeys[pSManIndicatorTop]]:=IntToStr(SManIndicator.Top);
end;


procedure TSManPlugin.ReloadObjectInfo;
var
  vIsObjectRegistered: boolean;
begin
       vIsObjectRegistered:=SManServer.IsObjectRegistered[SManIndicator.Component,SManIndicator.ObjectName] ;
       LogMessage('IsObjectRegistered:'+SManIndicator.ObjectName+'@'+SManIndicator.Component+'='+BoolToStr(vIsObjectRegistered,true));
       if vIsObjectRegistered then
       begin
         SManIndicator.RegisteredObject:=true;
       end
       else
       begin
         SManIndicator.RegisteredObject:=false;
       end;
end;
procedure TSManPlugin.ComponentSelected(Sender: TObject);
begin
   ReloadObjectInfo;
       {vIsObjectRegistered:=SManServer.IsObjectRegistered[SManIndicator.Component,SManIndicator.ObjectName] ;
       LogMessage('IsObjectRegistered:'+SManIndicator.ObjectName+'@'+SManIndicator.Component+'='+BoolToStr(vIsObjectRegistered,true));
       if vIsObjectRegistered then
       begin
         SManIndicator.RegisteredObject:=true;
       end
       else
       begin
         SManIndicator.RegisteredObject:=false;
       end;}

end;

procedure TSManPlugin.ExportComponent(Sender: TObject);
begin
  SManServer.ExportComponent(SManIndicator.Component, PropertyList.Values[PropertiesKeys[pSManWorkingComponentDirectory]]);
end;

procedure TSManPlugin.CustomComponentCommand(Sender: TObject);
var
  vCmd,vMsg:string;
  vInMessage:TSManInputMessageForm;
begin
  vCmd:= PropertyList.Values[PropertiesKeys[pSManCustomComponentCmd]];
  if vCmd <> '' then
  begin
    if PropertyList.Values[PropertiesKeys[pSManNeedMessageCustomComponentCmd]]=cpropYes then
    begin
       vInMessage:=TSManInputMessageForm.Create(Application);
       vInMessage.eMsg.Text:=PropertyList.Values[PropertiesKeys[pSManLastMessageCustomComponentCmd]];
       if vInMessage.ShowModal=mrOk then
       begin
          vMsg:=vInMessage.eMsg.Text;
          PropertyList.Values[PropertiesKeys[pSManLastMessageCustomComponentCmd]]:=vMsg;
       end
       else
       begin
         vInMessage.Free;
         exit;
       end;
       vInMessage.Free;
    end;
         SManIndicator.Progress:=10;
         vCmd:=StringReplace(vCmd,'%COMPONENT%',SManIndicator.Component,[rfReplaceAll]);
         vCmd:=StringReplace(vCmd,'%MSG%',vMsg,[rfReplaceAll]);
         LogMessage('Executing:'+vCmd);
         Exec(vCmd);
         SManIndicator.Progress:=100;
         SManIndicator.HideProgress;
         LogMessage('CustomComponentCommand done!');
  end;
end;

procedure TSManPlugin.ExportObject(Sender: TObject);
begin
  SManServer.ExportObject(SManIndicator.Component,SManIndicator.ObjectName, PropertyList.Values[PropertiesKeys[pSManWorkingObjectDirectory]]);
end;

procedure TSManPlugin.CompareObject(Sender: TObject);
begin
  SManServer.CompareObject(SManIndicator.Component,SManIndicator.ObjectName, PropertyList.Values[PropertiesKeys[pSManWorkingObjectDirectory]], PropertyList.Values[PropertiesKeys[pSManTempDirectory]]);
end;

procedure TSManPlugin.ObjectDetails(Sender: TObject);
var
 Info:TSManObjectInfo;
begin
   Info := TSManObjectInfo.Create(Application,SManIndicator.Component, SManIndicator.ObjectOwner, SManIndicator.ObjectName, SManIndicator.ObjectType, SManIndicator.RegisteredObject, SManIndicator.RegisteredSchema);
   Info.ShowModal;
   Info.Free;
end;

procedure TSManPlugin.ConfigComponent(Sender: TObject);
begin
  SManServer.ComponentReport(SManIndicator.Component);
end;

procedure StartIndicators;
begin
  SManIndicator := TSManIndicatorForm.Create(Application);
  SManIndicator.OnExportObject:=SManPlugin.ExportObject;
  SManIndicator.OnConfigComponent:=SManPlugin.ConfigComponent;
  SManIndicator.OnObjectDetails:=SManPlugin.ObjectDetails;
  SManIndicator.OnObjectCompare:=SManPlugin.CompareObject;
  SManIndicator.OnExportComponent:=SManPlugin.ExportComponent;
  SManIndicator.OnCustomComponentCommand:=SManPlugin.CustomComponentCommand;
  SManIndicator.OnComponetSelected:=SManPlugin.ComponentSelected;
  SManIndicator.OnMoved:=SManPlugin.IndicatorMoved;
  if ((PropertyList.Values[PropertiesKeys[pSManIndicatorLeft]]='') or (PropertyList.Values[PropertiesKeys[pSManIndicatorTop]]='')) then
  begin
    PropertyList.Values[PropertiesKeys[pSManIndicatorLeft]]:='0';
    PropertyList.Values[PropertiesKeys[pSManIndicatorTop]]:='0';
  end;
  SManIndicator.Left:=StrToInt(PropertyList.Values[PropertiesKeys[pSManIndicatorLeft]]);
  SManIndicator.Top:=StrToInt(PropertyList.Values[PropertiesKeys[pSManIndicatorTop]]);
  SManIndicator.Show;
  //SManIndicatorForm:= SManIndicator;
end;

procedure ReloadInfo;
var c: Boolean;
vKey,vValue:string;
vUsername,vPassword, vDatabase:PChar;
begin
  LogMessage('Sman reload info');
  c := IDE_Connected;
  SManIndicator.Connected:=false;
  SManIndicator.Connected:=c;
  if c then
  begin
    LogMessage('Sman schema :'+PropertiesTitles[pSManSchema]);
    if SManServer.IsAvalible then
    begin
        LogMessage('Sman version:'+SManServer.Version);
        LogMessage('Sman API version:'+SManServer.APIVersion);
    //Check schema
    //get current schema
    IDE_GetConnectionInfo(PChar(vUsername),PChar(vPassword), PChar(vDatabase));
    LogMessage('Connected to '+vUsername+'@'+vDatabase) ;

    //LogMessage('is registered ='+BoolToStr(SManServer.IsSchemaRegistered[vUsername],true)) ;
    if SManServer.IsSchemaRegistered[vUsername] then
    begin
        SManIndicator.RegisteredSchema:=true;

    //Read components
    if SQL_Execute(PChar('select t.key AKEY, t.val AVAL from table ('+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.get_components) t'))=0 then
    begin
        LogMessage('Result count:'+IntToStr(SQL_FieldCount));
        if SQL_FieldCount >0 then
        c:=false;
        repeat
          vKey:= SQL_Field(SQL_FieldIndex('AKEY'));
          vValue:= SQL_Field(SQL_FieldIndex('AVAL'));
          //SManIndicator.cbComponent.Items.Values[vKey]:=vValue;
          SManIndicator.cbComponent.Items.Append(vKey);
          if SQL_Eof then Break;
        until (SQL_Next<>0);
    end;

    end
    else
    begin
           LogMessage('Schema not registered in SMan') ;
           SManIndicator.RegisteredSchema:=false;
    end;
    end
    else
    begin
        SManIndicator.Connected:=false;
        LogMessage('Sman not detected');
        //exit;
    end;

  end;
  if SManIndicator.cbComponent.Items.Count=0 then
       SManIndicator.cbComponent.Enabled:=false
    else
       SManIndicator.cbComponent.Enabled:=true;
end;

procedure DoSmanObjectInfo;
var
 Info:TSManObjectInfo;
vType : PChar;
vOwner: PChar;
vName: PChar;
vSubObject: PChar;
vIsObjectRegistered:boolean;
begin
   IDE_GetPopupObject(vType,vOwner,vName,vSubObject);
   LogMessage('Show SMan object info for '+vType+' '+vOwner+'.'+vName+'.'+vSubObject);
   //Component, ObjectSchema, ObjectName, ObjectType:string; IsRegistered:boolean

   if SManIndicator.RegisteredSchema then
   begin
    vIsObjectRegistered:=SManServer.IsObjectRegistered[SManIndicator.Component,vName] ;
    LogMessage('IsObjectRegistered:'+vName+'@'+SManIndicator.Component+'='+BoolToStr(vIsObjectRegistered,true));
   end
   else
     vIsObjectRegistered:=false;
   Info := TSManObjectInfo.Create(Application,SManIndicator.Component, vOwner, vName, vType, vIsObjectRegistered, SManIndicator.RegisteredSchema);
   Info.ShowModal;
   Info.Free;
end;

procedure DoSManRegisterObject;
var
vType : PChar;
vOwner: PChar;
vName: PChar;
vSubObject: PChar;
  vRes:Integer;
Begin
	IDE_GetPopupObject(vType,vOwner,vName,vSubObject);
  LogMessage('Register SMan for '+vType+' '+vOwner+'.'+vName+'.'+vSubObject);
  {SQL_ClearVariables;
  SQL_SetVariable('ip_component',PChar(SManIndicator.Component));
  SQL_SetVariable('ip_object_name',vName);
  SQL_SetVariable('ip_object_type',vType);
  //LogMessage('begin '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.pkg_sman$plugin.register_object(:ip_component,:ip_object_name,:ip_object_type); end;');
  vRes:=SQL_Execute(PChar('begin '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.pkg_sman$plugin.register_object(:ip_component,:ip_object_name,:ip_object_type); end;'));
  if vRes<>0 then
    LogMessage('SQL error:'+SQL_ErrorMessage)
  else
    ShowMessage('Registered');
  SQL_ClearVariables;}
  SManServer.RegisterObject(SManIndicator.Component, vName, vType);
end;

procedure DoSManExport;
var
vType : PChar;
vOwner: PChar;
vName: PChar;
vSubObject: PChar;
begin
	IDE_GetPopupObject(vType,vOwner,vName,vSubObject);
  LogMessage('Export SMan for '+vType+' '+vOwner+'.'+vName+'.'+vSubObject);
  SManServer.ExportObject(SManIndicator.Component,vName, PropertyList.Values[PropertiesKeys[pSManWorkingObjectDirectory]]);
end;

procedure DoSManExtract;
var
vType : PChar;
vOwner: PChar;
vName: PChar;
vSubObject: PChar;
  vBuffStr:string;
  vBuff:PChar;
  vRes:Integer;
begin
	IDE_GetPopupObject(vType,vOwner,vName,vSubObject);
  LogMessage('Extract SMan for '+vType+' '+vOwner+'.'+vName+'.'+vSubObject);
  //vBuffStr := 'Here you will see result from SMan '+string(vType)+' '+String(vOwner)+'.'+string(vName)+'.'+string(vSubObject);
  {if vType='TABLE' then
  begin
    //vRes:=SQL_Execute(PAnsiChar('select pkg_sman$.get_dml(''DEFAULT'',upper('''+vName+''')) SRC from dual'));
    vRes:=SQL_Execute(PChar('select count(1) SRC from '+String(vOwner)+'.'+string(vName)));
    //vRes:=SQL_Execute(PChar('select t.key SRC from table (pkg_sman$plugin.get_components) t  where rownum=1'));
    ShowMessage('Exit code:'+IntToStr(vRes));
    if vRes=0 then
    begin
        ShowMessage('Result count:'+IntToStr(SQL_FieldCount)+' Field value:'+SQL_Field(SQL_FieldIndex('SRC')));
        vBuffStr:= SQL_Field(SQL_FieldIndex('SRC'));
        IDE_CreateWindow(wtSQL, PChar(vBuffStr), false);
    end;
  end
  else
  begin
    //'Here you will see result from SMan'
     IDE_CreateWindow(wtSQL, PChar(vBuffStr) , false);
  end}
  //select path, file_name, data from  table (pkg_sman$.get_single_object(p_component => 'TT', p_object_name => 'ZZ'))
  SQL_ClearVariables;
  SQL_SetVariable('component',PChar(SManIndicator.Component));
  SQL_SetVariable('object_name',vName);
  vRes:=SQL_Execute(PChar('select path, file_name, data from  table (pkg_sman$.get_single_object(p_component => :component, p_object_name => :object_name))'));
  LogMessage('Exit code:'+IntToStr(vRes));
  if vRes=0 then
  begin
       vBuffStr:= SQL_Field(SQL_FieldIndex('data'));
       IDE_CreateWindow(wtSQL, PChar(vBuffStr) , false);

  end;
end;

procedure DoSManComponentReport;
begin
  //IDE_ExecuteSQLReport('select t.*, rowid from '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.sman$_object_config t where cmp_cmp_id='''+PChar(SManIndicator.Component)+''',
  
end;


// Plug-In identification, a unique identifier is received and
// the description is returned
function IdentifyPlugIn(ID: Integer): PChar;  cdecl;
begin
  PlugInID := ID;
  Result := cDesc;
end;

// This function will be called with an Index ranging from 1 to 99. For every Index you
// can return a string that creates a new menu-item in PL/SQL Developer.
function CreateMenuItem(Index: Integer): PChar;  cdecl;
begin
  Result := '';
  case TSManActions(Index) of
    saShowLog : Result := 'Tools / SMan Log';
    saEditProperties : Result := 'Tools / SMan Preferences';
    saShowIndicator : Result := 'Tools / SMan Indicator';
    saResetIndicatorPos : Result := 'Tools / SMan Indicator reset position';
  end;
end;

// This function is called when a user selected a menu-item created with the
// CreateMenuItem function and the Index parameter has the value (1 to 99) it is related to.
procedure OnMenuClick(Index: Integer);  cdecl;
begin
  case TSManActions(Index) of
    saShowLog : begin
          //DemoForm := TDemoForm.Create(Application);
          //DemoForm.ShowModal;
          //DemoForm.Free;
          //DemoForm := nil;
          ShowLog;
        end;
    saEditProperties : EditPreferences;
    //saExtractPreview : DoSManExtract;
    saRegisterObject : DoSManRegisterObject;
    saObjectInfo : DoSManObjectInfo;
    saShowIndicator : begin
            SManIndicator.Show;
        end;
    saExport : DoSManExport;
    saResetIndicatorPos : begin
     SManIndicator.Left:=0;
     SManIndicator.Top:=0;
    end;
  end;
end;

// If your Plug-In depends on a selected item in the Browser, you can use this function
// to enable/disable menu-items. This function is called on every change in the Browser.
// You can use the IDE_GetBrowserInfo callback function to determine if the selected
// item is of interest to you.
procedure OnBrowserChange; cdecl;
begin

end;

// This function is called if PL/SQL Developer child windows change focus. You can use
// the IDE_GetWindowType callback to determine the active child window type.
procedure OnWindowChange; cdecl;
var
  ObjectType, ObjectOwner, ObjectName, SubObject: PChar ;
//  vIsObjectRegistered: boolean;
begin
LogMessage('API:OnWindowChange');
//IDE_GetWindowType
 if IDE_GetWindowType=wtProcEdit then
 begin
     if IDE_GetWindowObject(ObjectType, ObjectOwner, ObjectName, SubObject) then
     begin
       SManIndicator.ObjectOwner:=ObjectOwner;
       SManIndicator.ObjectType:=ObjectType;
       SManIndicator.ObjectName:=ObjectName;
       if SManIndicator.RegisteredSchema then
         SManPlugin.ReloadObjectInfo;
       {if SQL_Execute(PChar('select '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.pkg_sman$plugin.is_object_registred('''+SManIndicator.Component+''','''+SManIndicator.ObjectName+''') AVAL from dual t'))=0 then
       begin
         if SQL_Field(SQL_FieldIndex('AVAL'))='0' then
           SManIndicator.RegisteredObject:=true
         else
         begin
           SManIndicator.RegisteredObject:=false;
           exit;
         end;
       end;}
       {vIsObjectRegistered:=SManServer.IsObjectRegistered[SManIndicator.Component,SManIndicator.ObjectName] ;
       LogMessage('IsObjectRegistered:'+SManIndicator.ObjectName+'@'+SManIndicator.Component+'='+BoolToStr(vIsObjectRegistered,true));
       if vIsObjectRegistered then
       begin
         SManIndicator.RegisteredObject:=true;
       end
       else
       begin
         SManIndicator.RegisteredObject:=false;
       end;}
     end;
 end
 else
 begin
     SManIndicator.ObjectOwner:='';
     SManIndicator.ObjectType:='';
     SManIndicator.ObjectName:='';
     SManIndicator.RegisteredObject:=false;
 end;

end;

// This function is called when the Plug-In is loaded into memory. You can use it to do
// some one-time initialization. PL/SQL Developer is not logged on yet and you can�t
// use the callback functions, so you are limited in the things you can do.
procedure OnCreate; cdecl;
begin
end;

// OnActivate gets called after OnCreate. However, when OnActivate is called PL/SQL
// Developer and the Plug-In are fully initialized. This function is also called when the
// Plug-In is enabled in the configuration dialog. A good point to enable/disable menus.
procedure OnActivate; cdecl;
begin
  Application.Handle := IDE_GetAppHandle;
  InitLog;
  LogMessage('API:OnActivate');
  ReadPreferences;

  //IDE_CreatePopupItem(PlugInID,Integer(saExtractPreview),PChar(SManActionsTitles[saExtractPreview]),'PACKAGE');
  //IDE_CreatePopupItem(PlugInID,Integer(saExtractPreview),PChar(SManActionsTitles[saExtractPreview]),'TABLE');

  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'PACKAGE');
  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'TABLE');
  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'PROCEDURE');
  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'FUNCTION');
  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'VIEW');
  IDE_CreatePopupItem(PlugInID,Integer(saRegisterObject),PChar(SManActionsTitles[saRegisterObject]),'TYPE');

  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'PACKAGE');
  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'TABLE');
  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'PROCEDURE');
  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'FUNCTION');
  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'VIEW');
  IDE_CreatePopupItem(PlugInID,Integer(saObjectInfo),PChar(SManActionsTitles[saObjectInfo]),'TYPE');

  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'PACKAGE');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'PACKAGE BODY');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'TABLE');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'PROCEDURE');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'FUNCTION');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'VIEW');
  IDE_CreatePopupItem(PlugInID,Integer(saExport),PChar(SManActionsTitles[saExport]),'TYPE');

  IDE_CreateToolButton(PlugInID, Integer(saShowLog), PChar(SManActionsTitles[saShowLog]),nil, 0);
  IDE_CreateToolButton(PlugInID, Integer(saEditProperties), PChar(SManActionsTitles[saEditProperties]),nil, 0);

  SManServer:= TSManServer.Create();
  SManPlugin:=TSManPlugin.Create();

  StartIndicators;
  ReloadInfo;

end;

// This is the counterpart of the OnActivate. It is called when the Plug-In is de-activated
// in the configuration dialog.
procedure OnDeactivate; cdecl;
begin
end;

// This is the counterpart of the OnCreate. You can dispose of anything you created in
// the OnCreate.
procedure OnDestroy; cdecl;
begin
  //LogMessage('API:CanClose');
  SavePreferences;
end;

// This will be called when PL/SQL Developer is about to close. If your PlugIn is not
// ready to close, you can show a message and return False.
function CanClose: Bool; cdecl;
begin
  LogMessage('API:CanClose');
  Result := True;
end;

// This function is called directly after a new window is created.
procedure OnWindowCreate(WindowType: Integer); cdecl;
begin
  LogMessage('API:OnWindowCreate');

end;

// This function allows you to take some action before a window is closed. You can
// influence the closing of the window with the following return values:
// 0 = Default behavior
// 1 = Ask the user for confirmation (like the contents was changed)
// 2 = Don�t ask, allow to close without confirmation
// The Changed Boolean indicates the current status of the window.
function OnWindowClose(WindowType: Integer; Changed: BOOL): Integer; cdecl;
begin
  Result := 0;
end;

// This function is called when the user logs on to a different database or logs off. You
// can use the IDE_Connected and IDE_GetConnectionInfo callback to get information
// about the current connection.
procedure OnConnectionChange; cdecl;
begin
  LogMessage('API:OnConnectionChange');
  ReloadInfo;
  //IDE_MenuState(PlugInID, 1, c);
end;

// This function allows you to display an about dialog. You can decide to display a
// dialog yourself (in which case you should return an empty text) or just return the
// about text.
function About: PChar; cdecl;
begin
  Result := cAbout;
end;

// If the Plug-In has a configure dialog you could use this function to activate it. This will
// allow a user to configure your Plug-In using the configure button in the Plug-In
// configuration dialog.
procedure Configure; cdecl;
begin
  LogMessage('API:Configure');
  //ShowMessage('This could be a preference dialog...');
   {DemoForm := TDemoForm.Create(Application);
          DemoForm.ShowModal;
          DemoForm.Free;
          DemoForm := nil;}
   EditPreferences;
end;

// You can use this function if you want the Plug-In to be able to accept commands from
// the command window.
// commands are entered like SQL> plugin [name] command param1 param2 ...
// the [name] is either the dll filename or the identifying (first) part of the description
// See IDE_CommandFeedback for how to return messages to the command window.
procedure CommandLine(FeedbackHandle: Integer; Command, Params: PChar); cdecl;
var i: Integer;
    P: TStringList;
begin
  P := TStringList.Create;
  P.Text := Params;
  IDE_CommandFeedback(FeedbackHandle, PChar('Command "' + Command + '"'));
  for i := 0 to P. Count - 1 do
    IDE_CommandFeedback(FeedbackHandle, PChar('Param' + IntToStr(i + 1) + ' "' + P[i] + '"'));
  P.Free;
end;

procedure OnPopup(ObjectType, ObjectName: PChar); cdecl;
var
vIsObjectRegistered:boolean;
begin
  LogMessage('API:OnPopup:'+ObjectName);

  //if ObjectType = 'PACKAGE' then
  if SManIndicator.RegisteredSchema and (SManIndicator.Component<>'') then
  begin
    vIsObjectRegistered:=SManServer.IsObjectRegistered[SManIndicator.Component,ObjectName] ;
    LogMessage('IsObjectRegistered:'+ObjectName+'@'+SManIndicator.Component+'='+BoolToStr(vIsObjectRegistered,true));
    IDE_MenuState(PlugInID,Integer(saRegisterObject),not vIsObjectRegistered);
    IDE_MenuState(PlugInID,Integer(saExtractPreview),vIsObjectRegistered);
    IDE_MenuState(PlugInID,Integer(saExport),vIsObjectRegistered);
  end
  else
  begin
    IDE_MenuState(PlugInID,Integer(saRegisterObject),false);
    IDE_MenuState(PlugInID,Integer(saExtractPreview),false);
    IDE_MenuState(PlugInID,Integer(saExport),false);
  end;

end;

procedure AfterExecuteWindow(WindowType, Result: Integer); cdecl;
 var
  ObjectType, ObjectOwner, ObjectName, SubObject: PChar ;
    vIsObjectRegistered: boolean;
begin
  LogMessage('API:AfterExecuteWindow');
  if PropertyList.Values[PropertiesKeys[pSManExportOnCompile]]=cpropYes then
  if WindowType=wtProcEdit then
  begin
     if IDE_GetWindowObject(ObjectType, ObjectOwner, ObjectName, SubObject) then
     begin
       if (ObjectName=SManIndicator.ObjectName) and SManIndicator.RegisteredObject then
       begin
          LogMessage('Compile detected for registered object: '+ObjectName);
          SManServer.ExportObject(SManIndicator.Component,SManIndicator.ObjectName, PropertyList.Values[PropertiesKeys[pSManWorkingObjectDirectory]]);
       end;
     end;
  end;



end;

// Exported functions
exports
  IdentifyPlugIn,
  CreateMenuItem,
  RegisterCallback,
  OnCreate,
  OnActivate,
  OnDeactivate,
  OnDestroy,
  CanClose,
  OnMenuClick,
  OnBrowserChange,
  OnWindowChange,
  OnWindowCreate,
  OnWindowClose,
  OnConnectionChange,
  About,
  Configure,
  CommandLine,
  OnPopup,
  AfterExecuteWindow;

end.
