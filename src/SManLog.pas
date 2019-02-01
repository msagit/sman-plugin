unit SManLogUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSManFormLog = class(TForm)
    mSManLog: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SManFormLog: TSManFormLog;
  SManLog: TString;
procedure LogMessage(Message:string);
implementation

{$R *.dfm}
procedure InitLog;
begin
 SManLog:=TString.Create;
end;

procedure ShowLog;
begin
if SManFormLog=nil then
 SManFormLog:=TSManFormLog.Create;
 SManFormLog.Show;
end;

procedure LogMessage(pMessage:string);
begin
if SManFormLog<>nil then
 SManFormLog.mSManLog.Lines.Add(pMessage);
end;

end.
