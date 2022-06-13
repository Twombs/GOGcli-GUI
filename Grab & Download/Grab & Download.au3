#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; FUNCTIONS
; MainGUI(), IDResultsGUI()
; GetFileInfo(), GetTheFullTitle(), SaveGuiWindowPosition()

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <TrayConstants.au3>
#include <StaticConstants.au3>
#include <InetConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <GuiRichEdit.au3>
#include <Misc.au3>
#include <Inet.au3>
#include <File.au3>
#include <Array.au3>

Global $Button_down, $Button_list, $Button_menu, $Button_paste, $Button_start, $Context_menu, $Log_item, $Paste_item, $RichEdit_drop

Global $a, $array, $bytes, $checksum, $cookie, $created, $downurl, $DropperGUI, $e, $entries, $entry, $fext, $file, $fileinfo, $flat
Global $game, $GID, $gogcli, $grabini, $html, $htmltxt, $ID, $idlink, $left, $len, $line, $linkfle, $linksfile, $logerr, $loops, $mass
Global $n, $name, $names, $num, $nums, $params, $ping, $shell, $slug, $style, $target, $targlen, $text, $title, $top, $u, $url, $urls
Global $val, $version, $wait

_Singleton("grab-and-download-timboli", 0)

$cookie = @ScriptDir & "\Cookie.txt"
$created = "June 2022"
$fileinfo = @ScriptDir & "\Fileinfo.txt"
$gogcli = @ScriptDir & "\gogcli.exe"
$grabini = @ScriptDir & "\Grabber.ini"
$htmltxt = @ScriptDir & "\Html.txt"
$linkfle = @ScriptDir & "\Links.txt"
$linksfile = @ScriptDir & "\Downlinks.ini"
$version = "v1.0"

$wait = IniRead($grabini, "Clear Pasted URL", "wait", "")
If $wait = "" Then
	$wait = 1500
	IniWrite($grabini, "Clear Pasted URL", "wait", $wait)
EndIf

MainGUI()

Exit

Func MainGUI()
	$target = "  DRAG & DROP" & @CR & "    or PASTE the" & @CR & "    DOWNLOAD" & @CR & "     URL HERE"
	$targlen = StringLen($target)
	;
	TraySetToolTip("Grab & Download was created by Timboli")
	;
	; CREATE GUI section
	$left = IniRead($grabini, "Grabber Window", "left", -1)
	$top = IniRead($grabini, "Grabber Window", "top", -1)
	$style = $WS_CAPTION + $WS_POPUP + $WS_CLIPSIBLINGS + $WS_SYSMENU
	$DropperGUI = GUICreate("Grab & Download", 170, 130, $left, $top, $style, $WS_EX_TOPMOST)
	GUISetBkColor($COLOR_SKYBLUE, $DropperGUI)
	; CONTROLS
	$RichEdit_drop = _GUICtrlRichEdit_Create($DropperGUI, "", 8, 7, 152, 92, $ES_MULTILINE + $WS_VSCROLL + $ES_AUTOVSCROLL)
	;
	$Button_start = GUICtrlCreateButton("Start", 7, 104, 38, 22)
	GUICtrlSetFont($Button_start, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_start, "START BATCH!")
	;
	$Button_paste = GUICtrlCreateButton("Paste", 47, 104, 42, 22)
	GUICtrlSetFont($Button_paste, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_paste, "Click to Paste URL into dropfield!")
	;
	$Button_list = GUICtrlCreateButton("List", 92, 104, 22, 22, $BS_ICON)
	GUICtrlSetFont($Button_list, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_list, "BATCH LIST!")
	;
	$Button_down = GUICtrlCreateButton("Folder", 117, 104, 21, 22, $BS_ICON)
	GUICtrlSetFont($Button_down, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_down, "Downloads folder!")
	;
	$Button_menu = GUICtrlCreateButton("Menu", 141, 104, 22, 22, $BS_ICON)
	GUICtrlSetFont($Button_menu, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_menu, "Program Menu!")
	;
	; CONTEXT MENU
	$Context_menu = GUICtrlCreateContextMenu($Button_menu)
	$Paste_item = GUICtrlCreateMenuItem("Paste URL(s)", $Context_menu)
	GUICtrlCreateMenuItem("", $Context_menu)
	;
	GUICtrlCreateMenuItem("", $Context_menu)
	$Log_item = GUICtrlCreateMenuItem("View the Log file", $Context_menu)
	GUICtrlCreateMenuItem("", $Context_menu)
	;
	; OS SETTINGS
	$shell = @SystemDir & "\shell32.dll"
	GUICtrlSetImage($Button_list, $shell, -71, 0)
	GUICtrlSetImage($Button_down, $shell, -4, 0)
	GUICtrlSetImage($Button_menu, $shell, -85, 0)
	;
	; SETTINGS section
	GUISetState(@SW_SHOW)
	;
	_GUICtrlRichEdit_SetEventMask($RichEdit_drop, $ENM_LINK)
	;
	_GUICtrlRichEdit_AutoDetectURL($RichEdit_drop, True)
	;
	_GUICtrlRichEdit_SetText($RichEdit_drop, $target)
	_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
	_GUICtrlRichEdit_SetFont($RichEdit_drop, 14, "Times New Roman")
	_GUICtrlRichEdit_SetCharColor($RichEdit_drop, $COLOR_GRAY)
	_GUICtrlRichEdit_Deselect($RichEdit_drop)
	;
	$loops = 0

	$msg = ""
	While True
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				; Close the program or Minimize the Window
				If _IsPressed("11") Then
					; Minimize the Window
					GUISetState(@SW_MINIMIZE, $DropperGUI)
					WinSetTitle($DropperGUI, "", "Grab & Download was created by Timboli")
				Else
					; Exit or Close program (with checks)
					SaveGuiWindowPosition()
					;
					_GUICtrlRichEdit_Destroy($RichEdit_drop)
					ExitLoop
				EndIf
			Case $msg = $GUI_EVENT_MINIMIZE
				WinSetTitle($DropperGUI, "", "Grab & Download was created by Timboli")
			Case $msg = $GUI_EVENT_RESTORE
				WinSetTitle($DropperGUI, "", "Grab & Download")
			Case $msg = $Button_paste
				; Click to Paste URL into dropfield
				; Paste text from clipboard (Paste URL(s))
				$text = ClipGet()
				If StringLeft($text, 4) = "http" Then _GUICtrlRichEdit_SetText($RichEdit_drop, $text)
			Case $msg = $Button_menu
				; Program Menu
				ControlClick($DropperGUI, "", $Button_menu, "right", 1)
			Case $msg = $Button_list
				; Edit the List
				If FileExists($linkfle) Then ShellExecute($linkfle)
			Case Else
				If $loops = 40 Then
					$text = _GUICtrlRichEdit_GetText($RichEdit_drop)
					If $text <> "" And $text <> $target And StringIsDigit($text) = 0 Then
						;MsgBox(262208, "URL", "'" & $text & "'" & @LF & "'" & $target & "'", 0, $DropperGUI)
						GUISetState(@SW_DISABLE, $DropperGUI)
						GUICtrlSetState($RichEdit_drop, $GUI_DISABLE)
						GUICtrlSetState($Button_start, $GUI_DISABLE)
						GUICtrlSetState($Button_list, $GUI_DISABLE)
						GUICtrlSetState($Button_paste, $GUI_DISABLE)
						GUICtrlSetState($Button_down, $GUI_DISABLE)
						GUICtrlSetState($Button_menu, $GUI_DISABLE)
						_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
						_GUICtrlRichEdit_SetFont($RichEdit_drop, Default)
						_GUICtrlRichEdit_SetCharColor($RichEdit_drop, Default)
						If StringInStr($text, "https:") > 0 Then
							$urls = StringSplit($text, "https:", 1)
							$val = $urls[1]
							$len = StringLen($val)
							For $u = 2 To $urls[0]
								$text = StringStripWS($urls[$u], 3)
								;MsgBox(262208, "$text", $text, 0, $DropperGUI)
								If $text <> "" Then
									$text = "https:" & $text
									If $len = 0 Then
										If StringRight($text, $targlen) = $target Then
											$text = StringTrimRight($text, $targlen)
										EndIf
									Else
										If $val = StringLeft($target, $len) Then
											$flat = StringTrimLeft($target, $len)
											$len = StringLen($flat)
											If StringRight($text, $len) = $flat Then
												$text = StringTrimRight($text, $len)
											EndIf
										EndIf
									EndIf
									$url = $text
									; ADD to BATCH LISI
									If Not FileExists($linkfle) Then _FileCreate($linkfle)
									; Entries from a multiple URL string are skipped for Last addition recall,
									; to avoid any possible mistake by user.
									If $urls[0] = 1 Then
										IniWrite($grabini, "Last Pasted Addition", "url", $url)
									ElseIf $u = 1 Then
										IniWrite($grabini, "Last Pasted Addition", "url", "")
									EndIf
									If StringInStr($url, "www.gog.com") > 0 Then
										_GUICtrlRichEdit_SetText($RichEdit_drop, " Adding URL " & $u - 1)
										_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
										_GUICtrlRichEdit_SetFont($RichEdit_drop, 14, "Times New Roman")
										_GUICtrlRichEdit_SetCharColor($RichEdit_drop, $COLOR_FUCHSIA)
										_GUICtrlRichEdit_Deselect($RichEdit_drop)
										;
										FileWriteLine($linkfle, $url)
										Sleep(500)
										;
										$slug = StringSplit($url, "/", 1)
										$slug = $slug[$slug[0] - 1]
										$game = StringReplace($slug, "_", " ")
										If StringLeft($game, 4) = "the " Then
											$game = StringTrimLeft($game, 4)
										EndIf
										If IniRead($linksfile, $game, "slug", "") = "" Then
											IniWrite($linksfile, $game, "slug", $slug)
											; Make a query to get full title - present a selection GUI of resulting choices.
											GetTheFullTitle()
											If $ID <> "" Then
												IniWrite($linksfile, $game, "ID", $ID)
												IniWrite($linksfile, $game, "title", $title)
											EndIf
											;
											$num = 1
											IniWrite($linksfile, $game, "links", $num)
											IniWrite($linksfile, $game, $num, $url)
											IniWrite($linksfile, $url, "game", $game)
										Else
											$num = ""
											$nums = IniRead($linksfile, $game, "links", "")
											For $n = 1 To $nums
												$num = $n
												If $url = IniRead($linksfile, $game, $num, "") Then
													$num = ""
													ExitLoop
												EndIf
											Next
											If $num <> "" Then
												$num = $num + 1
												IniWrite($linksfile, $game, "links", $num)
												IniWrite($linksfile, $game, $num, $url)
												IniWrite($linksfile, $url, "game", $game)
											EndIf
										EndIf
										;
										_FileReadToArray($linkfle, $array)
										$array = _ArrayUnique($array)
										_FileCreate($linkfle)
										$array = _ArrayToString($array, @CRLF, 2)
										FileWrite($linkfle, $array & @CRLF)
										;MsgBox(262208, "URL", $url, 0, $DropperGUI)
										;
										If $num <> "" Then GetFileInfo()
									EndIf
									Sleep($wait)
									If $u = $urls[0] Then
										_GUICtrlRichEdit_SetText($RichEdit_drop, $target)
										_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
										_GUICtrlRichEdit_SetFont($RichEdit_drop, 14, "Times New Roman")
										_GUICtrlRichEdit_SetCharColor($RichEdit_drop, $COLOR_GRAY)
										_GUICtrlRichEdit_Deselect($RichEdit_drop)
									EndIf
								ElseIf $u = $urls[0] Then
									Sleep(1000)
									_GUICtrlRichEdit_SetText($RichEdit_drop, $target)
									_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
									_GUICtrlRichEdit_SetFont($RichEdit_drop, 14, "Times New Roman")
									_GUICtrlRichEdit_SetCharColor($RichEdit_drop, $COLOR_GRAY)
									_GUICtrlRichEdit_Deselect($RichEdit_drop)
								EndIf
							Next
						Else
							_GUICtrlRichEdit_SetText($RichEdit_drop, "Only URLs are supported!")
							;MsgBox(262192, "Not URL", "Only URLs are supported!" & @LF & @LF & $text, 0, $DropperGUI)
							Sleep(1000)
							_GUICtrlRichEdit_SetText($RichEdit_drop, $target)
							_GUICtrlRichEdit_SetSel($RichEdit_drop, 0, -1)
							_GUICtrlRichEdit_SetFont($RichEdit_drop, 14, "Times New Roman")
							_GUICtrlRichEdit_SetCharColor($RichEdit_drop, $COLOR_GRAY)
							_GUICtrlRichEdit_Deselect($RichEdit_drop)
						EndIf
						GUISetState(@SW_ENABLE, $DropperGUI)
						GUICtrlSetState($RichEdit_drop, $GUI_ENABLE)
						GUICtrlSetState($Button_start, $GUI_ENABLE)
						GUICtrlSetState($Button_list, $GUI_ENABLE)
						GUICtrlSetState($Button_paste, $GUI_ENABLE)
						GUICtrlSetState($Button_down, $GUI_ENABLE)
						GUICtrlSetState($Button_menu, $GUI_ENABLE)
					EndIf
					$loops = 0
				Else
					$loops = $loops + 1
				EndIf
		EndSelect
	WEnd
	;
	GUISetState(@SW_HIDE)
	GUIDelete($DropperGUI)
EndFunc ;=> MainGUI

Func IDResultsGUI()
	Local $Button_close, $Combo_gameid, $Group_gameid, $Label_advice
	Local $ResultsGUI
	;
	$ResultsGUI = GuiCreate("ID Results", 500, 75, Default, Default, $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU _
								+ $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX, $WS_EX_TOPMOST, $DropperGUI)
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
	GUICtrlSetImage($Button_close, $shell, -28, 1)
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
			$title = $ID[2]
			$ID = $ID[1]
			GUIDelete($ResultsGUI)
			ExitLoop
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> IDResultsGUI


Func GetFileInfo()
	$downurl = StringReplace($url, "http://www.gog.com", "")
	$downurl = StringReplace($downurl, "https://www.gog.com", "")
	If $downurl <> "" Then
		If FileExists($gogcli) Then
			If FileExists($cookie) Then
				$ping = Ping("gog.com", 4000)
				If $ping > 0 Then
					SplashTextOn("", "Downloading Info!", 200, 120, Default, Default, 33)
					FileDelete($fileinfo)
					Sleep(500)
					$file = ""
					$checksum = ""
					$mass = ""
					FileChangeDir(@ScriptDir)
					$params = "-c Cookie.txt gog-api url-path-info -p " & $downurl
					RunWait(@ComSpec & ' /c echo ' & $downurl & ' && gogcli.exe ' & $params & ' >"' & $fileinfo & '"', @ScriptDir)
					Sleep(1000)
					SplashOff()
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
									$bytes = $mass
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
							MsgBox(262192, "Download Error", "Missing information for download file - " & $logerr & ".", 0, $DropperGUI)
						Else
							IniWrite($linksfile, $url, "file", $file)
							IniWrite($linksfile, $url, "size", $bytes)
							IniWrite($linksfile, $url, "checksum", $checksum)
							;$entry = "File Name: " & $file & @LF & "Verified File Size: " & $bytes & " bytes" & @LF & "Checksum: " & $checksum
							;MsgBox(262192 + 16, "Download Result", $entry, 0, $DropperGUI)
						EndIf
					Else
						MsgBox(262192, "Program Error", "Required Fileinfo.txt file not found!", 0, $DropperGUI)
					EndIf
				Else
					MsgBox(262192, "Web Error", "No connection detected!", 0, $DropperGUI)
				EndIf
			Else
				MsgBox(262192, "Program Error", "Required Cookie.txt file not found!", 0, $DropperGUI)
			EndIf
		Else
			MsgBox(262192, "Program Error", "Required program gogcli.exe not found!", 0, $DropperGUI)
		EndIf
	Else
		MsgBox(262192, "Program Error", "No GOG game file download URL provided!", 0, $DropperGUI)
	EndIf
EndFunc ;=> GetFileInfo

Func GetTheFullTitle()
	SplashTextOn("", "Getting ID(s)!", 200, 120, Default, Default, 33)
	$idlink = "https://embed.gog.com/games/ajax/filtered?mediaType=game&search=*" & $game
	$html = _INetGetSource($idlink)
	If $html = "" Then
		$names = ""
		;$last = ""
	Else
		_FileCreate($htmltxt)
		FileWrite($htmltxt, $html)
		;
		;$last = $game
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
		;MsgBox(262192, "IDs Found", $entries, 0, $DropperGUI)
	EndIf
	If $names <> "" Then
		IDResultsGUI()
	Else
		$ID = ""
		MsgBox(262192, "ID Error", "No Results!", 2, $DropperGUI)
	EndIf
	SplashOff()
EndFunc ;=> GetTheFullTitle

Func SaveGuiWindowPosition()
   Local $winpos = WinGetPos($DropperGUI, "")
   $left = $winpos[0]
   If $left < 0 Then
	   $left = 2
   ElseIf $left > @DesktopWidth - $winpos[2] Then
	   $left = @DesktopWidth - $winpos[2]
   EndIf
   IniWrite($grabini, "Program Window", "left", $left)
   $top = $winpos[1]
   If $top < 0 Then
	   $top = 2
   ElseIf $top > @DesktopHeight - $winpos[3] Then
	   $top = @DesktopHeight - $winpos[3]
   EndIf
   IniWrite($grabini, "Program Window", "top", $top)
EndFunc ;=> SaveGuiWindowPosition
