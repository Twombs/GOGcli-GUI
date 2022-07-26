#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Timboli (aka TheSaint)

 Script Function:	Get detail about a game from GOG via the Game ID.
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

;FUNCTIONS
; IDResultsGUI(), SettingsGUI()
; AddSomeGame(), FixAllText($text), FixText($text), FixUnicode($text), GetExtras($section), GetGameDetail(), GetOthers($section)
; RemoveHtml($text)

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <InetConstants.au3>
#include <StaticConstants.au3>
#include <Misc.au3>
#include <File.au3>
#include <Date.au3>
#include <Inet.au3>
#include <GuiListBox.au3>
#include <GDIPlus.au3>

Global $Button_add, $Button_exit, $Button_get, $Button_info, $Button_move, $Button_ontop, $Button_replace, $Button_runurl
Global $Checkbox_remove, $Edit_reqs, $Edit_sumry, $Group_cover, $Group_date, $Group_devs, $Group_games, $Group_gametit
Global $Group_genre, $Group_ID, $Group_imgurl, $Group_OS, $Group_price, $Group_size, $Group_sumry, $Group_type, $Group_weburl
Global $Input_date, $Input_devs, $Input_gametit, $Input_genre, $Input_get, $Input_ID, $Input_imgurl, $Input_OS
Global $Input_price, $Input_size, $Input_type, $Input_weburl, $Item_list_manifest
Global $List_games, $Menu_list, $Pic_cover

Global $defimage, $GameInfoGUI, $height, $icoF, $icoI, $icoM, $icoX, $OptionsGUI, $pth, $shell, $user32, $width

Global $boxart, $bytes, $cc, $check, $cliptxt, $cnt, $cover, $d, $datafold, $date, $description, $developer, $dev, $devs
Global $dll, $downone, $downtwo, $e, $editor, $entries, $entry, $f, $feature, $features, $fixed, $gamedata, $gameinfo, $genre
Global $GID, $handle, $head, $hide, $high, $html, $htmltxt, $ID, $idlink, $image, $ind, $inifle, $last, $lastlang, $lastOS
Global $line, $logfle, $manfold, $minimize, $minimum, $mpos, $name, $names, $ontop, $OS, $ping, $playtype, $price, $publisher
Global $read, $release, $reload, $requires, $s, $show, $skip, $slug, $status, $success, $supported, $sys, $system, $systems
Global $t, $tag, $tags, $tail, $text, $titfile, $title, $titles, $total, $update, $updated, $URL, $val, $versions, $wide
Global $xpos, $ypos

Global $a, $array, $change, $checksum, $cookie, $create, $downurl, $extra, $extras, $file, $fileinfo, $gogcli, $i, $info
Global $installer, $installers, $lang, $manifest, $mass, $params, $section, $size, $type, $version

_Singleton("gog-game-info-timboli", 0)

$cookie = @ScriptDir & "\Cookie.txt"
$datafold = @ScriptDir & "\Data"
$defimage = @ScriptDir & "\Black.jpg"
$downone = @ScriptDir & "\Retrieved_1.txt"
$downtwo = @ScriptDir & "\Retrieved_2.txt"
$fileinfo = @ScriptDir & "\Fileinfo.txt"
$gogcli = @ScriptDir & "\gogcli.exe"
$inifle = @ScriptDir & "\Options.ini"
$logfle = @ScriptDir & "\Info.log"
$manfold = @ScriptDir & "\Manifests"
$titfile = @ScriptDir & "\Titles.ini"
$updated = "July 2022"
$update = "v2.3"

If Not FileExists($datafold) Then DirCreate($datafold)
If Not FileExists($manfold) Then DirCreate($manfold)

$change = IniRead($inifle, "Games Data Folder", "change", "")
If $change = "" Then
	If FileExists($titfile) Then
		SplashTextOn("", "Changing The Data" & @LF & "Folder Structure", 200, 140, Default, Default, 33)
		$read = _FileReadToArray($titfile, $entries)
		If IsArray($entries) Then
			For $e = 1 To $entries[0]
				$line = $entries[$e]
				If StringLeft($line, 3) = "id=" Then
					$ID = StringTrimLeft($line, 3)
					$gamedata = $datafold & "\" & $ID
					If Not FileExists($gamedata) Then DirCreate($gamedata)
					FileMove($gamedata & ".txt", $gamedata & "\")
					FileMove($gamedata & "_cover.jpg", $gamedata & "\")
					FileMove($gamedata & "_image.png", $gamedata & "\")
				EndIf
			Next
		EndIf
		SplashOff()
	EndIf
	$change = 1
	IniWrite($inifle, "Games Data Folder", "change", $change)
EndIf

$cc = IniRead($inifle, "Price Query", "country_code", "")
If $cc = "" Then
	;$cc = "AUD"
	$cc = "USD"
	$val = InputBox("Country Code Query", "A 3-letter country code is required.", $cc, "", 230, 135, Default, Default)
	If @error > 0 Or StringIsAlpha($val) = 0 Or StringLen($val) <> 3 Then
		Exit
	Else
		$cc = StringUpper($val)
	EndIf
	IniWrite($inifle, "Price Query", "country_code", $cc)
EndIf

$skip = IniRead($inifle, "Query ID At Startup", "skip", "")
If $skip = "" Then
	$skip = 4
	IniWrite($inifle, "Query ID At Startup", "skip", $skip)
EndIf
If $skip = 4 Then
	$ID = "1563735310"
	AddSomeGame()
 EndIf

$create = IniRead($inifle, "Manifest Entry", "create", "")
If $create = "" Then
	$create = 4
	IniWrite($inifle, "Manifest Entry", "create", $create)
EndIf

$show = IniRead($inifle, "Manifest Entry", "show", "")
If $show = "" Then
	$show = 4
	IniWrite($inifle, "Manifest Entry", "show", $show)
EndIf

$minimize = IniRead($inifle, "Main Window On ADD", "minimize", "")
If $minimize = "" Then
	$minimize = 4
	IniWrite($inifle, "Main Window On ADD", "minimize", $minimize)
EndIf

$hide = IniRead($inifle, "Console Window On ADD", "hide", "")
If $hide = "" Then
	$hide = 4
	IniWrite($inifle, "Console Window On ADD", "hide", $hide)
EndIf

$editor = IniRead($inifle, "Editor", "path", "")
If $editor = "" Then
	$editor = "none"
	IniWrite($inifle, "Editor", "path", $editor)
EndIf

$width = 900
$height = 700
$GameInfoGUI = GuiCreate("Get Game Info", $width, $height, 10, Default, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
											+ $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX, $WS_EX_TOPMOST)
; CONTROLS
$Group_gametit = GuiCtrlCreateGroup("Game Title", 10, 10, 420, 50)
$Input_gametit = GuiCtrlCreateInput("", 20, 30, 380, 20)
GUICtrlSetTip($Input_gametit, "Game or DLC Title!")
$Checkbox_remove = GUICtrlCreateCheckbox("", 405, 30, 15, 20)
GUICtrlSetTip($Checkbox_remove, "Enable removal!")
;
$Button_add = GuiCtrlCreateButton("ADD", 440, 15, 50, 45)
GUICtrlSetFont($Button_add, 9, 600)
GUICtrlSetTip($Button_add, "ADD a game or Update selected!")
;
$Group_weburl = GuiCtrlCreateGroup("Web Page URL", 10, 70, 420, 50)
$Input_weburl = GuiCtrlCreateInput("", 20, 90, 360, 20)
$Button_runurl = GuiCtrlCreateButton("GO", 385, 89, 35, 22)
GUICtrlSetFont($Button_runurl, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_runurl, "Run the Web Page URL in default browser!")
;
$Button_move = GuiCtrlCreateButton("Move", 440, 75, 50, 45, $BS_ICON)
GUICtrlSetFont($Button_move, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_move, "Move program window to right!")
;
$Group_imgurl = GuiCtrlCreateGroup("Image URL", 10, 130, 400, 50)
$Input_imgurl = GuiCtrlCreateInput("", 20, 150, 315, 20)
$Button_replace = GuiCtrlCreateButton("Replace", 340, 149, 60, 22)
GUICtrlSetFont($Button_replace, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_replace, "Replace one or both images!")
;
$Group_price = GuiCtrlCreateGroup("Price", 420, 130, 70, 50)
$Input_price = GuiCtrlCreateInput("", 430, 150, 50, 20)
;
$Group_sumry = GuiCtrlCreateGroup("Summary", 10, 190, 480, 190)
$Edit_sumry = GuiCtrlCreateEdit("", 20, 210, 460, 160, $ES_WANTRETURN + $WS_VSCROLL + $ES_AUTOVSCROLL)
;
$Group_type = GuiCtrlCreateGroup("Player Type", 10, 390, 205, 50)
$Input_type = GuiCtrlCreateInput("", 20, 410, 185, 21)
;
$Group_genre = GuiCtrlCreateGroup("Genre", 225, 390, 265, 50)
$Input_genre = GuiCtrlCreateInput("", 235, 410, 245, 20)

$Group_size = GuiCtrlCreateGroup("File Size", 10, 450, 80, 50)
$Input_size = GuiCtrlCreateInput("", 20, 470, 60, 20)
;
$Group_date = GuiCtrlCreateGroup("Date Released", 100, 450, 100, 50)
$Input_date = GuiCtrlCreateInput("", 110, 470, 80, 20)
;
$Group_devs = GuiCtrlCreateGroup("Company or Developer(s)", 210, 450, 280, 50)
$Input_devs = GuiCtrlCreateInput("", 220, 470, 260, 20)
;
$Group_OS = GuiCtrlCreateGroup("Operating System(s)", 10, 510, 360, 50)
$Input_OS = GuiCtrlCreateInput("", 20, 530, 340, 20)
;
$Group_ID = GuiCtrlCreateGroup("Game ID", 380, 510, 110, 50)
$Input_ID = GuiCtrlCreateInput("", 390, 530, 90, 20)
;
$Group_reqs = GuiCtrlCreateGroup("System Requirements", 10, 570, 420, 120)
$Edit_reqs = GuiCtrlCreateEdit("", 20, 590, 400, 90, $ES_WANTRETURN + $WS_VSCROLL + $ES_AUTOVSCROLL)
;
$Button_info = GuiCtrlCreateButton("Info", 440, 575, 50, 50, $BS_ICON)
GUICtrlSetTip($Button_info, "Program Information!")
;
$Button_exit = GuiCtrlCreateButton("EXIT", 440, 635, 50, 55, $BS_ICON)
GUICtrlSetTip($Button_exit, "Quit, Close or Exit window!")
;
; RIGHT SIDE
$Group_games = GuiCtrlCreateGroup("Game Titles", 500, 10, 390, 180)
$List_games = GUICtrlCreateList("", 510, 30, 370, 160)
GUICtrlSetTip($List_games, "List of games with details!")
;
$Button_ontop = GUICtrlCreateCheckbox("On Top", 820, 5, 60, 20, $BS_PUSHLIKE)
GUICtrlSetFont($Button_ontop, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_ontop, "Toggle the program window on top setting!")
;
$Input_get = GuiCtrlCreateInput("", 500, 200, 300, 20)
;GUICtrlSetFont($Input_get, 8, 400, 0, "Small Fonts")
$Button_get = GuiCtrlCreateButton("Get Game ID", 805, 199, 85, 22)
GUICtrlSetFont($Button_get, 7, 600, 0, "Small Fonts")
GUICtrlSetTip($Button_get, "Get Game ID via Title!")
;
$Group_cover = GuiCtrlCreateGroup("Cover Image", 500, 225, 390, 465)
$Pic_cover = GuiCtrlCreatePic($defimage, 510, 245, 370, 435, $SS_NOTIFY)
GUICtrlSetTip($Pic_cover, "Click to see full image!")
;
; CONTEXT MENU
$Menu_list = GUICtrlCreateContextMenu($List_games)
$Item_list_datafold = GUICtrlCreateMenuItem("Open Data Folder", $Menu_list)
GUICtrlCreateMenuItem("", $Menu_list)
GUICtrlCreateMenuItem("", $Menu_list)
$Item_list_manifest = GUICtrlCreateMenuItem("View Manifest", $Menu_list)
;
; OS_SETTINGS
$shell = @SystemDir & "\shell32.dll"
$user32 = @SystemDir & "\user32.dll"
$icoF = -85
$icoI = -5
$icoM = -138
$icoX = -28
GUICtrlSetImage($Button_move, $shell, $icoM, 1)
GUICtrlSetImage($Button_info, $user32, $icoI, 1)
GUICtrlSetImage($Button_exit, $shell, $icoX, 1)
;
; SETTINGS
$ontop = IniRead($inifle, "Main Window", "ontop", "")
If $ontop = "" Then
	$ontop = 1
	IniWrite($inifle, "Main Window", "ontop", $ontop)
EndIf
If $ontop = 4 Then
	WinSetOnTop($GameInfoGUI, "", 0)
EndIf
GUICtrlSetState($Button_ontop, $ontop)

LoadTheList()
;
$last = ""

GuiSetState()
While 1
	$msg = GuiGetMsg()
	Select
	Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_exit
		; Quit, Close or Exit window
		GUIDelete($GameInfoGUI)
		ExitLoop
	Case $msg = $Button_runurl
		; Run the Web Page URL in default browser
		$URL = GUICtrlRead($Input_weburl)
		If $URL = "" Then
			$cliptxt = ClipGet()
			If StringLeft($cliptxt, 20) = "https://www.gog.com/" Then
				$URL = $cliptxt
			EndIf
			$URL = InputBox("Get Game ID", "Please enter the URL for a GOG game page." & @LF _
				& @LF & "NOTE - This requires a web connection.", $URL, "", 450, 160, Default, Default, 0, $GameInfoGUI)
			If @error = 0 And StringLeft($URL, 20) = "https://www.gog.com/" Then
				GUICtrlSetState($Button_add, $GUI_DISABLE)
				GUICtrlSetState($Button_runurl, $GUI_DISABLE)
				GUICtrlSetState($Button_move, $GUI_DISABLE)
				GUICtrlSetState($Button_replace, $GUI_DISABLE)
				GUICtrlSetState($List_games, $GUI_DISABLE)
				GUICtrlSetState($Button_get, $GUI_DISABLE)
				GUICtrlSetState($Button_info, $GUI_DISABLE)
				GUICtrlSetState($Button_exit, $GUI_DISABLE)
				If $minimize = 1 Then GUISetState(@SW_MINIMIZE, $GameInfoGUI)
				$ping = Ping("gog.com", 4000)
				If $ping > 0 Then
					SplashTextOn("", "Downloading Page!", 200, 120, Default, Default, 33)
					$html = _INetGetSource($URL, True)
					If @error = 0 Then
						If $html = "" Then
							MsgBox(262192, "Download Error", "The web page html wasn't returned!", 3, $GameInfoGUI)
						EndIf
					Else
						MsgBox(262192, "Page Error", "The web page doesn't appear to exist!", 3, $GameInfoGUI)
						$html = ""
					EndIf
					If $html <> "" Then
						$ID = StringSplit($html, ' card-product="', 1)
						If $ID[0] = 2 Then
							$ID = $ID[2]
							$ID = StringSplit($ID, '"', 1)
							$ID = $ID[1]
						Else
							$ID = StringSplit($html, '"ProductCardCtrl"', 1)
							If $ID[0] = 2 Then
								$ID = $ID[2]
								$ID = StringSplit($ID, 'gog-product="', 1)
								If $ID[0] > 1 Then
									$ID = $ID[2]
									$ID = StringSplit($ID, '"', 1)
									$ID = $ID[1]
								Else
									$ID = ""
								EndIf
							Else
								$ID = ""
							EndIf
						EndIf
						If $ID = "" Then
							_FileCreate($htmltxt)
							FileWrite($htmltxt, $html)
							MsgBox(262192, "ID Error", "The Game ID could not be detected!" & @LF & "Possibly web page doesn't exist.", 5, $GameInfoGUI)
						Else
							$reload = ""
							_FileWriteLog($logfle, "ADDED = " & $title, -1)
							GetGameDetail()
							If $ID <> "" Then
								If $title <> "" Then
									FileWriteLine($logfle, "")
									If $reload = 1 Then
										GUICtrlSetData($List_games, "")
										LoadTheList()
										$ind = _GUICtrlListBox_FindString($List_games, $title, True)
										_GUICtrlListBox_SetCurSel($List_games, $ind)
									Else
										$ind = _GUICtrlListBox_GetCurSel($List_games)
									EndIf
									If $ind > -1 And $minimize = 4 Then
										GUISetState(@SW_SHOWNORMAL, $GameInfoGUI)
										_GUICtrlListBox_ClickItem($List_games, $ind, "left", False, 1, 0)
									EndIf
								EndIf
							Else
								MsgBox(262192, "Extraction Error", "Game detail not discovered!", 0, $GameInfoGUI)
							EndIf
						EndIf
					EndIf
					SplashOff()
				Else
					MsgBox(262192, "Web Error", "No connection detected!", 0, $GameInfoGUI)
				EndIf
				If $minimize = 1 And $show = 4 Then GUISetState(@SW_RESTORE, $GameInfoGUI)
				GUICtrlSetState($Button_add, $GUI_ENABLE)
				GUICtrlSetState($Button_runurl, $GUI_ENABLE)
				GUICtrlSetState($Button_move, $GUI_ENABLE)
				GUICtrlSetState($Button_replace, $GUI_ENABLE)
				GUICtrlSetState($List_games, $GUI_ENABLE)
				GUICtrlSetState($Button_get, $GUI_ENABLE)
				GUICtrlSetState($Button_info, $GUI_ENABLE)
				GUICtrlSetState($Button_exit, $GUI_ENABLE)
			EndIf
		Else
			ShellExecute($URL)
		EndIf
	Case $msg = $Button_replace
		; Replace one or both images
		$ID = GUICtrlRead($Input_ID)
		If $ID <> "" Then
			$ans = MsgBox(262179 + 256, "Replace Query", _
				"Replace both images (Boxart & Cover)?" & @LF & @LF & _
				"YES = Replace both." & @LF & _
				"NO = Select which to replace." & @LF & _
				"CANCEL = Abort any replacements.", 0, $GameInfoGUI)
			If $ans = 6 Then
				$cover = $datafold & "\" & $ID & "\" & $ID & "_cover.jpg"
				If FileExists($cover) Then
					FileDelete($cover)
					GUICtrlSetImage($Pic_cover, $defimage)
				Else
					$gamedata = $datafold & "\" & $ID
					If Not FileExists($gamedata) Then
						DirCreate($gamedata)
					EndIf
				EndIf
				$cover = $datafold & "\" & $ID & "_image.png"
				If FileExists($cover) Then FileDelete($cover)
				$boxart = IniRead($gameinfo, $ID, "boxart", "")
				If $boxart <> "" Then
					SplashTextOn("", "Downloading Boxart!", 200, 120, Default, Default, 33)
					InetGet($boxart, $cover, 1, 0)
					SplashOff()
					GUICtrlSetImage($Pic_cover, $cover)
				EndIf
				$image = IniRead($gameinfo, $ID, "cover", "")
				If $image <> "" Then
					SplashTextOn("", "Downloading Cover!", 200, 120, Default, Default, 33)
					InetGet($image, $cover, 1, 0)
					SplashOff()
				EndIf
			ElseIf $ans = 7 Then
				$ans = MsgBox(262179 + 256, "Replace Query", _
					"Select an image file to replace." & @LF & @LF & _
					"YES = Replace Boxart." & @LF & _
					"NO = Replace Cover." & @LF & _
					"CANCEL = Abort any replacements.", 0, $GameInfoGUI)
				If $ans = 6 Then
					$cover = $datafold & "\" & $ID & "\" & $ID & "_cover.jpg"
					If FileExists($cover) Then
						FileDelete($cover)
						GUICtrlSetImage($Pic_cover, $defimage)
					Else
						$gamedata = $datafold & "\" & $ID
						If Not FileExists($gamedata) Then
							DirCreate($gamedata)
						EndIf
					EndIf
					$boxart = IniRead($gameinfo, $ID, "boxart", "")
					If $boxart <> "" Then
						SplashTextOn("", "Downloading Boxart!", 200, 120, Default, Default, 33)
						InetGet($boxart, $cover, 1, 0)
						SplashOff()
						GUICtrlSetImage($Pic_cover, $cover)
					EndIf
				ElseIf $ans = 7 Then
					$cover = $datafold & "\" & $ID & "\" & $ID & "_image.png"
					If FileExists($cover) Then
						FileDelete($cover)
					Else
						$gamedata = $datafold & "\" & $ID
						If Not FileExists($gamedata) Then
							DirCreate($gamedata)
						EndIf
					EndIf
					$image = IniRead($gameinfo, $ID, "cover", "")
					If $image <> "" Then
						SplashTextOn("", "Downloading Cover!", 200, 120, Default, Default, 33)
						InetGet($image, $cover, 1, 0)
						;Local $loop = 0
						;While 1
						;	$success = InetGet($image, $cover, 1, 1)
						;	Do
						;		Sleep(250)
						;	Until InetGetInfo($success, $INET_DOWNLOADCOMPLETE)
						;	If InetGetInfo($success, $INET_DOWNLOADERROR) = 0 Then ExitLoop
						;	$loop = $loop + 1
						;	If $loop = 5 Then ExitLoop
						;WEnd
						SplashOff()
					EndIf
				EndIf
			EndIf
		EndIf
	Case $msg = $Button_ontop
		; Toggle the program window on top setting
		If GUICtrlRead($Button_ontop) = $GUI_CHECKED Then
			$ontop = 1
			WinSetOnTop($GameInfoGUI, "", 1)
		Else
			$ontop = 4
			WinSetOnTop($GameInfoGUI, "", 0)
		EndIf
		IniWrite($inifle, "Main Window", "ontop", $ontop)
	Case $msg = $Button_move
		; Move program window
		If GUICtrlRead($Button_move) = "Move" Then
			GUICtrlSetData($Button_move, "Back")
			GUICtrlSetImage($Button_move, $shell, -147, 1)
			WinMove($GameInfoGUI, "", @DesktopWidth - ($width + 30), Default)
			GUICtrlSetTip($Button_move, "Move program window to left!")
		Else
			GUICtrlSetData($Button_move, "Move")
			GUICtrlSetImage($Button_move, $shell, -138, 1)
			WinMove($GameInfoGUI, "", 10, Default)
			GUICtrlSetTip($Button_move, "Move program window to right!")
		EndIf
	Case $msg = $Button_info
		; Program Information
		;$ans = MsgBox(262209 + 256, "Program Information", _
		$ans = MsgBox(262211 + 512, "Program Information", _
			"Select a list entry to see details for that game title." & @LF & @LF & _
			"Click the ADD button to add a new entry, via the Game" & @LF & _
			"ID you provide, or to update the currently selected one." & @LF & _
			"NOTE - A web connection is required for ADD to work." & @LF & @LF & _
			"Alternatively, you can search for a Game ID using a full" & @LF & _
			"or partial title, and then choose one returned entry." & @LF & @LF & _
			"Another method, is to provide the URL for a GOG game" & @LF & _
			"page. The URL field must be empty first, then click GO." & @LF & @LF & _
			"Click the cover image to see a large widescreen image" & @LF & _
			"with your default image file viewer. NOTE - During the" & @LF & _
			"ADD process two image files are downloaded (Box Art" & @LF & _
			"& Widescreen), and stored in a 'Data' sub-folder." & @LF & @LF & _
			"In 'Program Settings' you can elect to have a manifest" & @LF & _
			"file created, suitable for using with gogcli.exe and my" & @LF & _
			"GOGcli GUI program. NOTE - To get the required file" & @LF & _
			"names and checksums etc, gogcli.exe and Cookie.txt" & @LF & _
			"files need to be in the 'GetGameInfo' program folder." & @LF & @LF & _
			"© March 2022 - created by Timboli." & @LF & _
			"(" & $update & " update " & $updated & ")" & @LF & @LF & _
			"YES = Program Settings." & @LF & _
			"NO = Open the program folder.", 0, $GameInfoGUI)
		;	"OK = Open the program folder.", 0, $GameInfoGUI)
		;If $ans = 1 Then ShellExecute(@ScriptDir)
		If $ans = 6 Then
			SettingsGUI()
		ElseIf $ans = 7 Then
			ShellExecute(@ScriptDir)
		EndIf
	Case $msg = $Button_get
		; Get Game ID via Title
		$game = GUICtrlRead($Input_get)
		If $game <> "" Then
			;$game = StringReplace($game, " ", "")
			SplashTextOn("", "Getting ID(s)!", 200, 120, Default, Default, 33)
			GUICtrlSetState($Button_add, $GUI_DISABLE)
			GUICtrlSetState($Button_runurl, $GUI_DISABLE)
			GUICtrlSetState($Button_move, $GUI_DISABLE)
			GUICtrlSetState($Button_replace, $GUI_DISABLE)
			GUICtrlSetState($List_games, $GUI_DISABLE)
			GUICtrlSetState($Button_get, $GUI_DISABLE)
			GUICtrlSetState($Button_info, $GUI_DISABLE)
			GUICtrlSetState($Button_exit, $GUI_DISABLE)
			If $minimize = 1 Then GUISetState(@SW_MINIMIZE, $GameInfoGUI)
			If $game <> $last Then
				$idlink = "https://embed.gog.com/games/ajax/filtered?mediaType=game&search=" & $game
				$html = _INetGetSource($idlink)
				If $html = "" Then
					$names = ""
					$last = ""
				Else
					$htmltxt = @ScriptDir & "\Html.txt"
					_FileCreate($htmltxt)
					FileWrite($htmltxt, $html)
					;
					$last = $game
					$names = ""
					$entries = StringSplit($html, ',"id":', 1)
					For $e = 2 To $entries[0]
						$entry = $entries[$e]
						$GID = StringSplit($entry, ',', 1)
						;$entry = $GID[2]
						$GID = $GID[1]
						$name = StringSplit($entry, '"title":', 1)
						If $name[0] > 1 Then
							$name = $name[2]
							$name = StringSplit($name, '",', 1)
							$name = $name[1]
							$name = StringReplace($name, '"', '')
							$name = StringStripWS($name, 3)
							If $name <> "" Then
								$name = $GID & " - " & $name
								If $names = "" Then
									$names = $name
								Else
									$names = $names & "|" & $name
								EndIf
							EndIf
						EndIf
					Next
					;$entries = $entries[0] - 1
					;MsgBox(262192, "IDs Found", $entries, 0, $GameInfoGUI)
				EndIf
			EndIf
			If $names <> "" Then
				IDResultsGUI()
				If $ID <> "" Then
					$reload = ""
					_FileWriteLog($logfle, "ADDED = " & $title, -1)
					GetGameDetail()
					If $ID <> "" Then
						If $title <> "" Then
							FileWriteLine($logfle, "")
							If $reload = 1 Then
								GUICtrlSetData($List_games, "")
								LoadTheList()
								$ind = _GUICtrlListBox_FindString($List_games, $title, True)
								_GUICtrlListBox_SetCurSel($List_games, $ind)
							Else
								$ind = _GUICtrlListBox_GetCurSel($List_games)
							EndIf
							If $ind > -1 Then
								If $minimize = 1 Then
									GUISetState(@SW_SHOWMINIMIZED, $GameInfoGUI)
								Else
									GUISetState(@SW_SHOWNORMAL, $GameInfoGUI)
								EndIf
								_GUICtrlListBox_ClickItem($List_games, $ind, "left", False, 1, 0)
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				MsgBox(262192, "ID Error", "No Results!", 0, $GameInfoGUI)
			EndIf
			If $minimize = 1 And $show = 4 Then GUISetState(@SW_RESTORE, $GameInfoGUI)
			GUICtrlSetState($Button_add, $GUI_ENABLE)
			GUICtrlSetState($Button_runurl, $GUI_ENABLE)
			GUICtrlSetState($Button_move, $GUI_ENABLE)
			GUICtrlSetState($Button_replace, $GUI_ENABLE)
			GUICtrlSetState($List_games, $GUI_ENABLE)
			GUICtrlSetState($Button_get, $GUI_ENABLE)
			GUICtrlSetState($Button_info, $GUI_ENABLE)
			GUICtrlSetState($Button_exit, $GUI_ENABLE)
			SplashOff()
		EndIf
	Case $msg = $Button_add
		; ADD a game
		$ID = GUICtrlRead($Input_ID)
		GUICtrlSetState($Button_add, $GUI_DISABLE)
		GUICtrlSetState($Button_runurl, $GUI_DISABLE)
		GUICtrlSetState($Button_move, $GUI_DISABLE)
		GUICtrlSetState($Button_replace, $GUI_DISABLE)
		GUICtrlSetState($List_games, $GUI_DISABLE)
		GUICtrlSetState($Button_get, $GUI_DISABLE)
		GUICtrlSetState($Button_info, $GUI_DISABLE)
		GUICtrlSetState($Button_exit, $GUI_DISABLE)
		If GUICtrlRead($Button_add) = "ADD" Then
			$reload = ""
			If $minimize = 1 Then GUISetState(@SW_MINIMIZE, $GameInfoGUI)
			_FileWriteLog($logfle, "ADDED = " & $title, -1)
			AddSomeGame()
			If $ID <> "" Then
				If $title <> "" Then
					FileWriteLine($logfle, "")
					If $reload = 1 Then
						GUICtrlSetData($List_games, "")
						LoadTheList()
						$ind = _GUICtrlListBox_FindString($List_games, $title, True)
						_GUICtrlListBox_SetCurSel($List_games, $ind)
					Else
						$ind = _GUICtrlListBox_GetCurSel($List_games)
					EndIf
					If $ind > -1 Then
						If $minimize = 1 Then
							GUISetState(@SW_SHOWMINIMIZED, $GameInfoGUI)
						Else
							GUISetState(@SW_SHOWNORMAL, $GameInfoGUI)
						EndIf
						_GUICtrlListBox_ClickItem($List_games, $ind, "left", False, 1, 0)
					EndIf
				EndIf
			EndIf
			If $minimize = 1 And $show = 4 Then GUISetState(@SW_RESTORE, $GameInfoGUI)
		ElseIf GUICtrlRead($Button_add) = "CUT" Then
			$title = GUICtrlRead($Input_gametit)
			If $title <> "" Then
				$ans = MsgBox(262177 + 256, "Removal Query", _
					"Remove the selected game & related files?" & @LF & @LF & _
					"OK = Remove them." & @LF & _
					"CANCEL = Abort any removal.", 0, $GameInfoGUI)
				If $ans = 1 Then
					$ind = _GUICtrlListBox_GetCurSel($List_games)
					GUICtrlSetData($List_games, "")
					GUICtrlSetData($Input_gametit, "")
					GUICtrlSetData($Input_ID, "")
					GUICtrlSetData($Input_weburl, "")
					GUICtrlSetData($Input_price, "")
					GUICtrlSetData($Input_size, "")
					GUICtrlSetData($Edit_sumry, "")
					GUICtrlSetData($Input_date, "")
					GUICtrlSetData($Input_devs, "")
					GUICtrlSetData($Input_genre, "")
					GUICtrlSetData($Input_type, "")
					GUICtrlSetData($Edit_reqs, "")
					GUICtrlSetData($Input_OS, "")
					GUICtrlSetData($Input_imgurl, "")
					GUICtrlSetImage($Pic_cover, $defimage)
					IniDelete($titfile, $title)
					$gameinfo = $datafold & "\" & $ID & "\" & $ID & ".txt"
					If FileExists($gameinfo) Then
						$slug = IniRead($gameinfo, $ID, "slug", "")
						If $slug <> "" Then
							$manifest = $manfold & "\" & $slug & "_manifest.txt"
							FileDelete($manifest)
						EndIf
					;Else
					;	$gamedata = $datafold & "\" & $ID
					;	If Not FileExists($gamedata) Then
					;		DirCreate($gamedata)
					;	EndIf
					EndIf
					;FileDelete($datafold & "\" & $ID & "\" & $ID & "*.*")
					DirRemove($datafold & "\" & $ID, 1)
					_FileWriteLog($logfle, "REMOVED = " & $title, -1)
					FileWriteLine($logfle, "")
					LoadTheList()
					$ind = $ind - 1
					_GUICtrlListBox_SetCurSel($List_games, $ind)
					GUICtrlSetState($List_games, $GUI_FOCUS)
					_GUICtrlListBox_ClickItem($List_games, $ind, "left", False, 1, 0)
				EndIf
			Else
				MsgBox(262192, "Selection Error", "Nothing to remove!", 0, $GameInfoGUI)
			EndIf
		EndIf
		GUICtrlSetState($Button_add, $GUI_ENABLE)
		GUICtrlSetState($Button_runurl, $GUI_ENABLE)
		GUICtrlSetState($Button_move, $GUI_ENABLE)
		GUICtrlSetState($Button_replace, $GUI_ENABLE)
		GUICtrlSetState($List_games, $GUI_ENABLE)
		GUICtrlSetState($Button_get, $GUI_ENABLE)
		GUICtrlSetState($Button_info, $GUI_ENABLE)
		GUICtrlSetState($Button_exit, $GUI_ENABLE)
		GUICtrlSetState($List_games, $GUI_FOCUS)
	Case $msg = $Checkbox_remove
		; Enable removal
		If GUICtrlRead($Checkbox_remove) = $GUI_CHECKED Then
			GUICtrlSetData($Button_add, "CUT")
			GUICtrlSetTip($Button_add, "Remove selected game from list!")
		Else
			GUICtrlSetData($Button_add, "ADD")
			GUICtrlSetTip($Button_add, "ADD a game or Update selected!")
		EndIf
	Case $msg = $List_games
		; List of games with details
		$ID = ""
		$URL = ""
		$price = ""
		$total = ""
		$description = ""
		$release = ""
		$publisher = ""
		$developer = ""
		$entry = ""
		$genre = ""
		$playtype = ""
		$requires = ""
		$supported = ""
		$image = ""
		$cover = ""
		$title = GUICtrlRead($List_games)
		If $title <> "" Then
			$ID = IniRead($titfile, $title, "id", "")
			If $ID <> "" Then
				;IniRead($titfile, $title, "date", $date)
				$gameinfo = $datafold & "\" & $ID & "\" & $ID & ".txt"
				If FileExists($gameinfo) Then
					;IniRead($gameinfo, $ID, "slug", $slug)
					$URL = IniRead($gameinfo, $ID, "url", "")
					$price = IniRead($gameinfo, $ID, "price", "")
					;IniRead($gameinfo, $ID, "bytes", $bytes)
					$total = IniRead($gameinfo, $ID, "size", "")
					$description = IniRead($gameinfo, $ID, "description", "")
					$description = StringReplace($description, "|", @CRLF)
					$release = IniRead($gameinfo, $ID, "released", "")
					;IniRead($gameinfo, $ID, "os", $OS)
					;GUICtrlSetData($Input_OS, $OS)
					$publisher = IniRead($gameinfo, $ID, "publisher", "")
					$developer = IniRead($gameinfo, $ID, "developer", "")
					$entry = $publisher & " / " & $developer
					$genre = IniRead($gameinfo, $ID, "genre", "")
					$playtype = IniRead($gameinfo, $ID, "playtype", "")
					$requires = ""
					$sys = "windows"
					While 1
						$system = IniRead($gameinfo, $ID, $sys, "")
						If $system <> "" Then
							If $requires = "" Then
								$requires = $system
							Else
								$requires = $requires & @CRLF & $system
							EndIf
						EndIf
						If $sys = "windows" Then
							$sys = "osx"
						ElseIf $sys = "osx" Then
							$sys = "mac"
						ElseIf $sys = "mac" Then
							$sys = "linux"
						ElseIf $sys = "linux" Then
							ExitLoop
						EndIf
					WEnd
					$requires = StringReplace($requires, "|", @CRLF)
					$supported = IniRead($gameinfo, $ID, "supported", "")
					;IniRead($gameinfo, $ID, "boxart", $boxart)
					$image = IniRead($gameinfo, $ID, "cover", "")
					$cover = $datafold & "\" & $ID & "\" & $ID & "_cover.jpg"
					If Not FileExists($cover) Then
						$cover = ""
					EndIf
				EndIf
			EndIf
		EndIf
		GUICtrlSetData($Input_gametit, $title)
		GUICtrlSetData($Input_ID, $ID)
		GUICtrlSetData($Input_weburl, $URL)
		GUICtrlSetData($Input_price, $price)
		GUICtrlSetData($Input_size, $total)
		GUICtrlSetData($Edit_sumry, $description)
		GUICtrlSetData($Input_date, $release)
		GUICtrlSetData($Input_devs, $entry)
		GUICtrlSetData($Input_genre, $genre)
		GUICtrlSetData($Input_type, $playtype)
		GUICtrlSetData($Edit_reqs, $requires)
		GUICtrlSetData($Input_OS, $supported)
		GUICtrlSetData($Input_imgurl, $image)
		If $cover = "" Then
			GUICtrlSetImage($Pic_cover, $defimage)
		Else
			GUICtrlSetImage($Pic_cover, $cover)
		EndIf
	Case $msg = $Pic_cover
		; Click to see full image.
		$ID = GUICtrlRead($Input_ID)
		If $ID <> "" Then
			$cover = $datafold & "\" & $ID & "\" & $ID & "_image.png"
			If FileExists($cover) Then
				ShellExecute($cover)
				GUISetState(@SW_MINIMIZE, $GameInfoGUI)
				SplashTextOn("", "Program Minimized!", 200, 120, Default, Default, 33)
				Sleep(750)
				SplashOff()
				;
				; WARNING - PNG images not supported.
				;
;~ 				GUICtrlSetState($Pic_cover, $GUI_DISABLE)
;~ 				_GDIPlus_Startup()
;~ 				$handle = _GDIPlus_ImageLoadFromFile($cover)
;~ 				$wide = _GDIPlus_ImageGetWidth($handle)
;~ 				$high = _GDIPlus_ImageGetHeight($handle)
;~ 				_GDIPlus_ImageDispose($handle)
;~ 				_GDIPlus_ShutDown()
;~ 				;MsgBox(262192, "$wide $high", $wide & " x " & $high, 0, $GameInfoGUI)
;~ 				SplashImageOn("", $cover, $wide, $high, Default, Default, 17)
;~ 				Sleep(300)
;~ 				$mpos = MouseGetPos()
;~ 				$xpos = $mpos[0]
;~ 				$ypos = $mpos[1]
;~ 				Sleep(300)
;~ 				$dll = DllOpen("user32.dll")
;~ 				While 1
;~ 					$mpos = MouseGetPos()
;~ 					If $mpos[0] > $xpos + 40 Or $mpos[0] < $xpos - 40 Then ExitLoop
;~ 					If $mpos[1] > $ypos + 40 Or $mpos[1] < $ypos - 40 Then ExitLoop
;~ 					If _IsPressed("01", $dll) Then ExitLoop
;~ 					Sleep(300)
;~ 				WEnd
;~ 				DllClose($dll)
;~ 				SplashOff()
;~ 				GUICtrlSetState($Pic_cover, $GUI_ENABLE)
;~ 				;GUICtrlSetState($Edit_comms, $GUI_FOCUS)
;~ 				;_GUICtrlEdit_Scroll($Edit_comms, $SB_LINEUP)
;~ 				;GUICtrlSetState($Edit_comms, $GUI_FOCUS)
			Else
				MsgBox(262192, "View Error", "No image file found!", 2, $GameInfoGUI)
			EndIf
		Else
			MsgBox(262192, "View Error", "No entry selected!", 2, $GameInfoGUI)
		EndIf
	Case $msg = $Item_list_manifest
		; View Manifest
		$title = GUICtrlRead($Input_gametit)
		If $title <> "" Then
			$ID = GUICtrlRead($Input_ID)
			$gameinfo = $datafold & "\" & $ID & "\" & $ID & ".txt"
			If FileExists($gameinfo) Then
				$slug = IniRead($gameinfo, $ID, "slug", "")
				If $slug <> "" Then
					$manifest = $manfold & "\" & $slug & "_manifest.txt"
					If FileExists($manifest) Then
						If $editor = "none" Then
							ShellExecute($manifest)
						Else
							Run($editor & ' "' & $manifest & '"')
						EndIf
					Else
						MsgBox(262192, "File Error", "No manifest file found for selected game!", 2, $GameInfoGUI)
					EndIf
				Else
					MsgBox(262192, "Slug Error", "No slug title found for selected game!", 2, $GameInfoGUI)
				EndIf
			Else
				MsgBox(262192, "File Error", "No game info file found for selected entry!", 2, $GameInfoGUI)
			EndIf
		Else
			MsgBox(262192, "View Error", "No entry selected!", 2, $GameInfoGUI)
		EndIf
	Case $msg = $Item_list_datafold
		; Open Data Folder
		$title = GUICtrlRead($Input_gametit)
		If $title <> "" Then
			$ID = GUICtrlRead($Input_ID)
			$gamedata = $datafold & "\" & $ID
			If FileExists($gamedata) Then
				ShellExecute($gamedata)
			Else
				MsgBox(262192, "Open Error", "Folder does not exist!", 2, $GameInfoGUI)
			EndIf
		Else
			MsgBox(262192, "View Error", "No entry selected!", 2, $GameInfoGUI)
		EndIf
	Case Else
		;;;
	EndSelect
WEnd

Exit


Func IDResultsGUI()
	Local $Button_close, $Combo_gameid, $Group_gameid, $Label_advice
	;
	$ResultsGUI = GuiCreate("ID Results", 500, 75, Default, Default, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
								+ $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX, $WS_EX_TOPMOST, $GameInfoGUI)
	; CONTROLS
	$Group_gameid = GuiCtrlCreateGroup("Game Title && ID", 10, 10, 420, 55)
	$Label_advice = GUICtrlCreateLabel("Select An Entry", 200, 5, 100, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetFont($Label_advice, 8, 600, 0, "Small Fonts")
	GUICtrlSetBkColor($Label_advice, $COLOR_RED)
	GUICtrlSetColor($Label_advice, $COLOR_YELLOW)
	$Combo_gameid = GUICtrlCreateCombo("", 20, 30, 400, 20)
	GUICtrlSetTip($Combo_gameid, "Select the Title & ID to use!")
	;
	$Button_close = GuiCtrlCreateButton("EXIT", 440, 15, 50, 50, $BS_ICON)
	GUICtrlSetTip($Button_close, "Quit, Close or Exit window!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_close, $shell, $icoX, 1)
	;
	GUICtrlSetData($Combo_gameid, $names, "")

	GuiSetState()
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_close
			; Quit, Close or Exit window
			$ID = ""
			GUIDelete($ResultsGUI)
			ExitLoop
		Case $msg = $Combo_gameid
			; Select the Title & ID to use
			$ID = GUICtrlRead($Combo_gameid)
			$ID = StringSplit($ID, " - ", 1)
			$ID = $ID[1]
			GUIDelete($ResultsGUI)
			ExitLoop
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> IDResultsGUI

Func SettingsGUI()
	Local $Button_log, $Button_path, $Checkbox_hide, $Checkbox_man, $Checkbox_min, $Checkbox_show, $Checkbox_skip
	Local $Input_code, $Input_path, $Label_code, $Label_path
	;
	$OptionsGUI = GuiCreate("Program Settings", 360, 125, Default, Default, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
														+ $WS_VISIBLE + $WS_CLIPSIBLINGS, $WS_EX_TOPMOST, $GameInfoGUI)
	; CONTROLS
	$Label_code = GUICtrlCreateLabel("Country Code", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_code, $COLOR_GREEN)
	GUICtrlSetColor($Label_code, $COLOR_YELLOW)
	$Input_code = GUICtrlCreateInput("", 90, 10, 35, 20)
	GUICtrlSetTip($Input_code, "Country Code to use!")
	;
	$Checkbox_skip = GUICtrlCreateCheckbox("Skip the ID query at startup", 135, 10, 150, 20)
	GUICtrlSetTip($Checkbox_skip, "Skip the ID query at startup!")
	;
	$Checkbox_man = GUICtrlCreateCheckbox("Create a manifest file", 10, 40, 120, 20)
	GUICtrlSetTip($Checkbox_man, "Create a manifest file!")
	$Checkbox_show = GUICtrlCreateCheckbox("Show the manifest file after", 135, 40, 145, 20)
	GUICtrlSetTip($Checkbox_show, "Show the manifest file after creation!")
	;
	$Button_log = GuiCtrlCreateButton("LOG", 295, 10, 55, 50)
	GUICtrlSetFont($Button_log, 9, 600)
	GUICtrlSetTip($Button_log, "View the Log file!")
	;
	$Checkbox_min = GUICtrlCreateCheckbox("Minimize program window on ADD", 10, 68, 180, 20)
	GUICtrlSetTip($Checkbox_min, "Minimize the program window on ADD!")
	;
	$Checkbox_hide = GUICtrlCreateCheckbox("Hide DOS console windows", 200, 68, 160, 20, $BS_AUTO3STATE)
	GUICtrlSetTip($Checkbox_hide, "Hide each DOS console window during ADD!")
	;
	$Label_path = GUICtrlCreateLabel("Editor", 10, 95, 45, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_path, $COLOR_BLUE)
	GUICtrlSetColor($Label_path, $COLOR_YELLOW)
	$Input_path = GUICtrlCreateInput("", 55, 95, 270, 20)
	GUICtrlSetTip($Input_path, "Path of Editor to use!")
	$Button_path = GuiCtrlCreateButton("B", 330, 95, 20, 20, $BS_ICON)
	GUICtrlSetTip($Button_path, "Browse to set the Editor path!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_path, $shell, $icoF, 0)
	;
	GUICtrlSetData($Input_code, $cc)
	;
	GUICtrlSetState($Checkbox_skip, $skip)
	;
	GUICtrlSetState($Checkbox_man, $create)
	GUICtrlSetState($Checkbox_show, $show)
	If $create = 4 Then
		GUICtrlSetState($Checkbox_show, $GUI_DISABLE)
	EndIf
	;
	GUICtrlSetState($Checkbox_min, $minimize)
	GUICtrlSetState($Checkbox_hide, $hide)
	;
	If $editor <> "none" Then
		GUICtrlSetData($Input_path, $editor)
	EndIf

	GuiSetState()
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE
			; Quit, Close or Exit window
			$cc = GUICtrlRead($Input_code)
			If $cc <> "" Then
				IniWrite($inifle, "Price Query", "country_code", $cc)
			EndIf
			GUIDelete($OptionsGUI)
			ExitLoop
		Case $msg = $Button_path
			; Browse to set the Editor path
			If $editor = "none" Then
				$pth = ""
			Else
				$pth = $editor
			EndIf
			$pth = FileOpenDialog("Browse to set the Editor path.", @ProgramFilesDir, "Program files (*.exe)", 3, $pth, $OptionsGUI)
			If @error = 0 And StringMid($pth, 2, 2) = ":\" Then
				$editor = $pth
				IniWrite($inifle, "Editor", "path", $editor)
				GUICtrlSetData($Input_path, $editor)
			EndIf
		Case $msg = $Button_log
			; View the Log file
			If FileExists($logfle) Then ShellExecute($logfle)
		Case $msg = $Checkbox_skip
			; Skip the ID query at startup
			If GUICtrlRead($Checkbox_skip) = $GUI_CHECKED Then
				$skip = 1
			Else
				$skip = 4
			EndIf
			IniWrite($inifle, "Query ID At Startup", "skip", $skip)
		Case $msg = $Checkbox_show
			; Show the manifest file after creation
			If GUICtrlRead($Checkbox_show) = $GUI_CHECKED Then
				$show = 1
			Else
				$show = 4
			EndIf
			IniWrite($inifle, "Manifest Entry", "show", $show)
		Case $msg = $Checkbox_min
			; Minimize the program window on ADD
			If GUICtrlRead($Checkbox_min) = $GUI_CHECKED Then
				$minimize = 1
			Else
				$minimize = 4
			EndIf
			IniWrite($inifle, "Main Window On ADD", "minimize", $minimize)
		Case $msg = $Checkbox_man
			; Create a manifest file
			If GUICtrlRead($Checkbox_man) = $GUI_CHECKED Then
				$create = 1
				GUICtrlSetState($Checkbox_show, $GUI_ENABLE)
			Else
				$create = 4
				GUICtrlSetState($Checkbox_show, $GUI_DISABLE)
			EndIf
			IniWrite($inifle, "Manifest Entry", "create", $create)
		Case $msg = $Checkbox_hide
			; Hide each DOS console window during ADD
			;If GUICtrlRead($Checkbox_hide) = $GUI_CHECKED Then
			;	$hide = 1
			;ElseIf GUICtrlRead($Checkbox_hide) = $GUI_UNCHECKED Then
			;	$hide = 4
			;Else
			;	$hide = 2
			;EndIf
			$hide = GUICtrlRead($Checkbox_hide)
			IniWrite($inifle, "Console Window On ADD", "hide", $hide)
			;MsgBox(262192, "Checkbox State", $hide, 0, $OptionsGUI)
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> SettingsGUI


Func AddSomeGame()
	$ID = InputBox("Get Game Info", "Enter a GOG Game ID (to ADD it), or" & @LF & "to Update the selected (shown) entry," & @LF & "or just click CANCEL to see the Viewer." & @LF _
		& @LF & "NOTE - ADD requires a web connection.", $ID, "", 230, 180, Default, Default, 0, $GameInfoGUI)
	If @error > 0 Or StringIsDigit($ID) = 0 Then
		$ID = ""
		Return
	Else
		GetGameDetail()
	EndIf
EndFunc ;=> AddSomeGame

Func FixAllText($text)
	$text = FixText($text)
	$text = RemoveHtml($text)
	Return $text
EndFunc ;=> FixAllText

Func FixText($text)
	$text = StringReplace($text, '{"id":', 'ID = ')
	$text = StringReplace($text, '\u010desk\u00fd', 'czech')
	$text = StringReplace($text, 'T\u00fcrkce', 'turkish')
	$text = StringReplace($text, 'portugu\u00eas', 'portuguese')
	$text = StringReplace($text, '\u4e2d\u6587(\u7b80\u4f53)', 'chinese')
	$text = StringReplace($text, '\u65e5\u672c\u8a9e', 'japanese')
	$text = StringReplace($text, '\ud55c\uad6d\uc5b4', 'korean')
	$text = FixUnicode($text)
	$text = StringReplace($text, '{"lead":', '')
	$text = StringReplace($text, '[],"', '"' & @CRLF)
	$text = StringReplace($text, '[],', @CRLF)
	$text = StringReplace($text, '":"', ' = ')
	$text = StringReplace($text, '":{"', @CRLF)
	$text = StringReplace($text, '":', ' = ')
	$text = StringReplace($text, '","', @CRLF)
	$text = StringReplace($text, '"},"', @CRLF)
	$text = StringReplace($text, '},"', @CRLF)
	$text = StringReplace($text, ',"', @CRLF)
	$text = StringReplace($text, '\/\/', '//')
	$text = StringReplace($text, '\/', '/')
	$text = StringReplace($text, '"}}', '')
	$text = StringReplace($text, '"}', '')
	$text = StringReplace($text, '\n', @CRLF)
	$text = StringReplace($text, ']},{"', @CRLF)
	$text = StringReplace($text, ',{"', @CRLF)
	$text = StringReplace($text, ' = [{"', @CRLF)
	$text = StringReplace($text, ' = [', @CRLF)
	$text = StringReplace($text, ']}]', '')
	$text = StringReplace($text, '}}]', '')
	$text = StringReplace($text, ']},', @CRLF)
	$text = StringReplace($text, ' = "', ' = ')
	$text = StringReplace($text, ',ID = ', @CRLF & 'ID = ')
	$text = StringReplace($text, 'youtube]', 'youtube')
	$text = StringReplace($text, 'null}', 'null')
	$text = StringReplace($text, '-amp;', '&')
	$text = StringReplace($text, '-quot;', '"')
	$text = StringReplace($text, '%2C', ',')
	$text = StringReplace($text, '   /', '')
	$text = StringReplace($text, ']' & @CRLF, @CRLF)
	$text = StringReplace($text, "<br><br>", @CRLF)
	$text = StringReplace($text, "<br>", @CRLF)
	;$text = StringStripWS($text, 4)
	Return $text
EndFunc ;=> FixText

Func FixUnicode($text)
	Local $chunk, $hextxt, $split, $string
	$split = StringSplit($text, "\u", 1)
	$text = $split[1]
	For $s = 2 To $split[0]
		$chunk = $split[$s]
		$string = StringMid($chunk, 5)
		$hextxt = StringLeft($chunk, 4)
		$val = Dec($hextxt)
		$val = ChrW($val)
		$text = $text & $val & $string
	Next
	Return $text
EndFunc ;=> FixUnicode

Func GetGameDetail()
	Local $bakfile, $errors, $flag, $logerr, $timestamp
	$gameinfo = $datafold & "\" & $ID & "\" & $ID & ".txt"
	$ping = Ping("gog.com", 4000)
	If $ping > 0 Then
		SplashTextOn("", "Downloading Data!", 200, 120, Default, Default, 33)
		$idlink = "https://api.gog.com/products/" & $ID & "?expand=downloads,description"
		InetGet($idlink, $downone, 1, 0)
		$installers = ""
		$read = FileRead($downone)
		If $read <> "" Then
			; TITLE
			$title = StringSplit($read, '"title":', 1)
			If $title[0] > 1 Then
				$title = $title[2]
				$title = StringSplit($title, '",', 1)
				$title = $title[1]
				$title = StringReplace($title, '"', '')
				$title = FixUnicode($title)
				IniWrite($gameinfo, $ID, "title", $title)
				$entry = IniRead($titfile, $title, "date", "")
				If $entry = "" Then
					IniWrite($titfile, $title, "title", $title)
					IniWrite($titfile, $title, "id", $ID)
					$date = _Now()
					IniWrite($titfile, $title, "date", $date)
					$reload = 1
				EndIf
				; SLUG
				$slug = StringSplit($read, '"slug":', 1)
				If $slug[0] > 1 Then
					$slug = $slug[2]
					$slug = StringSplit($slug, '",', 1)
					$slug = $slug[1]
					$slug = StringReplace($slug, '"', '')
					IniWrite($gameinfo, $ID, "slug", $slug)
					; WEB URL
					$URL = StringSplit($read, '"product_card":', 1)
					If $URL[0] > 1 Then
						$URL = $URL[2]
						$URL = StringSplit($URL, ',', 1)
						$URL = $URL[1]
						$URL = StringReplace($URL, "\/", "/")
						$URL = StringReplace($URL, '"', '')
						IniWrite($gameinfo, $ID, "url", $URL)
					EndIf
					; TOTAL SIZE
					$bytes = StringSplit($read, '"total_size":', 1)
					If $bytes[0] > 1 Then
						$bytes = $bytes[2]
						$bytes = StringSplit($bytes, ',', 1)
						$bytes = $bytes[1]
						IniWrite($gameinfo, $ID, "bytes", $bytes)
						If $bytes < 1024 Then
							$total = $bytes & " bytes"
						ElseIf $bytes < 1048576 Then
							$total = Round($bytes / 1024, 0) & " Kb"
						ElseIf $bytes < 1073741824 Then
							$total = Round($bytes / 1048576, 0) & " Mb"
						ElseIf $bytes < 1099511627776 Then
							$total = Round($bytes / 1073741824, 2) & " Gb"
						Else
							$total = Round($bytes / 1099511627776, 3) & " Tb"
						EndIf
						IniWrite($gameinfo, $ID, "size", $total)
					EndIf
					If $create = 1 Then
						$installers = StringSplit($read, '"downloads":', 1)
						If $installers[0] > 1 Then
							$installers = $installers[2]
							$installers = StringSplit($installers, '"description":', 1)
							$installers = $installers[1]
							$extras = StringSplit($installers, '"bonus_content":', 1)
							If $extras[0] > 1 Then
								$installers = $extras[1]
								$extras = $extras[2]
							Else
								$extras = ""
							EndIf
						EndIf
					EndIf
					; DESCRIPTION
					$fixed = FixAllText($read)
					$head = StringSplit($fixed, '"description":', 1)
					$tail = $head[$head[0]]
					$tail = StringSplit($tail, "description = ", 1)
					$tail = $tail[$tail[0]]
					$description = StringStripWS($tail, 3)
					$description = StringReplace($description, @CRLF, "|")
					$description = StringReplace($description, "full = |", "full = ")
					IniWrite($gameinfo, $ID, "description", $description)
					; RELEASE DATE
					$release = StringSplit($read, '"release_date":"', 1)
					If $release[0] > 1 Then
						$release = $release[2]
						$release = StringSplit($release, '",', 1)
						$release = $release[1]
						$release = StringLeft($release, 10)
						IniWrite($gameinfo, $ID, "released", $release)
					Else
						$release = ""
					EndIf
					; Also need to extract OS types and versions
					; "content_system_compatibility":{"windows":true,"osx":true,"linux":false},"
					; OS VERSIONS
					$OS = ""
					$systems = StringSplit($read, '"content_system_compatibility":{', 1)
					If $systems[0] > 1 Then
						$systems = $systems[2]
						$systems = StringSplit($systems, '},', 1)
						$systems = $systems[1]
						$systems = StringSplit($systems, ',', 1)
						For $s = 1 To $systems[0]
							$system = $systems[$s]
							$system = StringSplit($system, ":", 1)
							$status = $system[2]
							If $status = "true" Then
								$system = $system[1]
								$system = StringReplace($system, '"', '')
								If $OS = "" Then
									$OS = $system
								Else
									$OS = $OS & ", " & $system
								EndIf
							EndIf
						Next
						IniWrite($gameinfo, $ID, "os", $OS)
					EndIf
					; GAME TYPE
					$type = StringSplit($read, '"game_type":', 1)
					If $type[0] > 1 Then
						$type = $type[2]
						$type = StringSplit($type, ',', 1)
						$type = $type[1]
						$type = StringReplace($type, '"', '')
						IniWrite($gameinfo, $ID, "type", $type)
					Else
						$type = ""
					EndIf
				Else
					MsgBox(262192, "Data Error", "Slug not found!", 0, $GameInfoGUI)
				EndIf
			Else
				MsgBox(262192, "Data Error", "Title not found!", 0, $GameInfoGUI)
			EndIf
		Else
			MsgBox(262192, "Download Error", "No data retrieved!", 0, $GameInfoGUI)
		EndIf
		SplashTextOn("", "Downloading More!", 200, 120, Default, Default, 33)
		$idlink = "https://api.gog.com/v2/games/" & $ID & "?locale=en-US"
		InetGet($idlink, $downtwo, 1, 0)
		$read = FileRead($downtwo)
		If $read <> "" Then
			; PUBLISHER
			$publisher = StringSplit($read, '"publisher":', 1)
			If $publisher[0] > 1 Then
				$publisher = $publisher[2]
				$publisher = StringSplit($publisher, '},', 1)
				$publisher = $publisher[1]
				$publisher = StringSplit($publisher, '"name":', 1)
				If $publisher[0] > 1 Then
					$publisher = $publisher[2]
					$publisher = StringReplace($publisher, "\/", "/")
					;MsgBox(262192, "$publisher", $publisher, 0, $GameInfoGUI)
					$publisher = StringReplace($publisher, '"', '')
					IniWrite($gameinfo, $ID, "publisher", $publisher)
					; DEVELOPERS
					$devs = StringSplit($read, '"developers":', 1)
					If $devs[0] > 1 Then
						$devs = $devs[2]
						$devs = StringSplit($devs, '],', 1)
						$devs = $devs[1]
						$developer = ""
						$devs = StringSplit($devs, '"name":"', 1)
						For $d = 2 To $devs[0]
							$dev = $devs[$d]
							$dev = StringSplit($dev, '"', 1)
							$dev = $dev[1]
							If $dev <> "" Then
								If $developer = "" Then
									$developer = $dev
								Else
									$developer = $developer & ", " & $dev
								EndIf
							EndIf
						Next
						If $developer = "" Then
							MsgBox(262192, "Data Error", "Developer not found!", 0, $GameInfoGUI)
						Else
							IniWrite($gameinfo, $ID, "developer", $developer)
						EndIf
						; GENRE
						$tags = StringSplit($read, '"tags":', 1)
						If $tags[0] > 1 Then
							$tags = $tags[2]
							$tags = StringSplit($tags, '],', 1)
							$tags = $tags[1]
							$genre = ""
							$tags = StringSplit($tags, '"name":"', 1)
							For $t = 2 To $tags[0]
								$tag = $tags[$t]
								$tag = StringSplit($tag, '"', 1)
								$tag = $tag[1]
								If $tag <> "" Then
									If $genre = "" Then
										$genre = $tag
									Else
										$genre = $genre & ", " & $tag
									EndIf
								EndIf
							Next
							If $genre = "" Then
								MsgBox(262192, "Data Error", "Genre not found!", 0, $GameInfoGUI)
							Else
								IniWrite($gameinfo, $ID, "genre", $genre)
							EndIf
							; PLAY TYPE
							$features = StringSplit($read, '"features":', 1)
							If $features[0] > 1 Then
								$features = $features[2]
								$features = StringSplit($features, '],', 1)
								$features = $features[1]
								$playtype = ""
								$features = StringSplit($features, '"name":"', 1)
								For $f = 2 To $features[0]
									$feature = $features[$f]
									$feature = StringSplit($feature, '"', 1)
									$feature = $feature[1]
									If $feature <> "" Then
										If $feature = "Co-op" Or $feature = "Single-player" Or $feature = "Multi-player" Then
											If $playtype = "" Then
												$playtype = $feature
											Else
												$playtype = $playtype & ", " & $feature
											EndIf
										EndIf
									EndIf
								Next
								If $playtype = "" Then
									MsgBox(262192, "Data Error", "Play Types not found!", 0, $GameInfoGUI)
								Else
									IniWrite($gameinfo, $ID, "playtype", $playtype)
								EndIf
								If $release = "" Then
									; RELEASE DATE
									$release = StringSplit($read, '"gogReleaseDate":"', 1)
									If $release[0] > 1 Then
										$release = $release[2]
										$release = StringSplit($release, '",', 1)
										$release = $release[1]
										If $release = "" Then
											MsgBox(262192, "Data Error", "Release Date not found!", 0, $GameInfoGUI)
										Else
											$release = StringLeft($release, 10)
											IniWrite($gameinfo, $ID, "released", $release)
										EndIf
									Else
										MsgBox(262192, "Data Error", "Release Date issue!", 0, $GameInfoGUI)
									EndIf
								EndIf
								; BOX ART
								; "boxArtImage": https:\\images.gog-statics.com\c3cf6ba751c3150b95f7bddb5f85a52b47aa3254fac1c81aa62a20c7b1200b6c.jpg
								$boxart = StringSplit($read, '"boxArtImage":', 1)
								If $boxart[0] > 1 Then
									$boxart = $boxart[2]
									$boxart = StringSplit($boxart, '"}', 1)
									$boxart = $boxart[1]
									$boxart = StringSplit($boxart, '"', 1)
									$boxart = $boxart[$boxart[0]]
									$boxart = StringReplace($boxart, "\/", "/")
									IniWrite($gameinfo, $ID, "boxart", $boxart)
									$cover = $datafold & "\" & $ID & "\" & $ID & "_cover.jpg"
									If Not FileExists($cover) Then
										SplashTextOn("", "Downloading Cover!", 200, 120, Default, Default, 33)
										InetGet($boxart, $cover, 1, 0)
									EndIf
									; COVER IMAGE
									; "image": https:\\images.gog-statics.com\8f99f51394923901e3ba92ac42cef5fe863d3aa33ef0e1ac84610a9ad7dd8f96.png
									$image = StringSplit($read, '"image":', 1)
									If $image[0] > 1 Then
										$image = $image[2]
										$image = StringSplit($image, '",', 1)
										$image = $image[1]
										$image = StringSplit($image, '"', 1)
										$image = $image[$image[0]]
										$image = StringReplace($image, "\/", "/")
										$image = StringReplace($image, "_{formatter}.png", ".png")
										IniWrite($gameinfo, $ID, "cover", $image)
										$cover = $datafold & "\" & $ID & "\" & $ID & "_image.png"
										If Not FileExists($cover) Then
											SplashTextOn("", "Downloading Image!", 200, 120, Default, Default, 33)
											InetGet($image, $cover, 1, 0)
										EndIf
									EndIf
									; SYSTEM & REQS
									$supported = ""
									$requires = StringSplit($read, '"supportedOperatingSystems":', 1)
									If $requires[0] > 1 Then
										$requires = $requires[2]
										$requires = StringSplit($requires, '],', 1)
										$requires = $requires[1]
										$systems = StringSplit($requires, '"operatingSystem":', 1)
										If $systems[0] > 1 Then
											IniWrite($gameinfo, $ID, "supported", "")
											For $s = 2 To $systems[0]
												$system = $systems[$s]
												; OS
												$sys = StringSplit($system, '"name":', 1)
												$sys = $sys[2]
												$sys = StringSplit($sys, ',', 1)
												$sys = $sys[1]
												$sys = StringReplace($sys, '"', '')
												; Versions
												$versions = StringSplit($system, '"versions":', 1)
												$versions = $versions[2]
												$versions = StringSplit($versions, '},', 1)
												$versions = $versions[1]
												$versions = StringReplace($versions, '"', '')
												$versions = StringReplace($versions, '),', ')')
												If $versions <> "" Then
													If $supported = "" Then
														$supported = $versions
													Else
														$supported = $supported & ", " & $versions
													EndIf
												EndIf
												$requires = StringSplit($system, '"systemRequirements":', 1)
												If $requires[0] > 1 Then
													$requires = $requires[2]
													$requires = StringReplace($requires, '"type":', '')
													$requires = StringReplace($requires, '\/', '/')
													$requires = StringReplace($requires, '<br>', '|')
													$requires = StringReplace($requires, '\n', '')
													$requires = StringReplace($requires, '\u00ae', '')
													$requires = StringReplace($requires, '\u2122', '')
													$requires = StringReplace($requires, '"description":', '')
													$requires = StringReplace($requires, '"recommended"', '')
													$minimum = StringSplit($requires, '"requirements":', 1)
													If $minimum[0] > 1 Then
														$requires = $minimum[2]
													Else
														$requires = ""
													EndIf
													$minimum = $minimum[1]
													$minimum = StringReplace($minimum, '"minimum"', 'Minimum System: ')
													$minimum = StringReplace($minimum, '[', '')
													$minimum = StringReplace($minimum, '{', '')
													$minimum = StringReplace($minimum, ',', '')
													$minimum = StringReplace($minimum, '"', '')
													If $requires <> "" Then
														$requires = StringReplace($requires, '"id":', '')
														$requires = StringReplace($requires, '"system"', 'Recommended ')
														$requires = StringReplace($requires, '"name":', '')
														$requires = StringReplace($requires, '"System:"', 'System: ')
														$requires = StringReplace($requires, '"processor"', '')
														$requires = StringReplace($requires, '"Processor:"', '|Processor: ')
														$requires = StringReplace($requires, '"memory"', '')
														$requires = StringReplace($requires, '"Memory:"', '|Memory: ')
														$requires = StringReplace($requires, '"graphics"', '')
														$requires = StringReplace($requires, '"Graphics:"', '|Graphics: ')
														$requires = StringReplace($requires, '"directx"', '')
														$requires = StringReplace($requires, '"DirectX:"', '|DirectX: ')
														$requires = StringReplace($requires, '"storage"', '')
														$requires = StringReplace($requires, '"Storage:"', '|Storage: ')
														$requires = StringReplace($requires, '"other"', '')
														$requires = StringReplace($requires, '"Other:"', '|Other: ')
														$requires = StringReplace($requires, '"network"', '')
														$requires = StringReplace($requires, '"Network:"', '|Network: ')
														$requires = StringReplace($requires, '"sound"', '')
														$requires = StringReplace($requires, '"Sound:"', '|Sound: ')
														$requires = StringReplace($requires, '[', '')
														$requires = StringReplace($requires, ']', '')
														$requires = StringReplace($requires, '{', '')
														$requires = StringReplace($requires, '}', '')
														$requires = StringReplace($requires, ',', '')
														$requires = StringReplace($requires, '"', '')
													EndIf
													IniWrite($gameinfo, $ID, $sys, $minimum & "|" & $requires)
												EndIf
											Next
											IniWrite($gameinfo, $ID, "supported", $supported)
										EndIf
									EndIf
									; Title is also available, but likely not needed.
								Else
									MsgBox(262192, "Data Error", "Play Types issue!", 0, $GameInfoGUI)
								EndIf
							Else
								MsgBox(262192, "Data Error", "Genre issue!", 0, $GameInfoGUI)
							EndIf
						Else
							MsgBox(262192, "Data Error", "Developer issue!", 0, $GameInfoGUI)
						EndIf
					Else
						MsgBox(262192, "Data Error", "Publisher issue!", 0, $GameInfoGUI)
					EndIf
				Else
					MsgBox(262192, "Data Error", "Publisher not found!", 0, $GameInfoGUI)
				EndIf
			Else
				MsgBox(262192, "Download Error", "No data retrieved!", 0, $GameInfoGUI)
			EndIf
			SplashTextOn("", "Getting Price!", 200, 120, Default, Default, 33)
			$idlink = "https://api.gog.com/products/" & $ID & "/prices?countryCode=" & StringLeft($cc, 2)
			$html = _INetGetSource($idlink)
			If $html = "" Then
				$price = ""
			Else
				$htmltxt = @ScriptDir & "\Html.txt"
				_FileCreate($htmltxt)
				FileWrite($htmltxt, $html)
				$check = StringSplit($html, '{"code":"' & $cc & '"}', 1)
				If $check[0] = 2 Then
					$check = $check[2]
					$check = StringSplit($check, '"finalPrice":"', 1)
					If $check[0] > 1 Then
						$check = $check[2]
						$check = StringSplit($check, ' ' & $cc & '"', 1)
						$check = $check[1]
						$check = $check / 100
						If StringInStr($check, ".") > 0 Then
							$check = StringSplit($check, '.', 1)
							If StringLen($check[2]) = 1 Then
								$check = $check[1] & "." & $check[2] & "0"
							Else
								$check = $check[1] & "." & $check[2]
							EndIf
						Else
							$check = $check & ".00"
						EndIf
						;If $altcur = 1 Then
						;	$price = $csign & $check
						;Else
							$price = "$" & $check
						;EndIf
					Else
						$price = ""
					EndIf
				Else
					$price = ""
				EndIf
			EndIf
			IniWrite($gameinfo, $ID, "price", $price)
			Sleep(250)
		Else
			MsgBox(262192, "Download Error 2", "No data retrieved!", 0, $GameInfoGUI)
		EndIf
		If $create = 1 Then
			SplashTextOn("", "Creating Manifest!", 200, 120, Default, Default, 33)
			Sleep(500)
			$manifest = $manfold & "\" & $slug & "_manifest.txt"
			If FileExists($manifest) Then
				$ans = MsgBox(262179 + 256, "Replace Query", _
					"Manifest for this game already exists." & @LF & @LF & _
					"Do you want to replace with a new one?" & @LF & @LF & _
					"YES = Replace." & @LF & _
					"NO = Backup & Replace." & @LF & _
					"CANCEL = Abort any replacement.", 0, $GameInfoGUI)
				If $ans = 2 Then
					SplashOff()
					Return
				ElseIf $ans = 7 Then
					$timestamp = _Now()
					$timestamp = StringReplace($timestamp, "/", "")
					$timestamp = StringReplace($timestamp, ":", "")
					$timestamp = StringReplace($timestamp, " ", "")
					$bakfile = StringTrimRight($manifest, 4) & "_" & $timestamp & ".txt"
					FileMove($manifest, $bakfile)
				EndIf
			EndIf
			_FileCreate($manifest)
			$entry = '{' & @LF & '  "Games": [' & @LF & '    {' & @LF & '      "Id": ' & $ID & ',' & @LF & '      "Title": "' & $title & '",'
			$entry = $entry & @LF & '      "Type": "' & $type & '",' & @LF & '      "CdKey": "",' & @LF & '      "Tags": [],' & @LF & '      "Installers": ['
			If $installers <> "" Then
				$downurl = ""
				$errors = 0
				$lastlang = ""
				$lastOS = ""
				If $hide = 1 Then
					$flag = @SW_HIDE
				ElseIf $hide = 2 Then
					$flag = @SW_MINIMIZE
				Else
					$flag = @SW_SHOW
				EndIf
				;Local $details = @ScriptDir & "\Details.txt"
				;FileChangeDir(@ScriptDir)
				;$params = "-c Cookie.txt gog-api game-details -i " & $ID
				;RunWait(@ComSpec & ' /c gogcli.exe ' & $params & ' >"' & $details & '"', @ScriptDir, $flag)
				;Sleep(1000)
				$installers = StringSplit($installers, '"downlink":', 1)
				For $i = 2 To $installers[0]
					$installer = $installers[$i]
					If StringLeft($installer, 7) = '"https:' Then
						; $i = 2, 3, etc
						$downurl = StringSplit($installer, '"', 1)
						$downurl = $downurl[2]
						$downurl = StringReplace($downurl, '\/', '/')
						$downurl = StringSplit($downurl, '/', 1)
						$downurl = $downurl[$downurl[0]]
						$downurl = '/downloads/' & $slug & "/" & $downurl
						;
						$installer = $installers[$i - 1]
						GetOthers($installer)
						;
						$file = ""
						$checksum = ""
						$mass = ""
						If $downurl <> "" Then
							If FileExists($gogcli) Then
								If FileExists($cookie) Then
									FileDelete($fileinfo)
									Sleep(500)
									_FileWriteLog($logfle, "MANIFEST DOWNLOAD = " & $downurl, -1)
									FileChangeDir(@ScriptDir)
									$params = "-c Cookie.txt gog-api url-path-info -p " & $downurl
									RunWait(@ComSpec & ' /c echo ' & $downurl & ' && gogcli.exe ' & $params & ' >"' & $fileinfo & '"', @ScriptDir, $flag)
									Sleep(1000)
									If FileExists($fileinfo) Then
										$logerr = ""
										_FileReadToArray($fileinfo, $array)
										For $a = 1 To $array[0]
											$line = $array[$a]
											If StringInStr($line, "File Name:") > 0 Then
												$file = StringSplit($line, "File Name:", 1)
												$file = $file[2]
												$file = StringStripWS($file, 3)
											ElseIf StringInStr($line, "Checksum:") > 0 Then
												$checksum = StringSplit($line, "Checksum:", 1)
												$checksum = $checksum[2]
												$checksum = StringStripWS($checksum, 3)
											ElseIf StringInStr($line, "Size:") > 0 Then
												$mass = StringSplit($line, "Size:", 1)
												$mass = $mass[2]
												$mass = StringStripWS($mass, 3)
												If $mass <> "" Then
													;If $mass <> $bytes And $bytes = "" Then
													If $mass <> $bytes Then
														$bytes = $mass
													EndIf
												EndIf
											EndIf
										Next
										$fext = StringRight($file, 4)
										If $file = "" Then
											$logerr = "File Name"
										EndIf
										If $checksum = "" And ($fext = ".exe" Or $fext= ".bin" Or $fext = "") Then
											If $logerr = "" Then
												$logerr = "Checksum"
											Else
												$logerr = $logerr & ", Checksum"
											EndIf
										EndIf
										If $mass = "" Then
											If $logerr = "" Then
												$logerr = "File Size"
											Else
												$logerr = $logerr & ", File Size"
											EndIf
										EndIf
										If $logerr <> "" Then
											$errors = $errors + 1
											_FileWriteLog($logfle, "Missing download file information - " & $logerr & ".", -1)
										EndIf
									Else
										_FileWriteLog($logfle, "Required Fileinfo.txt file not found.", -1)
									EndIf
								Else
									_FileWriteLog($logfle, "Required Cookie.txt file not found.", -1)
								EndIf
							Else
								_FileWriteLog($logfle, "Required program gogcli.exe not found.", -1)
							EndIf
							If $i > 2 Then
								$entry = $entry & @LF & '        },'
							EndIf
							If $name = "" Then
								If $file <> "" Then
									If StringRight($file, 4) = ".bin" Then
										$name = StringTrimRight($file, 4)
										$name = StringSplit($name, "-", 1)
										$name = $name[$name[0]]
										$name = $name + 1
										$name = '"' & $title & ' - Part ' & $name & '"'
									EndIf
								EndIf
							EndIf
							$entry = $entry & @LF & '        {'
							$entry = $entry & @LF & '          "Languages": [' & @LF & '            "' & $lang & '"'
							$entry = $entry & @LF & '          ],' & @LF & '          "Os": ' & $OS & ','
							$entry = $entry & @LF & '          "Url": "' & $downurl & '",'
							$entry = $entry & @LF & '          "Title": ' & $name & ','
							$entry = $entry & @LF & '          "Slug": ' & $slug & ','
							$entry = $entry & @LF & '          "Name": "' & $file & '",'
							$entry = $entry & @LF & '          "Version": ' & $version & ','
							$entry = $entry & @LF & '          "Date": "",'
							$entry = $entry & @LF & '          "EstimatedSize": "' & $size & '",'
							$entry = $entry & @LF & '          "VerifiedSize": ' & $bytes & ','
							$entry = $entry & @LF & '          "Checksum": "' & $checksum & '"'
							$downurl = ""
						Else
							_FileWriteLog($logfle, "No download URL found.", -1)
						EndIf
					EndIf
				Next
				$entry = $entry & @LF & '        }' & @LF & '      ],'
				;
				; Extras go here
				If $extras <> "" Then
					$entry = $entry & @LF & '      "Extras": ['
					$downurl = ""
					$file = ""
					$extras = StringSplit($extras, '"downlink":', 1)
					For $i = 2 To $extras[0]
						$extra = $extras[$i]
						If StringLeft($extra, 7) = '"https:' Then
							$downurl = StringSplit($extra, '"', 1)
							$downurl = $downurl[2]
							$downurl = StringReplace($downurl, '\/', '/')
							$downurl = StringSplit($downurl, '/', 1)
							$downurl = $downurl[$downurl[0]]
							$downurl = '/downloads/' & $slug & "/" & $downurl
							;
							$extra = $extras[$i - 1]
							GetExtras($extra)
							;
							$file = ""
							$checksum = ""
							$mass = ""
							If $downurl <> "" Then
								If FileExists($gogcli) Then
									If FileExists($cookie) Then
										FileDelete($fileinfo)
										Sleep(500)
										_FileWriteLog($logfle, "MANIFEST DOWNLOAD = " & $downurl, -1)
										FileChangeDir(@ScriptDir)
										$params = "-c Cookie.txt gog-api url-path-info -p " & $downurl
										RunWait(@ComSpec & ' /c echo ' & $downurl & ' && gogcli.exe ' & $params & ' >"' & $fileinfo & '"', @ScriptDir, $flag)
										Sleep(1000)
										If FileExists($fileinfo) Then
											$logerr = ""
											_FileReadToArray($fileinfo, $array)
											For $a = 1 To $array[0]
												$line = $array[$a]
												If StringInStr($line, "File Name:") > 0 Then
													$file = StringSplit($line, "File Name:", 1)
													$file = $file[2]
													$file = StringStripWS($file, 3)
												ElseIf StringInStr($line, "Checksum:") > 0 Then
													$checksum = StringSplit($line, "Checksum:", 1)
													$checksum = $checksum[2]
													$checksum = StringStripWS($checksum, 3)
												ElseIf StringInStr($line, "Size:") > 0 Then
													$mass = StringSplit($line, "Size:", 1)
													$mass = $mass[2]
													$mass = StringStripWS($mass, 3)
													If $mass <> "" Then
														If $mass <> $bytes Then
															$bytes = $mass
														EndIf
													EndIf
												EndIf
											Next
											$fext = StringRight($file, 4)
											If $file = "" Then
												$logerr = "File Name"
											EndIf
											If $checksum = "" And ($fext = ".exe" Or $fext= ".bin" Or $fext = "") Then
												If $logerr = "" Then
													$logerr = "Checksum"
												Else
													$logerr = $logerr & ", Checksum"
												EndIf
											EndIf
											If $mass = "" Then
												If $logerr = "" Then
													$logerr = "File Size"
												Else
													$logerr = $logerr & ", File Size"
												EndIf
											EndIf
											If $logerr <> "" Then
												$errors = $errors + 1
												_FileWriteLog($logfle, "Missing download file information - " & $logerr & ".", -1)
											EndIf
										Else
											_FileWriteLog($logfle, "Required Fileinfo.txt file not found.", -1)
										EndIf
									Else
										_FileWriteLog($logfle, "Required Cookie.txt file not found.", -1)
									EndIf
								Else
									_FileWriteLog($logfle, "Required program gogcli.exe not found.", -1)
								EndIf
								;If $i > 2 Then
								;	$entry = $entry & @LF & '        },'
								;EndIf
								$entry = $entry & @LF & '        {'
								$entry = $entry & @LF & '          "Url": "' & $downurl & '",'
								$entry = $entry & @LF & '          "Title": ' & $name & ','
								$entry = $entry & @LF & '          "Name": "' & $file & '",'
								$entry = $entry & @LF & '          "Type": ' & $type & ','
								$entry = $entry & @LF & '          "Info": ' & $info & ','
								$entry = $entry & @LF & '          "EstimatedSize": "' & $size & '",'
								$entry = $entry & @LF & '          "VerifiedSize": ' & $bytes & ','
								$entry = $entry & @LF & '          "Checksum": "' & $checksum & '"'
								$downurl = ""
							Else
								_FileWriteLog($logfle, "No download URL found for extras.", -1)
							EndIf
						EndIf
					Next
					$entry = $entry & @LF & '        }' & @LF & '      ],'
				EndIf
				$entry = $entry & @LF & '    }' & @LF & '  ],'
				; Other details go here (Total Size estimated and verified, summary of all languages etc)
			Else
				_FileWriteLog($logfle, "No installers found.", -1)
			EndIf
			;
			$entry = $entry & @LF & '  }' & @LF & '}' & @LF
			FileWrite($manifest, $entry)
			If $show = 1 Then
				If $editor = "none" Then
					ShellExecute($manifest)
				Else
					Run($editor & ' "' & $manifest & '"')
				EndIf
			EndIf
			If $errors > 0 Then
				MsgBox(262192, "Errors Occurred", "Check the Log file for details!", 0, $GameInfoGUI)
			EndIf
		EndIf
		SplashOff()
	Else
		MsgBox(262192, "Web Error", "No connection detected!", 0, $GameInfoGUI)
	EndIf
EndFunc ;=> GetGameDetail

Func GetExtras($section)
	$name = StringSplit($section, '"name":', 1)
	If $name[0] > 1 Then
		$name = $name[2]
		$name = StringSplit($name, '",', 1)
		$name = $name[1]
		$name = StringReplace($name, '"', '')
		$name = StringStripWS($name, 3)
		$name = FixUnicode($name)
		$name = '"' & $name & '"'
	Else
		$name = ''
	EndIf
	;
	$file = ''
	;
	$type = StringSplit($section, '"type":', 1)
	If $type[0] > 1 Then
		$type = $type[2]
		$type = StringSplit($type, ',', 1)
		$type = $type[1]
		$type = StringReplace($type, '"', '')
		$type = StringStripWS($type, 3)
		$type = FixUnicode($type)
		$type = '"' & $type & '"'
	Else
		$type = ''
	EndIf
	$info = StringSplit($section, '"count":', 1)
	If $info[0] > 1 Then
		$info = $info[2]
		$info = StringSplit($info, ',', 1)
		$info = $info[1]
	Else
		$info = ''
	EndIf
	$bytes = StringSplit($section, '"size":', 1)
	If $bytes[0] > 1 Then
		$bytes = $bytes[2]
		$bytes = StringSplit($bytes, ',', 1)
		$bytes = $bytes[1]
		If $bytes < 1024 Then
			$size = $bytes & " bytes"
		ElseIf $bytes < 1048576 Then
			$size = Round($bytes / 1024, 0) & " KB"
		ElseIf $bytes < 1073741824 Then
			$size = Round($bytes / 1048576, 0) & " MB"
		ElseIf $bytes < 1099511627776 Then
			$size = Round($bytes / 1073741824, 2) & " GB"
		Else
			$size = Round($bytes / 1099511627776, 3) & " TB"
		EndIf
	Else
		$bytes = ''
		$size = ''
	EndIf
EndFunc ;=> GetExtras

Func GetOthers($section)
	$lang = StringSplit($section, '"language_full":', 1)
	If $lang[0] > 1 Then
		$lang = $lang[2]
		$lang = StringSplit($lang, ',', 1)
		$lang = $lang[1]
		$lang = StringReplace($lang, '"', '')
		$lang = StringStripWS($lang, 3)
		$lang = FixUnicode($lang)
		$lang = StringLower($lang)
		$lastlang = $lang
	Else
		If $lastlang = "" Then
			$lang = ''
		Else
			$lang = $lastlang
		EndIf
	EndIf
	$OS = StringSplit($section, 'os":', 1)
	If $OS[0] > 1 Then
		$OS = $OS[2]
		$OS = StringSplit($OS, ',', 1)
		$OS = $OS[1]
		$lastOS = $OS
	Else
		If $lastOS = "" Then
			$OS = ''
		Else
			$OS = $lastOS
		EndIf
	EndIf
	$name = StringSplit($section, '"name":', 1)
	If $name[0] > 1 Then
		$name = $name[2]
		$name = StringSplit($name, '",', 1)
		$name = $name[1]
		$name = StringReplace($name, '"', '')
		$name = StringStripWS($name, 3)
		$name = FixUnicode($name)
		$name = '"' & $name & '"'
	Else
		$name = ''
	EndIf
	;
	$file = ''
	;
	$version = StringSplit($section, '"version":', 1)
	If $version[0] > 1 Then
		$version = $version[2]
		$version = StringSplit($version, ',', 1)
		$version = $version[1]
	Else
		$version = ''
	EndIf
	$bytes = StringSplit($section, '"size":', 1)
	If $bytes[0] > 1 Then
		$bytes = $bytes[2]
		$bytes = StringSplit($bytes, ',', 1)
		$bytes = $bytes[1]
		If $bytes < 1024 Then
			$size = $bytes & " bytes"
		ElseIf $bytes < 1048576 Then
			$size = Round($bytes / 1024, 0) & " KB"
		ElseIf $bytes < 1073741824 Then
			$size = Round($bytes / 1048576, 0) & " MB"
		ElseIf $bytes < 1099511627776 Then
			$size = Round($bytes / 1073741824, 2) & " GB"
		Else
			$size = Round($bytes / 1099511627776, 3) & " TB"
		EndIf
	Else
		$bytes = ''
		$size = ''
	EndIf
EndFunc ;=> GetOthers

Func LoadTheList()
	$titles = ""
	If FileExists($titfile) Then
		$read = _FileReadToArray($titfile, $entries)
		If IsArray($entries) Then
			$cnt = 0
			For $e = 1 To $entries[0]
				$line = $entries[$e]
				If StringLeft($line, 6) = "title=" Then
					$title = StringTrimLeft($line, 6)
					If $titles = "" Then
						$titles = $title
					Else
						$titles = $titles & "|" & $title
					EndIf
					$cnt = $cnt + 1
				EndIf
			Next
			If $cnt > 0 Then
				GUICtrlSetData($List_games, "||" & $titles)
				GUICtrlSetData($Group_games, "Game Titles  (" & $cnt & ")")
			EndIf
		EndIf
	EndIf
EndFunc ;=> LoadTheList

Func RemoveHtml($text)
	Local $p, $part, $parts
	$text = StringReplace($text, "<p>", "")
	$text = StringReplace($text, "</p>", "")
	$text = StringReplace($text, "<hr>", @CRLF)
	$text = StringReplace($text, "<b>", "")
	$text = StringReplace($text, "</b>", "")
	$text = StringReplace($text, "<li>", "")
	$text = StringReplace($text, "</li>", "")
	$text = StringReplace($text, "<ul>", "")
	$text = StringReplace($text, "</ul>", "")
	$text = StringReplace($text, "</a>", "")
	$text = StringReplace($text, "</div>", "")
	$text = StringReplace($text, "</span>", "")
	$text = StringReplace($text, "<h4>", "")
	$text = StringReplace($text, "</h4>", "")
	$text = StringReplace($text, "</video>", "")
	$text = StringReplace($text, '<p class="module">', '')
	$text = StringReplace($text, '<div style="overflow: hidden;">', '')
	$text = StringReplace($text, '<span style="display: block;">', '')
	$text = StringReplace($text, '<ul class="bb_ul">', '')
	If StringInStr($text, "<") > 0 Then
		$parts = StringSplit($text, "<", 1)
		$text = $parts[1]
		For $p = 2 To $parts[0]
			$part = $parts[$p]
			If StringInStr($part, ">") > 0 Then
				$part = StringSplit($part, ">", 1)
				$text = $text & $part[2]
			ElseIf StringInStr($part, @CRLF) > 0 Then
				$part = StringSplit($part, @CRLF, 1)
				$text = $text & $part[2]
			Else
				$text = $text & $part
			EndIf
		Next
	EndIf
	While StringInStr($text, @CRLF & @CRLF)
		$text = StringReplace($text, @CRLF & @CRLF, @CRLF)
	WEnd
	$text = StringReplace($text, ".", ". ")
	$text = StringReplace($text, "  ", " ")
	$text = StringReplace($text, ". . . ", "...")
	$text = StringReplace($text, "gog. com", "gog.com", 0, 1)
	$text = StringReplace($text, "GOG. COM", "GOG.COM", 0, 1)
	Return $text
EndFunc ;=> RemoveHtml
