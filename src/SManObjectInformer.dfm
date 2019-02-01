object SManObjectInfo: TSManObjectInfo
  Left = 366
  Top = 187
  Width = 332
  Height = 224
  BorderStyle = bsSizeToolWin
  Caption = 'SMan Object Details'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 324
    Height = 190
    Align = alClient
    TabOrder = 0
    object Panel3: TPanel
      Left = 1
      Top = 22
      Width = 322
      Height = 48
      Align = alTop
      TabOrder = 0
      object Panel5: TPanel
        Left = 1
        Top = 1
        Width = 241
        Height = 46
        Align = alClient
        TabOrder = 0
        object Panel1: TPanel
          Left = 1
          Top = 22
          Width = 239
          Height = 21
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          DesignSize = (
            239
            21)
          object Label1: TLabel
            Left = 0
            Top = 0
            Width = 40
            Height = 21
            Align = alLeft
            AutoSize = False
            Caption = 'Name'
          end
          object eName: TEdit
            Left = 40
            Top = 0
            Width = 198
            Height = 23
            TabStop = False
            Anchors = [akLeft, akTop, akRight, akBottom]
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 0
            Text = 'eName'
          end
        end
        object Panel7: TPanel
          Left = 1
          Top = 1
          Width = 239
          Height = 21
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            239
            21)
          object Label2: TLabel
            Left = 0
            Top = 0
            Width = 40
            Height = 21
            Align = alLeft
            AutoSize = False
            Caption = 'Type'
          end
          object eType: TEdit
            Left = 40
            Top = 0
            Width = 198
            Height = 21
            TabStop = False
            Anchors = [akLeft, akTop, akRight, akBottom]
            Color = clBtnFace
            ReadOnly = True
            TabOrder = 0
            Text = 'eType'
          end
        end
      end
      object Panel6: TPanel
        Left = 242
        Top = 1
        Width = 79
        Height = 46
        Align = alRight
        TabOrder = 1
        object sRegistered: TShape
          Left = 0
          Top = 0
          Width = 79
          Height = 17
        end
        object btnRegister: TButton
          Left = 2
          Top = 18
          Width = 75
          Height = 25
          Caption = 'Register'
          Enabled = False
          TabOrder = 0
          OnClick = btnRegisterClick
        end
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 70
      Width = 322
      Height = 119
      Align = alClient
      TabOrder = 1
      object Panel8: TPanel
        Left = 1
        Top = 1
        Width = 136
        Height = 117
        Align = alLeft
        Caption = 'Panel8'
        TabOrder = 0
        Visible = False
        object Label3: TLabel
          Left = 1
          Top = 1
          Width = 134
          Height = 13
          Align = alTop
          Caption = 'Used in components:'
        end
        object CheckListBox1: TCheckListBox
          Left = 1
          Top = 14
          Width = 134
          Height = 102
          Align = alClient
          Enabled = False
          ItemHeight = 13
          Items.Strings = (
            'COMP1'
            'COMP2')
          TabOrder = 0
        end
      end
      object Panel9: TPanel
        Left = 137
        Top = 1
        Width = 184
        Height = 117
        Align = alClient
        Caption = 'Panel9'
        TabOrder = 1
        object Label4: TLabel
          Left = 1
          Top = 1
          Width = 182
          Height = 13
          Align = alTop
          Caption = 'Properties'
        end
        object ValueListEditor1: TValueListEditor
          Left = 1
          Top = 14
          Width = 182
          Height = 102
          Align = alClient
          Enabled = False
          TabOrder = 0
          ColWidths = (
            92
            84)
        end
      end
    end
    object Panel10: TPanel
      Left = 1
      Top = 1
      Width = 322
      Height = 21
      Align = alTop
      TabOrder = 2
      DesignSize = (
        322
        21)
      object Label5: TLabel
        Left = 1
        Top = 1
        Width = 95
        Height = 19
        Align = alLeft
        AutoSize = False
        Caption = 'Current component'
      end
      object eComponent: TEdit
        Left = 97
        Top = 0
        Width = 224
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 0
        Text = 'eComponent'
      end
    end
  end
end
