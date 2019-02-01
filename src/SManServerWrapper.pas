unit SManServerWrapper;

interface
uses SysUtils, SManPrefUnit,PlugInIntf, SManLogUnit, FileCtrl, StrUtils, SManIndicatorUnit, ShellTools;

type
  TSManServer = class (TObject)
  private
    { Private declarations }
    fLastWorkFolder:string;
    fLastSubFolder:string;
    fLastFileName:string;
    fLastFullPath:string;
    function  GetIsAvalible:boolean;
    function  GetVersion:string;
    function  GetAPIVersion:string;
    function  GetIsSchemaRegistered(const Name:string):boolean;
    function  GetIsObjectRegistered(const Component,ObjectName:string):boolean;
    procedure Save2DiskData(const Key, Data, WorkDirectory, Component, ObjectName, AfterSaveCmd:string);

  public
    { Public declarations }
    property IsAvalible:boolean read GetIsAvalible;
    property Version:string read GetVersion;
    property APIVersion:string read GetAPIVersion;
    property IsSchemaRegistered[const Name:string]:boolean read GetIsSchemaRegistered;
    property IsObjectRegistered[const Component,ObjectName:string]:boolean read GetIsObjectRegistered;
    procedure ExportObject(const Component, ObjectName, WorkDirectory, AfterExportCmd, AfterSaveCmd:string); overload;
    procedure ExportObject(const Component, ObjectName, WorkDirectory:string); overload;
    procedure CompareObject(const Component, ObjectName, WorkDirectory, TempDirrectory:string);
    procedure RegisterObject(const Component, ObjectName, ObjectType:string);
    procedure ComponentReport(const Component:string);
    procedure ExportComponent(const Component, WorkDirectory:string);
  end;

var
  SManServer: TSManServer;

implementation


function  TSManServer.GetIsAvalible:boolean;
begin
  if LeftStr(GetAPIVersion,4) = '1.0.' then
    Result:=true
  else
  begin
    Result:=false;
    LogMessage('Not supported SMan version:'+GetAPIVersion);
  end;
end;

function  TSManServer.GetVersion:string;
begin
   Result:='';
   if SQL_Execute(PChar('select '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.get_version AVAL from dual t'))=0 then
     Result:=SQL_Field(SQL_FieldIndex('AVAL'))
   else
     LogMessage('SQL error:'+SQL_ErrorMessage);
end;

function  TSManServer.GetAPIVersion:string;
begin
   Result:='';
   if SQL_Execute(PChar('select '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.get_api_version AVAL from dual t'))=0 then
     Result:=SQL_Field(SQL_FieldIndex('AVAL'))
   else
     LogMessage('SQL error:'+SQL_ErrorMessage);
end;

function  TSManServer.GetIsSchemaRegistered(const Name:string):boolean;
begin
    Result:=false;
    if SQL_Execute(PChar('select '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.is_schema_registred('''+Name+''') AVAL from dual t'))=0 then
    begin
       if SQL_Field(SQL_FieldIndex('AVAL'))='0' {or (StrCmp PropertyList.Values[PropertiesKeys[pSManSchema]],string(vUsername))} then
           Result:=true;
    end;
end;

function  TSManServer.GetIsObjectRegistered(const Component, ObjectName:string):boolean;
begin
    Result:=false;
    if SQL_Execute(PChar('select '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.is_object_registred('''+Component+''','''+ObjectName+''') AVAL from dual t'))=0 then
    begin
       if SQL_Field(SQL_FieldIndex('AVAL'))='0' {or (StrCmp PropertyList.Values[PropertiesKeys[pSManSchema]],string(vUsername))} then
           Result:=true;
    end;
end;

procedure TSManServer.Save2DiskData(const Key, Data, WorkDirectory, Component, ObjectName, AfterSaveCmd:string);
   var
    vKey:string;
    vPath,vFile,vBakFile:string;
    F: TextFile;
      vCmd:string;
  begin
       vKey:=StringReplace(Key, '/', '\', [rfReplaceAll]);
       //LogMessage('Save data to '+WorkDirectory+Component+vKey);
       fLastWorkFolder:=StringReplace(WorkDirectory,'%COMPONENT%',Component,[rfReplaceAll]);
       fLastFileName:=ExtractFileName(vKey);
       fLastSubFolder:=LeftStr(vKey,Length(vKey)-Length(fLastFileName));
       fLastFullPath:=fLastWorkFolder+fLastSubFolder;
       vFile:=fLastFileName;
       vPath:=fLastFullPath;
       LogMessage('Path :'+vPath);
       LogMessage('File :'+vFile);

       if not DirectoryExists(vPath) then
          if not ForceDirectories(vPath) then
            begin
               LogMessage('Error creating dirrectory:'+vPath+' Error:'+SysErrorMessage(GetLastError));
               LogMessage('Aborting export');
               exit;
            end;

       if (PropertyList.Values[PropertiesKeys[pSManMakeBAK]]=cpropYes) and FileExists(vPath+vFile) then
       begin
          vBakFile:=ChangeFileExt(vFile, '.BAK');
          LogMessage('BakFile :'+vBakFile);
          if FileExists(vPath+vBakFile) then
          begin
             if not DeleteFile(vPath+vBakFile) then
               LogMessage('Unable to delete backup file.'+' Error:'+SysErrorMessage(GetLastError))
             else
               LogMessage('Old backup file deleted.');
          end;
          if not RenameFile(vPath+vFile, vPath+ChangeFileExt(vFile, '.BAK')) then
             LogMessage('Unable to create backup file.'+' Error:'+SysErrorMessage(GetLastError))
          else
             LogMessage('Old file renamed to backup.');

       end;

       AssignFile(F, vPath+vFile); { File selected in dialog }
       Rewrite(F);
       Write(F, Data);
       CloseFile(F);
       LogMessage(IntToStr(Length(Data))+' bytes saved to '+vPath+vFile);

       if AfterSaveCmd<>'' then
       begin
           vCmd:=AfterSaveCmd;
           vCmd:=StringReplace(vCmd,'%COMPONENT%',Component,[rfReplaceAll]);
           vCmd:=StringReplace(vCmd,'%OBJECTNAME%',ObjectName,[rfReplaceAll]);
           vCmd:=StringReplace(vCmd,'%FILENAME%',fLastFileName,[rfReplaceAll]);
           vCmd:=StringReplace(vCmd,'%SUBFOLER%',fLastSubFolder,[rfReplaceAll]);
           vCmd:=StringReplace(vCmd,'%WORKFOLER%',fLastWorkFolder,[rfReplaceAll]);
           vCmd:=StringReplace(vCmd,'%FULLPATH%',fLastFullPath,[rfReplaceAll]);
           LogMessage('Executing:'+vCmd);
           Exec(vCmd);
       end;
  end;
procedure TSManServer.ExportObject(const Component, ObjectName, WorkDirectory:string);
begin
  ExportObject( Component, ObjectName, WorkDirectory, PropertyList.Values[PropertiesKeys[pSManAfterObjectExportCmd]],'');
end;

procedure TSManServer.ExportObject(const Component, ObjectName, WorkDirectory, AfterExportCmd, AfterSaveCmd:string);
var
  vKey:string;
  vData:string;
  vRes, vKeyIndex,vDataIndex:Integer;
  vCmd:string;

begin
  LogMessage('Export SMan for '+ObjectName+'@'+Component+'=>'+WorkDirectory);
  SManIndicator.Progress:=10;
  SQL_ClearVariables;
  SQL_SetVariable('component',PChar(Component));
  SQL_SetVariable('object_name',PChar(ObjectName));
  vRes:=SQL_Execute(PChar('select key, data from  table ('+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.get_object(ip_component => :component, ip_object_name => :object_name))'));
  LogMessage('Exit code:'+IntToStr(vRes));
  SManIndicator.Progress:=60;
  if vRes=0 then
  begin
       vKeyIndex:=SQL_FieldIndex('key');
       vDataIndex:=SQL_FieldIndex('data');
       while not SQL_Eof do
       begin
         vKey:= SQL_Field(vKeyIndex);
         vData:= SQL_Field(vDataIndex);
         SManIndicator.Progress:=SManIndicator.Progress+2;
         Save2DiskData(vKey, vData, WorkDirectory, Component, ObjectName, AfterSaveCmd);
         SManIndicator.Progress:=SManIndicator.Progress+2;
         SQL_Next;
       end;
  end;
  SQL_ClearVariables;
  SManIndicator.Progress:=90;
  vCmd:= AfterExportCmd;//PropertyList.Values[PropertiesKeys[pSManExecuteAfterObjectExport]];
  if vCmd <> '' then
  begin
    vCmd:=StringReplace(vCmd,'%COMPONENT%',Component,[rfReplaceAll]);
    vCmd:=StringReplace(vCmd,'%OBJECTNAME%',ObjectName,[rfReplaceAll]);
    LogMessage('Executing:'+vCmd);
    Exec(vCmd);
  end;

  SManIndicator.Progress:=100;
  SManIndicator.HideProgress;
  LogMessage('Export done!');
  //RunProgramInBackground
end;

procedure TSManServer.ExportComponent(const Component, WorkDirectory:string);
var
  vKey:string;
  vData:string;
  vRes, vKeyIndex,vDataIndex:Integer;
  vCmd:string;

begin
  LogMessage('Export SMan for '+Component+'=>'+WorkDirectory);
  SManIndicator.Progress:=10;
  SQL_ClearVariables;
  SQL_SetVariable('component',PChar(Component));
  vRes:=SQL_Execute(PChar('select key, data from  table ('+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.get_component(ip_component => :component))'));
  LogMessage('Exit code:'+IntToStr(vRes));
  SManIndicator.Progress:=40;
  if vRes=0 then
  begin
       vKeyIndex:=SQL_FieldIndex('key');
       vDataIndex:=SQL_FieldIndex('data');
       while not SQL_Eof do
       begin
         vKey:= SQL_Field(vKeyIndex);
         vData:= SQL_Field(vDataIndex);
         SManIndicator.Progress:=SManIndicator.Progress+2;
         Save2DiskData(vKey, vData, WorkDirectory, Component, '','');
         SManIndicator.Progress:=SManIndicator.Progress+2;
         SQL_Next;
       end;
  end;
  SQL_ClearVariables;
  SManIndicator.Progress:=95;
  vCmd:= PropertyList.Values[PropertiesKeys[pSManAfterComponentExportCmd]];
  if vCmd <> '' then
  begin
    vCmd:=StringReplace(vCmd,'%COMPONENT%',Component,[rfReplaceAll]);
    LogMessage('Executing:'+vCmd);
    Exec(vCmd);
  end;

  SManIndicator.Progress:=100;
  SManIndicator.HideProgress;
  LogMessage('Export done!');
  //RunProgramInBackground
end;

procedure TSManServer.RegisterObject(const Component, ObjectName, ObjectType:string);
var
 vRes : integer;
begin
  SManIndicator.Progress:=10;
  SQL_ClearVariables;
  SQL_SetVariable('ip_component',PChar(Component));
  SQL_SetVariable('ip_object_name',PChar(ObjectName));
  SQL_SetVariable('ip_object_type',PChar(ObjectType));
  //LogMessage('begin '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.pkg_sman$plugin.register_object(:ip_component,:ip_object_name,:ip_object_type); end;');
  vRes:=SQL_Execute(PChar('begin '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.'+PropertyList.Values[PropertiesKeys[pSManPlugingAPI]]+'.register_object(:ip_component,:ip_object_name,:ip_object_type); end;'));
  SManIndicator.Progress:=90;
  if vRes<>0 then
    LogMessage('SQL error:'+SQL_ErrorMessage)
  else
    LogMessage('Registered');
  SQL_ClearVariables;
  SManIndicator.Progress:=100;
  SManIndicator.HideProgress;
end;

procedure TSManServer.ComponentReport(const Component:string);
begin
  SManIndicator.Progress:=10;
  IDE_ExecuteSQLReport(PChar('select t.*, rowid from '+PropertyList.Values[PropertiesKeys[pSManSchema]]+'.sman$_object_config t where cmp_cmp_id='''+PChar(Component)+''''),'Component configuration', true);
  SManIndicator.Progress:=100;
  SManIndicator.HideProgress;
end;

procedure TSManServer.CompareObject(const Component, ObjectName, WorkDirectory, TempDirrectory:string);
var
 vCmd,vWorkFolder:string;
begin
  vCmd:=PropertyList.Values[PropertiesKeys[pSManCompareCmd]];
  if vCmd <> '' then
  begin
    vCmd:=StringReplace(vCmd,'%1','%FULLPATH%%FILENAME%',[rfReplaceAll]);
    vCmd:=StringReplace(vCmd,'%2',WorkDirectory+'%SUBFOLER%%FILENAME%',[rfReplaceAll]);
    Self.ExportObject(Component,ObjectName,TempDirrectory,'',vCmd);
    {vCmd:=StringReplace(vCmd,'%COMPONENT%',Component,[rfReplaceAll]);
    vCmd:=StringReplace(vCmd,'%OBJECTNAME%',ObjectName,[rfReplaceAll]);

    vWorkFolder:=StringReplace(WorkDirectory,'%COMPONENT%',Component,[rfReplaceAll]);

    vCmd:=StringReplace(vCmd,'%1',vWorkFolder+'\'+fLastSubFolder+fLastFileName,[rfReplaceAll]);
    vCmd:=StringReplace(vCmd,'%2',fLastFullPath+fLastFileName,[rfReplaceAll]);}
    //LogMessage('Executing:'+vCmd);
    //Exec(vCmd);
  end;
end;


end.
