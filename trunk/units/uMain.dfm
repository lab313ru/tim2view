object frmMain: TfrmMain
  Left = 0
  Top = 0
  Width = 754
  Height = 591
  AutoScroll = True
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlStatus: TPanel
    Left = 0
    Top = 502
    Width = 738
    Height = 30
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 2
    object lblStatus: TLabel
      Left = 76
      Top = 1
      Width = 157
      Height = 28
      Align = alClient
      Alignment = taRightJustify
      Layout = tlCenter
      ExplicitWidth = 154
    end
    object pbProgress: TProgressBar
      Left = 233
      Top = 1
      Width = 504
      Height = 28
      Align = alRight
      Smooth = True
      TabOrder = 1
    end
    object btnStopScan: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 28
      Align = alLeft
      Caption = 'Stop Scan'
      Enabled = False
      TabOrder = 0
      OnClick = btnStopScanClick
      ExplicitHeight = 27
    end
  end
  object cbbFiles: TComboBox
    Left = 0
    Top = 0
    Width = 738
    Height = 21
    Align = alTop
    AutoDropDown = True
    AutoCloseUp = True
    Style = csDropDownList
    DropDownCount = 30
    TabOrder = 0
    OnChange = cbbFilesChange
  end
  object pnlMain: TPanel
    Left = 0
    Top = 21
    Width = 738
    Height = 481
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitHeight = 482
    object splMain: TSplitter
      Left = 233
      Top = 0
      Height = 481
      ResizeStyle = rsUpdate
      ExplicitLeft = 201
    end
    object pnlList: TPanel
      Left = 0
      Top = 0
      Width = 233
      Height = 481
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitHeight = 482
      object lblTimInformation: TLabel
        AlignWithMargins = True
        Left = 3
        Top = 465
        Width = 227
        Height = 13
        Align = alBottom
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clHotLight
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblTimInformationClick
        OnMouseMove = lblTimInformationMouseMove
        OnMouseEnter = lblTimInformationMouseEnter
        OnMouseLeave = lblTimInformationMouseLeave
        ExplicitTop = 466
        ExplicitWidth = 3
      end
      object lvList: TListView
        Left = 0
        Top = 0
        Width = 233
        Height = 462
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
        HideSelection = False
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = lvListClick
        OnData = lvListData
        OnKeyDown = lvListKeyDown
        ExplicitHeight = 463
      end
    end
    object pnlImage: TPanel
      Left = 236
      Top = 0
      Width = 502
      Height = 481
      Align = alClient
      BevelOuter = bvLowered
      TabOrder = 1
      ExplicitHeight = 482
      object pbImage: TPaintBox
        Left = 1
        Top = 4
        Width = 500
        Height = 296
        Align = alClient
        Color = clWhite
        ParentColor = False
        OnPaint = pbImagePaint
        ExplicitLeft = 3
        ExplicitTop = -2
      end
      object splImageClut: TSplitter
        Left = 1
        Top = 1
        Width = 500
        Height = 3
        Cursor = crVSplit
        Align = alTop
        Beveled = True
        ResizeStyle = rsUpdate
        ExplicitTop = 274
      end
      object grdCurrCLUT: TDrawGrid
        Left = 1
        Top = 330
        Width = 500
        Height = 150
        Align = alBottom
        ColCount = 1
        DefaultColWidth = 14
        DefaultRowHeight = 14
        DoubleBuffered = True
        Enabled = False
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
        ParentDoubleBuffered = False
        ScrollBars = ssNone
        TabOrder = 0
        OnDblClick = grdCurrCLUTDblClick
        OnDrawCell = grdCurrCLUTDrawCell
        ExplicitLeft = 0
        ExplicitTop = 372
      end
      object pnlImageOptions: TPanel
        Left = 1
        Top = 300
        Width = 500
        Height = 30
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 1
        ExplicitTop = 451
        object cbbCLUT: TComboBox
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 152
          Height = 21
          Align = alLeft
          AutoDropDown = True
          AutoCloseUp = True
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbbCLUTChange
        end
        object cbbTransparenceMode: TComboBox
          AlignWithMargins = True
          Left = 162
          Top = 4
          Width = 145
          Height = 21
          Align = alLeft
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 1
          Text = 'Full transparence'
          OnClick = cbbTransparenceModeClick
          Items.Strings = (
            'Full transparence'
            'Black Transparence'
            'Semi Transparence'
            'No Transparence')
        end
        object pnlCLUTColor: TPanel
          Left = 314
          Top = 1
          Width = 185
          Height = 28
          Align = alRight
          BevelOuter = bvLowered
          TabOrder = 2
        end
      end
    end
  end
  object dlgOpenFile: TOpenDialog
    DefaultExt = '.bin'
    Filter = 'All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofAllowMultiSelect, ofFileMustExist, ofNoNetworkButton, ofEnableSizing, ofForceShowHidden]
    Title = 'Please, select File...'
    Left = 668
    Top = 502
  end
  object mmMain: TMainMenu
    Left = 608
    Top = 504
    object mnFile: TMenuItem
      Caption = '&File'
      object mnScanFile: TMenuItem
        Caption = 'Scan &File...'
        ShortCut = 116
        OnClick = mnScanFileClick
      end
      object mnScanDir: TMenuItem
        Caption = 'Scan &Directory...'
        ShortCut = 117
        OnClick = mnScanDirClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnCloseFile: TMenuItem
        Caption = 'Close &This File'
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
        OnClick = mnExitClick
      end
    end
    object mnImage: TMenuItem
      Caption = '&Image'
      object mnSaveToPNG: TMenuItem
        Caption = 'Save to PNG File...'
        ShortCut = 114
        OnClick = mnSaveToPNGClick
      end
    end
    object mnTIM: TMenuItem
      Caption = '&TIM'
      object mnSaveTIM: TMenuItem
        Caption = '&Save TIM to File...'
        ShortCut = 113
        OnClick = mnSaveTIMClick
      end
      object mnReplaceIn: TMenuItem
        Caption = '&Replace in File...'
        ShortCut = 16466
        OnClick = mnReplaceInClick
      end
    end
    object mnConfig: TMenuItem
      Caption = '&Config'
      object mnAutoExtract: TMenuItem
        AutoCheck = True
        Caption = '&Auto Extraction'
      end
      object mnViewMode: TMenuItem
        Caption = '&View Mode'
        object mnSimpleMode: TMenuItem
          AutoCheck = True
          Caption = '&Simple Mode'
          Checked = True
          RadioItem = True
          OnClick = mnSimpleModeClick
        end
        object mnAdvancedMode: TMenuItem
          AutoCheck = True
          Caption = '&Advanced Mode'
          RadioItem = True
          OnClick = mnAdvancedModeClick
        end
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
    Left = 640
    Top = 504
  end
  object dlgSavePNG: TSavePictureDialog
    DefaultExt = 'png'
    Filter = 'Portable Network Graphics (*.png)|*.png'
    Options = [ofHideReadOnly, ofNoChangeDir, ofNoNetworkButton, ofEnableSizing]
    Title = 'Please, select filename for PNG...'
    Left = 704
    Top = 504
  end
  object dlgSaveTIM: TSaveDialog
    DefaultExt = 'tim'
    Filter = 'PSX TIM Files (*.tim)|*.tim|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofNoNetworkButton, ofEnableSizing]
    Title = 'Please, select where to save TIM file...'
    Left = 576
    Top = 504
  end
  object dlgColor: TColorDialog
    Options = [cdFullOpen]
    Left = 544
    Top = 504
  end
end
