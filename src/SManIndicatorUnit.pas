unit SManIndicatorUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, SManPrefUnit, Gauges;

type
  TSManIndicatorForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Panel3: TPanel;
    cbComponent: TComboBox;
    Panel4: TPanel;
    stCurrentType: TEdit;
    stCurrentName: TEdit;
    btnExportObject: TBitBtn;
    btnComponentConfig: TBitBtn;
    Panel5: TPanel;
    gProgress: TGauge;
    Timer: TTimer;
    btnObjectDetails: TBitBtn;
    btnExportComponent: TBitBtn;
    btnCustomComponentCommand: TBitBtn;
    btnCompareObject: TBitBtn;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExportObjectClick(Sender: TObject);
    procedure btnComponentConfigClick(Sender: TObject);
    procedure cbComponentSelect(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure btnObjectDetailsClick(Sender: TObject);
    procedure btnExportComponentClick(Sender: TObject);
    procedure btnCustomComponentCommandClick(Sender: TObject);
    procedure btnCompareObjectClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);

  private
    fRegisteredObject:boolean;
    fRegisteredSchema:boolean;
    fConnected:boolean;
    fObjectOwner:string;
    fOnComponetSelected: TNotifyEvent;
    fOnExportObject: TNotifyEvent;
    fOnConfigComponent: TNotifyEvent;
    fOnObjectDetails: TNotifyEvent;
    fOnObjectCompare: TNotifyEvent;
    fOnCustomComponentCommand: TNotifyEvent;
    fOnExportComponent: TNotifyEvent;
    fOnMoved: TNotifyEvent;
    { Private declarations }
    function GetComponent:string;
    procedure SetComponent(const aValue:string);
    function GetObjectOwner:string;
    procedure SetObjectOwner(const aValue:string);
    function GetObjectType:string;
    procedure SetObjectType(const aValue:string);
    function GetObjectName:string;
    procedure SetObjectName(const aValue:string);
    function GetRegisteredObject:boolean;
    procedure SetRegisteredObject(const aValue:boolean);
    function GetRegisteredSchema:boolean;
    procedure SetRegisteredSchema(const aValue:boolean);
    function GetConnected:boolean;
    procedure SetConnected(const aValue:boolean);
    function GetProgress:integer;
    procedure SetProgress(const aValue:integer);
    procedure FormMoved(var Msg: TWMMove); message WM_MOVE;
  public
    { Public declarations }
    property ObjectOwner: string read GetObjectOwner write SetObjectOwner;
    property ObjectType: string read GetObjectType write SetObjectType;
    property ObjectName: string read GetObjectName write SetObjectName;
    property Component: string read GetComponent write SetComponent;
    property RegisteredObject: boolean read GetRegisteredObject write SetRegisteredObject;
    property RegisteredSchema: boolean read GetRegisteredSchema write SetRegisteredSchema;
    property Connected: boolean read GetConnected write SetConnected;
    property Progress: integer read GetProgress write SetProgress;

    procedure HideProgress;

    procedure ComponetSelected;
    property OnComponetSelected: TNotifyEvent read FOnComponetSelected write FOnComponetSelected;
    procedure ExportObject;
    property OnExportObject: TNotifyEvent read FOnExportObject write FOnExportObject;
    procedure ObjectDetails;
    property OnObjectDetails: TNotifyEvent read FOnObjectDetails write FOnObjectDetails;
    procedure ObjectCompare;
    property OnObjectCompare: TNotifyEvent read FOnObjectCompare write FOnObjectCompare;
    procedure ConfigComponent;
    property OnConfigComponent: TNotifyEvent read FOnConfigComponent write FOnConfigComponent;
    procedure ExportComponent;
    property OnExportComponent: TNotifyEvent read FOnExportComponent write FOnExportComponent;
    procedure CustomComponentCommand;
    property OnCustomComponentCommand: TNotifyEvent read FOnCustomComponentCommand write FOnCustomComponentCommand;
    procedure Moved;
    property OnMoved: TNotifyEvent read fOnMoved write fOnMoved;
  end;

var
  SManIndicator: TSManIndicatorForm;

implementation
//uses SManLogUnit;

{$R *.dfm}

procedure TSManIndicatorForm.Moved;
begin
  //stCurrentName.Text:=(IntToStr(Self.Left));
 if Assigned(fOnMoved) then fOnMoved(Self);
end;

procedure TSManIndicatorForm.ComponetSelected;
begin
   btnComponentConfig.Enabled:=Self.Component<>'';
   btnExportComponent.Enabled:=Self.Component<>'';
   btnCustomComponentCommand.Enabled:=Self.Component<>'';
 if Assigned(fOnComponetSelected) then fOnComponetSelected(Self);
end;

procedure TSManIndicatorForm.CustomComponentCommand;
begin
 if Assigned(fOnCustomComponentCommand) then fOnCustomComponentCommand(Self);
end;

procedure TSManIndicatorForm.ExportComponent;
begin
 if Assigned(fOnExportComponent) then fOnExportComponent(Self);
end;

procedure TSManIndicatorForm.ObjectDetails;
begin
 if Assigned(fOnObjectDetails) then fOnObjectDetails(Self);
end;

procedure TSManIndicatorForm.ObjectCompare;
begin
 if Assigned(fOnObjectCompare) then fOnObjectCompare(Self);
end;

procedure TSManIndicatorForm.ExportObject;
begin
 if Assigned(fOnExportObject) then fOnExportObject(Self);
end;

procedure TSManIndicatorForm.ConfigComponent;
begin
 if Assigned(fOnConfigComponent) then fOnConfigComponent(Self);
end;

procedure TSManIndicatorForm.FormCreate(Sender: TObject);
begin
   //stCurrentType.Caption:='';
   //stCurrentName.Caption:='';
   Connected:=false;
   //LogMessage('Indicator create');
end;

function TSManIndicatorForm.GetComponent:string;
var vIndex:integer;
begin
   vIndex:=cbComponent.ItemIndex;
    result := cbComponent.Text;
end;

procedure TSManIndicatorForm.SetComponent(const aValue:string);
begin
   //stCurrentType.Caption:=aValue;
end;



procedure TSManIndicatorForm.SetObjectOwner(const aValue:string);
begin
   fObjectOwner:=aValue;
end;

function TSManIndicatorForm.GetObjectOwner:string;
begin
   Result:=fObjectOwner;
end;

function TSManIndicatorForm.GetObjectType:string;
begin
   result:=stCurrentType.Text;
end;

procedure TSManIndicatorForm.SetObjectType(const aValue:string);
begin
   stCurrentType.Text:=aValue;
end;

function TSManIndicatorForm.GetObjectName:string;
begin
   Result:=stCurrentName.Text;
end;

procedure TSManIndicatorForm.SetObjectName(const aValue:string);
begin
   stCurrentName.Text:=aValue;
   btnObjectDetails.Enabled:= fRegisteredSchema and (aValue <> '');
end;

function TSManIndicatorForm.GetRegisteredObject:boolean;
begin
   Result:=fRegisteredObject;
end;

procedure TSManIndicatorForm.SetRegisteredObject(const aValue:boolean);
begin
   fRegisteredObject:=aValue;
   //stCurrentName.Caption:=stCurrentName.Caption+':'+BoolToStr(aValue,true);
   if fRegisteredObject then
   begin
     stCurrentName.Color:=clLime;
     btnExportObject.Enabled:=true;
     btnCompareObject.Enabled:=true;
   end
   else
   begin
     stCurrentName.Color:=clBtnFace;
     btnExportObject.Enabled:=false;
     btnCompareObject.Enabled:=false;
   end;
end;

function TSManIndicatorForm.GetRegisteredSchema:boolean;
begin
   Result:=fRegisteredSchema;
   //if not Result then LogMessage('Indicator is set: Schema is not registered');
end;

procedure TSManIndicatorForm.SetRegisteredSchema(const aValue:boolean);
begin
   //LogMessage('Indicator is set to:'+BoolToStr(aValue,true));
   fRegisteredSchema:=aValue;
   if fRegisteredSchema then
   begin
     Shape2.Brush.Color:=clLime;
   end
   else
   begin
     Shape2.Brush.Color:=clBtnFace;
   end;
end;

function TSManIndicatorForm.GetConnected:boolean;
begin
   Result:=fConnected;
end;

procedure TSManIndicatorForm.SetConnected(const aValue:boolean);
begin
   fConnected:=aValue;
   if fConnected then
     Shape1.Brush.Color:=clLime
   else
   begin
     Shape1.Brush.Color:=clSilver;
     Shape2.Brush.Color:=clSilver;
     cbComponent.Clear;
     ObjectType:='';
     ObjectName:='';
     RegisteredObject:=false;
     RegisteredSchema:=false;
     btnComponentConfig.Enabled:=false;
     btnExportComponent.Enabled:=false;
     btnCustomComponentCommand.Enabled:=false;
   end;
end;
procedure TSManIndicatorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action:=caHide;
end;

procedure TSManIndicatorForm.btnExportObjectClick(Sender: TObject);
begin
  //LogMessage('Export SMan for '+vType+' '+vOwner+'.'+vName+'.'+vSubObject);
  //SManServer.ExportObject(Self.Component,Self.ObjectName, PropertyList.Values[PropertiesKeys[pSManWorkingDirectory]]);
  Self.ExportObject;
end;

procedure TSManIndicatorForm.btnComponentConfigClick(Sender: TObject);
begin
//   SManServer.ComponentReport(Self.Component);
   Self.ConfigComponent;
end;

procedure TSManIndicatorForm.cbComponentSelect(Sender: TObject);
begin
   ComponetSelected;
end;

procedure TSManIndicatorForm.SetProgress(const aValue:integer);
begin
   gProgress.Progress:=aValue;
   gProgress.ForeColor:=clBlue;
   gProgress.Visible:=true;
   Application.ProcessMessages;
end;

procedure TSManIndicatorForm.HideProgress;
begin
   gProgress.ForeColor:=clLime;
   //gProgress.Visible:=false;
   Timer.Enabled:=true;
end;

function TSManIndicatorForm.GetProgress:integer;
begin
   result:=gProgress.Progress;
end;

procedure TSManIndicatorForm.TimerTimer(Sender: TObject);
begin
   gProgress.Visible:=false;
   Timer.Enabled:=false;
end;

procedure TSManIndicatorForm.btnObjectDetailsClick(Sender: TObject);
begin
   Self.ObjectDetails;
end;

procedure TSManIndicatorForm.btnExportComponentClick(Sender: TObject);
begin
  Self.ExportComponent;
end;

procedure TSManIndicatorForm.btnCustomComponentCommandClick(
  Sender: TObject);
begin
  Self.CustomComponentCommand;
end;

procedure TSManIndicatorForm.btnCompareObjectClick(Sender: TObject);
begin
  Self.ObjectCompare;
end;

procedure TSManIndicatorForm.FormMoved(var Msg: TWMMove);
begin
  inherited;
  //stCurrentName.Text:=(IntToStr(Self.Left));
  if Timer2 <> nil then
     Timer2.Enabled:=true;
end;

procedure TSManIndicatorForm.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled:=false;
  Self.Moved;
end;

end.
