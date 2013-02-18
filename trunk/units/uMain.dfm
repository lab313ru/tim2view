object frmMain: TfrmMain
  Left = 0
  Top = 0
  ActiveControl = btnStopScan
  Caption = 'frmMain'
  ClientHeight = 504
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object stbMain: TStatusBar
    Left = 0
    Top = 471
    Width = 738
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
  object tbcFiles: TTabControl
    Left = 0
    Top = 0
    Width = 738
    Height = 471
    Align = alClient
    MultiLine = True
    TabOrder = 3
    object pnlMain: TPanel
      Left = 4
      Top = 6
      Width = 730
      Height = 461
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object splMain: TSplitter
        Left = 201
        Top = 0
        Height = 461
        ExplicitHeight = 481
      end
      object tvList: TTreeView
        Left = 0
        Top = 0
        Width = 201
        Height = 461
        Align = alLeft
        Indent = 19
        RowSelect = True
        TabOrder = 0
        Items.NodeData = {
          0302000000300000000000000000000000FFFFFFFFFFFFFFFF00000000000000
          0000000000010947006F006F0064002000540049004D0073002E000000000000
          0000000000FFFFFFFFFFFFFFFF00000000000000000000000001084200610064
          002000540049004D007300}
      end
      object pgcMain: TPageControl
        Left = 204
        Top = 0
        Width = 526
        Height = 461
        ActivePage = tsImage
        Align = alClient
        TabOrder = 1
        object tsInfo: TTabSheet
          Caption = 'INFO'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 514
          ExplicitHeight = 439
          object tbInfo: TStringGrid
            Left = 0
            Top = 0
            Width = 518
            Height = 433
            Align = alClient
            ColCount = 3
            DefaultColWidth = 50
            DefaultRowHeight = 20
            FixedCols = 0
            RowCount = 26
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
            ScrollBars = ssVertical
            TabOrder = 0
            ExplicitWidth = 514
            ExplicitHeight = 439
            ColWidths = (
              210
              108
              154)
          end
        end
        object tsImage: TTabSheet
          Caption = 'IMAGE'
          ImageIndex = 1
          object pnlImage: TPanel
            Left = 0
            Top = 0
            Width = 518
            Height = 433
            Align = alClient
            BevelOuter = bvLowered
            TabOrder = 0
          end
        end
        object tsClut: TTabSheet
          Caption = 'CLUT'
          ImageIndex = 2
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 468
          ExplicitHeight = 369
        end
      end
    end
  end
  object btnStopScan: TButton
    Left = 503
    Top = 477
    Width = 75
    Height = 25
    Caption = 'Stop Scan'
    TabOrder = 0
    OnClick = btnStopScanClick
  end
  object pbProgress: TProgressBar
    Left = 336
    Top = 480
    Width = 150
    Height = 16
    Smooth = True
    TabOrder = 1
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = '.bin'
    Filter = 'All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofNoNetworkButton, ofEnableSizing, ofForceShowHidden]
    Title = 'Please, select File to Scan...'
    Left = 652
    Top = 478
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
      object mnHelpFile: TMenuItem
        Caption = '&Help'
        ShortCut = 16496
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnSVN: TMenuItem
        Caption = 'Tim2Vew &SVN Repo'
      end
      object mnSite: TMenuItem
        Caption = '&Lab 313 Forum'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnAbout: TMenuItem
        Caption = '&About...'
      end
    end
  end
  object xpMain: TXPManifest
    Left = 624
    Top = 480
  end
end
