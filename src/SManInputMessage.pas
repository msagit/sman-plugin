unit SManInputMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TSManInputMessageForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    eMsg: TMemo;
    lMessage: TLabel;
    Panel3: TPanel;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SManInputMessageForm: TSManInputMessageForm;

implementation

{$R *.dfm}

end.
