unit SManObjectInformer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,  Buttons, Grids,
  ValEdit, ExtCtrls, CheckLst, SManServerWrapper;

type
  TSManObjectInfo = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Panel7: TPanel;
    Label2: TLabel;
    eName: TEdit;
    eType: TEdit;
    Panel8: TPanel;
    CheckListBox1: TCheckListBox;
    Label3: TLabel;
    Panel9: TPanel;
    ValueListEditor1: TValueListEditor;
    Label4: TLabel;
    Panel10: TPanel;
    Label5: TLabel;
    eComponent: TEdit;
    btnRegister: TButton;
    sRegistered: TShape;
    procedure btnRegisterClick(Sender: TObject);
  private
    { Private declarations }
    fObjectName:string;
    fObjectType:string;
    fRegisteredObject:boolean;
    fConnected:boolean;
    fComponent:string;
    fObjectSchema:string;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; Component, ObjectSchema, ObjectName, ObjectType:string; Registered,Connected:boolean ); //override; { this syntax is always the same }
  end;

//var
//  SManObjectInfo: TSManObjectInfo;

implementation

{$R *.dfm}

constructor TSManObjectInfo.Create(AOwner: TComponent; Component, ObjectSchema, ObjectName, ObjectType:string; Registered,Connected:boolean );  { this syntax is always the same }
begin
   inherited Create(AOwner);
   fObjectName:=ObjectName;
   fObjectType:=ObjectType;
   fRegisteredObject:=Registered;
   fComponent:=Component;
   fObjectSchema:=ObjectSchema;
   fConnected:=Connected;
   //init
   eType.Text:=fObjectType;
   eName.Text:=fObjectName;
   eComponent.Text:=fComponent;
   btnRegister.Enabled:=false;
   if fRegisteredObject then
   begin
      sRegistered.Brush.Color:=clLime;
      //sRegistered.Caption:='Registered';
      //ShowMessage(intToStr(sRegistered.Color));
   end
   else
   begin
      //sRegistered.Caption:='';
      sRegistered.Brush.Color:=clSilver;
      if fConnected and (eComponent.Text<>'') then
      begin
        btnRegister.Enabled:=true;

      end;
   end;
end;

procedure TSManObjectInfo.btnRegisterClick(Sender: TObject);
begin
  SManServer.RegisterObject(fComponent, fObjectName, fObjectType);
  if SManServer.IsObjectRegistered[fComponent, fObjectName] then
  begin
      sRegistered.Brush.Color:=clLime;
      btnRegister.Enabled:=false;
  end;
end;

end.
