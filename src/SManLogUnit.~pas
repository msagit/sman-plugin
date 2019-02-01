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
const
 cMaxLogSize:Integer=1000;
var
  SManFormLog: TSManFormLog;
  SManLog: TStringList;
procedure LogMessage(pMsg:string);
procedure InitLog;
procedure ShowLog;
implementation

{$R *.dfm}
procedure InitLog;
begin
 SManLog:=TStringList.Create;
end;

procedure ShowLog;
begin
if SManFormLog=nil then
 SManFormLog:=TSManFormLog.Create(Application);
 SManFormLog.mSManLog.Lines:=SManLog;
 SManFormLog.Show;
end;

procedure LogMessage(pMsg:string);
var
aMsg : string;
begin
aMsg:=DateTimeToStr(Now)+' '+pMsg;
SManLog.Add(aMsg);
if SManFormLog<>nil then
 SManFormLog.mSManLog.Lines.Add(aMsg);

if SManLog.Count > cMaxLogSize then
   SManLog.Delete(0);
end;

end.
