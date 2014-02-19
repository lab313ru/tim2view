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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlStatus: TPanel
    Left = 0
    Top = 515
    Width = 746
    Height = 30
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 2
    object lblStatus: TLabel
      Left = 76
      Top = 1
      Width = 165
      Height = 28
      Align = alClient
      Alignment = taRightJustify
      Layout = tlCenter
      ExplicitLeft = 238
      ExplicitWidth = 3
      ExplicitHeight = 13
    end
    object pbProgress: TProgressBar
      Left = 241
      Top = 1
      Width = 504
      Height = 28
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
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
    end
  end
  object cbbFiles: TComboBox
    Left = 0
    Top = 0
    Width = 746
    Height = 21
    Align = alTop
    AutoDropDown = True
    AutoCloseUp = True
    Style = csDropDownList
    DropDownCount = 30
    Enabled = False
    TabOrder = 0
    OnChange = cbbFilesChange
  end
  object pnlMain: TPanel
    Left = 0
    Top = 21
    Width = 746
    Height = 494
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object splMain: TSplitter
      Left = 233
      Top = 0
      Height = 494
      ResizeStyle = rsUpdate
      ExplicitLeft = 201
      ExplicitHeight = 481
    end
    object pnlList: TPanel
      Left = 0
      Top = 0
      Width = 233
      Height = 494
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lvList: TListView
        Left = 0
        Top = 0
        Width = 233
        Height = 494
        Align = alClient
        Columns = <
          item
            Caption = '# / 0'
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
        ColumnClick = False
        DoubleBuffered = True
        Enabled = False
        GridLines = True
        HideSelection = False
        OwnerData = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        PopupMenu = pmList
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = lvListClick
        OnData = lvListData
        OnSelectItem = lvListSelectItem
        ExplicitLeft = -2
        ExplicitTop = -5
      end
    end
    object pnlImage: TPanel
      Left = 236
      Top = 0
      Width = 510
      Height = 494
      Align = alClient
      BevelOuter = bvLowered
      TabOrder = 1
      object splImageClut: TSplitter
        Left = 1
        Top = 1
        Width = 508
        Height = 3
        Cursor = crVSplit
        Align = alTop
        Beveled = True
        ResizeStyle = rsUpdate
        ExplicitTop = 274
        ExplicitWidth = 500
      end
      object pbTim: TImage
        AlignWithMargins = True
        Left = 4
        Top = 7
        Width = 502
        Height = 303
        Align = alClient
        Center = True
        IncrementalDisplay = True
        Proportional = True
        Transparent = True
        ExplicitLeft = 168
        ExplicitTop = 80
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
      object grdCurrClut: TDrawGrid
        Left = 1
        Top = 343
        Width = 508
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
        OnDblClick = grdCurrClutDblClick
        OnDrawCell = grdCurrClutDrawCell
      end
      object pnlImageOptions: TPanel
        Left = 1
        Top = 313
        Width = 508
        Height = 30
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 1
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
          Enabled = False
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
          Enabled = False
          ItemIndex = 0
          TabOrder = 1
          Text = 'Full transparence'
          OnChange = cbbTransparenceModeChange
          Items.Strings = (
            'Full transparence'
            'Black Transparence'
            'Semi Transparence'
            'No Transparence')
        end
        object cbbBitMode: TComboBox
          AlignWithMargins = True
          Left = 313
          Top = 4
          Width = 88
          Height = 21
          Align = alLeft
          Style = csDropDownList
          Enabled = False
          ItemIndex = 0
          TabOrder = 2
          Text = 'Real'
          OnChange = cbbBitModeChange
          Items.Strings = (
            'Real'
            '4 BPP'
            '8 BPP'
            '16 BPP'
            '24 BPP')
        end
        object chkStretch: TCheckBox
          AlignWithMargins = True
          Left = 407
          Top = 4
          Width = 97
          Height = 22
          Action = actStretch
          Align = alClient
          Enabled = False
          TabOrder = 3
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
        Action = actScanFile
      end
      object mnScanDir: TMenuItem
        Action = actScanDir
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnCloseFile: TMenuItem
        Action = actCloseFile
      end
      object mnCloseAllFiles: TMenuItem
        Action = actCloseFiles
      end
      object mnExit: TMenuItem
        Action = actExit
      end
    end
    object mnTIM: TMenuItem
      Caption = '&TIM'
      object mnSaveTIM: TMenuItem
        Action = actExtractTim
      end
      object mnReplaceIn: TMenuItem
        Action = actReplaceTim
      end
      object mnSaveToPNG: TMenuItem
        Action = actTim2Png
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object IMInfo1: TMenuItem
        Action = actTimInfo
      end
    end
    object mnConfig: TMenuItem
      Caption = '&Options'
      object mnAssociate: TMenuItem
        Action = actAssocTims
      end
    end
    object mnHelp: TMenuItem
      Caption = '&Help'
      object mnSVN: TMenuItem
        Action = actOpenRepo
      end
      object mnSite: TMenuItem
        Action = actOpenLab
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnAbout: TMenuItem
        Action = actAbout
      end
    end
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
    Top = 502
  end
  object actList: TActionList
    Left = 512
    Top = 502
    object actScanFile: TAction
      Caption = 'Scan &File...'
      ShortCut = 116
      OnExecute = actScanFileExecute
    end
    object actScanDir: TAction
      Caption = 'Scan &Directory...'
      ShortCut = 117
      OnExecute = actScanDirExecute
    end
    object actCloseFile: TAction
      Caption = 'Close &this File'
      ShortCut = 119
      OnExecute = actCloseFileExecute
    end
    object actCloseFiles: TAction
      Caption = 'Close &all Files'
      ShortCut = 120
      OnExecute = actCloseFilesExecute
    end
    object actExit: TAction
      Caption = '&Exit...'
      ShortCut = 121
      OnExecute = actExitExecute
    end
    object actExtractTim: TAction
      Caption = '&Extract TIM...'
      ShortCut = 113
      OnExecute = actExtractTimExecute
    end
    object actReplaceTim: TAction
      Caption = '&Replace TIM...'
      ShortCut = 114
      OnExecute = actReplaceTimExecute
    end
    object actTim2Png: TAction
      Caption = 'Save as &PNG...'
      ShortCut = 115
      OnExecute = actTim2PngExecute
    end
    object actOpenRepo: TAction
      Caption = 'Tim2Vew &SVN Repo'
      OnExecute = actOpenRepoExecute
    end
    object actOpenLab: TAction
      Caption = '[&Lab313] Forum'
      OnExecute = actOpenLabExecute
    end
    object actAbout: TAction
      Caption = 'About...'
      OnExecute = actAboutExecute
    end
    object actStretch: TAction
      AutoCheck = True
      Caption = '&Stretch'
      OnExecute = actStretchExecute
    end
    object actTimInfo: TAction
      Caption = 'TIM Info'
      Enabled = False
      OnExecute = actTimInfoExecute
    end
    object actAssocTims: TAction
      Caption = 'Open TIMs with T2V'
      OnExecute = actAssocTimsExecute
    end
    object actExtractList: TAction
      Caption = 'Extract TIMs'
      Enabled = False
      ShortCut = 112
      OnExecute = actExtractListExecute
    end
  end
  object pmList: TPopupMenu
    Left = 640
    Top = 502
    object ExtractTIMs1: TMenuItem
      Action = actExtractList
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object ExtractTIM1: TMenuItem
      Action = actExtractTim
    end
    object ReplaceTIM1: TMenuItem
      Action = actReplaceTim
    end
    object SaveasPNG1: TMenuItem
      Action = actTim2Png
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnTIMInfo: TMenuItem
      Action = actTimInfo
    end
  end
end
