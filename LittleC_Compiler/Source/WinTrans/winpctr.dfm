object Form1: TForm1
  Left = 192
  Top = 107
  ActiveControl = Memo1
  AutoScroll = False
  Caption = 'WinTrans'
  ClientHeight = 127
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 275
    Height = 86
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 86
    Width = 275
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object Button1: TButton
      Left = 4
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Send'
      Default = True
      TabOrder = 0
      OnClick = Button1Click
    end
    object pb: TProgressBar
      Left = 1
      Top = 30
      Width = 273
      Height = 10
      Align = alBottom
      Min = 0
      Max = 100
      TabOrder = 1
    end
  end
  object cp: TComPort
    BaudRate = br1200
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = True
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsHandshake
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    OnTxEmpty = cpTxEmpty
    Left = 4
  end
end
