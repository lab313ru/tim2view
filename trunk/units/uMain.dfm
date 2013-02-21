object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 532
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
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object tbcMain: TTabControl
    Left = 0
    Top = 0
    Width = 738
    Height = 503
    Align = alClient
    TabOrder = 0
    OnChange = tbcMainChange
    object pnlMain: TPanel
      Left = 4
      Top = 6
      Width = 730
      Height = 493
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object splMain: TSplitter
        Left = 233
        Top = 0
        Height = 493
        ExplicitLeft = 201
        ExplicitHeight = 481
      end
      object pgcMain: TPageControl
        Left = 236
        Top = 0
        Width = 494
        Height = 493
        ActivePage = tsImage
        Align = alClient
        TabOrder = 0
        object tsInfo: TTabSheet
          Caption = 'INFO'
          object tbInfo: TStringGrid
            Left = 0
            Top = 0
            Width = 486
            Height = 465
            Align = alClient
            ColCount = 3
            DefaultColWidth = 50
            DefaultRowHeight = 16
            FixedCols = 0
            RowCount = 26
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
            ScrollBars = ssVertical
            TabOrder = 0
            ColWidths = (
              210
              108
              154)
          end
        end
        object tsImage: TTabSheet
          Caption = 'IMAGE'
          ImageIndex = 1
          object pnlImage: TPaintBox
            Left = 0
            Top = 0
            Width = 486
            Height = 465
            Align = alClient
            Color = clWhite
            ParentColor = False
            ExplicitLeft = 144
            ExplicitTop = 168
            ExplicitWidth = 105
            ExplicitHeight = 105
          end
        end
        object tsClut: TTabSheet
          Caption = 'CLUT'
          ImageIndex = 2
          object grdCLUT: TDrawGrid
            Left = 0
            Top = 0
            Width = 486
            Height = 465
            Align = alClient
            ColCount = 16
            DefaultColWidth = 20
            DefaultRowHeight = 20
            FixedCols = 0
            RowCount = 16
            FixedRows = 0
            ScrollBars = ssNone
            TabOrder = 0
          end
        end
      end
      object pnlList: TPanel
        Left = 0
        Top = 0
        Width = 233
        Height = 493
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object lvList: TListView
          Left = 0
          Top = 0
          Width = 233
          Height = 493
          Align = alClient
          Columns = <
            item
              Caption = '#'
              Width = 60
            end
            item
              Alignment = taCenter
              Caption = 'Resolution'
              Width = 95
            end
            item
              Caption = 'BPP'
            end>
          DoubleBuffered = True
          GridLines = True
          OwnerData = True
          ReadOnly = True
          RowSelect = True
          ParentDoubleBuffered = False
          TabOrder = 0
          ViewStyle = vsReport
          OnClick = lvListClick
          OnData = lvListData
          OnKeyDown = lvListKeyDown
          ExplicitLeft = 1
          ExplicitTop = -1
        end
      end
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 503
    Width = 738
    Height = 29
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object lblStatus: TLabel
      Left = 76
      Top = 1
      Width = 161
      Height = 27
      Align = alClient
      Alignment = taRightJustify
      Layout = tlCenter
      ExplicitLeft = 234
      ExplicitWidth = 3
      ExplicitHeight = 13
    end
    object pbProgress: TProgressBar
      Left = 237
      Top = 1
      Width = 500
      Height = 27
      Align = alRight
      Smooth = True
      TabOrder = 0
    end
    object btnStopScan: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 27
      Align = alLeft
      Caption = 'Stop Scan'
      Enabled = False
      TabOrder = 1
      OnClick = btnStopScanClick
    end
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
        Enabled = False
        ShortCut = 119
        OnClick = mnCloseFileClick
      end
      object mnCloseAllFiles: TMenuItem
        Caption = 'Close &All Files'
        ShortCut = 120
        OnClick = mnCloseAllFilesClick
      end
      object mnExit: TMenuItem
        Caption = '&Exit...'
        ShortCut = 121
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
    object mnConfig: TMenuItem
      Caption = '&Config'
      object mnAutoExtract: TMenuItem
        AutoCheck = True
        Caption = '&Auto Extraction'
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
