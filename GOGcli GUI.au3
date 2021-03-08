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
; MainGUI(), SetupGUI(), FileSelectorGUI()
; ClearFieldValues(), FillTheGamesList(), FixTitle($text), GetFileDownloadDetails($listview), GetTheSize(), ParseTheGamelist()
; SetStateOfControls($state, $which), SetTheColumnWidths(), ShowCorrectImage()

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <ListViewConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <GuiListView.au3>
#include <Misc.au3>
#include <File.au3>
#include <Date.au3>
#include <Inet.au3>
#include <Crypt.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>

_Singleton("gog-cli-gui-timboli")

Global $Button_dest, $Button_down, $Button_exit, $Button_find, $Button_fold, $Button_game, $Button_get, $Button_info, $Button_last
Global $Button_log, $Button_man, $Button_pic, $Button_setup, $Button_web, $Checkbox_alpha, $Checkbox_show, $Combo_dest, $Group_cover
Global $Group_dest, $Group_games, $Input_cat, $Input_dest, $Input_dlc, $Input_OS, $Input_slug, $Input_title, $Input_ups, $Item_verify
Global $Label_bed, $Label_cat, $Label_dlc, $Label_mid, $Label_OS, $Label_slug, $Label_top, $Label_ups, $Listview_games, $Pic_cover

Global $7zip, $a, $addlist, $alf, $alpha, $ans, $array, $bigcover, $bigpic, $blackjpg, $bytes, $caption, $category, $checksum, $checkval
Global $cookie, $cookies, $cover, $covers, $covimg, $dest, $details, $DLC, $done, $downfiles, $downlist, $download, $drv, $entries, $entry
Global $exists, $f, $file, $filepth, $files, $filesize, $flag, $fold, $foldzip, $free, $game, $gamefold, $gamelist, $gamepic, $games
Global $gamesfold, $gamesini, $getlatest, $gogcli, $GOGcliGUI, $handle, $hash, $head, $height, $i, $icoD, $icoF, $icoI, $icoS, $icoT
Global $icoW, $icoX, $ID, $identry, $image, $imgfle, $inifle, $json, $keep, $lang, $left, $line, $lines, $link, $listed, $listview, $logfle
Global $m, $manifest, $md5check, $minimize, $n, $name, $num, $OP, $OS, $OSes, $params, $part, $parts, $percent, $pid, $ping, $progress, $pth
Global $read, $res, $resultfle, $row, $s, $second, $selector, $SetupGUI, $shell, $size, $slug, $space, $splash, $split, $splits, $state
Global $style, $tail, $text, $title, $titlist, $top, $type, $types, $updated, $updates, $URL, $user, $validate, $verify, $version, $web
Global $which, $width, $winpos

$addlist = @ScriptDir & "\Added.txt"
$bigpic = @ScriptDir & "\Big.jpg"
$blackjpg = @ScriptDir & "\Black.jpg"
$cookies = @ScriptDir & "\Cookie.txt"
$covers = @ScriptDir & "\Covers"
$details = @ScriptDir & "\Detail.txt"
$downfiles = @ScriptDir & "\Downfiles.ini"
$downlist = @ScriptDir & "\Downloads.txt"
$foldzip = @ScriptDir & "\7-Zip"
$gamelist = @ScriptDir & "\Games.txt"
$gamesini = @ScriptDir & "\Games.ini"
$gogcli = @ScriptDir & "\gogcli.exe"
$imgfle = @ScriptDir & "\Image.jpg"
$inifle = @ScriptDir & "\Settings.ini"
$json = @ScriptDir & "\manifest.json"
$logfle = @ScriptDir & "\Log.txt"
$manifest = @ScriptDir & "\Manifest.txt"
$resultfle = @ScriptDir & "\Results.txt"
$splash = @ScriptDir & "\Splash.jpg"
$titlist = @ScriptDir & "\Titles.txt"
$updated = @ScriptDir & "\Updated.txt"
$version = "v1.0"

If Not FileExists($addlist) Then _FileCreate($addlist)
If Not FileExists($covers) Then DirCreate($covers)
If Not FileExists($downlist) Then _FileCreate($downlist)
;~ If Not FileExists($foldzip) Then DirCreate($foldzip)
If Not FileExists($updated) Then _FileCreate($updated)

MainGUI()

Exit

Func MainGUI()
	Local $Menu_button, $Menu_list, $Item_clear, $Item_view
	Local $buttxt, $cnt, $display, $dll, $find, $ind, $last, $latest, $mpos, $xpos, $ypos
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
	$Listview_games = GUICtrlCreateListView("", 20, 30, 350, 240, $LVS_REPORT + $LVS_SINGLESEL + $LVS_SHOWSELALWAYS + $LVS_NOCOLUMNHEADER, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES)
	;GUICtrlSetBkColor($Listview_games, $GUI_BKCOLOR_LV_ALTERNATE)
	GUICtrlSetBkColor($Listview_games, 0xBBFFBB)
	GUICtrlSetTip($Listview_games, "List of games!")
	_GUICtrlListView_AddColumn($Listview_games, "", 0)
	_GUICtrlListView_AddColumn($Listview_games, "", 320)
	;SetTheColumnWidths()
	$Input_title = GUICtrlCreateInput("", 20, 276, 325, 20)
	GUICtrlSetBkColor($Input_title, 0xFFFFB0)
	GUICtrlSetTip($Input_title, "Game Title!")
	$Button_find = GuiCtrlCreateButton("?", 348, 275, 22, 22, $BS_ICON)
	GUICtrlSetTip($Button_find, "Find the specified game title text in the list!")
	$Label_slug = GuiCtrlCreateLabel("Slug", 20, 301, 38, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN + $SS_NOTIFY)
	GUICtrlSetBkColor($Label_slug, $COLOR_BLUE)
	GUICtrlSetColor($Label_slug, $COLOR_WHITE)
	$Input_slug = GUICtrlCreateInput("", 58, 301, 270, 20) ;, $ES_READONLY
	GUICtrlSetBkColor($Input_slug, 0xBBFFBB)
	GUICtrlSetTip($Input_slug, "Game Slug!")
	$Button_last = GuiCtrlCreateButton("Last", 330, 300, 40, 22)
	GUICtrlSetFont($Button_last, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_last, "Find the latest added game(s)!")
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
	;$lowid = $Button_exit
	;MsgBox(262208, "$lowid", $lowid & @LF & $Button_exit & @LF & $Button_info & @LF & $Button_log & @LF & $Input_dest)
	;
	; CONTEXT MENU
	$Menu_list = GUICtrlCreateContextMenu($Listview_games)
	$Item_clear = GUICtrlCreateMenuItem("Clear Download List", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Item_view = GUICtrlCreateMenuItem("View Download List", $Menu_list)
	;
	$Menu_button = GUICtrlCreateContextMenu($Button_down)
	$Item_verify = GUICtrlCreateMenuItem("Validate", $Menu_button, -1, 0)
	;
	$lowid = $Item_verify
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
	GUICtrlSetImage($Button_find, $shell, $icoS, 0)
	GUICtrlSetImage($Button_web, $shell, $icoW, 0)
	GUICtrlSetImage($Button_dest, $shell, $icoF, 0)
	GUICtrlSetImage($Button_fold, $shell, $icoD, 0)
	GUICtrlSetImage($Button_log, $shell, $icoT, 1)
	GUICtrlSetImage($Button_info, $user, $icoI, 1)
	GUICtrlSetImage($Button_exit, $user, $icoX, 1)
	;
	; SETTINGS
	$cnt = _FileCountLines($downlist)
	If $cnt > 0 Then
		GUICtrlSetStyle($Button_down, $BS_MULTILINE)
		GUICtrlSetData($Button_down, "DOWNLOAD" & @LF & "LIST")
		$listed = FileRead($downlist)
	Else
		$listed = ""
	EndIf
	;
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
	$lang = IniRead($inifle, "Manifest Inclusion", "language", "none")
	If $lang = "none" Then
		$lang = "english"
		IniWrite($inifle, "Manifest Inclusion", "language", $lang)
	EndIf
	$second = IniRead($inifle, "Manifest Inclusion", "language_2", "none")
	If $second = "none" Then
		$second = ""
		IniWrite($inifle, "Manifest Inclusion", "language_2", $second)
	EndIf
	;
	$OS = IniRead($inifle, "Manifest Inclusion", "OS", "")
	If $OS = "" Then
		$OS = "windows"
		IniWrite($inifle, "Manifest Inclusion", "OS", $OS)
	EndIf
	;
	$validate = IniRead($inifle, "Download Options", "validate", "")
	If $validate = "" Then
		$validate = 1
		IniWrite($inifle, "Download Options", "validate", $validate)
	EndIf
	$getlatest = IniRead($inifle, "Download Options", "get_latest", "")
	If $getlatest = "" Then
		$getlatest = 4
		IniWrite($inifle, "Download Options", "get_latest", $getlatest)
	EndIf
	$selector = IniRead($inifle, "Download Options", "selector", "")
	If $selector = "" Then
		$selector = 1
		IniWrite($inifle, "Download Options", "selector", $selector)
	EndIf
	$cover = IniRead($inifle, "Download Options", "cover", "")
	If $cover = "" Then
		$cover = 1
		IniWrite($inifle, "Download Options", "cover", $cover)
	EndIf
	;
;~ 	$7zip = IniRead($inifle, "7-Zip", "path", "")
;~ 	If $7zip = "" Then
;~ 		$7zip = $foldzip & "\7z.exe"
;~ 		If FileExists($7zip) Then
;~ 			IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 		Else
;~ 			$7zip = $foldzip & "\7za.exe"
;~ 			If FileExists($7zip) Then
;~ 				MsgBox(262192, "7-Zip Error", "This program does not support using '7za.exe'." _
;~ 					& @LF & "Instead it requires the alternate '7z.exe'." & @LF _
;~ 					& @LF & "Please update your version of 7-Zip.", 0, $GOGcliGUI)
;~ 			EndIf
;~ 			$7zip = ""
;~ 			IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 		EndIf
;~ 	ElseIf Not FileExists($7zip) Then
;~ 		MsgBox(262192, "7-Zip Error", "The path set for '7z.exe' no longer exists." & @LF _
;~ 			& @LF & "Please reinstate 7-Zip or manually correct" _
;~ 			& @LF & "the setting in the 'Settings.ini' file.", 0, $GOGcliGUI)
;~ 		$7zip = ""
;~ 		IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 	EndIf
	;If $7zip = "" Then GUICtrlSetState($Item_verify, $GUI_DISABLE)
	;
	$find = ""
	$last = ""
	$verify = 4
	;
	FillTheGamesList()
	$ID = ""
	$title = ""
	$slug = ""
	$image = ""
	$web = ""
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
			If $web = "" Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				$link = "https://www.gog.com" & $web
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
						_FileWriteLog($logfle, "SAVE COVER - " & $title, -1)
						FileWriteLine($logfle, "")
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
			ElseIf _IsPressed("A2") Then
				; Left CTRL
				If FileExists($manifest) Then Run(@ProgramFilesDir & "\Windows NT\Accessories\wordpad.exe " & $manifest)
			ElseIf _IsPressed("A3") Then
				; Right CTRL
				If FileExists($json) Then
					$read = FileRead($json)
					$read = StringSplit($read, '"Id": ', 1)
					$read = $read[0]
					MsgBox(262208, "Manifest Information", $read & " games are listed.", 0, $GOGcliGUI)
				EndIf
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
											$params = StringStripWS($lang & " " & $second, 3)
											$params = StringReplace($params, " ", " -l=")
											$OP = StringReplace($OS, " ", " -o=")
											$params = "-c Cookie.txt manifest generate -l=" & $params & ' -o=' & $OP & ' -i="' & $title & '"'
											;$params = "-c Cookie.txt manifest generate -l english -o windows linux mac -i " & $title
											$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
											Sleep(1000)
											If FileExists($json) Then
												$game = FileRead($json)
												If $game <> "" Then
													; Something was returned, check for game ID in the return.
													$identry = '"Id": ' & $ID & ','
													If StringInStr($game, $identry) > 0 Then
														If FileExists($manifest) Then
															$read = FileRead($manifest)
															If StringInStr($read, $identry) < 1 Then
																; Add to manifest
																FileWrite($manifest, @LF & $game)
															Else
																; Replace in manifest
																GUICtrlSetData($Label_mid, "Replacing Game in Manifest")
																FileCopy($manifest, $manifest & ".bak", 1)
																$head = StringSplit($read, $identry, 1)
																$tail = $head[2]
																$tail = StringSplit($tail, @LF & "}", 1)
																$tail = $tail[2]
																$head = $head[1]
																$game = StringSplit($game, $identry, 1)
																$game = $game[2]
																$read = $head & $identry & $game & $tail
																_FileCreate($manifest)
																FileWrite($manifest, $read)
															EndIf
															Sleep(1000)
														Else
															; Start the manifest
															FileCopy($json, $manifest)
														EndIf
														_FileWriteLog($logfle, "GET MANIFEST - " & $title, -1)
														FileWriteLine($logfle, "")
													Else
														; Game ID not found in return.
														_FileWriteLog($logfle, "MANIFEST FAILED - " & $title, -1)
														FileWriteLine($logfle, "")
														MsgBox(262192, "Add Error", "Retrieval failed!", 0, $GOGcliGUI)
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
			If _IsPressed("11") Then
				If FileExists($updated) Then ShellExecute($updated)
			Else
				If FileExists($logfle) Then ShellExecute($logfle)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_last
			; Find the latest added game(s)
			If _IsPressed("11") Then $last = ""
			If FileExists($addlist) Then
				$res = _FileReadToArray($addlist, $latest)
				If $res = 1 Then
					If $last = "" Then
						$last = $latest[0]
						$title = $latest[$last]
					Else
						If $last > 1 Then
							$last = $last - 1
						Else
							$last = $latest[0]
						EndIf
						$title = $latest[$last]
					EndIf
					$ind = -1
					While 1
						$ind = _GUICtrlListView_FindInText($Listview_games, $title, $ind, False, False)
						If $ind = -1 Then ExitLoop
						If _GUICtrlListView_GetItemText($Listview_games, $ind, 1) = $title Then ExitLoop
					WEnd
					If $ind > -1 Then
						GUICtrlSetState($Listview_games, $GUI_FOCUS)
						_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
						ContinueLoop
					EndIf
				Else
					MsgBox(262192, "Read Error", "Added.txt file not read!", 0, $GOGcliGUI)
				EndIf
			Else
				MsgBox(262192, "File Error", "Added.txt file not found!", 0, $GOGcliGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_info
			; Program Information
			$ans = MsgBox(262209 + 256, "Program Information", _
				"To get started with the program, click the SETUP button." & @LF & @LF & _
				"The DOWNLOAD button has a right-click VALIDATE option." & @LF & @LF & _
				"The LAST button cycles through latest game list additions." & @LF & _
				"The FIND button is also a next button for the text specified." & @LF & _
				"Both the FIND and LAST buttons remember their value, so" & @LF & _
				"to start afresh, hold down CTRL when clicking them." & @LF & @LF & _
				"The LOG button similarly has a hold down CTRL option, to" & @LF & _
				"see the 'Updated.txt' file instead." & @LF & @LF & _
				"Width of the 'Game Files Selector' window is adjustable." & @LF & @LF & _
				"Click OK to see more information.", 0, $GOGcliGUI)
			If $ans = 1 Then
				MsgBox(262208, "Program Information (continued)", _
					"DISCLAIMER - As always, you use my programs at your own" & @LF & _
					"risk. That said, I strive to ensure they work safe. I also cannot" & @LF & _
					"guarantee the results (or my read) of any 3rd party programs." & @LF & _
					"This is Freeware that I have voluntarily given many hours to." & @LF & @LF & _
					"BIG THANKS to Magnitus for 'gogcli.exe'." & @LF & @LF & _
					"BIG thanks to j0kky (AutoIt Forum) for download size help." & @LF & _
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
									$params = "-c Cookie.txt gog-api owned-games -p="
									$pid = RunWait(@ComSpec & ' /c echo Page 1 && gogcli.exe ' & $params & '1 >"' & $gamelist & '"', @ScriptDir, $flag)
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
																	$pid = RunWait(@ComSpec & ' /c echo Page ' & $n & ' && gogcli.exe ' & $params & $n & ' >>"' & $gamelist & '"', @ScriptDir, $flag)
																Next
																GUICtrlSetData($Label_top, "")
																GUICtrlSetData($Label_bed, "")
															EndIf
															Sleep(1000)
															ParseTheGamelist()
															_FileWriteLog($logfle, "RETRIEVE GAMES LIST.", -1)
															FileWriteLine($logfle, "")
															SetStateOfControls($GUI_ENABLE, "all")
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
											_FileWriteLog($logfle, "GET DETAILS - " & $title, -1)
											FileWriteLine($logfle, "")
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
		Case $msg = $Button_find
			; Find the specified game title on list
			If _IsPressed("11") Then $find = ""
			$text = GUICtrlRead($Input_title)
			If $text <> "" Then
				;$cnt = _GUICtrlListView_GetItemCount($Listview_games)
				If $find = "" Then
					$find = $text
					If StringIsDigit($find) Then
						MsgBox(262192, "Find Advice", "Because the list has a hidden ID column, it is not recommended" _
							& @LF & "to search with just a number, unless that number has a leading" _
							& @LF & "or trailing space!", 0, $GOGcliGUI)
					EndIf
				EndIf
				If $ind = "" Then
					$ind = -1
				EndIf
				$ind = _GUICtrlListView_FindInText($Listview_games, $find, $ind, True, False)
				If $ind > -1 Then
					GUICtrlSetState($Listview_games, $GUI_FOCUS)
					_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
					ContinueLoop
				EndIf
			Else
				MsgBox(262192, "Find Error", "No text specified!", 0, $GOGcliGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_down
			; Download the selected game
			$buttxt = GUICtrlRead($Button_down)
			If $title = "" And ($buttxt = "DOWNLOAD" Or $buttxt = "VALIDATE") Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				If _IsPressed("11") And $buttxt <> "VALIDATE" Then
					; Build a download list of games.
					If $buttxt <> "DOWNLOAD" & @LF & "LIST" Then
						GUICtrlSetStyle($Button_down, $BS_MULTILINE)
						GUICtrlSetData($Button_down, "DOWNLOAD" & @LF & "LIST")
						GUICtrlSetState($Listview_games, $GUI_FOCUS)
					EndIf
					$entry = $title & "|" & $ID & @CRLF
					If $listed = "" Then
						; Start the list.
						FileWriteLine($downlist, $entry)
						$listed = $entry
					Else
						; Check the list.
						If StringInStr($listed, $entry) < 1 Then
							; Add new unique entry.
							FileWriteLine($downlist, $entry)
							$listed = $listed & $entry
						EndIf
					EndIf
				ElseIf $buttxt = "DOWNLOAD" & @LF & "LIST" Then
					; Downloads from a list of games.
					MsgBox(262192, "Download Error", "This feature is not yet supported!", 2, $GOGcliGUI)
				Else
					; Downloads from just one game.
					SetStateOfControls($GUI_DISABLE, "all")
					GUICtrlSetImage($Pic_cover, $blackjpg)
					$game = ""
					$retrieve = ""
					GUICtrlSetData($Label_mid, "Retrieving Game File Data")
					If $getlatest = 1 Then
						; Retrieve game file data
						$retrieve = 1
					Else
						If FileExists($json) Then
							$game = FileRead($json)
							If $game <> "" Then
								;$titentry = '"Title": "' & $title & '",'
								;If StringInStr($read, $titentry) < 1 Then
								$identry = '"Id": ' & $ID & ','
								If StringInStr($game, $identry) < 1 Then
									$game = ""
									If FileExists($manifest) Then
										$read = FileRead($manifest)
										If StringInStr($read, $identry) < 1 Then
											; Retrieve game file data
											$retrieve = 1
										Else
											; Extract just the relevant game entry
											$game = StringSplit($read, $identry, 1)
											$game = $game[2]
											$game = StringSplit($game, '"Id":', 1)
											$game = $game[1]
										EndIf
									Else
										; Retrieve game file data
										$retrieve = 1
									EndIf
								EndIf
							Else
								; Retrieve game file data
								$retrieve = 1
							EndIf
						Else
							; Retrieve game file data
							$retrieve = 1
						EndIf
					EndIf
					If $retrieve = 1 Then
						; Download game file data from GOG
						$cookie = ""
						If FileExists($cookies) Then
							$res = _FileReadToArray($cookies, $array)
							If $res = 1 Then
								For $a = 1 To $array[0]
									$line = $array[$a]
									If $line <> "" Then
										If StringLeft($line, 7) = "gog-al=" Then
											$cookie = 1
											$ping = Ping("gog.com", 4000)
											If $ping > 0 Then
												GUICtrlSetData($Label_mid, "Downloading Game Data")
												If $minimize = 1 Then
													$flag = @SW_MINIMIZE
												Else
													$flag = @SW_SHOW
												EndIf
												FileChangeDir(@ScriptDir)
												$params = StringStripWS($lang & " " & $second, 3)
												$params = StringReplace($params, " ", " -l=")
												$OP = StringReplace($OS, " ", " -o=")
												$params = "-c Cookie.txt manifest generate -l=" & $params & " -o=" & $OP & ' -i="' & $title & '"'
												;$params = "-c Cookie.txt manifest generate -l english -o windows linux mac -i " & $title
												$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
												Sleep(1000)
												If FileExists($json) Then
													$game = FileRead($json)
													If $game <> "" Then
														; Something was returned, check for game ID in the return.
														$identry = '"Id": ' & $ID & ','
														If StringInStr($game, $identry) > 0 Then
															If FileExists($manifest) Then
																$read = FileRead($manifest)
																If StringInStr($read, $identry) < 1 Then
																	; Add to manifest
																	GUICtrlSetData($Label_mid, "Adding Game to Manifest")
																	FileWrite($manifest, @LF & $game)
																Else
																	; Replace in manifest
																	GUICtrlSetData($Label_mid, "Replacing Game in Manifest")
																	FileCopy($manifest, $manifest & ".bak", 1)
																	$head = StringSplit($read, $identry, 1)
																	$tail = $head[2]
																	$tail = StringSplit($tail, @LF & "}", 1)
																	$tail = $tail[2]
																	$head = $head[1]
																	$game = StringSplit($game, $identry, 1)
																	$game = $game[2]
																	$read = $head & $identry & $game & $tail
																	_FileCreate($manifest)
																	FileWrite($manifest, $read)
																EndIf
																Sleep(1000)
															Else
																; Start the manifest
																FileCopy($json, $manifest)
															EndIf
														Else
															; Game ID not found in return.
															$game = ""
															MsgBox(262192, "Add Error", "Retrieval failed!", 0, $GOGcliGUI)
														EndIf
													EndIf
												EndIf
											Else
												MsgBox(262192, "Web Error", "No connection detected!", 0, $GOGcliGUI)
											EndIf
											ExitLoop
										EndIf
									EndIf
								Next
								If $cookie = "" Then
									MsgBox(262192, "Cookie Error", "The 'Cookie.txt' file doesn't contain a line starting with 'gog-al='.", 0, $GOGcliGUI)
								EndIf
							Else
								MsgBox(262192, "Content Error", "The 'Cookie.txt' file appears to be empty!", 0, $GOGcliGUI)
							EndIf
						Else
							MsgBox(262192, "File Error", "The 'Cookie.txt' file is missing!", 0, $GOGcliGUI)
						EndIf
					EndIf
					If $game <> "" Then
						If $verify = 4 Then
							; Download
							If $selector = 1 Then
								GUICtrlSetData($Label_mid, "Game Files Selector")
								$caption = $title
								FileSelectorGUI()
							Else
								GUICtrlSetData($Label_mid, "Game Downloading")
								MsgBox(262192, "Download Error", "This feature is not yet supported!", 2, $GOGcliGUI)
								GetFileDownloadDetails()
								If $validate = 1 Then
									GUICtrlSetData($Label_mid, "Verifying Game Files")
								EndIf
							EndIf
						Else
							; Validate
							GUICtrlSetData($Label_mid, "Verifying Game Files")
							GetFileDownloadDetails()
							MsgBox(262192, "Verify Error", "This feature is not yet supported!", 2, $GOGcliGUI)
						EndIf
					Else
						MsgBox(262192, "Details Error", "Game data could not be found!", 0, $GOGcliGUI)
					EndIf
					SetStateOfControls($GUI_ENABLE, "all")
					GUICtrlSetData($Label_mid, "")
					If $ind > -1 Then _GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
			;_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
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
		Case $msg = $Checkbox_alpha
			; Create alphanumeric sub-folder
			If GUICtrlRead($Checkbox_alpha) = $GUI_CHECKED Then
				$alpha = 1
			Else
				$alpha = 4
			EndIf
			IniWrite($inifle, "Game Folder Names", "alpha", $alpha)
		Case $msg = $Combo_dest
			; Type of game folder name
			$type = GUICtrlRead($Combo_dest)
			IniWrite($inifle, "Game Folder Names", "type", $type)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_view
			; View Download List
			If FileExists($downlist) Then ShellExecute($downlist)
		Case $msg = $Item_verify
			; Validate for DOWNLOAD button
			If $verify = 4 Then
				$verify = 1
				GUICtrlSetData($Button_down, "VALIDATE")
			Else
				$verify = 4
				GUICtrlSetData($Button_down, "DOWNLOAD")
			EndIf
			GUICtrlSetState($Item_verify, $verify)
		Case $msg = $Item_clear
			; Clear Download List
			If GUICtrlRead($Button_down) <> "VALIDATE" Then
				GUICtrlSetData($Button_down, "DOWNLOAD")
				_FileCreate($downlist)
				$listed = ""
			EndIf
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
			$web = IniRead($gamesini, $ID, "URL", "")
			$category = IniRead($gamesini, $ID, "category", "")
			GUICtrlSetData($Input_cat, $category)
			$OSes = IniRead($gamesini, $ID, "OSes", "")
			GUICtrlSetData($Input_OS, $OSes)
			$DLC = IniRead($gamesini, $ID, "DLC", "")
			GUICtrlSetData($Input_dlc, $DLC)
			$updates = IniRead($gamesini, $ID, "updates", "")
			GUICtrlSetData($Input_ups, $updates)
			;GUICtrlSetData($Input_ups, $ind)
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
	Local $Button_close, $Button_cookie, $Checkbox_dos, $Checkbox_image, $Checkbox_keep, $Checkbox_latest, $Checkbox_select, $Checkbox_valid
	Local $Combo_lang, $Combo_OS, $Combo_two, $Edit_info, $Group_down, $Group_lang, $Label_OS
	Local $above, $high, $info, $langs, $opsys, $side, $wide
	;
	$wide = 250
	$high = 405
	$side = IniRead($inifle, "Setup Window", "left", $left)
	$above = IniRead($inifle, "Setup Window", "top", $top)
	$SetupGUI = GuiCreate("Setup", $wide, $high, $side, $above, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
											+ $WS_VISIBLE + $WS_CLIPSIBLINGS, $WS_EX_TOPMOST, $GOGcliGUI)
	GUISetBkColor(0xFFFFB0, $SetupGUI)
	;
	; CONTROLS
	$Edit_info = GUICtrlCreateEdit("", 11, 10, 228, 100, $ES_WANTRETURN + $WS_VSCROLL + $ES_AUTOVSCROLL + $ES_MULTILINE + $ES_READONLY)
	;
	$Button_cookie = GuiCtrlCreateButton("CREATE COOKIE", 10, 120, 160, 50)
	GUICtrlSetFont($Button_cookie, 9, 600)
	GUICtrlSetTip($Button_cookie, "Create the basic cookie file!")
	;
	$Button_close = GuiCtrlCreateButton("EXIT", 180, 120, 60, 50, $BS_ICON)
	GUICtrlSetTip($Button_close, "Exit / Close / Quit the window!")
	;
	$Checkbox_keep = GUICtrlCreateCheckbox("Save cover images locally when shown", 24, 180, 210, 20)
	GUICtrlSetTip($Checkbox_keep, "Save cover images locally when obtained!")
	;
	$Checkbox_dos = GUICtrlCreateCheckbox("Minimize DOS Console window process", 24, 200, 210, 20)
	GUICtrlSetTip($Checkbox_dos, "Minimize a DOS Console window process when it starts!")
	;
	$Group_lang = GuiCtrlCreateGroup("Language(s)", 10, 225, 230, 52)
	$Combo_lang = GUICtrlCreateCombo("", 20, 245, 125, 21)
	;GUICtrlSetBkColor($Combo_lang, 0xFFFFB0)
	GUICtrlSetTip($Combo_lang, "Main language to use!")
	$Combo_two = GUICtrlCreateCombo("", 150, 245, 80, 21)
	GUICtrlSetTip($Combo_two, "Second language to use!")
	;
	$Label_OS = GuiCtrlCreateLabel("OS", 15, 286, 28, 21, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_OS, $COLOR_BLACK)
	GUICtrlSetColor($Label_OS, $COLOR_WHITE)
	$Combo_OS = GUICtrlCreateCombo("", 43, 286, 113, 21)
	GUICtrlSetTip($Combo_OS, "OSes to use!")
	;
	GuiCtrlCreateGroup("", 166, 280, 74, 41)
	$Checkbox_valid = GUICtrlCreateCheckbox("Validate", 175, 293, 60, 20)
	GUICtrlSetTip($Checkbox_valid, "Validate after downloading!")
	;
	$Group_down = GuiCtrlCreateGroup("Download Options", 10, 313, 230, 85)
	$Checkbox_latest = GUICtrlCreateCheckbox("Download the latest game file information", 21, 331, 210, 20)
	GUICtrlSetTip($Checkbox_latest, "Get latest file information for the game!")
	$Checkbox_select = GUICtrlCreateCheckbox("Present the 'Game Files Selector' window", 21, 351, 210, 20)
	GUICtrlSetTip($Checkbox_select, "Present the game files selector window!")
	$Checkbox_image = GUICtrlCreateCheckbox("Download the game cover image file", 21, 371, 210, 20)
	GUICtrlSetTip($Checkbox_image, "Download the game cover image file automatically!")
	;
	; SETTINGS
	$info = "Before using 'gogcli.exe' to download your games, update etc, you need a cookie file." _
		& @CRLF & "The 'Cookie.txt' file must be located inside the main program folder and contain some required content to pass an authentication check when connecting to GOG." _
		& @CRLF & "At this current point in time, 'gogcli.exe' is unable to obtain the necessary data your cookie file needs, so you need to obtain it manually, or with the help of a browser addon (recommended)." _
		& @CRLF & "To assist you, this program can create an empty 'Cookie.txt' file, to which you copy the required entry(s)."
	GUICtrlSetData($Edit_info, $info)
	;
	GUICtrlSetImage($Button_close, $user, $icoX, 1)
	;
	GUICtrlSetState($Checkbox_keep, $keep)
	GUICtrlSetState($Checkbox_dos, $minimize)
	;
	$langs = "||arabic|chinese_simplified|czech|danish|dutch|english|finnish|french|german|hungarian|italian|japanese|korean|polish|portuguese|portuguese_brazilian|romanian|russian|spanish|swedish|turkish|unknown"
	GUICtrlSetData($Combo_lang, $langs, $lang)
	GUICtrlSetData($Combo_two, $langs, $second)
	;
	$opsys = "linux|mac|windows|mac linux|windows linux|windows mac|windows mac linux"
	GUICtrlSetData($Combo_OS, $opsys, $OS)
	;
;~ 	If $7zip = "" Then
;~ 		$7zip = $foldzip & "\7z.exe"
;~ 		If FileExists($7zip) Then
;~ 			IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 			;GUISwitch($GOGcliGUI)
;~ 			;GUICtrlSetState($Item_verify, $GUI_ENABLE)
;~ 			;GUISwitch($SetupGUI)
;~ 		Else
;~ 			$7zip = $foldzip & "\7za.exe"
;~ 			If FileExists($7zip) Then
;~ 				MsgBox(262192, "7-Zip Error", "This program does not support using '7za.exe'." _
;~ 					& @LF & "Instead it requires the alternate '7z.exe'." & @LF _
;~ 					& @LF & "Please update your version of 7-Zip.", 0, $SetupGUI)
;~ 			EndIf
;~ 			$7zip = ""
;~ 			IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 		EndIf
;~ 	ElseIf Not FileExists($7zip) Then
;~ 		MsgBox(262192, "7-Zip Error", "The path set for '7z.exe' no longer exists." & @LF _
;~ 			& @LF & "Please reinstate 7-Zip or manually correct" _
;~ 			& @LF & "the setting in the 'Settings.ini' file.", 0, $SetupGUI)
;~ 		$7zip = ""
;~ 		IniWrite($inifle, "7-Zip", "path", $7zip)
;~ 		;GUISwitch($GOGcliGUI)
;~ 		;GUICtrlSetState($Item_verify, $GUI_DISABLE)
;~ 		;GUISwitch($SetupGUI)
;~ 	EndIf
;~ 	If $7zip = "" Then
;~ 		;GUICtrlSetState($Checkbox_valid, $GUI_DISABLE)
;~ 		;If $validate = 1 Then
;~ 		;	$validate = 4
;~ 		;	IniWrite($inifle, "Download Options", "validate", $validate)
;~ 		;EndIf
;~ 	EndIf
	;
	GUICtrlSetState($Checkbox_valid, $validate)
	GUICtrlSetState($Checkbox_latest, $getlatest)
	GUICtrlSetState($Checkbox_select, $selector)
	GUICtrlSetState($Checkbox_image, $cover)
	;
	$window = $SetupGUI


	GuiSetState(@SW_SHOW, $SetupGUI)
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_close
			; Exit / Close / Quit the window
			If $lang & $second = "" Then
				MsgBox(262192, "Language Error", "You must specify one language at least!", 0, $SetupGUI)
				ContinueLoop
			EndIf
			;
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
		Case $msg = $Checkbox_valid
			; Validate after downloading
			If GUICtrlRead($Checkbox_valid) = $GUI_CHECKED Then
				$validate = 1
			Else
				$validate = 4
			EndIf
			IniWrite($inifle, "Download Options", "validate", $validate)
		Case $msg = $Checkbox_select
			; Present the game files selector window
			If GUICtrlRead($Checkbox_select) = $GUI_CHECKED Then
				$selector = 1
			Else
				$selector = 4
			EndIf
			IniWrite($inifle, "Download Options", "selector", $selector)
		Case $msg = $Checkbox_latest
			; Get latest file information for the game
			If GUICtrlRead($Checkbox_latest) = $GUI_CHECKED Then
				$getlatest = 1
			Else
				$getlatest = 4
			EndIf
			IniWrite($inifle, "Download Options", "get_latest", $getlatest)
		Case $msg = $Checkbox_keep
			; Save cover images locally when obtained & shown
			If GUICtrlRead($Checkbox_keep) = $GUI_CHECKED Then
				$keep = 1
			Else
				$keep = 4
			EndIf
			IniWrite($inifle, "Cover Image", "keep", $keep)
		Case $msg = $Checkbox_image
			; Download the game cover image file automatically
			If GUICtrlRead($Checkbox_image) = $GUI_CHECKED Then
				$cover = 1
			Else
				$cover = 4
			EndIf
			IniWrite($inifle, "Download Options", "cover", $cover)
		Case $msg = $Checkbox_dos
			; Minimize DOS Console window process
			If GUICtrlRead($Checkbox_dos) = $GUI_CHECKED Then
				$minimize = 1
			Else
				$minimize = 4
			EndIf
			IniWrite($inifle, "DOS Console", "minimize", $minimize)
		Case $msg = $Combo_two
			; Second language to use
			$second = GUICtrlRead($Combo_two)
			IniWrite($inifle, "Manifest Inclusion", "language_2", $second)
			If $second = $lang Then
				$lang = ""
				IniWrite($inifle, "Manifest Inclusion", "language", $lang)
				GUICtrlSetData($Combo_lang, $langs, $lang)
			EndIf
		Case $msg = $Combo_OS
			; OSes to use
			$OS = GUICtrlRead($Combo_OS)
			IniWrite($inifle, "Manifest Inclusion", "OS", $OS)
		Case $msg = $Combo_lang
			; Main language to use
			$lang = GUICtrlRead($Combo_lang)
			IniWrite($inifle, "Manifest Inclusion", "language", $lang)
			If $lang = $second Then
				$second = ""
				IniWrite($inifle, "Manifest Inclusion", "language_2", $second)
				GUICtrlSetData($Combo_two, $langs, $second)
			EndIf
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> SetupGUI

Func FileSelectorGUI()
	Local $Button_download, $Button_quit, $Button_uncheck, $Checkbox_cancel, $Combo_OSfle, $Group_files, $Group_OS, $Label_percent, $Label_warn, $ListView_files
	Local $Progress_bar, $Radio_selall, $Radio_selext, $Radio_selgame, $Radio_selpat, $Radio_selset
	Local $amount, $checked, $downloads, $edge, $ents, $fext, $final, $first, $osfle, $p, $portion, $portions, $sum, $tmpman, $wide
	;
	$SelectorGUI = GuiCreate("Game Files Selector - " & $caption, $width - 5, $height, $left, $top, $style + $WS_SIZEBOX + $WS_VISIBLE, $WS_EX_TOPMOST, $GOGcliGUI)
	GUISetBkColor(0xBBFFBB, $SelectorGUI)
	; CONTROLS
	$Group_files = GuiCtrlCreateGroup("Game Files To Download", 10, 10, $width - 25, 302)
	GUICtrlSetResizing($Group_files, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	$ListView_files = GUICtrlCreateListView("||||", 20, 30, $width - 45, 270, $LVS_SHOWSELALWAYS + $LVS_SINGLESEL + $LVS_REPORT + $LVS_NOCOLUMNHEADER, _
													$LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES + $LVS_EX_CHECKBOXES) ;
	GUICtrlSetBkColor($ListView_files, 0xB9FFFF)
	GUICtrlSetResizing($ListView_files, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	;
	$Label_warn = GuiCtrlCreateLabel("", 10, 318, $width - 184, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_warn, $COLOR_RED)
	GUICtrlSetColor($Label_warn, $COLOR_YELLOW)
	GUICtrlSetFont($Label_warn, 8, 600)
	GUICtrlSetResizing($Label_warn, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKSIZE)
	;GUICtrlSetResizing($Label_warn, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	;
	$Progress_bar = GUICtrlCreateProgress($width - 166, 317, 90, 20, $PBS_SMOOTH)
	GUICtrlSetResizing($Progress_bar, $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKAUTO + $GUI_DOCKAUTO)
	$Label_percent = GUICtrlCreateLabel("0%", $width - 160, 318, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor($Label_percent, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_percent, $COLOR_BLACK)
	GUICtrlSetFont($Label_percent, 9, 600)
	GUICtrlSetResizing($Label_percent, $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKAUTO + $GUI_DOCKAUTO)
	;
	$Checkbox_cancel = GUICtrlCreateCheckbox("Cancel", $width - 66, 318, 50, 20)
	GUICtrlSetResizing($Checkbox_cancel, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetTip($Checkbox_cancel, "Cancel downloading after the current download has finished!")
	;
	$Group_select = GuiCtrlCreateGroup("Select Files", 10, $height - 65, 300, 55)
	GUICtrlSetResizing($Group_select, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Radio_selall = GUICtrlCreateRadio("ALL", 20, $height - 44,  50, 20)
	GUICtrlSetResizing($Radio_selall, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selall, "Select ALL file entries!")
	$Radio_selgame = GUICtrlCreateRadio("GAME", 70, $height - 44,  60, 20)
	GUICtrlSetResizing($Radio_selgame, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selgame, "Select GAME file entries!")
	$Radio_selext = GUICtrlCreateRadio("EXTRA", 130, $height - 44,  65, 20)
	GUICtrlSetResizing($Radio_selext, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selext, "Select EXTRA file entries!")
	$Radio_selset = GUICtrlCreateRadio("setup", 195, $height - 44,  55, 20)
	GUICtrlSetResizing($Radio_selset, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selset, "Select SETUP file entries!")
	$Radio_selpat = GUICtrlCreateRadio("patch", 250, $height - 44,  50, 20)
	GUICtrlSetResizing($Radio_selpat, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selpat, "Select PATCH file entries!")
	GUICtrlSetBkColor($Radio_selall, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selgame, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selext, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selset, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selpat, 0xFFD5FF)
	;
	$Group_OS = GuiCtrlCreateGroup("OS Select", $width - 270, $height - 65, 90, 55)
	GUICtrlSetResizing($Group_OS, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Combo_OSfle = GUICtrlCreateCombo("", $width - 260, $height - 45, 70, 21)
	GUICtrlSetResizing($Combo_OSfle, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Combo_OSfle, "OS for files!")
	;
	$Button_download = GuiCtrlCreateButton("DOWNLOAD", $width - 170, $height - 60, 100, 28)
	GUICtrlSetFont($Button_download, 8, 600)
	GUICtrlSetResizing($Button_download, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_download, "Download selected files!")
	;
	$Button_uncheck = GuiCtrlCreateButton("De-Select ALL", $width - 170, $height - 28, 100, 18)
	GUICtrlSetFont($Button_uncheck, 7, 600, 0, "Small Fonts")
	GUICtrlSetResizing($Button_uncheck, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_uncheck, "Deselect ALL files!")
	;
	$Button_quit = GuiCtrlCreateButton("EXIT", $width - 60, $height - 60, 45, 50, $BS_ICON)
	GUICtrlSetResizing($Button_quit, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_quit, "Exit / Close / Quit the window!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_quit, $user, $icoX, 1)
	;
	;_GUICtrlListView_SetColumn($ListView_files, 2, "", 200, -1, -1, False)
	GetFileDownloadDetails($ListView_files)
	;
	_GUICtrlListView_JustifyColumn($ListView_files, 0, 0)
	_GUICtrlListView_JustifyColumn($ListView_files, 1, 2)
	_GUICtrlListView_JustifyColumn($ListView_files, 2, 2)
	_GUICtrlListView_JustifyColumn($ListView_files, 3, 0)
	_GUICtrlListView_SetColumnWidth($ListView_files, 0, 45)
	_GUICtrlListView_SetColumnWidth($ListView_files, 1, 55)
	_GUICtrlListView_SetColumnWidth($ListView_files, 2, 70)
	_GUICtrlListView_SetColumnWidth($ListView_files, 3, $LVSCW_AUTOSIZE_USEHEADER)
	;_GUICtrlListView_SetColumnWidth($ListView_files, 3, $LVSCW_AUTOSIZE)
	;
	$ents = _GUICtrlListView_GetItemCount($ListView_files)
	GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
	;
	GUICtrlSetData($Label_warn, "Ensure desired download settings have been set on the SETUP window.")
	;
	$osfle = IniRead($inifle, "Selector", "OS", "")
	If $osfle = "" Then
		$osfle = "Win-Lin"
		IniWrite($inifle, "Selector", "OS", $osfle)
	ElseIf $osfle = "Both" Then
		$osfle = "Win-Lin"
		IniWrite($inifle, "Selector", "OS", $osfle)
	EndIf
	GUICtrlSetData($Combo_OSfle, "ALL|Windows|Linux|Mac|Win-Lin|Win-Mac|Mac-Lin", $osfle)

	GuiSetState()
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_quit
			; Exit / Close / Quit the window
			GUIDelete($SelectorGUI)
			ExitLoop
		Case $msg = $GUI_EVENT_MINIMIZE
			GUISetState(@SW_MINIMIZE, $GOGcliGUI)
		Case $msg = $GUI_EVENT_RESIZED
			$winpos = WinGetPos($SelectorGUI, "")
			$wide = $winpos[2]
			If $left > @DesktopWidth - $wide Then
				$edge = @DesktopWidth - $wide - 20
			ElseIf $wide < $width Then
				$wide = $width + 10
			Else
				$edge = $left
			EndIf
			WinMove($SelectorGUI, "", $edge, $top, $wide, $height + 38)
		Case $msg = $Button_uncheck
			; Deselect ALL files
			_GUICtrlListView_SetItemChecked($ListView_files, -1, False)
			If $ents > 0 Then
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
			Else
				GUICtrlSetData($Group_files, "Game Files To Download")
			EndIf
			GUICtrlSetState($Radio_selall, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selgame, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selext, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selset, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selpat, $GUI_UNCHECKED)
		Case $msg = $Button_download
			; Download selected files
			;MsgBox(262192, "Download Error", "This feature is not yet supported!", 1.5, $SelectorGUI)
			Local $cancel, $IDD, $imageD, $slugD, $titleD, $test = ""
			If GUICtrlRead($Checkbox_cancel) = $GUI_CHECKED Then
				MsgBox(262192, "Download Error", "Cancel is selected!", 0, $SelectorGUI)
			Else
				$cancel = ""
				$ping = Ping("gog.com", 4000)
				If $ping > 0 Or $test = 1 Then
					GUICtrlSetState($Button_download, $GUI_DISABLE)
					GUICtrlSetState($ListView_files, $GUI_DISABLE)
					GUICtrlSetState($Radio_selall, $GUI_DISABLE)
					GUICtrlSetState($Radio_selgame, $GUI_DISABLE)
					GUICtrlSetState($Radio_selext, $GUI_DISABLE)
					GUICtrlSetState($Radio_selset, $GUI_DISABLE)
					GUICtrlSetState($Radio_selpat, $GUI_DISABLE)
					GUICtrlSetState($Combo_OSfle, $GUI_DISABLE)
					GUICtrlSetState($Button_uncheck, $GUI_DISABLE)
					GUICtrlSetState($Button_quit, $GUI_DISABLE)
					$downloads = ""
					_GUICtrlListView_SetItemSelected($ListView_files, -1, True, False)
					For $a = 0 To $ents - 1
						If _GUICtrlListView_GetItemChecked($ListView_files, $a) = True Then
							$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
							If StringLeft($entry, 14) <> "Downloading..." And StringLeft($entry, 9) <> "PASSED..." And StringLeft($entry, 7) <> "DONE..." _
								And StringLeft($entry, 11) <> "MD5check..." And StringLeft($entry, 10) <> "MD5okay..." Then
								If StringLeft($entry, 9) = "FAILED..." Or StringLeft($entry, 9) = "MD5bad..." Then
									$entry = StringTrimLeft($entry, 9)
									_GUICtrlListView_SetItemText($ListView_files, $a, $entry, 3)
								ElseIf StringLeft($entry, 10) = "SKIPPED..." Then
									$entry = StringTrimLeft($entry, 10)
									_GUICtrlListView_SetItemText($ListView_files, $a, $entry, 3)
								EndIf
								If $downloads = "" Then
									$downloads = $entry
								Else
									$downloads = $downloads & "|" & $entry
								EndIf
							EndIf
						EndIf
					Next
					If $downloads <> "" Then
						;MsgBox(262192, "Selected Files", $downloads, 2, $SelectorGUI)
						If $minimize = 1 Then
							$flag = @SW_MINIMIZE
						Else
							$flag = @SW_SHOW
						EndIf
						$md5check = ""
						FileChangeDir(@ScriptDir)
						$files = StringSplit($downloads, "|", 1)
						For $f = 1 To $files[0]
							$file = $files[$f]
							$URL = IniRead($downfiles, $file, "URL", "")
							If $URL <> "" Then
								$drv = StringLeft(@ScriptDir, 3)
								$space = DriveSpaceFree($drv)
								$free = $space * 1048576
								$filesize = IniRead($downfiles, $file, "bytes", 0)
								If $filesize < $free Then
									$titleD = IniRead($downfiles, $file, "game", "")
									$slugD = IniRead($downfiles, $file, "slug", "")
									$IDD = IniRead($downfiles, $file, "ID", "")
									$checksum = IniRead($downfiles, $file, "checksum", "")
									$i = _GUICtrlListView_FindInText($ListView_files, $file, -1, True, False)
									If $i > -1 Then
										$row = $Button_quit + $i + 1
										GUICtrlSetBkColor($row, $COLOR_YELLOW)
										_GUICtrlListView_SetItemText($ListView_files, $i, "Downloading..." & $file, 3)
										$download = @ScriptDir & "\" & $file
										If $test = 1 Then
											Sleep(5000)
										Else
											_FileWriteLog($logfle, "DOWNLOADING - " & $file, -1)
											GUICtrlSetData($Progress_bar, 0)
											GUICtrlSetData($Label_percent, "0%")
											$exists = ""
											$params = "-c Cookie.txt gog-api download-url-path -p=" & $URL
											;$pid = RunWait(@ComSpec & ' /c echo DOWNLOADING ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
											$pid = Run(@ComSpec & ' /c echo DOWNLOADING ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
											While ProcessExists($pid) <> 0
												Sleep(500)
												If $filesize <> 0 Then
													If $exists = "" Then $exists = FileExists($download)
													If $exists = 1 Then
														$handle = FileOpen($download, 0)
														DllCall("Kernel32.dll", "BOOLEAN", "FlushFileBuffers", "HANDLE", $handle)
														$done = FileGetSize($download)
														FileClose($handle)
														If $done <> 0 Then
															$progress = $done
															$percent = ($progress / $filesize) * 100
															GUICtrlSetData($Progress_bar, $percent)
															$percent = Floor($percent) & "%"
															GUICtrlSetData($Label_percent, $percent)
															;GUICtrlSetTip($Progress_bar, $percent)
															;$done = $done / 1048576
															;If $done > 999 Then
															;	$done = Round($done / 1024, 2) & " Gb"
															;Else
															;	$done = Round($done) & " Mb"
															;EndIf
														EndIf
													EndIf
												EndIf
											WEnd
											_FileWriteLog($logfle, "COMPLETED.", -1)
										EndIf
										If $filesize <> 0 Then
											If $test = 1 Then
												GUICtrlSetBkColor($row, $COLOR_LIME)
												_GUICtrlListView_SetItemText($ListView_files, $i, "PASSED..." & $file, 3)
											Else
												If FileExists($download) Then
													$bytes = FileGetSize($download)
													If $bytes = $filesize Then
														GUICtrlSetData($Progress_bar, 100)
														GUICtrlSetData($Label_percent, "100%")
														If $checksum <> "" Then
															GUICtrlSetBkColor($row, $COLOR_LIME)
															_GUICtrlListView_SetItemText($ListView_files, $i, "PASSED..." & $file, 3)
														Else
															GUICtrlSetBkColor($row, $COLOR_AQUA)
															_GUICtrlListView_SetItemText($ListView_files, $i, "PASSED..." & $file, 3)
														EndIf
														_FileWriteLog($logfle, "Passed the File Size check.", -1)
													Else
														GUICtrlSetBkColor($row, $COLOR_RED)
														_GUICtrlListView_SetItemText($ListView_files, $i, "FAILED..." & $file, 3)
														_FileWriteLog($logfle, "File Size check failed.", -1)
													EndIf
													$filepth = ""
													$gamepic = ""
													$gamefold = $gamesfold
													If $type = "Slug" Then
														$name = $slugD
													ElseIf $type = "Title" Then
														$name = FixTitle($titleD)
													EndIf
													If $alpha = 1 Then
														$alf = StringUpper(StringLeft($name, 1))
														$gamefold = $gamefold & "\" & $alf
													EndIf
													$gamefold = $gamefold & "\" & $name
													If Not FileExists($gamefold) Then DirCreate($gamefold)
													If FileExists($gamefold) Then
														FileMove($download, $gamefold & "\", 1)
														If $cover = 1 Then
															$gamepic = $gamefold & "\Folder.jpg"
														EndIf
														If $checksum <> "" And $validate = 1 Then
															$filepth = $gamefold & "\" & $file
														EndIf
													ElseIf FileExists($gamesfold) Then
														FileMove($download, $gamesfold & "\", 1)
														If $cover = 1 Then
															$gamepic = $gamesfold & "\" & $name & ".jpg"
														EndIf
														If $checksum <> "" And $validate = 1 Then
															$filepth = $gamesfold & "\" & $file
														EndIf
													EndIf
													If $filepth <> "" And $validate = 1 Then
														$checkval = $filepth & "|" & $checksum & "|" & $i
														If $md5check = "" Then
															$md5check = $checkval
														Else
															$md5check = $md5check & "||" & $checkval
														EndIf
													EndIf
													If $gamepic <> "" Then
														If Not FileExists($gamepic) Then
															$imageD = IniRead($gamesini, $IDD, "image", "")
															$link = "https:" & $imageD & ".jpg"
															InetGet($link, $gamepic, 1, 0)
															If Not FileExists($gamepic) Then
																InetGet($link, $gamepic, 0, 0)
																If Not FileExists($gamepic) Then
																	InetGet($link, $gamepic, 0, 1)
																EndIf
															EndIf
															_FileWriteLog($logfle, "Download cover.", -1)
														EndIf
													EndIf
												Else
													GUICtrlSetBkColor($row, $COLOR_RED)
													_GUICtrlListView_SetItemText($ListView_files, $i, "FAILED..." & $file, 3)
													_FileWriteLog($logfle, "File is missing.", -1)
												EndIf
											EndIf
										Else
											_FileWriteLog($logfle, "No file size listed.", -1)
											If FileExists($download) Then
												GUICtrlSetData($Progress_bar, 100)
												GUICtrlSetData($Label_percent, "100%")
												GUICtrlSetBkColor($row, $COLOR_MONEYGREEN)
												_GUICtrlListView_SetItemText($ListView_files, $i, "DONE..." & $file, 3)
											Else
												GUICtrlSetBkColor($row, $COLOR_RED)
												_GUICtrlListView_SetItemText($ListView_files, $i, "FAILED..." & $file, 3)
												_FileWriteLog($logfle, "File is missing.", -1)
											EndIf
										EndIf
									EndIf
								Else
									$i = _GUICtrlListView_FindInText($ListView_files, $file, -1, True, False)
									If $i > -1 Then
										$row = $Button_quit + $i + 1
										GUICtrlSetBkColor($row, $COLOR_FUCHSIA)
										_GUICtrlListView_SetItemText($ListView_files, $i, "SKIPPED..." & $file, 3)
									EndIf
									_FileWriteLog($logfle, "Not enough drive space.", -1)
									$space = Round($space, 3)
									MsgBox(262192, "Drive Space Error", "Not enough free space on destination drive, only " & $space & " Mb's", 6, $SelectorGUI)
								EndIf
								FileWriteLine($logfle, "")
							EndIf
							If $f <> $files[0] Then
								If GUICtrlRead($Checkbox_cancel) = $GUI_CHECKED Then
									$ans = MsgBox(262209 + 256, "Cancel Query", "Do you want to cancel remaining downloads?", 0, $SelectorGUI)
									If $ans = 1 Then
										$cancel = 1
										ExitLoop
									EndIf
								EndIf
								Sleep(500)
							EndIf
						Next
						If $validate = 1 Then
							If $md5check <> "" Then
								; Compare MD5 values.
								$md5check = StringSplit($md5check, "||", 1)
								For $m = 1 To $md5check[0]
									$checkval = $md5check[$m]
									$checkval = StringSplit($checkval, "|", 1)
									$filepth = $checkval[1]
									$checksum = $checkval[2]
									$i = $checkval[3]
									$row = $Button_quit + $i + 1
									If FileExists($filepth) Then
										$file = StringSplit($filepth, "\", 1)
										$file = $file[$file[0]]
										_GUICtrlListView_SetItemText($ListView_files, $i, "MD5check..." & $file, 3)
										_Crypt_Startup()
										$hash = _Crypt_HashFile($filepth, $CALG_MD5)
										$hash = StringTrimLeft($hash, 2)
										If $hash = $checksum Then
											GUICtrlSetBkColor($row, $COLOR_LIME)
											_GUICtrlListView_SetItemText($ListView_files, $i, "MD5okay..." & $file, 3)
											_FileWriteLog($logfle, "MD5 Check passed.", -1)
										Else
											GUICtrlSetBkColor($row, $COLOR_RED)
											_GUICtrlListView_SetItemText($ListView_files, $i, "MD5bad..." & $file, 3)
											_FileWriteLog($logfle, "MD5 Check failed.", -1)
											MsgBox(262192, "Checksum Failure", "MD5 = " & $checksum & @LF & "Hash = " & $hash, 0, $SelectorGUI)
										EndIf
										_Crypt_Shutdown()
										;$foldpth = StringTrimRight($filepth, StringLen($file) + 1)
									EndIf
								Next
							EndIf
						EndIf
						_GUICtrlListView_SetColumnWidth($ListView_files, 3, $LVSCW_AUTOSIZE)
					Else
						MsgBox(262192, "Program Error", "Nothing to download!", 2, $SelectorGUI)
					EndIf
					GUICtrlSetState($Button_download, $GUI_ENABLE)
					GUICtrlSetState($ListView_files, $GUI_ENABLE)
					GUICtrlSetState($Radio_selall, $GUI_ENABLE)
					GUICtrlSetState($Radio_selgame, $GUI_ENABLE)
					GUICtrlSetState($Radio_selext, $GUI_ENABLE)
					GUICtrlSetState($Radio_selset, $GUI_ENABLE)
					GUICtrlSetState($Radio_selpat, $GUI_ENABLE)
					GUICtrlSetState($Combo_OSfle, $GUI_ENABLE)
					GUICtrlSetState($Button_uncheck, $GUI_ENABLE)
					GUICtrlSetState($Button_quit, $GUI_ENABLE)
					_GUICtrlListView_SetItemSelected($ListView_files, -1, True, False)
				Else
					MsgBox(262192, "Web Error", "No connection detected!", 0, $SelectorGUI)
				EndIf
			EndIf
		Case $msg = $Combo_OSfle
			; OS for files
			$osfle = GUICtrlRead($Combo_OSfle)
			IniWrite($inifle, "Selector", "OS", $osfle)
			;
			_GUICtrlListView_SetItemChecked($ListView_files, -1, False)
			If $ents > 0 Then
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
			Else
				GUICtrlSetData($Group_files, "Game Files To Download")
			EndIf
			GUICtrlSetState($Radio_selall, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selgame, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selext, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selset, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selpat, $GUI_UNCHECKED)
		Case $msg = $ListView_files Or $msg > $Button_quit
			; Game Files To Download
			$amount = 0
			$checked = 0
			For $a = 0 To $ents - 1
				If _GUICtrlListView_GetItemChecked($ListView_files, $a) = True Then
					$checked = $checked + 1
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				EndIf
			Next
			If $checked = 0 Then
				If $ents > 0 Then
					GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Game Files To Download")
				EndIf
			Else
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
			EndIf
		Case $msg = $Radio_selset
			; Select SETUP file entries
			$amount = 0
			$checked = 0
			For $a = 0 To $ents - 1
				$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
				$fext = StringRight($entry, 4)
				If $osfle = "ALL" Or $osfle = "Win-Lin" Or $osfle = "Win-Mac" Or $osfle = "Mac-Lin" Then
					If ($fext = ".dmg" Or $fext = ".pkg") And $osfle <> "ALL" And $osfle <> "Win-Mac" And $osfle <> "Mac-Lin" Then
						_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
						$sum = ""
					ElseIf StringRight($fext, 3) = ".sh" And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Mac-Lin" Then
						_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
						$sum = ""
					ElseIf ($fext = ".exe" Or $fext = ".bin") And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Win-Mac" Then
						_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
						$sum = ""
					Else
						If StringInStr($entry, "setup_") > 0 Then
							_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
							$checked = $checked + 1
							$sum = 1
						ElseIf StringInStr($entry, "patch_") < 1 Then
							$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 1)
							If $entry = "GAME" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						Else
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						EndIf
					EndIf
				ElseIf StringInStr($entry, "patch_") < 1 Then
					;$fext = StringRight($entry, 4)
					$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 1)
					If $entry = "GAME" Then
						If $osfle = "Windows" Then
							If $fext = ".exe" Or $fext = ".bin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						ElseIf $osfle = "Mac" Then
							If $fext = ".dmg" Or $fext = ".pkg" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						;ElseIf $fext <> ".exe" And $fext <> ".bin" Then
						ElseIf $osfle = "Linux" Then
							If StringRight($fext, 3) = ".sh" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						Else
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						EndIf
					Else
						_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
						$sum = ""
					EndIf
				Else
					_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
					$sum = ""
				EndIf
				If $sum = 1 Then
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				EndIf
			Next
			If $checked = 0 Then
				If $ents > 0 Then
					GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Game Files To Download")
				EndIf
			Else
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
			EndIf
		Case $msg = $Radio_selpat
			; Select PATCH file entries
			$amount = 0
			$checked = 0
			For $a = 0 To $ents - 1
				$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
				$fext = StringRight($entry, 4)
				If StringInStr($entry, "patch_") > 0 Then
					If $osfle = "ALL" Or $osfle = "Win-Lin" Or $osfle = "Win-Mac" Or $osfle = "Mac-Lin" Then
						If ($fext = ".dmg" Or $fext = ".pkg") And $osfle <> "ALL" And $osfle <> "Win-Mac" And $osfle <> "Mac-Lin" Then
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						ElseIf StringRight($fext, 3) = ".sh" And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Mac-Lin" Then
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						ElseIf ($fext = ".exe" Or $fext = ".bin") And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Win-Mac" Then
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						Else
							_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
							$checked = $checked + 1
							$sum = 1
						EndIf
					Else
						If $osfle = "Windows" Then
							If $fext = ".exe" Or $fext = ".bin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						ElseIf $osfle = "Mac" Then
							If $fext = ".dmg" Or $fext = ".pkg" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						ElseIf $osfle = "Linux" Then
							If StringRight($fext, 3) = ".sh" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						Else
							_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
							$sum = ""
						EndIf
					EndIf
				Else
					_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
					$sum = ""
				EndIf
				If $sum = 1 Then
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				EndIf
			Next
			If $checked = 0 Then
				If $ents > 0 Then
					GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Game Files To Download")
				EndIf
			Else
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
			EndIf
		Case $msg = $Radio_selgame
			; Select GAME file entries
			$amount = 0
			$checked = 0
			For $a = 0 To $ents - 1
				$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 1)
				If $entry = "GAME" Then
					If $osfle = "ALL" Then
						_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
						$checked = $checked + 1
						$sum = 1
					Else
						$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
						$fext = StringRight($entry, 4)
						If $osfle = "ALL" Or $osfle = "Win-Lin" Or $osfle = "Win-Mac" Or $osfle = "Mac-Lin" Then
							If ($fext = ".dmg" Or $fext = ".pkg") And $osfle <> "ALL" And $osfle <> "Win-Mac" And $osfle <> "Mac-Lin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							ElseIf StringRight($fext, 3) = ".sh" And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Mac-Lin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							ElseIf ($fext = ".exe" Or $fext = ".bin") And $osfle <> "ALL" And $osfle <> "Win-Lin" And $osfle <> "Win-Mac" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							EndIf
						Else
							If $osfle = "Windows" Then
								If $fext = ".exe" Or $fext = ".bin" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = $checked + 1
									$sum = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$sum = ""
								EndIf
							ElseIf $osfle = "Mac" Then
								If $fext = ".dmg" Or $fext = ".pkg" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = $checked + 1
									$sum = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$sum = ""
								EndIf
							ElseIf $osfle = "Linux" Then
								If StringRight($fext, 3) = ".sh" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = $checked + 1
									$sum = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$sum = ""
								EndIf
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							EndIf
						EndIf
					EndIf
				Else
					_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
					$sum = ""
				EndIf
				If $sum = 1 Then
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				EndIf
			Next
			If $checked = 0 Then
				If $ents > 0 Then
					GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Game Files To Download")
				EndIf
			Else
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
			EndIf
		Case $msg = $Radio_selext
			; Select EXTRA file entries
			$amount = 0
			$checked = 0
			For $a = 0 To $ents - 1
				$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 1)
				If $entry = "EXTRA" Then
					_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
					$checked = $checked + 1
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				Else
					_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
				EndIf
			Next
			If $checked = 0 Then
				If $ents > 0 Then
					GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Game Files To Download")
				EndIf
			Else
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
			EndIf
		Case $msg = $Radio_selall
			; Select ALL file entries
			$amount = 0
			If $osfle = "ALL" Then
				_GUICtrlListView_SetItemChecked($ListView_files, -1, True)
				For $a = 0 To $ents - 1
					$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
					$val = StringSplit($sum, " ", 1)
					$sum = $val[1]
					$val = $val[2]
					If $val = "bytes" Then
						$amount = $amount + $sum
					ElseIf $val = "Kb" Then
						$amount = $amount + ($sum * 1024)
					ElseIf $val = "Mb" Then
						$amount = $amount + ($sum * 1048576)
					ElseIf $val = "Gb" Then
						$amount = $amount + ($sum * 1073741824)
					EndIf
				Next
			Else
				$checked = 0
				_GUICtrlListView_SetItemChecked($ListView_files, -1, True)
				For $a = 0 To $ents - 1
					$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 1)
					If $entry = "EXTRA" Then
						_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
						$checked = 1
					Else
						$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
						$fext = StringRight($entry, 4)
						If $osfle = "Win-Lin" Or $osfle = "Win-Mac" Or $osfle = "Mac-Lin" Then
							If ($fext = ".dmg" Or $fext = ".pkg") And $osfle <> "Win-Mac" And $osfle <> "Mac-Lin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							ElseIf StringRight($fext, 3) = ".sh" And $osfle <> "Win-Lin" And $osfle <> "Mac-Lin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							ElseIf ($fext = ".exe" Or $fext = ".bin") And $osfle <> "Win-Lin" And $osfle <> "Win-Mac" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$sum = ""
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = $checked + 1
								$sum = 1
							EndIf
						Else
							If $osfle = "Windows" Then
								If $fext = ".exe" Or $fext = ".bin" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = ""
								EndIf
							ElseIf $osfle = "Mac" Then
								If $fext = ".dmg" Or $fext = ".pkg" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = ""
								EndIf
							ElseIf $osfle = "Linux" Then
								If StringRight($fext, 3) = ".sh" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = ""
								EndIf
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$checked = ""
							EndIf
						EndIf
					EndIf
					If $checked = 1 Then
						$sum = _GUICtrlListView_GetItemText($ListView_files, $a, 2)
						$val = StringSplit($sum, " ", 1)
						$sum = $val[1]
						$val = $val[2]
						If $val = "bytes" Then
							$amount = $amount + $sum
						ElseIf $val = "Kb" Then
							$amount = $amount + ($sum * 1024)
						ElseIf $val = "Mb" Then
							$amount = $amount + ($sum * 1048576)
						ElseIf $val = "Gb" Then
							$amount = $amount + ($sum * 1073741824)
						EndIf
					EndIf
				Next
			EndIf
			If $ents > 0 Then
				If $amount < 1024 Then
					$amount = $amount & " bytes"
				ElseIf $amount < 1048576 Then
					$amount = $amount / 1024
					$amount =  Round($amount) & " Kb"
				ElseIf $amount < 1073741824 Then
					$amount = $amount / 1048576
					$amount =  Round($amount, 1) & " Mb"
				ElseIf $amount < 1099511627776 Then
					$amount = $amount / 1073741824
					$amount = Round($amount, 2) & " Gb"
				Else
					$amount = $amount / 1099511627776
					$amount = Round($amount, 3) & " Tb"
				EndIf
				GUICtrlSetData($Group_files, "Game Files To Download (" & $ents & ")  Selected  (" & $ents & ")  (" & $amount & ")")
			Else
				GUICtrlSetData($Group_files, "Game Files To Download")
			EndIf
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> FileSelectorGUI


Func ClearFieldValues()
	$ID = ""
	$title = ""
	GUICtrlSetData($Input_title, $title)
	$slug = ""
	GUICtrlSetData($Input_slug, $slug)
	$image = ""
	$web = ""
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

Func GetFileDownloadDetails($listview = "")
	Local $alias, $col1, $col2, $col3, $col4, $language, $OPS
	;$caption
	_FileCreate($downfiles)
	Sleep(500)
	If $listview <> "" Then IniWrite($downfiles, "Title", "caption", $caption)
	;
	$alias = ""
	$checksum = ""
	$col1 = 0
	$col2 = ""
	$col3 = ""
	$col4 = ""
	$filesize = ""
	$language = ""
	$OPS = ""
	$URL = ""
	$lines = StringSplit($game, @LF, 1)
	For $l = 1 To $lines[0]
		$line = $lines[$l]
		If StringInStr($line, '"Installers":') > 0 Then
			$col2 = "GAME"
		ElseIf StringInStr($line, '"Extras":') > 0 Then
			$col2 = "EXTRA"
		ElseIf StringInStr($line, '"Language":') > 0 Then
			$line = StringSplit($line, '"Language": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '",', 1)
			$language = $line[1]
		ElseIf StringInStr($line, '"Os":') > 0 Then
			$line = StringSplit($line, '"Os": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '",', 1)
			$OPS = $line[1]
		ElseIf StringInStr($line, '"Url":') > 0 Then
			$line = StringSplit($line, '"Url": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '",', 1)
			$URL = $line[1]
		ElseIf StringInStr($line, '"Title":') > 0 Then
			$line = StringSplit($line, '"Title": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '",', 1)
			$alias = $line[1]
		ElseIf StringInStr($line, '"Name":') > 0 Then
			$line = StringSplit($line, '"Name": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '",', 1)
			$col4 = $line[1]
		ElseIf StringInStr($line, '"VerifiedSize":') > 0 Then
			$line = StringSplit($line, '"VerifiedSize":', 1)
			$line = $line[2]
			$line = StringSplit($line, ',', 1)
			$line = $line[1]
			$col3 = StringStripWS($line, 8)
			$filesize = $col3
			If StringIsDigit($col3) Then
				$size = $col3
				GetTheSize()
				$col3 = $size
			Else
				$col3 = "0 bytes"
			EndIf
		ElseIf StringInStr($line, '"Checksum":') > 0 Then
			$line = StringSplit($line, '"Checksum": "', 1)
			$line = $line[2]
			$line = StringSplit($line, '"', 1)
			$checksum = $line[1]
			;
			IniWrite($downfiles, $col4, "game", $title)
			IniWrite($downfiles, $col4, "slug", $slug)
			IniWrite($downfiles, $col4, "ID", $ID)
			IniWrite($downfiles, $col4, "file", $col3)
			IniWrite($downfiles, $col4, "language", $language)
			IniWrite($downfiles, $col4, "OS", $OPS)
			IniWrite($downfiles, $col4, "URL", $URL)
			IniWrite($downfiles, $col4, "title", $alias)
			IniWrite($downfiles, $col4, "bytes", $filesize)
			IniWrite($downfiles, $col4, "size", $col4)
			IniWrite($downfiles, $col4, "checksum", $checksum)
			IniWrite($downfiles, $col4, "type", $col2)
			;
			If $listview <> "" Then
				;If $col3 <> "" And $col4 <> "" Then
				If $col4 <> "" Then
					$col1 = $col1 + 1
					$entry = $col1 & "|" & $col2 & "|" & $col3 & "|" & $col4
					;MsgBox(262208, "Entry Information", $entry, 0, $SelectorGUI)
					GUICtrlCreateListViewItem($entry, $listview)
				EndIf
			EndIf
			$alias = ""
			$checksum = ""
			$col3 = ""
			$col4 = ""
			$filesize = ""
			$language = ""
			$OPS = ""
			$URL = ""
		EndIf
	Next
	;If $cover = 1 Then
	;EndIf
EndFunc ;=> GetFileDownloadDetails

Func GetTheSize()
	If $size < 1024 Then
		$size = $size & " bytes"
	ElseIf $size < 1048576 Then
		$size = $size / 1024
		$size =  Round($size) & " Kb"
	ElseIf $size < 1073741824 Then
		$size = $size / 1048576
		$size =  Round($size, 1) & " Mb"
	ElseIf $size < 1099511627776 Then
		$size = $size / 1073741824
		$size = Round($size, 2) & " Gb"
	Else
		$size = $size / 1099511627776
		$size = Round($size, 3) & " Tb"
	EndIf
	;Return $size
EndFunc ;=> GetTheSize

Func ParseTheGamelist()
	Local $p, $titles, $uplist
	If FileExists($gamelist) Then
		; Parse for titles
		;SplashTextOn("", "Please Wait!", 140, 120, Default, Default, 33)
		GUICtrlSetData($Label_mid, "Parsing Games List")
		_GUICtrlListView_BeginUpdate($Listview_games)
		_GUICtrlListView_DeleteAllItems($Listview_games)
		_GUICtrlListView_EndUpdate($Listview_games)
		If FileExists($titlist) Then
			$titles = FileRead($titlist)
		Else
			$titles = ""
		EndIf
		$entries = ""
		$lines = ""
		$new = ""
		$uplist = ""
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
				$web = ""
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
						$web = StringTrimLeft($part, 4)
						$web = StringStripWS($web, 3)
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
				$line = $title & "|" & $ID
				If $titles <> "" Then
					If StringInStr($titles, $line) < 1 Then
						If $new = "" Then
							$new = $title
						Else
							$new = $new & @CRLF & $title
						EndIf
					EndIf
				EndIf
				$line = $line & "|" & $updates
				If $lines = "" Then
					$lines = $line
				Else
					$lines = $lines & @LF & $line
				EndIf
				$entries = $entries & @CRLF & "[" & $ID & "]" & @CRLF & "title=" & $title & @CRLF & "slug=" & $slug & @CRLF & "image=" & $image
				$entries = $entries & @CRLF & "URL=" & $web & @CRLF & "category=" & $category & @CRLF & "OSes=" & $OSes & @CRLF & "DLC=" & $DLC
				$entries = $entries & @CRLF & "updates=" & $updates
				If $updates > 0 Then
					$entry = $title & " | " & _Now()
					If $uplist = "" Then
						$uplist = $entry
					Else
						$uplist = $uplist & @CRLF & $entry
					EndIf
				EndIf
			Next
			If $uplist <> "" Then
				FileWriteLine($updated, $uplist & @CRLF & @CRLF)
			EndIf
			_FileCreate($titlist)
			If $lines <> "" Then
				FileWrite($titlist, $lines)
			EndIf
			If $new <> "" Then
				FileWriteLine($addlist, $new)
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
	GUICtrlSetState($Button_last, $state)
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
