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
  object stbMain: TStatusBar
    Left = 0
    Top = 505
    Width = 738
    Height = 27
    Panels = <
      item
        Width = 220
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
    Height = 505
    Align = alClient
    MultiLine = True
    TabOrder = 3
    object pnlMain: TPanel
      Left = 4
      Top = 6
      Width = 730
      Height = 495
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object splMain: TSplitter
        Left = 233
        Top = 0
        Height = 495
        ExplicitLeft = 201
        ExplicitHeight = 481
      end
      object pgcMain: TPageControl
        Left = 236
        Top = 0
        Width = 494
        Height = 495
        ActivePage = tsImage
        Align = alClient
        TabOrder = 0
        object tsInfo: TTabSheet
          Caption = 'INFO'
          object tbInfo: TStringGrid
            Left = 0
            Top = 0
            Width = 486
            Height = 467
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
            Height = 467
            Align = alClient
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
            Height = 467
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
        Height = 495
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object lvList: TListView
          Left = 0
          Top = 0
          Width = 233
          Height = 495
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
              Alignment = taRightJustify
              Caption = 'BPP'
            end>
          DoubleBuffered = True
          Groups = <
            item
              Header = 'Good TIMs'
              GroupID = 0
              State = [lgsNormal, lgsCollapsed, lgsCollapsible]
              HeaderAlign = taLeftJustify
              FooterAlign = taLeftJustify
              TitleImage = -1
            end
            item
              Header = 'Bad TIMs'
              GroupID = 1
              State = [lgsNormal, lgsCollapsed, lgsCollapsible]
              HeaderAlign = taLeftJustify
              FooterAlign = taLeftJustify
              TitleImage = -1
            end>
          GroupView = True
          ReadOnly = True
          RowSelect = True
          ParentDoubleBuffered = False
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = lvListChange
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
    Enabled = False
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
        OnClick = mnScanDirClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnCloseFile: TMenuItem
        Caption = 'Close &This File'
        ShortCut = 119
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
end
