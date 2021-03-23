;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;;  AutoIt Version: 3.3.14.2                                                             ;;
;;                                                                                       ;;
;;  Template AutoIt script.                                                              ;;
;;                                                                                       ;;
;;  AUTHOR:  Timboli                                                                     ;;
;;                                                                                       ;;
;;  SCRIPT FUNCTION:  GOG Games Library GUI for gogcli manifest comparison report        ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <ColorConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <Misc.au3>
#include <Date.au3>

Local $exe, $script, $status, $w, $wins

Global $compare, $handle, $inifle, $pid, $Scriptname, $version

$version = "v1.1"
$Scriptname = "Manifest Comparison Report " & $version

$status = _Singleton("gog-cli-gui-timboli", 1)
If $status = 0 Then
	; Attempt to retore and activate a non-active or minimized window.
	If @Compiled = 1 Then
		$pid = ProcessExists(@ScriptName)
		$exe = @ScriptName
	Else
		$pid = ProcessExists("AutoIt3.exe")
		$exe = "AutoIt3.exe"
	EndIf
	$script = @AutoItPID
	If $script <> $pid Then
		$wins = WinList($Scriptname, "")
		For $w = 1 to $wins[0][0]
			$handle = $wins[$w][1]
			If WinGetProcess($handle, "") = $pid Then
				WinSetState($handle, "", @SW_RESTORE)
				WinActivate($handle, "")
				ExitLoop
			EndIf
		Next
		Exit
	EndIf
EndIf

$compare = @ScriptDir & "\Comparisons.txt"
$inifle = @ScriptDir & "\Settings.ini"

MainGUI()

Exit


Func MainGUI()
	Local $Button_clr, $Button_find, $Input_file, $Input_title, $Listview_games
	;
	Local $aqua, $cnt, $col, $color, $date, $entry, $file, $files, $find, $height, $icoR, $icoS, $id, $ind, $l, $last, $left, $line, $lines, $lowid
	Local $manifest, $num, $orange, $read, $red, $ReportGUI, $shell, $size, $style, $text, $title, $top, $user, $width, $winpos, $yellow
	;
	$width = 690
	$height = 405
	$left = IniRead($inifle, "Report Window", "left", @DesktopWidth - $width - 25)
	$top = IniRead($inifle, "Report Window", "top", @DesktopHeight - $height - 60)
	$style = $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU + $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX ; + $WS_VISIBLE
	$ReportGUI = GuiCreate($Scriptname, $width, $height, $left, $top, $style, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
	GUISetBkColor(0xBBFFBB, $ReportGUI)
	; CONTROLS
	$Listview_games = GUICtrlCreateListView("", 5, 5, 680, 360, $LVS_REPORT + $LVS_SINGLESEL + $LVS_SHOWSELALWAYS, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES) ; + $LVS_SORTASCENDING
	GUICtrlSetBkColor($Listview_games, 0xFFFFB0)
	GUICtrlSetFont($Listview_games, 8, 400, 0, "Tahoma")
	;GUICtrlSetFont($Listview_games, 7, 400, 0, "Small Fonts")
	GUICtrlSetTip($Listview_games, "List of games!")
	_GUICtrlListView_AddColumn($Listview_games, "No.", 40, 2)
	_GUICtrlListView_AddColumn($Listview_games, "Game Title", 210, 0)
	_GUICtrlListView_AddColumn($Listview_games, "File", 185, 0)
	_GUICtrlListView_AddColumn($Listview_games, "Manifest", 58, 2)
	_GUICtrlListView_AddColumn($Listview_games, "Folder", 50, 2)
	_GUICtrlListView_AddColumn($Listview_games, "Size", 40, 2)
	_GUICtrlListView_AddColumn($Listview_games, "Date", 70, 2)
	;
	$Input_title = GUICtrlCreateInput("", 5, 375, 300, 22)
	GUICtrlSetBkColor($Input_title, 0xFFFFB0)
	GUICtrlSetTip($Input_title, "Game Title or Slug!")
	;
	$Input_file = GUICtrlCreateInput("", 310, 375, 320, 22)
	GUICtrlSetBkColor($Input_file, 0xFFFFB0)
	GUICtrlSetTip($Input_file, "Game File!")
	;
	$Button_find = GuiCtrlCreateButton("?", 635, 374, 22, 22, $BS_ICON)
	GUICtrlSetTip($Button_find, "Find the specified text in the list!")
	;
	$Button_clr = GuiCtrlCreateButton("C", 663, 374, 22, 22, $BS_ICON)
	GUICtrlSetTip($Button_clr, "Clear the search text!")
	;
	$lowid = $Button_find
	;
	; OS SETTINGS
	$user = @SystemDir & "\user32.dll"
	$shell = @SystemDir & "\shell32.dll"
	$icoR = -239
	$icoS = -23
	GUICtrlSetImage($Button_find, $shell, $icoS, 0)
	GUICtrlSetImage($Button_clr, $shell, $icoR, 0)
	;
	; SETTINGS
	$red = IniRead($inifle, "Compare Options", "red", "")
	$orange = IniRead($inifle, "Compare Options", "orange", "")
	$yellow = IniRead($inifle, "Compare Options", "yellow", "")
	$aqua = IniRead($inifle, "Compare Options", "aqua", "")
	;
	$cnt = _FileCountLines($compare)
	If $cnt > 0 Then
		$last = ""
		$num = 0
		$read = FileRead($compare)
		$lines = StringSplit($read, @CRLF)
		For $l = 1 To $lines[0]
			$line = $lines[$l]
			If $line <> "" Then
				$title = StringSplit($line, " | ", 1)
				If $title[0] = 6 Then
					$files = $title[2]
					$manifest = $title[3]
					$folder = $title[4]
					$size = $title[5]
					$title = $title[1]
					;$num = StringRight( "00" & $num + 1, 4)
					$num = $num + 1
					$entry = $num & "|" & StringReplace($line, " | ", "|")
					$id = GUICtrlCreateListViewItem($entry, $Listview_games)
					If $folder = "no" And $red = 1 Then
						GUICtrlSetBkColor($id, $COLOR_RED)
					ElseIf $size = "fail" And $orange = 1 Then
						GUICtrlSetBkColor($id, 0xFF8000)
					ElseIf $size = "no" And $manifest = "yes" And $yellow = 1 Then
						GUICtrlSetBkColor($id, $COLOR_YELLOW)
					ElseIf $files = "manifest entry missing" And $aqua = 1 Then
						GUICtrlSetBkColor($id, $COLOR_AQUA)
					Else
						If $last = "" Then
							$last = $title
							$color = 0xFFB9DC
						ElseIf $last <> $title Then
							$last = $title
							If $color = 0xFFB9DC Then
								$color = $COLOR_SKYBLUE
							Else
								$color = 0xFFB9DC
							EndIf
						EndIf
						GUICtrlSetBkColor($id, $color)
					EndIf
				EndIf
			EndIf
		Next
		;SetTheColumnWidths()
	EndIf

	GuiSetState(@SW_SHOWNORMAL, $ReportGUI)
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE
			; Exit / Close / Quit the program
			$winpos = WinGetPos($ReportGUI, "")
			$left = $winpos[0]
			If $left < 0 Then
				$left = 2
			ElseIf $left > @DesktopWidth - $width Then
				$left = @DesktopWidth - $width - 25
			EndIf
			IniWrite($inifle, "Report Window", "left", $left)
			$top = $winpos[1]
			If $top < 0 Then
				$top = 2
			ElseIf $top > @DesktopHeight - ($height + 20) Then
				$top = @DesktopHeight - $height - 60
			EndIf
			IniWrite($inifle, "Report Window", "top", $top)
			;
			GUIDelete($ReportGUI)
			ExitLoop
		Case $msg = $Button_find
			; Find the specified game title on list
			$text = GUICtrlRead($Input_file)
			If $text <> "" Then
				If $find = "" Then $find = $text
				If $ind = "" Then
					$ind = 0
				EndIf
				$ind = _GUICtrlListView_FindInText($Listview_games, $find, $ind, True, False)
				If $ind > -1 Then
					GUICtrlSetState($Listview_games, $GUI_FOCUS)
					_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
					ContinueLoop
				EndIf
			Else
				MsgBox(262192, "Find Error", "No text specified!", 0, $ReportGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_clr
			; Clear the search text
			$find = ""
			GUICtrlSetData($Input_file, "")
			GUICtrlSetState($Input_file, $GUI_FOCUS)
		Case $msg = $Listview_games Or $msg > $lowid
			; List of games
			$col = GUICtrlGetState($Listview_games)
			If $col > -1 Then
				_GUICtrlListView_SimpleSort($Listview_games, False, $col)
			Else
				$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
				$ind = Number($ind)
				$title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1)
				GUICtrlSetData($Input_title, $title)
				$file = _GUICtrlListView_GetItemText($Listview_games, $ind, 2)
				GUICtrlSetData($Input_file, $file)
				;$tagtxt = IniRead($tagfle, $ID, "comment", "")
				;If $tagtxt <> "" Then
				;	MsgBox(262208, "Tag Comment", $tagtxt, 0, $ReportGUI)
				;EndIf
			EndIf
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> MainGUI
