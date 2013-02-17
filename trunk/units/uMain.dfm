object frmMain: TfrmMain
  Left = 426
  Top = 188
  Caption = 'Tim2View by [Lab 313]'
  ClientHeight = 510
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  ScreenSnap = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object tbcFiles: TTabControl
    Left = 0
    Top = 0
    Width = 734
    Height = 477
    Align = alClient
    MultiLine = True
    TabOrder = 0
    ExplicitHeight = 491
    object pnlMain: TPanel
      Left = 4
      Top = 6
      Width = 726
      Height = 467
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitHeight = 481
      object splMain: TSplitter
        Left = 201
        Top = 0
        Height = 467
        ExplicitHeight = 481
      end
      object tvList: TTreeView
        Left = 0
        Top = 0
        Width = 201
        Height = 467
        Align = alLeft
        Indent = 19
        RowSelect = True
        TabOrder = 0
        Items.NodeData = {
          0302000000300000000000000000000000FFFFFFFFFFFFFFFF00000000000000
          0000000000010947006F006F0064002000540049004D0073002E000000000000
          0000000000FFFFFFFFFFFFFFFF00000000000000000000000001084200610064
          002000540049004D007300}
        ExplicitHeight = 481
      end
      object pgcMain: TPageControl
        Left = 204
        Top = 0
        Width = 522
        Height = 467
        ActivePage = tsImage
        Align = alClient
        TabOrder = 1
        ExplicitHeight = 481
        object tsInfo: TTabSheet
          Caption = 'INFO'
          ExplicitHeight = 453
          object tbInfo: TStringGrid
            Left = 0
            Top = 0
            Width = 514
            Height = 439
            Align = alClient
            ColCount = 3
            DefaultColWidth = 50
            DefaultRowHeight = 20
            FixedCols = 0
            RowCount = 26
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
            ScrollBars = ssVertical
            TabOrder = 0
            ExplicitHeight = 453
            ColWidths = (
              210
              108
              154)
          end
        end
        object tsImage: TTabSheet
          Caption = 'IMAGE'
          ImageIndex = 1
          ExplicitHeight = 453
          object pnlImage: TPanel
            Left = 0
            Top = 0
            Width = 514
            Height = 439
            Align = alClient
            BevelOuter = bvLowered
            TabOrder = 0
            ExplicitHeight = 453
          end
        end
        object tsClut: TTabSheet
          Caption = 'CLUT'
          ImageIndex = 2
          ExplicitHeight = 453
        end
      end
    end
  end
  object stbMain: TStatusBar
    Left = 0
    Top = 477
    Width = 734
    Height = 33
    Panels = <
      item
        Width = 250
      end
      item
        Style = psOwnerDraw
        Width = 50
      end>
    OnDrawPanel = stbMainDrawPanel
  end
  object pbProgress: TProgressBar
    Left = 248
    Top = 440
    Width = 150
    Height = 16
    Smooth = True
    TabOrder = 2
  end
  object btnStopScan: TButton
    Left = 404
    Top = 440
    Width = 75
    Height = 25
    Caption = 'Stop Scan'
    TabOrder = 3
    OnClick = btnStopScanClick
  end
  object mmMain: TMainMenu
    Left = 592
    Top = 480
    object mnFile: TMenuItem
      Caption = '&File'
      object mnScanFile: TMenuItem
        Caption = 'Scan &File...'
        OnClick = mnScanFileClick
      end
      object mnScanDir: TMenuItem
        Caption = 'Scan &Directory...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnCloseFile: TMenuItem
        Caption = 'Close &This File'
      end
      object mnCloseAllFiles: TMenuItem
        Caption = 'Close &All Files'
      end
      object mnExit: TMenuItem
        Caption = '&Exit...'
      end
    end
    object mnImage: TMenuItem
      Caption = '&Image'
    end
    object mnTIM: TMenuItem
      Caption = '&TIM'
      object mnReplaceIn: TMenuItem
        Caption = '&Replace in File...'
        ShortCut = 16466
      end
    end
    object mnHelp: TMenuItem
      Caption = '&Help'
    end
  end
  object xpMain: TXPManifest
    Left = 624
    Top = 480
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = '.bin'
    Filter = 'All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofNoNetworkButton, ofEnableSizing, ofForceShowHidden]
    Title = 'Please, select File to Scan...'
    Left = 652
    Top = 478
  end
end
