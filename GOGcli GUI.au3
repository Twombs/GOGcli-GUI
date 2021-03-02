;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;;  AutoIt Version: 3.3.14.2                                                             ;;
;;                                                                                       ;;
;;  Template AutoIt script.                                                              ;;
;;                                                                                       ;;
;;  AUTHOR:  Timboli                                                                     ;;
;;                                                                                       ;;
;;  SCRIPT FUNCTION:  A GOG Games Library GUI frontend for gogcli                        ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; FUNCTIONS
; MainGUI(), SetupGUI()
; ClearFieldValues(), FillTheGamesList(), FixTitle($text), ParseTheGamelist(), SetStateOfControls($state, $which)
; SetTheColumnWidths(), ShowCorrectImage()

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <GuiListView.au3>
#include <Misc.au3>
#include <File.au3>
#include <Inet.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>

_Singleton("gog-cli-gui-timboli")

Global $Button_dest, $Button_down, $Button_exit, $Button_fold, $Button_game, $Button_get, $Button_info, $Button_log, $Button_man
Global $Button_pic, $Button_setup, $Button_web, $Checkbox_alpha, $Checkbox_show, $Combo_dest, $Group_cover, $Group_dest, $Group_games
Global $Input_cat, $Input_dest, $Input_dlc, $Input_OS, $Input_slug, $Input_title, $Input_ups, $Label_bed, $Label_cat, $Label_dlc
Global $Label_mid, $Label_OS, $Label_slug, $Label_top, $Label_ups, $Listview_games, $Pic_cover

Global $a, $alf, $alpha, $ans, $array, $bigcover, $bigpic, $blackjpg, $category, $cookies, $covers, $covimg, $dest, $details, $DLC
Global $entries, $entry, $flag, $fold, $game, $gamefold, $gamelist, $gamepic, $games, $gamesfold, $gamesini, $gogcli, $GOGcliGUI
Global $height, $icoD, $icoF, $icoI, $icoS, $icoT, $icoW, $icoX, $ID, $image, $imgfle, $inifle, $json, $keep, $left, $line, $lines
Global $link, $logfle, $manifest, $minimize, $n, $name, $num, $OSes, $p, $params, $part, $parts, $pid, $ping, $pth, $read, $res
Global $row, $s, $SetupGUI, $shell, $slug, $splash, $split, $splits, $state, $style, $text, $title, $titlist, $top, $type, $types
Global $updates, $URL, $user, $version, $which, $width, $winpos

$bigpic = @ScriptDir & "\Big.jpg"
$blackjpg = @ScriptDir & "\Black.jpg"
$cookies = @ScriptDir & "\Cookie.txt"
$covers = @ScriptDir & "\Covers"
$details = @ScriptDir & "\Detail.txt"
$gamelist = @ScriptDir & "\Games.txt"
$gamesini = @ScriptDir & "\Games.ini"
$gogcli = @ScriptDir & "\gogcli.exe"
$imgfle = @ScriptDir & "\Image.jpg"
$inifle = @ScriptDir & "\Settings.ini"
$json = @ScriptDir & "\manifest.json"
$logfle = @ScriptDir & "\Log.txt"
$manifest = @ScriptDir & "\Manifest.txt"
$splash = @ScriptDir & "\Splash.jpg"
$titlist = @ScriptDir & "\Titles.txt"
$version = "v1.0"

If Not FileExists($covers) Then DirCreate($covers)

MainGUI()

Exit

Func MainGUI()
	Local $display, $dll, $mpos, $xpos, $ypos
	;
	If FileExists($splash) Then SplashImageOn("", $splash, 350, 300, Default, Default, 1)
	;
	If Not FileExists($blackjpg) Then
		Local $hBitmap, $hGraphic, $hImage
		_GDIPlus_Startup()
		$hBitmap = _ScreenCapture_Capture("", 0, 0, 100, 100, False)
		$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
		$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage)
		_GDIPlus_GraphicsClear($hGraphic, 0xFF000000)
		_GDIPlus_ImageSaveToFile($hImage, $blackjpg)
		_GDIPlus_GraphicsDispose($hGraphic)
		_GDIPlus_ImageDispose($hImage)
		_WinAPI_DeleteObject($hBitmap)
		_GDIPlus_ShutDown()
		If Not FileExists($blackjpg) Then
			If FileExists($splash) Then SplashOff()
			MsgBox(262192, "Program Error", "This program requires an image file named" _
				& @LF & "'Black.jpg' for the default cover image file." _
				& @LF & "It needs to be in the main program folder." _
				& @LF & @LF & "This program will now exit.", 0)
			Exit
		EndIf
	EndIf
	;
	$width = 590
	$height = 405
	$left = IniRead($inifle, "Program Window", "left", @DesktopWidth - $width - 25)
	$top = IniRead($inifle, "Program Window", "top", @DesktopHeight - $height - 60)
	$style = $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU + $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX ; + $WS_VISIBLE
	$GOGcliGUI = GuiCreate("GOGcli GUI " & $version, $width, $height, $left, $top, $style, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
	GUISetBkColor($COLOR_SKYBLUE, $GOGcliGUI)
	; CONTROLS
	$Group_games = GuiCtrlCreateGroup("Games", 10, 10, 370, 323)
	$Listview_games = GUICtrlCreateListView("", 20, 30, 350, 240, $LVS_REPORT + $LVS_NOCOLUMNHEADER, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES) ;$GUI_SS_DEFAULT_LISTVIEW + $LVS_SORTASCENDING
	;GUICtrlSetBkColor($Listview_games, $GUI_BKCOLOR_LV_ALTERNATE)
	GUICtrlSetBkColor($Listview_games, 0xBBFFBB)
	GUICtrlSetTip($Listview_games, "List of games!")
	_GUICtrlListView_AddColumn($Listview_games, "", 0)
	_GUICtrlListView_AddColumn($Listview_games, "", 320)
	;SetTheColumnWidths()
	$Input_title = GUICtrlCreateInput("", 20, 276, 350, 20)
	GUICtrlSetBkColor($Input_title, 0xFFFFB0)
	GUICtrlSetTip($Input_title, "Game Title!")
	$Label_slug = GuiCtrlCreateLabel("Slug", 20, 301, 38, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN + $SS_NOTIFY)
	GUICtrlSetBkColor($Label_slug, $COLOR_BLUE)
	GUICtrlSetColor($Label_slug, $COLOR_WHITE)
	$Input_slug = GUICtrlCreateInput("", 58, 301, 312, 20) ;, $ES_READONLY
	GUICtrlSetBkColor($Input_slug, 0xBBFFBB)
	GUICtrlSetTip($Input_slug, "Game Slug!")
	;
	;$Group_dest = GuiCtrlCreateGroup("Download Destination - Games Folder && Naming Types", 10, 341, 390, 52)
	$Group_dest = GuiCtrlCreateGroup("Download Destination - Games Folder && Sub-Folder Options", 10, 341, 390, 52)
	$Combo_dest = GUICtrlCreateCombo("", 20, 361, 48, 21)
	GUICtrlSetBkColor($Combo_dest, 0xFFFFB0)
	GUICtrlSetTip($Combo_dest, "Type of game folder name!")
	$Input_dest = GUICtrlCreateInput("", 70, 361, 218, 21)
	;GUICtrlSetBkColor($Input_dest, 0xFFFFB0)
	GUICtrlSetTip($Input_dest, "Destination path (main parent folder for games)!")
	$Checkbox_alpha = GUICtrlCreateCheckbox("Alpha", 293, 361, 45, 21)
	GUICtrlSetTip($Checkbox_alpha, "Create alphanumeric sub-folder!")
	$Button_dest = GuiCtrlCreateButton("B", 342, 361, 20, 21, $BS_ICON)
	GUICtrlSetTip($Button_dest, "Browse to set the destination folder!")
	$Button_fold = GuiCtrlCreateButton("Open", 367, 361, 23, 22, $BS_ICON)
	GUICtrlSetTip($Button_fold, "Open the selected destination folder!")
	;
	$Group_cover = GuiCtrlCreateGroup("Cover or Status", 390, 10, 190, 160)
	$Pic_cover = GUICtrlCreatePic($blackjpg, 400, 30, 170, 100, $SS_NOTIFY)
	GUICtrlSetTip($Pic_cover, "Game cover image (click to enlarge)!")
	$Label_top = GuiCtrlCreateLabel("", 405, 40, 160, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont($Label_top, 8, 600)
	GUICtrlSetBkColor($Label_top, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_top, $COLOR_WHITE)
	$Label_mid = GuiCtrlCreateLabel("", 405, 70, 160, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor($Label_mid, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_mid, $COLOR_WHITE)
	$Label_bed = GuiCtrlCreateLabel("", 405, 100, 160, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont($Label_bed, 8, 600)
	GUICtrlSetBkColor($Label_bed, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_bed, $COLOR_WHITE)
	$Button_pic = GuiCtrlCreateButton("Download Cover", 400, 135, 120, 25)
	GUICtrlSetFont($Button_pic, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_pic, "Download the selected image!")
	$Checkbox_show = GUICtrlCreateCheckbox("Show", 525, 138, 45, 20)
	GUICtrlSetTip($Checkbox_show, "Show the cover image!")
	;
	;$Button_get = GuiCtrlCreateButton("RETRIEVE LIST" & @LF & "OF GAMES", 390, 180, 105, 40, $BS_MULTILINE)
	$Button_get = GuiCtrlCreateButton("CHECK or GET" & @LF & "GAMES LIST", 390, 180, 100, 35, $BS_MULTILINE)
	GUICtrlSetFont($Button_get, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_get, "Get game titles from GOG library!")
	;
	$Button_down = GuiCtrlCreateButton("DOWNLOAD", 500, 180, 80, 35)
	GUICtrlSetFont($Button_down, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_down, "Download the selected game!")
	;
	$Label_cat = GuiCtrlCreateLabel("Genre", 390, 224, 43, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_cat, $COLOR_BLUE)
	GUICtrlSetColor($Label_cat, $COLOR_WHITE)
	GUICtrlSetFont($Label_cat, 8, 400)
	$Input_cat = GUICtrlCreateInput("", 433, 224, 147, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_cat, 0xBBFFBB)
	GUICtrlSetFont($Input_cat, 8, 400)
	GUICtrlSetTip($Input_cat, "Game categories!")
	;
	$Label_OS = GuiCtrlCreateLabel("OS", 390, 248, 29, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_OS, $COLOR_BLUE)
	GUICtrlSetColor($Label_OS, $COLOR_WHITE)
	GUICtrlSetFont($Label_OS, 8, 400)
	$Input_OS = GUICtrlCreateInput("", 419, 248, 110, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_OS, 0xBBFFBB)
	GUICtrlSetFont($Input_OS, 8, 400)
	GUICtrlSetTip($Input_OS, "Game OSes!")
	;
	$Label_dlc = GuiCtrlCreateLabel("DLC", 534, 248, 31, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_dlc, $COLOR_BLUE)
	GUICtrlSetColor($Label_dlc, $COLOR_WHITE)
	GUICtrlSetFont($Label_dlc, 8, 400)
	$Input_dlc = GUICtrlCreateInput("", 565, 248, 15, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_dlc, 0xBBFFBB)
	GUICtrlSetFont($Input_dlc, 8, 400)
	GUICtrlSetTip($Input_dlc, "Game DLC!")
	;
	$Label_ups = GuiCtrlCreateLabel("Updates", 390, 272, 52, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_ups, $COLOR_BLUE)
	GUICtrlSetColor($Label_ups, $COLOR_WHITE)
	GUICtrlSetFont($Label_ups, 8, 400)
	$Input_ups = GUICtrlCreateInput("", 442, 272, 18, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_ups, 0xBBFFBB)
	GUICtrlSetFont($Input_ups, 8, 400)
	GUICtrlSetTip($Input_ups, "Game updates!")
	;
	$Button_game = GuiCtrlCreateButton("GAME DETAILS", 470, 271, 110, 21)
	GUICtrlSetFont($Button_game, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_game, "View details of selected game!")
	;
	$Button_man = GuiCtrlCreateButton("ADD TO" & @LF & "MANIFEST", 390, 300, 80, 35, $BS_MULTILINE)
	GUICtrlSetFont($Button_man, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_man, "Add selected game to manifest!")
	;
	$Button_setup = GuiCtrlCreateButton("SETUP", 480, 300, 55, 35)
	GUICtrlSetFont($Button_setup, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_setup, "View the Setup window!")
	;
	$Button_web = GuiCtrlCreateButton("WEB", 545, 300, 35, 35, $BS_ICON)
	GUICtrlSetFont($Button_web, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_web, "Visit the online page of selected game!")
	;
	$Button_log = GuiCtrlCreateButton("Log", 410, 345, 50, 50, $BS_ICON)
	GUICtrlSetTip($Button_log, "Log Record!")
	;
	$Button_info = GuiCtrlCreateButton("Info", 470, 345, 50, 50, $BS_ICON)
	GUICtrlSetTip($Button_info, "Program Information!")
	;
	$Button_exit = GuiCtrlCreateButton("EXIT", 530, 345, 50, 50, $BS_ICON)
	GUICtrlSetTip($Button_exit, "Exit / Close / Quit the program!")
	;
	$lowid = $Button_exit
	;$lowid = $Button_exit - 11
	;MsgBox(262208, "$lowid", $lowid & @LF & $Button_exit & @LF & $Button_info & @LF & $Button_log & @LF & $Input_dest)
	;
	; OS SETTINGS
	$user = @SystemDir & "\user32.dll"
	$shell = @SystemDir & "\shell32.dll"
	$icoD = -4
	$icoF = -85
	$icoI = -5
	$icoS = -23
	$icoT = -71
	$icoW = -14
	$icoX = -4
	;GUICtrlSetImage($Button_find, $shell, $icoS, 0)
	GUICtrlSetImage($Button_web, $shell, $icoW, 0)
	GUICtrlSetImage($Button_dest, $shell, $icoF, 0)
	GUICtrlSetImage($Button_fold, $shell, $icoD, 0)
	GUICtrlSetImage($Button_log, $shell, $icoT, 1)
	GUICtrlSetImage($Button_info, $user, $icoI, 1)
	GUICtrlSetImage($Button_exit, $user, $icoX, 1)
	;
	; SETTINGS
	$types = "Slug|Title"
	$type = IniRead($inifle, "Game Folder Names", "type", "")
	If $type = "" Then
		$type = "Slug"
		IniWrite($inifle, "Game Folder Names", "type", $type)
	EndIf
	GUICtrlSetData($Combo_dest, $types, $type)
	$dest = IniRead($inifle, "Main Games Folder", "path", "")
	If $dest = "" Then
		$dest = @ScriptDir & "\GAMES"
		IniWrite($inifle, "Main Games Folder", "path", $dest)
		If Not FileExists($dest) Then DirCreate($dest)
	EndIf
	GUICtrlSetData($Input_dest, $dest)
	$gamesfold = $dest
	$alpha = IniRead($inifle, "Game Folder Names", "alpha", "")
	If $alpha = "" Then
		$alpha = 4
		IniWrite($inifle, "Game Folder Names", "alpha", $alpha)
	EndIf
	GUICtrlSetState($Checkbox_alpha, $alpha)
	;
	If Not FileExists($gogcli) Or Not FileExists($cookies) Then
		If Not FileExists($gogcli) Then GUICtrlSetState($Button_setup, $GUI_DISABLE)
		SetStateOfControls($GUI_DISABLE)
	EndIf
	;
	$minimize = IniRead($inifle, "DOS Console", "minimize", "")
	If $minimize = "" Then
		$minimize = 4
		IniWrite($inifle, "DOS Console", "minimize", $minimize)
	EndIf
	;
	$display = IniRead($inifle, "Cover Image", "show", "")
	If $display = "" Then
		$display = 4
		IniWrite($inifle, "Cover Image", "show", $display)
	EndIf
	GUICtrlSetState($Checkbox_show, $display)
	$keep = IniRead($inifle, "Cover Image", "keep", "")
	If $keep = "" Then
		$keep = 1
		IniWrite($inifle, "Cover Image", "keep", $keep)
	EndIf
	;
	FillTheGamesList()
	$ID = ""
	$title = ""
	$slug = ""
	$image = ""
	$URL = ""
	$category = ""
	$OSes = ""
	$DLC = ""
	$updates = ""
	;
	If FileExists($splash) Then SplashOff()

	GuiSetState(@SW_SHOWNORMAL, $GOGcliGUI)
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_exit
			; Exit / Close / Quit the program
			$winpos = WinGetPos($GOGcliGUI, "")
			$left = $winpos[0]
			If $left < 0 Then
				$left = 2
			ElseIf $left > @DesktopWidth - $width Then
				$left = @DesktopWidth - $width - 25
			EndIf
			IniWrite($inifle, "Program Window", "left", $left)
			$top = $winpos[1]
			If $top < 0 Then
				$top = 2
			ElseIf $top > @DesktopHeight - ($height + 20) Then
				$top = @DesktopHeight - $height - 60
			EndIf
			IniWrite($inifle, "Program Window", "top", $top)
			;
			GUIDelete($GOGcliGUI)
			ExitLoop
		Case $msg = $Button_web
			; Visit the online page of selected game
			If $URL = "" Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				$link = "https://www.gog.com" & $URL
				ShellExecute($link)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_setup
			; Setup window
			GuiSetState(@SW_DISABLE, $GOGcliGUI)
			SetupGUI()
			GuiSetState(@SW_ENABLE, $GOGcliGUI)
			$window = $GOGcliGUI
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_pic
			; Download the selected image
			If $image = "" Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				$ping = Ping("gog.com", 4000)
				If $ping > 0 Then
					$link = "https:" & $image & ".jpg"
					$ans = MsgBox(262179 + 256, "Save Query", _
						"YES = Save cover image to game folder." & @LF & _
						"NO = Save cover image to games folder." & @LF & _
						"CANCEL = Save to program folder.", 0, $GOGcliGUI)
					;SplashTextOn("", "Saving!", 200, 120, Default, Default, 33)
					GUICtrlSetData($Label_mid, "Saving!")
					If $ans = 6 Then
						$gamepic = ""
						$gamefold = $gamesfold
						If $type = "Slug" Then
							$name = $slug
						ElseIf $type = "Title" Then
							$name = FixTitle($title)
						EndIf
						If $alpha = 1 Then
							$alf = StringUpper(StringLeft($name, 1))
							$gamefold = $gamefold & "\" & $alf
						EndIf
						$gamefold = $gamefold & "\" & $name
						If FileExists($gamefold) Then
							$gamepic = $gamefold & "\Folder.jpg"
						Else
							MsgBox(262192, "Save Error", "Game folder not found!", 0, $GOGcliGUI)
						EndIf
					Else
						$gamepic = FixTitle($title)
						$gamepic = $gamepic & ".jpg"
						If $ans = 2 Then
							$gamepic = @ScriptDir & "\" & $gamepic
						ElseIf $ans = 7 Then
							If FileExists($gamesfold) Then
								$gamepic = $gamesfold & "\" & $gamepic
							Else
								$gamepic = ""
								MsgBox(262192, "Save Error", "Games folder not found!", 0, $GOGcliGUI)
							EndIf
						EndIf
					EndIf
					If $gamepic <> "" Then
						InetGet($link, $gamepic, 1, 0)
						If Not FileExists($gamepic) Then
							InetGet($link, $gamepic, 0, 0)
							If Not FileExists($gamepic) Then
								InetGet($link, $gamepic, 0, 1)
							EndIf
						EndIf
					EndIf
					GUICtrlSetData($Label_mid, "")
					;SplashOff()
				Else
					MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_man
			; Add selected game to manifest
			If _IsPressed("10") Then
				; SHIFT
				If FileExists($json) Then Run(@ProgramFilesDir & "\Windows NT\Accessories\wordpad.exe " & $json)
			ElseIf _IsPressed("11") Then
				; CTRL
				If FileExists($manifest) Then Run(@ProgramFilesDir & "\Windows NT\Accessories\wordpad.exe " & $manifest)
			Else
				If $title = "" Then
					MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
				Else
					If FileExists($cookies) Then
						$res = _FileReadToArray($cookies, $array)
						If $res = 1 Then
							For $a = 1 To $array[0]
								$line = $array[$a]
								If $line <> "" Then
									If StringLeft($line, 7) = "gog-al=" Then
										SetStateOfControls($GUI_DISABLE, "all")
										$ping = Ping("gog.com", 4000)
										If $ping > 0 Then
											GUICtrlSetImage($Pic_cover, $blackjpg)
											GUICtrlSetData($Label_mid, "Adding Game to Manifest")
											If $minimize = 1 Then
												$flag = @SW_MINIMIZE
											Else
												$flag = @SW_SHOW
											EndIf
											FileChangeDir(@ScriptDir)
											$params = "-c Cookie.txt manifest generate -l english -o windows linux mac -i " & $title
											$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
											Sleep(1000)
											If FileExists($json) Then
												$game = FileRead($json)
												If $game <> "" Then
													If FileExists($manifest) Then
														$read = FileRead($manifest)
														If StringInStr($read, $title) < 1 Then
															FileWrite($manifest, @LF & $game)
														EndIf
													Else
														FileCopy($json, $manifest)
													EndIf
												EndIf
											EndIf
											GUICtrlSetData($Label_mid, "")
										Else
											MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
										EndIf
										SetStateOfControls($GUI_ENABLE, "all")
										GUICtrlSetState($Listview_games, $GUI_FOCUS)
										_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
										ContinueLoop 2
									EndIf
								EndIf
							Next
							MsgBox(262192, "Cookie Error", "The 'Cookie.txt' file doesn't contain a line starting with 'gog-al='.", 0, $GOGcliGUI)
						Else
							MsgBox(262192, "Content Error", "The 'Cookie.txt' file appears to be empty!", 0, $GOGcliGUI)
						EndIf
					Else
						MsgBox(262192, "File Error", "The 'Cookie.txt' file is missing!", 0, $GOGcliGUI)
					EndIf
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_log
			; Log Record
			If FileExists($logfle) Then ShellExecute($logfle)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_info
			; Program Information
			$ans = MsgBox(262209 + 256, "Program Information", _
				"Click OK to see more information.", 0, $GOGcliGUI)
			If $ans = 1 Then
				MsgBox(262208, "Program Information (continued)", _
					"DISCLAIMER - As always, you use my programs at your own" & @LF & _
					"risk. That said, I strive to ensure they work safe. I also cannot" & @LF & _
					"guarantee the results (or my read) of any 3rd party programs." & @LF & _
					"This is Freeware that I have voluntarily given many hours to." & @LF & @LF & _
					"BIG THANKS to Magnitus for 'gogcli.exe'." & @LF & @LF & _
					"Praise & BIG thanks as always, to Jon & team for free AutoIt." & @LF & @LF & _
					"© February 2021 - Created by Timboli (aka TheSaint). (" & $version & ")", 0, $GOGcliGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_get
			; Get game titles from GOG library
			If FileExists($cookies) Then
				$res = _FileReadToArray($cookies, $array)
				If $res = 1 Then
					For $a = 1 To $array[0]
						$line = $array[$a]
						If $line <> "" Then
							If StringLeft($line, 7) = "gog-al=" Then
								SetStateOfControls($GUI_DISABLE, "all")
								$ping = Ping("gog.com", 4000)
								If $ping > 0 Then
									GUICtrlSetImage($Pic_cover, $blackjpg)
									GUICtrlSetData($Label_top, "100 Games per Page")
									GUICtrlSetData($Label_mid, "Obtaining Games List")
									GUICtrlSetData($Label_bed, "Page 1")
									ClearFieldValues()
									If $minimize = 1 Then
										$flag = @SW_MINIMIZE
									Else
										$flag = @SW_SHOW
									EndIf
									FileChangeDir(@ScriptDir)
									$params = "-c Cookie.txt gog-api owned-games -p "
									$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params & '1 >"' & $gamelist & '"', @ScriptDir, $flag)
									If FileExists($gamelist) Then
										$res = _FileReadToArray($gamelist, $lines)
										If $res = 1 Then
											For $l = 1 To $lines[0]
												$line = $lines[$l]
												If $line <> "" Then
													If StringLeft($line, 11) = "TotalPages:" Then
														$line = StringReplace($line, "TotalPages:", "")
														$num = StringStripWS($line, 3)
														If StringIsDigit($num) Then
															If $num > 1 Then
																For $n = 2 To $num
																	Sleep(500)
																	GUICtrlSetData($Label_bed, "Page " & $n)
																	$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params & $n & ' >>"' & $gamelist & '"', @ScriptDir, $flag)
																Next
																GUICtrlSetData($Label_top, "")
																GUICtrlSetData($Label_bed, "")
															EndIf
															Sleep(1000)
															ParseTheGamelist()
															GUICtrlSetState($Button_setup, $GUI_ENABLE)
															SetStateOfControls($GUI_ENABLE)
															ContinueLoop 3
														EndIf
													EndIf
												EndIf
											Next
											MsgBox(262192, "List Error", "The 'Game.txt' file appears to be empty!", 0, $GOGcliGUI)
										EndIf
									EndIf
									GUICtrlSetData($Label_top, "")
									GUICtrlSetData($Label_mid, "")
									GUICtrlSetData($Label_bed, "")
								Else
									MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
								EndIf
								SetStateOfControls($GUI_ENABLE, "all")
								ContinueLoop 2
							EndIf
						EndIf
					Next
					MsgBox(262192, "Cookie Error", "The 'Cookie.txt' file doesn't contain a line starting with 'gog-al='.", 0, $GOGcliGUI)
				Else
					MsgBox(262192, "Content Error", "The 'Cookie.txt' file appears to be empty!", 0, $GOGcliGUI)
				EndIf
			Else
				MsgBox(262192, "File Error", "The 'Cookie.txt' file is missing!", 0, $GOGcliGUI)
			EndIf
		Case $msg = $Button_game
			; View details of selected game
			If $ID = "" Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				If FileExists($cookies) Then
					$res = _FileReadToArray($cookies, $array)
					If $res = 1 Then
						For $a = 1 To $array[0]
							$line = $array[$a]
							If $line <> "" Then
								If StringLeft($line, 7) = "gog-al=" Then
									SetStateOfControls($GUI_DISABLE, "all")
									$ping = Ping("gog.com", 4000)
									If $ping > 0 Then
										GUICtrlSetImage($Pic_cover, $blackjpg)
										GUICtrlSetData($Label_mid, "Retrieving Game Detail")
										If $minimize = 1 Then
											$flag = @SW_MINIMIZE
										Else
											$flag = @SW_SHOW
										EndIf
										FileChangeDir(@ScriptDir)
										$params = "-c Cookie.txt gog-api game-details -i " & $ID
										$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params & ' >"' & $details & '"', @ScriptDir, $flag)
										Sleep(1000)
										If FileExists($details) Then
											_ReplaceStringInFile($details, @LF, @CRLF)
											Sleep(500)
											ShellExecute($details)
										EndIf
										GUICtrlSetData($Label_mid, "")
									Else
										MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
									EndIf
									SetStateOfControls($GUI_ENABLE, "all")
									GUICtrlSetState($Listview_games, $GUI_FOCUS)
									_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
									ContinueLoop 2
								EndIf
							EndIf
						Next
						MsgBox(262192, "Cookie Error", "The 'Cookie.txt' file doesn't contain a line starting with 'gog-al='.", 0, $GOGcliGUI)
					Else
						MsgBox(262192, "Content Error", "The 'Cookie.txt' file appears to be empty!", 0, $GOGcliGUI)
					EndIf
				Else
					MsgBox(262192, "File Error", "The 'Cookie.txt' file is missing!", 0, $GOGcliGUI)
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_fold
			; Open the selected destination folder
			If FileExists($gamesfold) Then
				GUISetState(@SW_MINIMIZE, $GOGcliGUI)
				If $title <> "" Then
					$gamefold = $gamesfold
					If $type = "Slug" Then
						$name = $slug
					ElseIf $type = "Title" Then
						$name = FixTitle($title)
					EndIf
					If $alpha = 1 Then
						$alf = StringUpper(StringLeft($name, 1))
						$gamefold = $gamefold & "\" & $alf
					EndIf
					$gamefold = $gamefold & "\" & $name
					If FileExists($gamefold) Then
						Run(@WindowsDir & "\Explorer.exe " & $gamefold)
					Else
						Run(@WindowsDir & "\Explorer.exe " & $gamesfold)
					EndIf
				Else
					Run(@WindowsDir & "\Explorer.exe " & $gamesfold)
				EndIf
			Else
				MsgBox(262192, "Path Error", "Game folder does not exist!", 0, $GOGcliGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_down
			; Download the selected game
			MsgBox(262192, "Download Error", "This feature is not yet supported!", 0, $GOGcliGUI)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_dest
			; Browse to set the destination folder
			If $dest = "" Then
				$fold = @ScriptDir
			Else
				$fold = $dest
			EndIf
			$pth = FileSelectFolder("Browse to set the main games folder.", $fold, 7, $dest, $GOGcliGUI)
			If Not @error And StringMid($pth, 2, 2) = ":\" Then
				$dest = $pth
				IniWrite($inifle, "Main Games Folder", "path", $dest)
				GUICtrlSetData($Input_dest, $dest)
				$gamesfold = $dest
			EndIf
		Case $msg = $Checkbox_show
			; Show the cover image
			If GUICtrlRead($Checkbox_show) = $GUI_CHECKED Then
				$display = 1
				ShowCorrectImage()
			Else
				$display = 4
				GUICtrlSetImage($Pic_cover, $blackjpg)
			EndIf
			IniWrite($inifle, "Cover Image", "show", $display)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Combo_dest
			; Type of game folder name
			$type = GUICtrlRead($Combo_dest)
			IniWrite($inifle, "Game Folder Names", "type", $type)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Listview_games Or $msg > $lowid
			; List of games
			$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
			;MsgBox(262208, "Index", "'" & $ind & "'")
			$ind = Number($ind)
			$ID = _GUICtrlListView_GetItemText($Listview_games, $ind, 0)
			$title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1)
			;MsgBox(262208, "Title", $title)
			GUICtrlSetData($Input_title, $title)
			$slug = IniRead($gamesini, $ID, "slug", "")
			GUICtrlSetData($Input_slug, $slug)
			$image = IniRead($gamesini, $ID, "image", "")
			If $display = 1 Then
				ShowCorrectImage()
			EndIf
			$URL = IniRead($gamesini, $ID, "URL", "")
			$category = IniRead($gamesini, $ID, "category", "")
			GUICtrlSetData($Input_cat, $category)
			$OSes = IniRead($gamesini, $ID, "OSes", "")
			GUICtrlSetData($Input_OS, $OSes)
			$DLC = IniRead($gamesini, $ID, "DLC", "")
			GUICtrlSetData($Input_dlc, $DLC)
			$updates = IniRead($gamesini, $ID, "updates", "")
			GUICtrlSetData($Input_ups, $updates)
		Case $msg = $Pic_cover
			; Cover Image - Click For Large Preview
			If $imgfle <> "" Then
				If $image <> "" Then
					;SplashTextOn("", "Please Wait!", 200, 120, Default, Default, 33)
					GUICtrlSetData($Label_mid, "Please Wait!")
					If FileExists($bigpic) Then FileDelete($bigpic)
					$bigcover = ""
					$ping = Ping("gog.com", 4000)
					If $ping > 0 Then
						$link = "https:" & $image & ".jpg"
						InetGet($link, $bigpic, 1, 0)
						If FileExists($bigpic) Then
							$bigcover = $bigpic
						EndIf
					Else
						MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
						;$covimg = $covers & "\" & $slug & ".jpg"
						;If FileExists($covimg) Then
						;	$bigcover = $covimg
						;EndIf
					EndIf
					If $bigcover <> "" Then
						GUICtrlSetState($Pic_cover, $GUI_DISABLE)
						SplashImageOn("", $bigcover, 900, 450, Default, Default, 17)
						Sleep(300)
						$mpos = MouseGetPos()
						$xpos = $mpos[0]
						$ypos = $mpos[1]
						Sleep(300)
						$dll = DllOpen("user32.dll")
						While 1
							$mpos = MouseGetPos()
							If $mpos[0] > $xpos + 40 Or $mpos[0] < $xpos - 40 Then ExitLoop
							If $mpos[1] > $ypos + 40 Or $mpos[1] < $ypos - 40 Then ExitLoop
							If _IsPressed("01", $dll) Then ExitLoop
							Sleep(300)
						WEnd
						DllClose($dll)
						SplashOff()
						GUICtrlSetState($Pic_cover, $GUI_ENABLE)
					EndIf
					GUICtrlSetData($Label_mid, "")
					;SplashOff()
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> MainGUI

Func SetupGUI()
	Local $Button_close, $Button_cookie, $Checkbox_dos, $Checkbox_keep, $Label_info
	Local $above, $high, $side, $wide
	;
	$wide = 230
	$high = 405
	$side = IniRead($inifle, "Setup Window", "left", $left)
	$above = IniRead($inifle, "Setup Window", "top", $top)
	$SetupGUI = GuiCreate("Setup", $wide, $high, $side, $above, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
											+ $WS_VISIBLE + $WS_CLIPSIBLINGS, $WS_EX_TOPMOST, $GOGcliGUI)
	GUISetBkColor(0xFFFFB0, $SetupGUI)
	;
	; CONTROLS
	$Label_info = GuiCtrlCreateLabel("Before using 'gogcli.exe' to download your" _
		& @LF & "games, update etc, you need a cookie file." _
		& @LF & "The 'Cookie.txt' file must be located inside" _
		& @LF & "the main program folder and contain some" _
		& @LF & "required content to pass an authentication" _
		& @LF & "check when connecting to GOG." & @LF _
		& @LF & "At this current point in time, 'gogcli.exe' is" _
		& @LF & "unable to obtain the necessary data your" _
		& @LF & "cookie file needs, so you need to obtain" _
		& @LF & "it manually, or with the help of a browser" _
		& @LF & "addon (recommended)." & @LF _
		& @LF & "To assist you, this program can create an" _
		& @LF & "empty 'Cookie.txt' file, to which you copy" _
		& @LF & "the required entry(s).", 11, 10, 210, 215)
	;
	$Button_cookie = GuiCtrlCreateButton("CREATE COOKIE", 10, 235, 140, 50)
	GUICtrlSetFont($Button_cookie, 9, 600)
	GUICtrlSetTip($Button_cookie, "Create the basic cookie file!")
	;
	$Button_close = GuiCtrlCreateButton("EXIT", 160, 235, 60, 50, $BS_ICON)
	GUICtrlSetTip($Button_close, "Exit / Close / Quit the window!")
	;
	$Checkbox_keep = GUICtrlCreateCheckbox("Save cover images locally when shown", 14, 295, 210, 20)
	GUICtrlSetTip($Checkbox_keep, "Save cover images locally when obtained!")
	;
	$Checkbox_dos = GUICtrlCreateCheckbox("Minimize DOS Console window process", 14, 315, 210, 20)
	GUICtrlSetTip($Checkbox_dos, "Minimize a DOS Console window process when it starts!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_close, $user, $icoX, 1)
	;
	GUICtrlSetState($Checkbox_keep, $keep)
	GUICtrlSetState($Checkbox_dos, $minimize)
	;
	$window = $SetupGUI


	GuiSetState(@SW_SHOW, $SetupGUI)
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_close
			; Exit / Close / Quit the window
			$winpos = WinGetPos($SetupGUI, "")
			$side = $winpos[0]
			If $side < 0 Then
				$side = 2
			ElseIf $side > @DesktopWidth - $wide Then
				$side = @DesktopWidth - $wide - 25
			EndIf
			IniWrite($inifle, "Setup Window", "left", $side)
			$above = $winpos[1]
			If $above < 0 Then
				$above = 2
			ElseIf $above > @DesktopHeight - ($high + 20) Then
				$above = @DesktopHeight - $high - 60
			EndIf
			IniWrite($inifle, "Setup Window", "top", $above)
			;
			GUIDelete($SetupGUI)
			ExitLoop
		Case $msg = $Button_cookie
			; Create the cookie file
			If FileExists($cookies) Then
				$ans = MsgBox(262177 + 256, "Replace Query", _
					"The 'Cookie.txt' file already exists." & @LF & @LF & _
					"OK = Replace with a new empty one." & @LF & _
					"CANCEL = Abort any replace.", 0, $SetupGUI)
			Else
				$ans = 1
			EndIf
			If $ans = 1 Then
				If Not FileExists($cookies) And FileExists($gogcli) Then
					GUISwitch($GOGcliGUI)
					GUICtrlSetState($Button_pic, $GUI_ENABLE)
					GUICtrlSetState($Checkbox_show, $GUI_ENABLE)
					GUICtrlSetState($Button_get, $GUI_ENABLE)
					GUICtrlSetState($Button_down, $GUI_ENABLE)
					GUICtrlSetState($Button_game, $GUI_ENABLE)
					GUICtrlSetState($Button_man, $GUI_ENABLE)
					;GUICtrlSetState($Button_setup, $GUI_ENABLE)
					GUICtrlSetState($Button_web, $GUI_ENABLE)
					GUICtrlSetState($Combo_dest, $GUI_ENABLE)
					GUICtrlSetState($Checkbox_alpha, $GUI_ENABLE)
					GUICtrlSetState($Button_dest, $GUI_ENABLE)
					GUICtrlSetState($Button_fold, $GUI_ENABLE)
					GUISwitch($SetupGUI)
				EndIf
				_FileCreate($cookies)
			EndIf
		Case $msg = $Checkbox_keep
			; Save cover images locally when obtained & shown
			If GUICtrlRead($Checkbox_keep) = $GUI_CHECKED Then
				$keep = 1
			Else
				$keep = 4
			EndIf
			IniWrite($inifle, "Cover Image", "keep", $keep)
		Case $msg = $Checkbox_dos
			; Minimize DOS Console window process
			If GUICtrlRead($Checkbox_dos) = $GUI_CHECKED Then
				$minimize = 1
			Else
				$minimize = 4
			EndIf
			IniWrite($inifle, "DOS Console", "minimize", $minimize)
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> SetupGUI


Func ClearFieldValues()
	$ID = ""
	$title = ""
	GUICtrlSetData($Input_title, $title)
	$slug = ""
	GUICtrlSetData($Input_slug, $slug)
	$image = ""
	$URL = ""
	$category = ""
	GUICtrlSetData($Input_cat, $category)
	$OSes = ""
	GUICtrlSetData($Input_OS, $OSes)
	$DLC = ""
	GUICtrlSetData($Input_dlc, $DLC)
	$updates = ""
	GUICtrlSetData($Input_ups, $updates)
EndFunc ;=> ClearFieldValues

Func FillTheGamesList()
	If FileExists($titlist) Then
		$res = _FileReadToArray($titlist, $array)
		If $res = 1 Then
			GUICtrlSetData($Label_mid, "Loading the List")
			;_ArrayDisplay($array)
			_ArraySort($array, 0, 1)
			;_ArrayDisplay($array)
			$games = 0
			For $a = 1 To $array[0]
				$line = $array[$a]
				If $line <> "" Then
					$ID = StringSplit($line, "|")
					$title = $ID[1]
					$updates = $ID[3]
					$ID = $ID[2]
					GUICtrlCreateListViewItem($ID & "|" & $title, $Listview_games)
					If $updates > 0 Then
						GUICtrlSetBkColor(-1, $COLOR_RED)
					Else
						;GUICtrlSetBkColor($Listview_games, 0xBBFFBB)
						$row = $games / 2
						If StringIsDigit($row) Then
							GUICtrlSetBkColor(-1, 0xF0D0F0)
						EndIf
					EndIf
					$games = $games + 1
				EndIf
			Next
			If $games > 0 Then GUICtrlSetData($Group_games, "Games  (" & $games & ")")
			;_GUICtrlListView_SimpleSort($Listview_games, False, 1, True)
			;_GUICtrlListView_SetItemSelected($Listview_games, -1, False, False)
			GUICtrlSetData($Label_mid, "")
		EndIf
	Else
		ParseTheGamelist()
	EndIf
EndFunc ;=> FillTheGamesList

Func FixTitle($text)
	$text = StringReplace($text, ": ", " - ")
	$text = StringReplace($text, "?", "")
	$text = StringReplace($text, "*", "")
	$text = StringReplace($text, "|", "")
	$text = StringReplace($text, "/", "")
	$text = StringReplace($text, "\", "")
	$text = StringReplace($text, "<", "")
	$text = StringReplace($text, ">", "")
	$text = StringReplace($text, '"', '')
	Return $text
EndFunc ;=> FixTitle

Func ParseTheGamelist()
	If FileExists($gamelist) Then
		; Parse for titles
		;SplashTextOn("", "Please Wait!", 140, 120, Default, Default, 33)
		GUICtrlSetData($Label_mid, "Parsing Games List")
		_GUICtrlListView_BeginUpdate($Listview_games)
		_GUICtrlListView_DeleteAllItems($Listview_games)
		_GUICtrlListView_EndUpdate($Listview_games)
		$entries = ""
		$lines = ""
		$read = FileRead($gamelist)
		$split = StringSplit($read, "- Title:", 1)
		$splits = $split[0]
		If $splits > 1 Then
			$games = $splits - 1
			$entries = "[Games]" & @CRLF & "total=" & $games
			For $s = 2 To $splits
				$entry = $split[$s]
				$entry = StringStripWS($entry, 3)
				$parts = StringSplit($entry, @LF, 1)
				$title = $parts[1]
				$title = StringStripWS($title, 3)
				$category = ""
				$DLC = ""
				$ID = ""
				$image = ""
				$OSes = ""
				$slug = ""
				$URL = ""
				For $p = 2 To $parts[0]
					$part = $parts[$p]
					$part = StringStripWS($part, 3)
					If StringLeft($part, 5) = "Slug:" Then
						$slug = StringTrimLeft($part, 5)
						$slug = StringStripWS($slug, 3)
					ElseIf StringLeft($part, 3) = "Id:" Then
						$ID = StringTrimLeft($part, 3)
						$ID = StringStripWS($ID, 3)
					ElseIf StringLeft($part, 6) = "Image:" Then
						$image = StringTrimLeft($part, 6)
						$image = StringStripWS($image, 3)
					ElseIf StringLeft($part, 4) = "Url:" Then
						$URL = StringTrimLeft($part, 4)
						$URL = StringStripWS($URL, 3)
					ElseIf StringLeft($part, 9) = "Category:" Then
						$category = StringTrimLeft($part, 9)
						$category = StringStripWS($category, 3)
					ElseIf StringLeft($part, 8) = "worksOn:" Then
						$OSes = StringTrimLeft($part, 8)
						$OSes = StringReplace($OSes, "[", "")
						$OSes = StringReplace($OSes, ", ]", "")
						$OSes = StringStripWS($OSes, 3)
					ElseIf StringLeft($part, 8) = "Updates:" Then
						$updates = StringTrimLeft($part, 8)
						$updates = StringStripWS($updates, 3)
					ElseIf StringLeft($part, 9) = "DlcCount:" Then
						$DLC = StringTrimLeft($part, 9)
						$DLC = StringStripWS($DLC, 3)
					EndIf
				Next
				$line = $title & "|" & $ID & "|" & $updates
				If $lines = "" Then
					$lines = $line
				Else
					$lines = $lines & @LF & $line
				EndIf
				$entries = $entries & @CRLF & "[" & $ID & "]" & @CRLF & "title=" & $title & @CRLF & "slug=" & $slug & @CRLF & "image=" & $image
				$entries = $entries & @CRLF & "URL=" & $URL & @CRLF & "category=" & $category & @CRLF & "OSes=" & $OSes & @CRLF & "DLC=" & $DLC
				$entries = $entries & @CRLF & "updates=" & $updates
			Next
			_FileCreate($titlist)
			If $lines <> "" Then
				FileWrite($titlist, $lines)
			EndIf
			_FileCreate($gamesini)
			If $entries <> "" Then
				FileWrite($gamesini, $entries)
			EndIf
			FillTheGamesList()
		Else
			MsgBox(48 + 262144, "Content Error", "No games found in 'Games.txt'.")
		EndIf
		GUICtrlSetData($Label_mid, "")
		;SplashOff()
	Else
		MsgBox(48 + 262144, "Path Error", "The 'Games.txt' file wasn't found.")
	EndIf
EndFunc ;=> ParseTheGamelist

Func SetStateOfControls($state, $which = "")
	GUICtrlSetState($Button_pic, $state)
	GUICtrlSetState($Checkbox_show, $state)
	GUICtrlSetState($Button_get, $state)
	GUICtrlSetState($Button_down, $state)
	GUICtrlSetState($Button_game, $state)
	GUICtrlSetState($Button_man, $state)
	GUICtrlSetState($Button_web, $state)
	GUICtrlSetState($Combo_dest, $state)
	GUICtrlSetState($Checkbox_alpha, $state)
	GUICtrlSetState($Button_dest, $state)
	GUICtrlSetState($Button_fold, $state)
	If $which = "all" Then
		GUICtrlSetState($Listview_games, $state)
		GUICtrlSetState($Button_setup, $state)
		GUICtrlSetState($Button_log, $state)
		GUICtrlSetState($Button_info, $state)
		GUICtrlSetState($Button_exit, $state)
	EndIf
EndFunc ;=> SetStateOfControls

Func SetTheColumnWidths()
	;_GUICtrlListView_HideColumn($Listview_games, 0)
	;_GUICtrlListView_SetColumnWidth($Listview_games, 0, 330)	; Title
	;_GUICtrlListView_SetColumnWidth($Listview_games, 1, 0)	; ID
	;_GUICtrlListView_SetColumnWidth($Listview_games, 1, $LVSCW_AUTOSIZE_USEHEADER)	; ID
	;_GUICtrlListView_SetColumn($Listview_games, 0, "Title", 350, 0)
	;_GUICtrlListView_SetColumn($Listview_games, 1, "ID", 0, 2)
	;_GUIScrollBars_EnableScrollBar($GOGcliGUI, $SB_HORZ, $ESB_DISABLE_BOTH)
	;_GUICtrlListView_Scroll($Listview_games, 0, 0)
EndFunc ;=> SetTheColumnWidths

Func ShowCorrectImage()
	If $image <> "" Then
		$covimg = $covers & "\" & $slug & ".jpg"
		If FileExists($covimg) Then
			GUICtrlSetImage($Pic_cover, $covimg)
		Else
			GUICtrlSetData($Label_mid, "Please Wait")
			$link = "https:" & $image & "_196.jpg"
			If FileExists($imgfle) Then FileDelete($imgfle)
			InetGet($link, $imgfle, 1, 0)
			If FileExists($imgfle) Then
				If $keep = 1 Then
					FileMove($imgfle, $covimg)
					GUICtrlSetImage($Pic_cover, $covimg)
				Else
					GUICtrlSetImage($Pic_cover, $imgfle)
				EndIf
			Else
				GUICtrlSetImage($Pic_cover, $blackjpg)
			EndIf
			GUICtrlSetData($Label_mid, "")
		EndIf
	Else
		GUICtrlSetImage($Pic_cover, $blackjpg)
	EndIf
EndFunc ;=> ShowCorrectImage
