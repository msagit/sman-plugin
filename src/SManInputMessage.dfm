object SManInputMessageForm: TSManInputMessageForm
  Left = 283
  Top = 114
  Width = 615
  Height = 299
  Caption = 'Input message'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 607
    Height = 17
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lMessage: TLabel
      Left = 0
      Top = 0
      Width = 46
      Height = 17
      Align = alLeft
      Caption = 'Message:'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 17
    Width = 607
    Height = 207
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object eMsg: TMemo
      Left = 0
      Top = 0
      Width = 607
      Height = 207
      Align = alClient
      Lines.Strings = (
        '')
      TabOrder = 0
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 224
    Width = 607
    Height = 41
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      607
      41)
    object BitBtn1: TBitBtn
      Left = 519
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 0
    end
  end
end
