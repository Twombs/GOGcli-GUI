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
; BackupManifestEtc(), ClearFieldValues(), CompareFilesToManifest($numb), FillTheGamesList(), FixTitle($text)
; GetChecksumQuery($rat), GetFileDownloadDetails($listview), GetGameFolderNameAndPath($titleF, $slugF), GetManifestForTitle()
; GetTheSize(), ParseTheGamelist(), RetrieveDataFromGOG($listed, $list), SetStateOfControls($state, $which), ShowCorrectImage()
;
; , SetTheColumnWidths() UNUSED
;
; _Zip_DllChk(), _Zip_List($zipfile)

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
#include <SendMessage.au3>
#include <MsgBoxConstants.au3>

Local $exe, $script, $status, $w, $wins

Global $handle, $pid, $Scriptname, $version

$version = "v2.0"
$Scriptname = "GOGcli GUI " & $version

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

Global $Button_dest, $Button_dir, $Button_down, $Button_exit, $Button_find, $Button_fold, $Button_game, $Button_get, $Button_info
Global $Button_last, $Button_log, $Button_man, $Button_pic, $Button_setup, $Button_sub, $Button_tag, $Button_web, $Checkbox_alpha
Global $Checkbox_show, $Combo_dest, $Group_cover, $Group_dest, $Group_games, $Input_cat, $Input_dest, $Input_dlc, $Input_key
Global $Input_OS, $Input_slug, $Input_title, $Input_ups, $Item_database_add, $Item_database_relax, $Item_down_all, $Item_verify_file
Global $Item_verify_game, $Label_bed, $Label_cat, $Label_dlc, $Label_key, $Label_mid, $Label_OS, $Label_slug, $Label_top, $Label_ups
Global $Listview_games, $Pic_cover

Global $7zip, $a, $addlist, $alert, $alerts, $alf, $alpha, $ans, $array, $backups, $bigcover, $bigpic, $blackjpg, $bytes, $caption
Global $category, $cdkey, $cdkeys, $checksum, $checkval, $cnt, $compare, $cookie, $cookies, $cover, $covers, $covimg, $declare, $dest
Global $details, $DLC, $dlcfile, $done, $downfiles, $downlist, $download, $downloads, $drv, $entries, $entry, $erred, $existDB, $exists
Global $f, $file, $fileinfo, $filepth, $files, $filesize, $flag, $fold, $found, $free, $game, $gamefold, $gamelist, $gamepic, $games
Global $gamesfold, $gamesini, $getlatest, $gogcli, $GOGcliGUI, $hash, $head, $height, $i, $icoD, $icoF, $icoI, $icoS, $icoT, $icoW
Global $icoX, $ID, $identry, $ignore, $image, $imgfle, $inifle, $json, $keep, $lang, $left, $line, $lines, $link, $list, $listed
Global $listview, $logfle, $lowid, $m, $manall, $manifest, $manifests, $manlist, $md5check, $minimize, $model, $n, $name, $num, $numb
Global $OP, $OS, $OSes, $overlook, $params, $part, $parts, $percent, $ping, $pinged, $progress, $pth, $rat, $ratify, $read, $record
Global $relax, $reportexe, $res, $ret, $row, $s, $same, $second, $selector, $SetupGUI, $shell, $size, $slug, $slugF, $slugfld, $space
Global $splash, $split, $splits, $state, $style, $tag, $tagfle, $tail, $text, $title, $titleF, $titlist, $top, $type, $types, $updated
Global $updates, $URL, $user, $validate, $verify, $web, $which, $width, $winpos, $z, $zipcheck, $zipfile, $zippath
;, $foldzip, $resultfle

$addlist = @ScriptDir & "\Added.txt"
$alerts = @ScriptDir & "\Alerts.txt"
$backups = @ScriptDir & "\Backups"
$bigpic = @ScriptDir & "\Big.jpg"
$blackjpg = @ScriptDir & "\Black.jpg"
$cdkeys = @ScriptDir & "\CDkeys.ini"
$compare = @ScriptDir & "\Comparisons.txt"
$cookies = @ScriptDir & "\Cookie.txt"
$covers = @ScriptDir & "\Covers"
$details = @ScriptDir & "\Detail.txt"
$dlcfile = @ScriptDir & "\DLCs.ini"
$downfiles = @ScriptDir & "\Downfiles.ini"
$downlist = @ScriptDir & "\Downloads.txt"
$existDB = @ScriptDir & "\Database.ini"
$fileinfo = @ScriptDir & "\Fileinfo.txt"
;$foldzip = @ScriptDir & "\7-Zip"
$gamelist = @ScriptDir & "\Games.txt"
$gamesini = @ScriptDir & "\Games.ini"
$gogcli = @ScriptDir & "\gogcli.exe"
$imgfle = @ScriptDir & "\Image.jpg"
$inifle = @ScriptDir & "\Settings.ini"
$json = @ScriptDir & "\manifest.json"
$logfle = @ScriptDir & "\Log.txt"
$manifest = @ScriptDir & "\Manifest.txt"
$manlist = @ScriptDir & "\Manifests.txt"
$reportexe = @ScriptDir & "\Report.exe"
;$resultfle = @ScriptDir & "\Results.txt"
$splash = @ScriptDir & "\Splash.jpg"
$tagfle = @ScriptDir & "\Tags.ini"
$titlist = @ScriptDir & "\Titles.txt"
$updated = @ScriptDir & "\Updated.txt"

If Not FileExists($addlist) Then _FileCreate($addlist)
If Not FileExists($covers) Then DirCreate($covers)
If Not FileExists($downlist) Then _FileCreate($downlist)
;~ If Not FileExists($foldzip) Then DirCreate($foldzip)
If Not FileExists($updated) Then _FileCreate($updated)

MainGUI()

Exit


Func MainGUI()
	Local $Checkbox_quit, $Checkbox_stop, $Menu_down, $Menu_get, $Menu_list, $Menu_man, $Menu_compare_opts
	Local $Item_alerts_clear, $Item_alerts_view, $Item_clear_down, $Item_clear_man, $Item_compare_all, $Item_compare_aqua
	Local $Item_compare_declare, $Item_compare_ignore, $Item_compare_one, $Item_compare_orange, $Item_compare_overlook
	Local $Item_compare_red, $Item_compare_rep, $Item_compare_report, $Item_compare_view, $Item_compare_wipe
	Local $Item_compare_yellow, $Item_database_view, $Item_lists_dlcs, $Item_lists_keys, $Item_lists_latest
	Local $Item_lists_tags, $Item_lists_updated, $Item_manifest_fix, $Item_view_down, $Item_view_man
	Local $Sub_menu_alerts, $Sub_menu_comparisons, $Sub_menu_database, $Sub_menu_downloads, $Sub_menu_lists, $Sub_menu_manifests
	;
	Local $accept, $addto, $alias, $aqua, $buttxt, $c, $chunk, $col1, $col2, $col3, $col4, $compall, $compone, $ctrl, $dir
	Local $display, $dll, $e, $exist, $existing, $fext, $filelist, $find, $fixed, $flename, $foldpth, $IDD, $ids, $ind, $l
	Local $language, $languages, $last, $latest, $loop, $mans, $mpos, $OPS, $orange, $p, $patchfld, $pos, $prior, $proceed
	Local $query, $red, $rep, $result, $retrieve, $sect, $sects, $slugD, $tagtxt, $tested, $titleD, $valfold, $values, $xpos
	Local $yellow, $ypos
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
	$GOGcliGUI = GuiCreate($Scriptname, $width, $height, $left, $top, $style, $WS_EX_TOPMOST + $WS_EX_ACCEPTFILES)
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
	$Label_slug = GuiCtrlCreateLabel("Slug", 20, 301, 35, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN + $SS_NOTIFY)
	GUICtrlSetBkColor($Label_slug, $COLOR_BLUE)
	GUICtrlSetColor($Label_slug, $COLOR_WHITE)
	;GUICtrlSetTip($Label_slug, "Click to create Slug named sub-folder in selected game folder!")
	$Input_slug = GUICtrlCreateInput("", 55, 301, 230, 20) ;, $ES_READONLY
	GUICtrlSetBkColor($Input_slug, 0xBBFFBB)
	GUICtrlSetTip($Input_slug, "Game Slug!")
	$Button_sub = GuiCtrlCreateButton("SUB", 288, 300, 40, 22)
	GUICtrlSetFont($Button_sub, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_sub, "Create a Slug (etc) named sub-folder in selected game folder!")
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
	GUICtrlSetColor($Label_top, $COLOR_YELLOW) ;$COLOR_WHITE
	$Label_mid = GuiCtrlCreateLabel("", 405, 70, 160, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor($Label_mid, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_mid, $COLOR_WHITE)
	$Label_bed = GuiCtrlCreateLabel("", 405, 100, 160, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont($Label_bed, 8, 600)
	GUICtrlSetBkColor($Label_bed, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_bed, $COLOR_RED) ;$COLOR_WHITE
	$Button_pic = GuiCtrlCreateButton("Download Cover", 400, 135, 120, 25)
	GUICtrlSetFont($Button_pic, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_pic, "Download the selected image!")
	$Checkbox_show = GUICtrlCreateCheckbox("Show", 525, 138, 45, 20)
	GUICtrlSetTip($Checkbox_show, "Show the cover image!")
	;
	$Checkbox_quit = GUICtrlCreateCheckbox("STOP", 420, 199, 50, 18)
	GUICtrlSetTip($Checkbox_quit, "STOP comparing!")
	GUICtrlSetState($Checkbox_quit, $GUI_HIDE)
	;
	$Button_get = GuiCtrlCreateButton("CHECK or GET" & @LF & "GAMES LIST", 390, 180, 100, 35, $BS_MULTILINE)
	GUICtrlSetFont($Button_get, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_get, "Get game titles from GOG library!")
	;
	$Button_down = GuiCtrlCreateButton("DOWNLOAD", 500, 180, 80, 35, $BS_MULTILINE)
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
	$Label_key = GuiCtrlCreateLabel("KEY", 534, 248, 31, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_key, $COLOR_BLUE)
	GUICtrlSetColor($Label_key, $COLOR_WHITE)
	GUICtrlSetFont($Label_key, 8, 400)
	$Input_key = GUICtrlCreateInput("", 565, 248, 15, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_key, 0xBBFFBB)
	GUICtrlSetFont($Input_key, 8, 400)
	GUICtrlSetTip($Input_key, "Game Key or Code etc!")
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
	$Label_dlc = GuiCtrlCreateLabel("DLC", 465, 272, 31, 19, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetBkColor($Label_dlc, $COLOR_BLUE)
	GUICtrlSetColor($Label_dlc, $COLOR_WHITE)
	GUICtrlSetFont($Label_dlc, 8, 400)
	$Input_dlc = GUICtrlCreateInput("", 496, 272, 21, 19, $ES_READONLY)
	GUICtrlSetBkColor($Input_dlc, 0xBBFFBB)
	GUICtrlSetFont($Input_dlc, 8, 400)
	GUICtrlSetTip($Input_dlc, "Game DLC!")
	;
	$Button_game = GuiCtrlCreateButton("DETAILS", 522, 271, 58, 21)
	GUICtrlSetFont($Button_game, 6, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_game, "View details of selected game!")
	;
	$Checkbox_stop = GUICtrlCreateCheckbox("STOP", 410, 319, 50, 18)
	GUICtrlSetTip($Checkbox_stop, "STOP getting manifests!")
	GUICtrlSetState($Checkbox_stop, $GUI_HIDE)
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
	$Button_log = GuiCtrlCreateButton("Log", 410, 345, 23, 23, $BS_ICON)
	GUICtrlSetTip($Button_log, "Log Record!")
	;
	$Button_dir = GuiCtrlCreateButton("D", 438, 345, 23, 23, $BS_ICON)
	GUICtrlSetTip($Button_dir, "Open the program folder!")
	;
	$Button_tag = GuiCtrlCreateButton("TAG IT", 410, 373, 52, 22)
	GUICtrlSetFont($Button_tag, 7, 600, 0, "Small Fonts")
	GUICtrlSetTip($Button_tag, "Tag (color mark) the selected game title!")
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
	$Sub_menu_alerts = GUICtrlCreateMenu("Alerts", $Menu_list)
	$Item_alerts_view = GUICtrlCreateMenuItem("View Alerts", $Sub_menu_alerts)
	GUICtrlCreateMenuItem("", $Sub_menu_alerts)
	$Item_alerts_clear = GUICtrlCreateMenuItem("Clear Alerts", $Sub_menu_alerts)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Sub_menu_comparisons = GUICtrlCreateMenu("Comparisons", $Menu_list)
	$Item_compare_rep = GUICtrlCreateMenuItem("Comparison Report", $Sub_menu_comparisons)
	GUICtrlCreateMenuItem("", $Sub_menu_comparisons)
	$Item_compare_view = GUICtrlCreateMenuItem("View Comparison File", $Sub_menu_comparisons)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Menu_compare_opts = GUICtrlCreateMenu("Comparison Settings", $Menu_list)
	$Item_compare_ignore = GUICtrlCreateMenuItem("Ignore Missing Folders", $Menu_compare_opts, -1, 0)
	$Item_compare_report = GUICtrlCreateMenuItem("Report Missing Folders", $Menu_compare_opts, -1, 0)
	GUICtrlCreateMenuItem("", $Menu_compare_opts)
	$Item_compare_overlook = GUICtrlCreateMenuItem("Ignore Missing Manifest Entry", $Menu_compare_opts, -1, 0)
	$Item_compare_declare = GUICtrlCreateMenuItem("Report Missing Manifest Entry", $Menu_compare_opts, -1, 0)
	GUICtrlCreateMenuItem("", $Menu_compare_opts)
	$Item_compare_red = GUICtrlCreateMenuItem("Missing Files (RED)", $Menu_compare_opts, -1, 0)
	$Item_compare_orange = GUICtrlCreateMenuItem("Wrong Size (ORANGE)", $Menu_compare_opts, -1, 0)
	$Item_compare_yellow = GUICtrlCreateMenuItem("No Size (YELLOW)", $Menu_compare_opts, -1, 0)
	$Item_compare_aqua = GUICtrlCreateMenuItem("No Manifest Entry (AQUA)", $Menu_compare_opts, -1, 0)
	GUICtrlCreateMenuItem("", $Sub_menu_comparisons)
	$Item_compare_wipe = GUICtrlCreateMenuItem("Wipe Comparison File", $Sub_menu_comparisons)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Sub_menu_database = GUICtrlCreateMenu("Database", $Menu_list)
	$Item_database_relax = GUICtrlCreateMenuItem("Relax The Rules", $Sub_menu_database, -1, 0)
	GUICtrlCreateMenuItem("", $Sub_menu_downloads)
	$Item_database_view = GUICtrlCreateMenuItem("View The Database", $Sub_menu_database)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Sub_menu_downloads = GUICtrlCreateMenu("Downloads", $Menu_list)
	$Item_clear_down = GUICtrlCreateMenuItem("Clear Downloads List", $Sub_menu_downloads)
	GUICtrlCreateMenuItem("", $Sub_menu_downloads)
	$Item_view_down = GUICtrlCreateMenuItem("View Downloads List", $Sub_menu_downloads)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Sub_menu_lists = GUICtrlCreateMenu("Lists", $Menu_list)
	$Item_lists_latest = GUICtrlCreateMenuItem("Latest Additions", $Sub_menu_lists)
	GUICtrlCreateMenuItem("", $Sub_menu_lists)
	$Item_lists_updated = GUICtrlCreateMenuItem("Games Updated", $Sub_menu_lists)
	GUICtrlCreateMenuItem("", $Sub_menu_lists)
	$Item_lists_keys = GUICtrlCreateMenuItem("CDKeys", $Sub_menu_lists)
	GUICtrlCreateMenuItem("", $Sub_menu_lists)
	$Item_lists_dlcs = GUICtrlCreateMenuItem("DLCs", $Sub_menu_lists)
	GUICtrlCreateMenuItem("", $Sub_menu_lists)
	$Item_lists_tags = GUICtrlCreateMenuItem("Tags", $Sub_menu_lists)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Sub_menu_manifests = GUICtrlCreateMenu("Manifests", $Menu_list)
	$Item_clear_man = GUICtrlCreateMenuItem("Clear Manifests List", $Sub_menu_manifests)
	GUICtrlCreateMenuItem("", $Sub_menu_manifests)
	$Item_view_man = GUICtrlCreateMenuItem("View Manifests List", $Sub_menu_manifests)
	GUICtrlCreateMenuItem("", $Menu_list)
	GUICtrlCreateMenuItem("", $Menu_list)
	$Item_manifest_fix = GUICtrlCreateMenuItem("Check && Fix The Manifest", $Menu_list)
	;
	$Menu_get = GUICtrlCreateContextMenu($Button_get)
	$Item_compare_one = GUICtrlCreateMenuItem("Compare One Game", $Menu_get, -1, 0)
	GUICtrlCreateMenuItem("", $Menu_get)
	$Item_compare_all = GUICtrlCreateMenuItem("Compare ALL Games", $Menu_get, -1, 0)
	;
	$Menu_down = GUICtrlCreateContextMenu($Button_down)
	$Item_verify_file = GUICtrlCreateMenuItem("Validate File", $Menu_down, -1, 0)
	GUICtrlCreateMenuItem("", $Menu_down)
	$Item_verify_game = GUICtrlCreateMenuItem("Validate Game", $Menu_down, -1, 0)
	;
	$Menu_man = GUICtrlCreateContextMenu($Button_man)
	$Item_database_add = GUICtrlCreateMenuItem("ADD To Database", $Button_man, -1, 0)
	GUICtrlCreateMenuItem("", $Button_man)
	GUICtrlCreateMenuItem("", $Button_man)
	$Item_down_all = GUICtrlCreateMenuItem("Download ALL", $Menu_man, -1, 0)
	;
	$lowid = $Item_down_all
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
	GUICtrlSetImage($Button_log, $shell, $icoT, 0)
	GUICtrlSetImage($Button_dir, $shell, $icoD, 0)
	GUICtrlSetImage($Button_info, $user, $icoI, 1)
	GUICtrlSetImage($Button_exit, $user, $icoX, 1)
	;
	; SETTINGS
	$cnt = _FileCountLines($downlist)
	If $cnt > 0 Then
		GUICtrlSetData($Button_down, "DOWNLOAD" & @LF & "LIST")
		GUICtrlSetTip($Button_down, "Download with the download list!")
		GUICtrlSetState($Item_verify_file, $GUI_DISABLE)
		GUICtrlSetState($Item_verify_game, $GUI_DISABLE)
		$downloads = FileRead($downlist)
	Else
		$downloads = ""
	EndIf
	;
	$cnt = _FileCountLines($manlist)
	If $cnt > 0 Then
		GUICtrlSetState($Item_database_add, $GUI_DISABLE)
		GUICtrlSetState($Item_down_all, $GUI_DISABLE)
		GUICtrlSetData($Button_man, "MANIFEST" & @LF & "LIST")
		GUICtrlSetTip($Button_man, "Add selected game to manifest download list!")
		$manifests = FileRead($manlist)
	Else
		$manifests = ""
	EndIf
	$manall = 4
	;
	$exists = IniRead($inifle, "Exists Database", "use", "")
	If $exists = "" Then
		$exists = 1
		IniWrite($inifle, "Exists Database", "use", $exists)
	EndIf
	$relax = IniRead($inifle, "Exists Database", "relax", "")
	If $relax = "" Then
		$relax = 4
		IniWrite($inifle, "Exists Database", "relax", $relax)
	EndIf
	GUICtrlSetState($Item_database_relax, $relax)
	$addto = 4
	$foldpth = ""
	$query = ""
	;
	BackupManifestEtc()
	;
	$ignore = IniRead($inifle, "Compare Options", "ignore", "")
	If $ignore = "" Then
		$ignore = 4
		IniWrite($inifle, "Compare Options", "ignore", $ignore)
	EndIf
	GUICtrlSetState($Item_compare_ignore, $ignore)
	$record = IniRead($inifle, "Compare Options", "report", "")
	If $record = "" Then
		$record = 4
		IniWrite($inifle, "Compare Options", "report", $record)
	EndIf
	GUICtrlSetState($Item_compare_report, $record)
	$overlook = IniRead($inifle, "Compare Options", "overlook", "")
	If $overlook = "" Then
		$overlook = 4
		IniWrite($inifle, "Compare Options", "overlook", $overlook)
	EndIf
	GUICtrlSetState($Item_compare_overlook, $overlook)
	$declare = IniRead($inifle, "Compare Options", "declare", "")
	If $declare = "" Then
		$declare = 4
		IniWrite($inifle, "Compare Options", "declare", $declare)
	EndIf
	GUICtrlSetState($Item_compare_declare, $declare)
	$red = IniRead($inifle, "Compare Options", "red", "")
	If $red = "" Then
		$red = 1
		IniWrite($inifle, "Compare Options", "red", $red)
	EndIf
	GUICtrlSetState($Item_compare_red, $red)
	$orange = IniRead($inifle, "Compare Options", "orange", "")
	If $orange = "" Then
		$orange = 1
		IniWrite($inifle, "Compare Options", "orange", $orange)
	EndIf
	GUICtrlSetState($Item_compare_orange, $orange)
	$yellow = IniRead($inifle, "Compare Options", "yellow", "")
	If $yellow = "" Then
		$yellow = 1
		IniWrite($inifle, "Compare Options", "yellow", $yellow)
	EndIf
	GUICtrlSetState($Item_compare_yellow, $yellow)
	$aqua = IniRead($inifle, "Compare Options", "aqua", "")
	If $aqua = "" Then
		$aqua = 4
		IniWrite($inifle, "Compare Options", "aqua", $aqua)
	EndIf
	GUICtrlSetState($Item_compare_aqua, $aqua)
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
	$exist = FileExists($gogcli)
	If $exist <> 1 Or Not FileExists($cookies) Then
		SetStateOfControls($GUI_DISABLE)
		If $exist <> 1 Then GUICtrlSetState($Button_setup, $GUI_DISABLE)
	ElseIf $exist = 1 Then
		_Crypt_Startup()
		$hash = _Crypt_HashFile($gogcli, $CALG_MD5)
		$hash = StringTrimLeft($hash, 2)
		; Win32 or Win64
		If $hash = "3628874296eb56801d035ed94e08b3a5" Or $hash = "fed1bcfbee23cd70039836d49b97901d" Then
			; Note - v0.1.1 (Win64 only) and v0.1.2 have the same Win 64 version.
			$model = 1
		ElseIf $hash = "0e14a4ecd72b1df04e7b5161edd09157" Or $hash = "6293d448cafabea81fd9ebef325be1c9" Then
			$model = 2
		ElseIf $hash = "7ea8487d664d77b17fba01654534b2a8" Or $hash = "663e7644144bb8dd69bdaf8d947d699b" Then
			$model = 3
		ElseIf $hash = "eb31b8e2e92f23b21fbec12a46bd018b" Or $hash = "1b415189123f4af596739a5b8e365a23" Then
			$model = 4
		ElseIf $hash = "2aaa0e08a43851e0d45dcd06467d4307" Or $hash = "d9ac73f14ff470683f3855125fcc4912" Then
			$model = 5
		ElseIf $hash = "426c2f4b9cc1598cd599b41443e8cb86" Or $hash = "0f8800e625c60a2f34b727596258cee3" Then
			$model = 5.1
		ElseIf $hash = "c2a8c97eb9072297922c5e8084039e33" Or $hash = "3b0eca66a859494307973a80e47524cd" Then
			$model = 6
		ElseIf $hash = "8277fd2044f922e7aff000596a56f39a" Or $hash = "5e0fe5090fc4d9f252c6e16e771bf8ae" Then
			$model = 7
		ElseIf $hash = "9d3cb9df6fae01ab13f608de5cbc8bbf" Or $hash = "2b0cea101bb12a00bd73dfd1b58f5253" Then
			$model = 8
		ElseIf $hash = "ba659ad7e3cc33b0bc0b600302fe308e" Or $hash = "336c9416f6dc6d28c8337ad8283173ad" Then
			$model = 9
		ElseIf $hash = "4e9024fafe084b48aab64dc079436e82" Or $hash = "d9caee3343f5dad898ceefff5860d8d8" Then
			$model = 10
		Else
			$model = 666
			$accept = IniRead($inifle, "gogcli.exe", "accept", "")
			If $accept <> 1 Then
				IniWrite($inifle, "gogcli.exe", "accept", 4)
				$ans = MsgBox(262177 + 256, "WARNING", "The version of 'gogcli.exe' isn't recognized!" & @LF & @LF _
					& "THIS VERSION MAY CAUSE PROBLEMS" & @LF & @LF _
					& "Do you want to continue?" & @LF & @LF _
					& "NOTE - If you are happy to continue and" & @LF _
					& "want to avoid seeing this message every" & @LF _
					& "program start, then you could manually" & @LF _
					& "adjust the 'accept=4' value to 'accept=1'" & @LF _
					& "in the 'Settings.ini' file.", 0, $GOGcliGUI)
				If $ans = 2 Then Exit
			EndIf
		EndIf
		IniWrite($inifle, "gogcli.exe", "version", $model)
		If $model <> 666 Then IniWrite($inifle, "gogcli.exe", "accept", 4)
		_Crypt_Shutdown()
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
	$compall = 4
	$compone = 4
	$existing = ""
	$find = ""
	$last = ""
	$ratify = 4
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
	; Testing only
	;GUICtrlSetData($Label_top, "123456789012345....")
	;
	If FileExists($alerts) Then
		$cnt = _FileCountLines($alerts)
		If $cnt > 0 Then
			GUICtrlSetData($Label_top, "Changed Filename(s)")
			GUICtrlSetData($Label_mid, "Check the 'Alerts.txt' File")
			GUICtrlSetData($Label_bed, $cnt & " file(s) changed")
		EndIf
	EndIf
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
		Case $msg = $Button_tag
			; Tag (color mark) the selected game title
			If _IsPressed("11") Then
				If FileExists($tagfle) Then ShellExecute($tagfle)
			Else
				$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
				If $ind = "" Then $ind = -1
				If $ind = -1 Then
					MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
				Else
					$ind = Number($ind)
					If $title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1) Then
						$tag = IniRead($tagfle, $ID, "tagged", "")
						If $tag = "" Then
							$tagtxt = InputBox("Game Tag - " & $title, "OK = Tag. Add some comments if you wish.", "", "", 500, 130, Default, Default, 0, $GOGcliGUI)
							If Not @error Then
								$tag = 1
								IniWrite($tagfle, $ID, "tagged", $tag)
								IniWrite($tagfle, $ID, "title", $title)
								IniWrite($tagfle, $ID, "comment", $tagtxt)
								$row = $lowid + $ind + 1
								If $updates = 0 Then
									GUICtrlSetBkColor($row, $COLOR_AQUA)
								Else
									GUICtrlSetBkColor($row, 0x8080FF)
								EndIf
								_FileWriteLog($logfle, "Tagged = " & $title, -1)
							EndIf
						Else
							$ans = MsgBox(262179 + 256, "Removal Query", "Do you want to remove the tag?" & @LF & @LF & _
								"YES = Remove. NO = Edit. CANCEL = Skip.", 0, $GOGcliGUI)
							If $ans = 6 Then
								IniDelete($tagfle, $ID)
								$row = $lowid + $ind + 1
								If $updates = 0 Then
									If StringIsDigit($row / 2) Then
										GUICtrlSetBkColor($row, 0xF0D0F0)
									Else
										GUICtrlSetBkColor($row, 0xBBFFBB)
									EndIf
								Else
									GUICtrlSetBkColor($row, $COLOR_RED)
								EndIf
								_FileWriteLog($logfle, "Tag Removed = " & $title, -1)
							ElseIf $ans = 7 Then
								$tagtxt = IniRead($tagfle, $ID, "comment", "")
								$tagtxt = InputBox("Game Tag", "Edit the current comments.", $tagtxt, "", 400, 130, Default, Default, 0, $GOGcliGUI)
								If Not @error Then
									IniWrite($tagfle, $ID, "comment", $tagtxt)
								EndIf
							EndIf
						EndIf
					Else
						MsgBox(262192, "Title Error", "A game is not selected correctly!", 0, $GOGcliGUI)
					EndIf
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_sub
			; Create a Slug (etc) named sub-folder in the selected game folder
			If FileExists($gamesfold) Then
				If $title <> "" Then
					GetGameFolderNameAndPath($title, $slug)
					If FileExists($gamefold) Then
						$ans = MsgBox(262177 + 256, "Create & Relocate Query - OS", _
							"This option creates a sub-folder in the destination folder" & @LF & _
							"of the selected game title, using the 'Slug' title as name." & @LF & @LF & _
							"The process also copies any 'Folder.jpg' file to that new" & @LF & _
							"sub-folder, along with moving (relocating) any Linux or" & @LF & _
							"Mac files to it as well." & @LF & @LF & _
							"Click OK to continue ... or CANCEL to skip to next." & @LF & @LF & _
							"NOTE - Create a Patches sub-folder query comes next.", 0, $GOGcliGUI)
						If $ans = 1 Then
							$slugfld = $gamefold & "\" & $slug
							If Not FileExists($slugfld) Then DirCreate($slugfld)
							If FileExists($slugfld) Then
								FileCopy($gamefold & "\Folder.jpg", $slugfld & "\")
								FileMove($gamefold & "\*.sh", $slugfld & "\")
								FileMove($gamefold & "\*.dmg", $slugfld & "\")
								FileMove($gamefold & "\*.pkg", $slugfld & "\")
							EndIf
						EndIf
						$ans = MsgBox(262177 + 256, "Create & Relocate Query - Patches", _
							"This option creates a sub-folder in the destination folder of" & @LF & _
							"the selected game title, using the text '_Patches' as name." & @LF & @LF & _
							"The process also copies any 'patch' named files to that new" & @LF & _
							"sub-folder." & @LF & @LF & _
							"Click OK to continue ... or CANCEL to abort.", 0, $GOGcliGUI)
						If $ans = 1 Then
							$patchfld = $gamefold & "\_Patches"
							If Not FileExists($patchfld) Then DirCreate($patchfld)
							If FileExists($patchfld) Then
								FileMove($gamefold & "\patch*.exe", $patchfld & "\")
								FileMove($gamefold & "\patch*.bin", $patchfld & "\")
								FileMove($gamefold & "\patch*.sh", $patchfld & "\")
								FileMove($gamefold & "\patch*.dmg", $patchfld & "\")
								FileMove($gamefold & "\patch*.pkg", $patchfld & "\")
							EndIf
						EndIf
					Else
						MsgBox(262192, "Path Error", "Game folder does not exist!", 0, $GOGcliGUI)
					EndIf
				Else
					MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
				EndIf
			Else
				MsgBox(262192, "Path Error", "Games folder does not exist!" & @LF & @LF & "( i.e. Drive is disconnected )", 0, $GOGcliGUI)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_setup
			; Setup window
			GuiSetState(@SW_DISABLE, $GOGcliGUI)
			SetupGUI()
			GuiSetState(@SW_ENABLE, $GOGcliGUI)
			;$window = $GOGcliGUI
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
						GetGameFolderNameAndPath($title, $slug)
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
				$mans = ""
				If FileExists($json) Then
					$read = FileRead($json)
					$read = StringSplit($read, '"Id": ', 1)
					$read = $read[0] - 1
				Else
					$read = 0
				EndIf
				$mans = $read & " game(s) in 'manifest.json' file."
				If FileExists($manifest) Then
					$read = FileRead($manifest)
					$read = StringSplit($read, '"Id": ', 1)
					$read = $read[0] - 1
				Else
					$read = 0
				EndIf
				$mans = $mans & @LF & $read & " game(s) in 'Manifest.txt' file."
				$ans = MsgBox(262179 + 256, "View Query", _
					$mans & @LF & @LF & _
					"YES = View the 'manifest.json' file." & @LF & _
					"NO = View the 'Manifest.txt' file." & @LF & _
					"CANCEL = Abort viewing.", 0, $GOGcliGUI)
				If $ans = 6 Then
					If FileExists($json) Then Run(@ProgramFilesDir & "\Windows NT\Accessories\wordpad.exe " & $json)
				ElseIf $ans = 7 Then
					If FileExists($manifest) Then Run(@ProgramFilesDir & "\Windows NT\Accessories\wordpad.exe " & $manifest)
				EndIf
			Else
				$buttxt = GUICtrlRead($Button_man)
				$ctrl = _IsPressed("11")
				If $title = "" And ($buttxt = "ADD TO" & @LF & "MANIFEST" Or $buttxt = "ADD TO" & @LF & "DATABASE" Or ($buttxt = "MANIFEST" & @LF & "LIST" And $ctrl = True)) Then
					MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
				Else
					If $ctrl = True Then
						If $buttxt = "MANIFEST" & @LF & "FOR ALL" Then
							MsgBox(262192, "Add Error", "MANIFEST FOR ALL is active!", 2, $GOGcliGUI)
						ElseIf $buttxt = "ADD TO" & @LF & "DATABASE" Then
							MsgBox(262192, "Add Error", "ADD TO DATABASE is active!", 2, $GOGcliGUI)
						Else
							; CTRL
							$cnt = _FileCountLines($manlist)
							If $cnt < 20 Then
								If FileExists($manifest) Then
									If $existing = "" Then $existing = FileRead($manifest)
									$identry = '"Id": ' & $ID & ','
									If StringInStr($existing, $identry) > 0 Then
										; Entry already exists in the manifest.
										$ans = MsgBox(262177 + 256, "Update Query", "Entry already exists in the manifest." & @LF & @LF & _
											"OK = ADD anyway. CANCEL = Skip.", 0, $GOGcliGUI)
										If $ans = 2 Then ContinueLoop
									EndIf
								EndIf
								If $buttxt <> "MANIFEST" & @LF & "LIST" Then
									GUICtrlSetState($Item_database_add, $GUI_DISABLE)
									GUICtrlSetState($Item_down_all, $GUI_DISABLE)
									GUICtrlSetData($Button_man, "MANIFEST" & @LF & "LIST")
									GUICtrlSetState($Listview_games, $GUI_FOCUS)
								EndIf
								$entry = $title & "|" & $ID & @CRLF
								If $manifests = "" Then
									; Start the list.
									FileWriteLine($manlist, $entry)
									$manifests = $entry
								Else
									; Check the list.
									If StringInStr($manifests, $entry) < 1 Then
										; Add new unique entry.
										FileWriteLine($manlist, $entry)
										$manifests = $manifests & $entry
									EndIf
								EndIf
							Else
								MsgBox(262192, "Add Error", "Limit of 20 games has been reached!", 2, $GOGcliGUI)
							EndIf
						EndIf
					Else
						$existing = ""
						If $buttxt = "MANIFEST" & @LF & "LIST" Then
							;MsgBox(262192, "Manifest Error", "This feature is not yet supported!", 2, $GOGcliGUI)
							SetStateOfControls($GUI_DISABLE, "all")
							GUICtrlSetImage($Pic_cover, $blackjpg)
							RetrieveDataFromGOG($manifests, "manifest")
							GUICtrlSetData($Label_mid, "")
							SetStateOfControls($GUI_ENABLE, "all")
							GUICtrlSetState($Listview_games, $GUI_FOCUS)
							_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
						ElseIf $buttxt = "ADD TO" & @LF & "DATABASE" Then
							If $query = "no" Then
								$ans = 6
							Else
								$ans = MsgBox(262195, "ADD To Database Query", "A game (and existing files) can be added individually to the" & @LF _
									& "'Exists' database, or the full list of games can be processed." & @LF & @LF _
									& "YES = Selected Game Only." & @LF _
									& "NO = ADD ALL Games." & @LF _
									& "CANCEL = Abort any ADD." & @LF & @LF _
									& "NOTE - If YES is selected, you won't see this query again," & @LF _
									& "until resetting the button text to 'ADD TO MANIFEST'." & @LF & @LF _
									& "IMPORTANT - If NO is selected, then matching game title(s)" & @LF _
									& "to game folder name(s) determines the chance of success." & @LF _
									& "Any mismatches, you will need to process individually." & @LF _
									& "See the Log for successes and or failures.", 0, $GOGcliGUI)
							EndIf
							If $ans <> 2 And $slug <> "" Then
								If $ans = 7 Then
									MsgBox(262192, "ADD Error", "This feature is not yet supported!", 2, $GOGcliGUI)
									GUICtrlSetState($Listview_games, $GUI_FOCUS)
									_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
									ContinueLoop
								EndIf
								SetStateOfControls($GUI_DISABLE, "all")
								GUICtrlSetImage($Pic_cover, $blackjpg)
								GUICtrlSetData($Label_mid, "Adding To Database")
								If $ans = 6 Then
									$query = "no"
									GUICtrlSetData($Label_top, "ADDING ONE")
									;AddToDatabase()
									If $slug <> "" Then
										Local $md5 = ""
										$ans = MsgBox(262193 + 256, "Checksum Query", "Do you want to include MD5 values?" & @LF & @LF _
											& "NOTE - Obtaining MD5 (checksum) values is not" & @LF _
											& "recommended, unless you have downloaded this" & @LF _
											& "game recently, and not updated its manifest entry" & @LF _
											& "since then. If in doubt, you should exclude.", 0, $GOGcliGUI)
										If $ans = 1 Then
											$read = FileRead($manifest)
											If $read = "" Then
												MsgBox(262192, "Data Error", "Manifest is empty!" & @LF & @LF & "Populate the manifest first.", 0, $GOGcliGUI)
											Else
												$identry = '"Id": ' & $ID & ','
												If StringInStr($read, $identry) > 0 Then
													$game = StringSplit($read, $identry, 1)
													$game = $game[2]
													$game = StringSplit($game, '"Id":', 1)
													$game = $game[1]
													If $game <> "" Then
														$md5 = 1
													EndIf
												EndIf
											EndIf
										EndIf
										If $foldpth = "" Then $foldpth = $gamesfold
										$pth = FileSelectFolder("Browse to select the game folder.", $foldpth, 7, "", $GOGcliGUI)
										If Not @error And StringMid($pth, 2, 2) = ":\" Then
											_FileWriteLog($logfle, "ADDING GAME to Database.", -1)
											_FileWriteLog($logfle, $title, -1)
											$foldpth = $pth
											$filelist = _FileListToArrayRec($foldpth, "*.*", 1, 1, 0, 1)
											If @error Then $filelist = ""
											If IsArray($filelist) Then
												For $f = 1 To $filelist[0]
													$file = $filelist[$f]
													$filepth = $foldpth & "\" & $file
													_PathSplit($filepth, $drv, $dir, $flename, $fext)
													If $fext = ".exe" Or $fext = ".bin" Or $fext = ".dmg" Or $fext = ".pkg" Or $fext = ".sh" Or $fext = ".zip" Then
														$filesize = FileGetSize($filepth)
														If StringInStr($file, "\") > 0 Then $file = $flename & $fext
														_FileWriteLog($logfle, $file, -1)
														$checksum = ""
														If $md5 = 1 Then
															$sect = '"' & $file & '"'
															If StringInStr($game, $sect) > 0 Then
																$checksum = StringSplit($game, $sect, 1)
																$checksum = $checksum[2]
																$checksum = StringSplit($checksum, '"Checksum": "', 1)
																$checksum = $checksum[2]
																$checksum = StringSplit($checksum, '"', 1)
																$checksum = $checksum[1]
																$checksum = StringStripWS($checksum, 8)
																If $checksum <> "" Then _FileWriteLog($logfle, "MD5 (checksum) added.", -1)
															EndIf
														EndIf
														IniWrite($existDB, $file, $slug, $filesize & "|" & $checksum)
													EndIf
												Next
												$pos = StringInStr($slug, "chapter")
												$pos = $pos + StringInStr($slug, "episode")
												$pos = $pos + StringInStr($slug, "part")
												$pos = $pos + StringInStr($slug, "volume")
												If $pos > 0 Then
													MsgBox(262192, "Warning Alert & Advice", "Possible multiple game titles in a game folder detected." & @LF & @LF _
														& "If the content of the currently selected main game folder" & @LF _
														& "contains multiple game title content as deemed by GOG, " & @LF _
														& "and some are in sub-folders, then you must additionally" & @LF _
														& "process each of those sub-folders, or files will incorrectly" & @LF _
														& "exist in the database, paired to the wrong game title." & @LF & @LF _
														& "An example of this, is a game purchased from GOG that" & @LF _
														& "does not have its own title listing in your library, but has" & @LF _
														& "two or more chapter (or episode etc) title listings." & @LF & @LF _
														& "'Wallace & Gromit's Grand Adventures', is a recent game" & @LF _
														& "purchase I made at GOG, but there is no such game title" & @LF _
														& "in my GOG library, instead four chapter titles are listed as" & @LF _
														& "separate games." & @LF & @LF _
														& "The ADD TO DATABASE process requires linking a game" & @LF _
														& "title with a game folder, a problem when you have more" & @LF _
														& "than one candidate on your 'Games' list of titles, none of" & @LF _
														& "them being totally correct, but you have to choose one." & @LF & @LF _
														& "You can get around this issue, by having a sub-folder for" & @LF _
														& "each chapter title, and then adding them all individually" & @LF _
														& "to the database (after processing the main game folder" & @LF _
														& "first). Though you can skip the main folder if it doesn't" & @LF _
														& "contain (at root) any files (i.e. game extras) of its own." & @LF & @LF _
														& "Keywords for an alert - chapter, episode, part, volume.", 0, $GOGcliGUI)
												EndIf
											EndIf
											FileWriteLine($logfle, "")
										EndIf
										GUICtrlSetData($Label_top, "")
										GUICtrlSetData($Label_bed, "")
									EndIf
								Else
									$query = "yes"
									$cnt = _GUICtrlListView_GetItemCount($Listview_games)
									If $cnt > 0 Then
										GUICtrlSetData($Button_man, "Adding")
										GUICtrlSetPos($Button_man, 390, 300, 80, 18)
										GUICtrlSetState($Checkbox_stop, $GUI_SHOW)
										_FileWriteLog($logfle, "ADDING ALL to Database.", -1)
										GUICtrlSetData($Label_top, "ADDING ALL")
										$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
										If $ind = "" Then $ind = -1
										If $ind > -1 And $ind < $cnt Then
											$ans = MsgBox(262177 + 256, "Start Query", _
												"Do you want to start at the selected entry?" & @LF & @LF & _
												"OK = Start at selected entry, skipping any prior ones." & @LF & _
												"CANCEL = Start over from the beginning.", 0, $GOGcliGUI)
											If $ans = 2 Then
												$ind = 0
											EndIf
										Else
											$ind = 0
										EndIf
										$ind = Number($ind)
										For $i = $ind To ($cnt - 1)
											$ind = $i
											$num = $i + 1
											GUICtrlSetData($Label_bed, $num & " of " & $cnt)
											_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
											_GUICtrlListView_EnsureVisible($Listview_games, $ind, False)
											$ID = _GUICtrlListView_GetItemText($Listview_games, $ind, 0)
											$title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1)
											GUICtrlSetData($Input_title, $title)
											_FileWriteLog($logfle, $title, -1)
											$slug = IniRead($gamesini, $ID, "slug", "")
											GUICtrlSetData($Input_slug, $slug)
											$web = IniRead($gamesini, $ID, "URL", "")
											$category = IniRead($gamesini, $ID, "category", "")
											GUICtrlSetData($Input_cat, $category)
											$OSes = IniRead($gamesini, $ID, "OSes", "")
											GUICtrlSetData($Input_OS, $OSes)
											$DLC = IniRead($gamesini, $ID, "DLC", "")
											If $DLC = 0 Then $DLC = IniRead($dlcfile, $ID, "dlc", "0")
											GUICtrlSetData($Input_dlc, $DLC)
											$updates = IniRead($gamesini, $ID, "updates", "")
											GUICtrlSetData($Input_ups, $updates)
											$cdkey = IniRead($cdkeys, $ID, "keycode", "")
											If $cdkey = "" Then
												GUICtrlSetData($Input_key, 0)
											Else
												GUICtrlSetData($Input_key, 1)
											EndIf
											;AddToDatabase()
											If $erred > 0 Then ExitLoop
											If GUICtrlRead($Checkbox_stop) = $GUI_CHECKED Then
												GUICtrlSetState($Checkbox_stop, $GUI_UNCHECKED)
												ExitLoop
											EndIf
											;ExitLoop
										Next
										FileWriteLine($logfle, "")
										GUICtrlSetData($Label_top, "")
										GUICtrlSetData($Label_bed, "")
										GUICtrlSetState($Checkbox_stop, $GUI_HIDE)
										GUICtrlSetPos($Button_man, 390, 300, 80, 35)
										GUICtrlSetData($Button_man, "ADD TO" & @LF & "DATABASE")
									Else
										MsgBox(262192, "List Error", "No games found!", 0, $GOGcliGUI)
									EndIf
								EndIf
								GUICtrlSetData($Label_mid, "")
								SetStateOfControls($GUI_ENABLE, "all")
							EndIf
							GUICtrlSetState($Listview_games, $GUI_FOCUS)
							_GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
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
													$erred = 0
													$read = ""
													If $buttxt = "MANIFEST" & @LF & "FOR ALL" Then
														$cnt = _GUICtrlListView_GetItemCount($Listview_games)
														If $cnt > 0 Then
															GUICtrlSetData($Button_man, "Retrieving")
															GUICtrlSetPos($Button_man, 390, 300, 80, 18)
															GUICtrlSetState($Checkbox_stop, $GUI_SHOW)
															_FileWriteLog($logfle, "Get MANIFEST For ALL.", -1)
															GUICtrlSetData($Label_top, "MANIFEST FOR ALL")
															$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
															If $ind = "" Then $ind = -1
															If $ind > -1 And $ind < $cnt Then
																$ans = MsgBox(262177 + 256, "Start Query", _
																	"Do you want to start at the selected entry?" & @LF & @LF & _
																	"OK = Start at selected entry, skipping any prior ones." & @LF & _
																	"CANCEL = Start over from the beginning.", 0, $GOGcliGUI)
																If $ans = 2 Then
																	$ind = 0
																EndIf
															Else
																$ind = 0
															EndIf
															$ind = Number($ind)
															For $i = $ind To ($cnt - 1)
																$ind = $i
																$num = $i + 1
																GUICtrlSetData($Label_bed, $num & " of " & $cnt)
																_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
																_GUICtrlListView_EnsureVisible($Listview_games, $ind, False)
																$ID = _GUICtrlListView_GetItemText($Listview_games, $ind, 0)
																$title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1)
																GUICtrlSetData($Input_title, $title)
																$slug = IniRead($gamesini, $ID, "slug", "")
																GUICtrlSetData($Input_slug, $slug)
																$web = IniRead($gamesini, $ID, "URL", "")
																$category = IniRead($gamesini, $ID, "category", "")
																GUICtrlSetData($Input_cat, $category)
																$OSes = IniRead($gamesini, $ID, "OSes", "")
																GUICtrlSetData($Input_OS, $OSes)
																$DLC = IniRead($gamesini, $ID, "DLC", "")
																If $DLC = 0 Then $DLC = IniRead($dlcfile, $ID, "dlc", "0")
																GUICtrlSetData($Input_dlc, $DLC)
																$updates = IniRead($gamesini, $ID, "updates", "")
																GUICtrlSetData($Input_ups, $updates)
																$cdkey = IniRead($cdkeys, $ID, "keycode", "")
																If $cdkey = "" Then
																	GUICtrlSetData($Input_key, 0)
																Else
																	GUICtrlSetData($Input_key, 1)
																EndIf
																GetManifestForTitle()
																If $erred > 0 Then ExitLoop
																If GUICtrlRead($Checkbox_stop) = $GUI_CHECKED Then
																	GUICtrlSetState($Checkbox_stop, $GUI_UNCHECKED)
																	ExitLoop
																EndIf
																;ExitLoop
															Next
															GUICtrlSetData($Label_top, "")
															GUICtrlSetData($Label_bed, "")
															GUICtrlSetState($Checkbox_stop, $GUI_HIDE)
															GUICtrlSetPos($Button_man, 390, 300, 80, 35)
															GUICtrlSetData($Button_man, "MANIFEST" & @LF & "FOR ALL")
														Else
															MsgBox(262192, "List Error", "No games found!", 0, $GOGcliGUI)
														EndIf
													Else
														GetManifestForTitle()
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
				"The DOWNLOAD button has right-click VALIDATE options." & @LF & @LF & _
				"The LAST button cycles through latest game list additions." & @LF & _
				"The FIND button is also a next button for the text specified." & @LF & _
				"Both the FIND and LAST buttons remember their value, so" & @LF & _
				"to start afresh, hold down CTRL when clicking them." & @LF & @LF & _
				"The LOG button similarly has a hold down CTRL option, to" & @LF & _
				"see the 'Updated.txt' file instead." & @LF & @LF & _
				"If you hold down CTRL while clicking on the DOWNLOAD" & @LF & _
				"button, you can build a list to download with the selected" & @LF & _
				"game title. Likewise if you hold down CTRL while clicking" & @LF & _
				"on the MANIFEST button, you can build a list of manifest" & @LF & _
				"downloads. The following list options are also related." & @LF & @LF & _
				"The 'Games' list has some right-click menu options." & @LF & @LF & _
				"The MANIFEST button has another hold down option." & @LF & _
				"SHIFT = Get a query prompt to view a manifest file etc." & @LF & @LF & _
				"Click on Open the selected destination folder button with" & @LF & _
				"CTRL held down, to minimize the main program window." & @LF & @LF & _
				"Width of the 'Game Files Selector' window is adjustable." & @LF & @LF & _
				"Click OK to see more information.", 0, $GOGcliGUI)
			If $ans = 1 Then
				$ans = MsgBox(262209 + 256, "Program Information (continued)", _
					"DISCLAIMER - As always, you use my programs at your own" & @LF & _
					"risk. That said, I strive to ensure they work safe. I also cannot" & @LF & _
					"guarantee the results (or my read) of any 3rd party programs." & @LF & _
					"This is Freeware that I have voluntarily given many hours to." & @LF & @LF & _
					"BIG THANKS to Magnitus for 'gogcli.exe'.   (Model = " & $model & ")" & @LF & @LF & _
					"BIG THANKS to TerriblePurpose for encouragment support." & @LF & @LF & _
					"BIG thanks to j0kky (AutoIt Forum) for download size help," & @LF & _
					"and to torels_ & smashley (AutoIt Forum) for zip functions." & @LF & _
					"Praise & BIG thanks as always, to Jon & team for free AutoIt." & @LF & @LF & _
					"© February 2021 - Created by Timboli (aka TheSaint). (" & $version & ")" & @LF & @LF & _
					"Click OK to open the program folder.", 0, $GOGcliGUI)
				If $ans = 1 Then ShellExecute(@ScriptDir)
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_get
			; Get game titles from GOG library
			$buttxt = GUICtrlRead($Button_get)
			If $buttxt = "CHECK or GET" & @LF & "GAMES LIST" Then
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
			Else
				If FileExists($gamesfold) Then
					If FileExists($manifest) Then
						SetStateOfControls($GUI_DISABLE, "all")
						GUICtrlSetImage($Pic_cover, $blackjpg)
						GUICtrlSetData($Label_mid, "Game Folder && Manifest Check")
						$read = FileRead($manifest)
						If $read = "" Then
							MsgBox(262192, "Data Error", "Manifest is empty!" & @LF & @LF & "Populate the manifest first.", 0, $GOGcliGUI)
						Else
							If $buttxt = "COMPARE" & @LF & "ONE GAME" Then
								If $ID = "" Then
									MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
								Else
									If $title <> "" Then
										GUICtrlSetData($Label_top, "COMPARING ONE")
										CompareFilesToManifest("one")
										FileWriteLine($logfle, "")
										GUICtrlSetData($Label_top, "")
										GUICtrlSetData($Label_bed, "")
									Else
										MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
									EndIf
								EndIf
							ElseIf $buttxt = "COMPARE" & @LF & "ALL GAMES" Then
								If ProcessExists("Report.exe") Then
									$ans = MsgBox(262177 + 256, "Program Alert", "The 'Manifest Comparison Report' program" & @LF _
										& "window is running and needs to close." & @LF & @LF _
										& "OK = Close & Continue." & @LF _
										& "CANCEL = Abort Closure.", 0, $GOGcliGUI)
									If $ans = 1 Then
										ProcessClose("Report.exe")
									EndIf
								Else
									$ans = 1
								EndIf
								If $ans = 1 Then
									$ans = MsgBox(262195 + 512, "Compare Advice", "See the right-click 'Games' list menu compare options." & @LF _
										& "Those options dictate how the compare process works." & @LF & @LF _
										& "If both 'Ignore ...' options are enabled, then the process" & @LF _
										& "won't stop even if a folder or manifest entry is missing." & @LF _
										& "If you want missing game folders and manifest entries" & @LF _
										& "to be reported (recorded), enable a 'Report ...' option." & @LF & @LF _
										& "Do you want to wipe any prior report and continue?" & @LF & @LF _
										& "YES = Wipe & Continue." & @LF _
										& "NO = Just Continue, No Wipe." & @LF _
										& "CANCEL = Abort Comparing." & @LF & @LF _
										& "NOTE - If you are not continuing on from a previous" & @LF _
										& "'COMPARE ALL GAMES' process, it is recommended" & @LF _
										& "to clear (wipe) any prior report results. This prevents" & @LF _
										& "the possible mess (confusion) of duplicate entries.", 0, $GOGcliGUI)
									If $ans <> 2 Then
										;MsgBox(262192, "Compare Error", "This feature is not yet fully supported!", 2, $GOGcliGUI)advised
										If $ans = 6 Then _FileCreate($compare)
										$cnt = _GUICtrlListView_GetItemCount($Listview_games)
										If $cnt > 0 Then
											GUICtrlSetData($Button_get, "Compare All")
											GUICtrlSetPos($Button_get, 390, 180, 100, 18)
											GUICtrlSetState($Checkbox_quit, $GUI_SHOW)
											_FileWriteLog($logfle, "COMPARING all games.", -1)
											GUICtrlSetData($Label_top, "COMPARING ALL")
											$erred = 0
											$ind = _GUICtrlListView_GetSelectedIndices($Listview_games, False)
											If $ind = "" Then $ind = -1
											If $ind > -1 And $ind < $cnt Then
												$ans = MsgBox(262177 + 256, "Start Query", _
													"Do you want to start at the selected entry?" & @LF & @LF & _
													"OK = Start at selected entry, skipping any prior ones." & @LF & _
													"CANCEL = Start over from the beginning.", 0, $GOGcliGUI)
												If $ans = 2 Then
													$ind = 0
												EndIf
											Else
												$ind = 0
											EndIf
											$ind = Number($ind)
											For $i = $ind To ($cnt - 1)
												$ind = $i
												$num = $i + 1
												GUICtrlSetData($Label_bed, $num & " of " & $cnt)
												_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
												_GUICtrlListView_EnsureVisible($Listview_games, $ind, False)
												$ID = _GUICtrlListView_GetItemText($Listview_games, $ind, 0)
												$title = _GUICtrlListView_GetItemText($Listview_games, $ind, 1)
												GUICtrlSetData($Input_title, $title)
												$slug = IniRead($gamesini, $ID, "slug", "")
												GUICtrlSetData($Input_slug, $slug)
												$web = IniRead($gamesini, $ID, "URL", "")
												$category = IniRead($gamesini, $ID, "category", "")
												GUICtrlSetData($Input_cat, $category)
												$OSes = IniRead($gamesini, $ID, "OSes", "")
												GUICtrlSetData($Input_OS, $OSes)
												$DLC = IniRead($gamesini, $ID, "DLC", "")
												If $DLC = 0 Then $DLC = IniRead($dlcfile, $ID, "dlc", "0")
												GUICtrlSetData($Input_dlc, $DLC)
												$updates = IniRead($gamesini, $ID, "updates", "")
												GUICtrlSetData($Input_ups, $updates)
												$cdkey = IniRead($cdkeys, $ID, "keycode", "")
												If $cdkey = "" Then
													GUICtrlSetData($Input_key, 0)
												Else
													GUICtrlSetData($Input_key, 1)
												EndIf
												CompareFilesToManifest("all")
												If $erred > 2 Or ($erred = 1 And $ignore = 4) Or ($erred = 2 And $overlook = 4) Then ExitLoop
												If GUICtrlRead($Checkbox_quit) = $GUI_CHECKED Then
													GUICtrlSetState($Checkbox_quit, $GUI_UNCHECKED)
													ExitLoop
												EndIf
												;Sleep(500)
												;ExitLoop
											Next
											FileWriteLine($logfle, "")
											GUICtrlSetData($Label_top, "")
											GUICtrlSetData($Label_bed, "")
											GUICtrlSetState($Checkbox_quit, $GUI_HIDE)
											GUICtrlSetPos($Button_get, 390, 180, 100, 35)
											GUICtrlSetData($Button_get, "COMPARE" & @LF & "ALL GAMES")
											If FileExists($reportexe) Then Run($reportexe)
										Else
											MsgBox(262192, "List Error", "No games found!", 0, $GOGcliGUI)
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						SetStateOfControls($GUI_ENABLE, "all")
						GUICtrlSetData($Label_mid, "")
						If $ind > -1 Then _GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
					Else
						MsgBox(262192, "Source Error", "Manifest.txt file does not exist!" & @LF & @LF & "( i.e. not yet created )", 0, $GOGcliGUI)
					EndIf
				Else
					MsgBox(262192, "Path Error", "Games folder does not exist!" & @LF & @LF & "( i.e. Drive is disconnected )", 0, $GOGcliGUI)
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_game
			; View details of selected game
			If $ID = "" Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				If $cdkey <> "" Then
					$cdkey = StringReplace($cdkey, "\u003c/span\u003e\u003cspan\u003e", @CRLF)
					$cdkey = StringReplace($cdkey, "\t\u003cbr\u003e", @CRLF)
					$cdkey = StringReplace($cdkey, "\u003cspan\u003e", "")
					$cdkey = StringReplace($cdkey, "\u003c/span\u003e", "")
					$cdkey = StringReplace($cdkey, "\u003cbr\u003e\t", " ")
					$cdkey = StringReplace($cdkey, "\u003cbr\u003e", " ")
					$cdkey = StringReplace($cdkey, "\u0000", "")
					;$cdkey = "XXXXX-XXXXX-XXXXX-XXXXX"
					$ans = MsgBox(262179 + 256, "Game Key, Code or Redeem Link", _
						$cdkey & @LF & @LF & _
						"Continuing getting 'Game Details' from GOG?" & @LF & @LF & _
						"YES = Continue (no copying)." & @LF & _
						"NO = Copy to clipboard & close." & @LF & _
						"CANCEL = Just close.", 0, $GOGcliGUI)
					If $ans = 2 Then
						ContinueLoop
					ElseIf $ans = 7 Then
						ClipPut($cdkey)
						ContinueLoop
					EndIf
				Else
					$ans = 6
				EndIf
				If $ans = 6 Then
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
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_fold
			; Open the selected destination folder
			If FileExists($gamesfold) Then
				If _IsPressed("11") Then GUISetState(@SW_MINIMIZE, $GOGcliGUI)
				If $title <> "" Then
					GetGameFolderNameAndPath($title, $slug)
					If FileExists($gamefold) Then
						Run(@WindowsDir & "\Explorer.exe " & $gamefold)
					Else
						Run(@WindowsDir & "\Explorer.exe " & $gamesfold)
					EndIf
				Else
					Run(@WindowsDir & "\Explorer.exe " & $gamesfold)
				EndIf
			Else
				MsgBox(262192, "Path Error", "Games folder does not exist!" & @LF & @LF & "( i.e. Drive is disconnected )", 0, $GOGcliGUI)
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
					IniWrite($inifle, "Titles Search", "text", $find)
					If StringIsDigit($find) Then
						MsgBox(262192, "Find Advice", "Because the list has a hidden ID column, it is not recommended" _
							& @LF & "to search with just a number, unless that number has a leading" _
							& @LF & "or trailing space!", 0, $GOGcliGUI)
					EndIf
				EndIf
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
				$find = IniRead($inifle, "Titles Search", "text", "")
				If $find = "" Then
					MsgBox(262192, "Find Error", "No text specified!", 0, $GOGcliGUI)
				Else
					GUICtrlSetData($Input_title, $find)
				EndIf
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Button_down
			; Download the selected game
			$alert = 0
			$buttxt = GUICtrlRead($Button_down)
			If $title = "" And ($buttxt = "DOWNLOAD" Or $buttxt = "VALIDATE" & @LF & "GAME" Or $buttxt = "VALIDATE" & @LF & "FILE") Then
				MsgBox(262192, "Title Error", "A game is not selected!", 0, $GOGcliGUI)
			Else
				$ctrl = _IsPressed("11")
				If $ctrl = True And ($buttxt <> "VALIDATE" & @LF & "GAME" And $buttxt <> "VALIDATE" & @LF & "FILE") Then
					; Build a download list of games.
					$cnt = _FileCountLines($downlist)
					If $cnt < 15 Then
						If $buttxt <> "DOWNLOAD" & @LF & "LIST" Then
							GUICtrlSetStyle($Button_down, $BS_MULTILINE)
							GUICtrlSetData($Button_down, "DOWNLOAD" & @LF & "LIST")
							GUICtrlSetState($Item_verify_file, $GUI_DISABLE)
							GUICtrlSetState($Item_verify_game, $GUI_DISABLE)
							GUICtrlSetState($Listview_games, $GUI_FOCUS)
						EndIf
						$entry = $title & "|" & $ID & @CRLF
						If $downloads = "" Then
							; Start the list.
							FileWriteLine($downlist, $entry)
							$downloads = $entry
						Else
							; Check the list.
							If StringInStr($downloads, $entry) < 1 Then
								; Add new unique entry.
								FileWriteLine($downlist, $entry)
								$downloads = $downloads & $entry
							EndIf
						EndIf
					Else
						MsgBox(262192, "Add Error", "Limit of 15 games has been reached!", 2, $GOGcliGUI)
					EndIf
				ElseIf $ctrl = True Then
					; Abort adding to or building a download list of games.
					MsgBox(262192, "Download ADD Error", "A validate option is enabled!", 0, $GOGcliGUI)
				ElseIf $buttxt = "DOWNLOAD" & @LF & "LIST" Then
					; Downloads from a list of games.
					;MsgBox(262192, "Download Error", "This feature is not yet supported!", 2, $GOGcliGUI)
					;Local $e, $IDD, $paramsD, $titleD
					SetStateOfControls($GUI_DISABLE, "all")
					GUICtrlSetImage($Pic_cover, $blackjpg)
					$retrieve = ""
					GUICtrlSetData($Label_mid, "Retrieving Game File Data")
					_FileWriteLog($logfle, "Using DOWNLOADS LIST", -1)
					_FileWriteLog($logfle, "Checking MANIFEST", -1)
					; Check for multiple game entries.
					If $getlatest = 1 Or Not FileExists($manifest) Then
						RetrieveDataFromGOG($downloads, "download")
					Else
						; Retrieve game file data where needed from GOG
						$read = FileRead($manifest)
						If $read = "" Then
							RetrieveDataFromGOG($downloads, "download")
						Else
							;MsgBox(262192, "$downloads", $downloads, 2, $GOGcliGUI)
							$entries = StringSplit($downloads, @CRLF, 1)
							For $e = 1 To $entries[0]
								$entry = $entries[$e]
								If $entry <> "" Then
									;MsgBox(262192, "$entry", $entry, 2, $GOGcliGUI)
									$game = StringSplit($entry, "|", 1)
									$titleD = $game[1]
									$IDD = $game[2]
									$identry = '"Id": ' & $IDD & ','
									If StringInStr($read, $identry) < 1 Then
										; Retrieve game file data for one from GOG
										If $retrieve = "" Then
											$retrieve = $entry
										Else
											$retrieve = $retrieve & @CRLF & $entry
										EndIf
									EndIf
								EndIf
							Next
							If $retrieve <> "" Then
								RetrieveDataFromGOG($retrieve, "download")
							EndIf
						EndIf
					EndIf
					_FileCreate($downfiles)
					Sleep(500)
					$read = FileRead($manifest)
					If $read = "" Then
						_FileWriteLog($logfle, "Empty Manifest Error", -1)
						MsgBox(262192, "Read Error", "The 'Manifest.txt' file appears to be empty!" & @LF & "It may need restoring from backup.", 0, $GOGcliGUI)
					Else
						_FileWriteLog($logfle, "Building FILE DATA", -1)
						$caption = "Downloads List"
						IniWrite($downfiles, "Title", "caption", $caption)
						$game = ""
						$entries = StringSplit($downloads, @CRLF, 1)
						For $e = 1 To $entries[0]
							$entry = $entries[$e]
							If $entry <> "" Then
								$entry = StringSplit($entry, "|", 1)
								$titleD = $entry[1]
								$IDD = $entry[2]
								$slugD = IniRead($gamesini, $IDD, "slug", "")
								$identry = '"Id": ' & $IDD & ','
								If StringInStr($read, $identry) > 0 Then
									; Extract just the relevant game entry
									$game = StringSplit($read, $identry, 1)
									$game = $game[2]
									$game = StringSplit($game, '"Id":', 1)
									$game = $game[1]
									If $game <> "" Then
										$alias = ""
										$checksum = ""
										;$col1 = 0
										$col2 = ""
										$col3 = ""
										$col4 = ""
										$filesize = ""
										$language = ""
										$languages = ""
										$loop = 0
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
											ElseIf StringInStr($line, '"Languages":') > 0 Then
												$line = StringSplit($line, '"Languages": [', 1)
												$line = $line[2]
												If StringInStr($line, '",') > 0 Then
													$line = StringSplit($line, '",', 1)
													$languages = $line[1]
												Else
													$languages = $line
													$loop = 1
												EndIf
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
												$proceed = 1
												If $exists = 1 Then
													; Check to skip existing in Database.
													$values = IniRead($existDB, $col4, $slugD, "")
													If $values <> "" Then
														$values = StringSplit($values, "|")
														;If $values[1] = $filesize And $values[2] = $checksum Then $proceed = ""
														If $values[1] = $filesize Then
															; File Size Match
															$fext = StringRight($col4, 4)
															If $fext = ".zip" Then
																$proceed = 0
															Else
																If $relax = 1 And $values[2] = "" Then
																	; Relaxed Match.
																	$proceed = 2
																ElseIf $values[2] = $checksum Then
																	; Checksum Match
																	; Perfect Match, so exclude.
																	$proceed = 0
																EndIf
															EndIf
														EndIf
													EndIf
												EndIf
												If $proceed > 0 Then
													; Check to skip duplicates.
													If IniRead($downfiles, $col4, "file", "") <> $col4 Then
														IniWrite($downfiles, $col4, "game", $titleD)
														IniWrite($downfiles, $col4, "slug", $slugD)
														IniWrite($downfiles, $col4, "ID", $IDD)
														IniWrite($downfiles, $col4, "file", $col4)
														IniWrite($downfiles, $col4, "language", $language)
														IniWrite($downfiles, $col4, "languages", $languages)
														IniWrite($downfiles, $col4, "OS", $OPS)
														IniWrite($downfiles, $col4, "URL", $URL)
														IniWrite($downfiles, $col4, "title", $alias)
														IniWrite($downfiles, $col4, "bytes", $filesize)
														IniWrite($downfiles, $col4, "size", $col3)
														IniWrite($downfiles, $col4, "checksum", $checksum)
														IniWrite($downfiles, $col4, "type", $col2)
														If $proceed = 2 Then IniWrite($downfiles, $col4, "missing", "checksum")
													EndIf
												EndIf
												$alias = ""
												$checksum = ""
												$col3 = ""
												$col4 = ""
												$filesize = ""
												$language = ""
												$languages = ""
												$OPS = ""
												$URL = ""
											ElseIf $loop = 1 Then
												;MsgBox(262192, "Line", $line, 2, $GOGcliGUI)
												$line = StringStripWS($line, 3)
												If $line = '],' Then
													$languages = StringReplace($languages, '"', '')
													$loop = 0
												Else
													$languages = $languages & $line
													$languages = StringReplace($languages, '""', ', ')
												EndIf
											EndIf
										Next
									EndIf
								EndIf
							EndIf
						Next
						; Download
						If $selector = 1 Then
							; Download with Game Files Selector window
							GUICtrlSetData($Label_top, "Downloads")
							GUICtrlSetData($Label_mid, "Game Files Selector")
							GUICtrlSetData($Label_bed, "List")
							_FileWriteLog($logfle, "Loading FILE SELECTOR", -1)
							FileWriteLine($logfle, "")
							FileSelectorGUI()
							$ans = MsgBox(262209 + 256, "Remove Query", "Do you want to clear the 'Downloads' list?", 0, $GOGcliGUI)
							If $ans = 1 Then
								_FileWriteLog($logfle, "Clearing DOWNLOADS LIST", -1)
								FileWriteLine($logfle, "")
								GUICtrlSetData($Button_down, "DOWNLOAD")
								GUICtrlSetTip($Button_down, "Download the selected game!")
								GUICtrlSetState($Item_verify_file, $GUI_ENABLE)
								GUICtrlSetState($Item_verify_game, $GUI_ENABLE)
								_FileCreate($downlist)
								$downloads = ""
							EndIf
							GUICtrlSetData($Label_top, "")
							GUICtrlSetData($Label_bed, "")
						Else
							MsgBox(262192, "Download Error", "This feature is not yet supported!", 2, $GOGcliGUI)
						EndIf
					EndIf
					SetStateOfControls($GUI_ENABLE, "all")
					GUICtrlSetData($Label_mid, "")
					If $alert = 0 Then
						If $ind > -1 Then _GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
					EndIf
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
							; Check for single game entry.
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
												If StringInStr($title, "&") > 0 Then
													$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
												Else
													$pid = RunWait(@ComSpec & ' /c ECHO ' & $title & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
												EndIf
												Sleep(1000)
												If FileExists($json) Then
													$game = FileRead($json)
													If $game <> "" Then
														; Something was returned, check for game ID in the return.
														$identry = '"Id": ' & $ID & ','
														If StringInStr($game, $identry) > 0 Then
															_FileWriteLog($logfle, "GET MANIFEST - " & $title, -1)
															$ids = StringSplit($game, '"Id":', 1)
															If $ids[0] > 2 Then
																; More than one game returned, need to extract the right one.
																_FileWriteLog($logfle, "Multiple games return.", -1)
																$lines = StringSplit($game, @LF, 1)
																$game = $lines[1] & @LF & $lines[2] & @LF & $lines[3]
																For $l = 4 To $lines[0]
																	$line = $lines[$l]
																	If StringInStr($line, $identry) > 0 Then
																		;$game = $game & @LF & $line
																		$ids = 1
																		$prior = $line
																	ElseIf $ids = 1 Then
																		If StringInStr($line, '"Id":') > 0 Then
																			$ids = 2
																		Else
																			$game = $game & @LF & $prior
																			If $line = "}" Then
																				$game = $game & @LF & $line
																				ExitLoop
																			EndIf
																			$prior = $line
																		EndIf
																	ElseIf $l = $lines[0] Then
																		$game = StringStripWS($game, 2)
																		$game = StringTrimRight($game, 1)
																		$game = $game & @LF & $prior
																		If $line = "}" Then
																			$game = $game & @LF & $line
																		EndIf
																	Else
																		$prior = $line
																	EndIf
																Next
																$ids = ""
															Else
																$ids = 1
															EndIf
															If FileExists($manifest) Then
																$read = FileRead($manifest)
																If StringInStr($read, $identry) < 1 Then
																	; Add to manifest
																	GUICtrlSetData($Label_mid, "Adding Game to Manifest")
																	FileWrite($manifest, @LF & $game)
																	_FileWriteLog($logfle, "ADD to manifest", -1)
																Else
																	; Replace in manifest
																	GUICtrlSetData($Label_mid, "Replacing Game in Manifest")
																	FileCopy($manifest, $manifest & ".bak", 1)
																	$head = StringSplit($read, $identry, 1)
																	$tail = $head[2]
																	$head = $head[1]
																	$pos = StringInStr($tail, @LF & "}")
																	$tail = StringMid($tail, $pos + 2)
																	;$tail = StringSplit($tail, @LF & "}", 1)
																	;$tail = $tail[2]
																	$game = StringSplit($game, $identry, 1)
																	$game = $game[2]
																	$read = $head & $identry & $game & $tail
																	_FileCreate($manifest)
																	FileWrite($manifest, $read)
																	_FileWriteLog($logfle, "REPLACE in manifest", -1)
																EndIf
																Sleep(1000)
															Else
																; Start the manifest
																If $ids = 1 Then
																	FileCopy($json, $manifest)
																Else
																	FileWrite($manifest, $game)
																EndIf
																_FileWriteLog($logfle, "ADD to manifest", -1)
															EndIf
															; Check for CDKey
															$cdkey = StringSplit($game, '"CdKey":', 1)
															If $cdkey[0] = 2 Then
																$cdkey = $cdkey[2]
																$cdkey = StringSplit($cdkey, '",', 1)
																$cdkey = $cdkey[1]
																$cdkey = StringReplace($cdkey, '"', '')
																$cdkey = StringStripWS($cdkey, 3)
																If $cdkey <> "" Then
																	IniWrite($cdkeys, $ID, "title", $title)
																	IniWrite($cdkeys, $ID, "keycode", $cdkey)
																	_FileWriteLog($logfle, "CDKey found.", -1)
																EndIf
															EndIf
															; Check for DLC
															$DLC = StringSplit($game, '"DLC"', 1)
															If $DLC[0] > 1 Then
																$DLC = $DLC[0] - 1
																If $DLC > 0 Then
																	IniWrite($dlcfile, $ID, "title", $title)
																	IniWrite($dlcfile, $ID, "dlc", $DLC)
																	_FileWriteLog($logfle, "DLC(s) found.", -1)
																EndIf
															EndIf
															FileWriteLine($logfle, "")
														Else
															; Game ID not found in return.
															$game = ""
															_FileWriteLog($logfle, "MANIFEST FAILED - " & $title, -1)
															FileWriteLine($logfle, "")
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
						If $verify = 4 And $ratify = 4 Then
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
						ElseIf $verify = 1 Then
							; Validate Game
							GUICtrlSetData($Label_mid, "Validating Game Files")
							_FileWriteLog($logfle, "Validating Game Files.", -1)
							GetFileDownloadDetails()
							;MsgBox(262192, "Verify Error", "This feature is not yet supported!", 2, $GOGcliGUI)
							If FileExists($gamesfold) Then
								If $title <> "" Then
									_FileWriteLog($logfle, $title, -1)
									If $valfold = "" Or Not FileExists($valfold) Then
										GetGameFolderNameAndPath($title, $slug)
										If FileExists($gamefold) Then
											$valfold = $gamefold
										Else
											$valfold = $gamesfold
										EndIf
									EndIf
								Else
									$valfold = $gamesfold
								EndIf
								_FileWriteLog($logfle, $valfold, -1)
								$pth = FileSelectFolder("Browse to select a game folder.", $valfold, 7, "", $GOGcliGUI)
								If Not @error And StringMid($pth, 2, 2) = ":\" Then
									$foldpth = $pth
									$valfold = $pth
									_FileWriteLog($logfle, $valfold, -1)
									$ans = MsgBox(262209 + 256, "Validate Query", "Do you want to include sub-folder content?", 0, $GOGcliGUI)
									If $ans = 1 Then
										$filelist = _FileListToArrayRec($foldpth, "*.*", 1, 1, 0, 1)
										If @error Then $filelist = ""
									Else
										$filelist = _FileListToArray($foldpth, "*.*", 1, False)
										If @error Then $filelist = ""
									EndIf
									If IsArray($filelist) Then
										Local $bin = 0, $dmg = 0, $exe = 0, $pkg = 0, $sh = 0, $tested = 0, $zip = 0
										$entries = IniReadSectionNames($downfiles)
										$cnt = $entries[0]
										For $c = 1 To $cnt
											$entry = $entries[$c]
											$fext = StringRight($entry, 3)
											If $fext = "bin" Then
												$bin = $bin + 1
											ElseIf $fext = "dmg" Then
												$dmg = $dmg + 1
											ElseIf $fext = "exe" Then
												$exe = $exe + 1
											ElseIf $fext = "pkg" Then
												$pkg = $pkg + 1
											ElseIf $fext = ".sh" Then
												$sh = $sh + 1
											ElseIf $fext = "zip" Then
												$zip = $zip + 1
											EndIf
										Next
										$result = ""
										If $bin > 0 Then $result = "(" & $bin & " BIN files"
										If $dmg > 0 Then
											If $result = "" Then
												$result = "(" & $dmg & " DMG files"
											Else
												$result = $result & ", " & $dmg & " DMG files"
											EndIf
										EndIf
										If $exe > 0 Then
											If $result = "" Then
												$result = "(" & $exe & " EXE files"
											Else
												$result = $result & ", " & $exe & " EXE files"
											EndIf
										EndIf
										If $pkg > 0 Then
											If $result = "" Then
												$result = "(" & $pkg & " PKG files"
											Else
												$result = $result & ", " & $pkg & " PKG files"
											EndIf
										EndIf
										If $sh > 0 Then
											If $result = "" Then
												$result = "(" & $sh & " SH files"
											Else
												$result = $result & ", " & $sh & " SH files"
											EndIf
										EndIf
										If $zip > 0 Then
											If $result = "" Then
												$result = "(" & $zip & " ZIP files"
											Else
												$result = $result & ", " & $zip & " ZIP files"
											EndIf
										EndIf
										_FileWriteLog($logfle, $cnt & " files listed in the manifest (for the game).", -1)
										$same = ""
										$result = $result & ")"
										_FileWriteLog($logfle, $result, -1)
										$result = $cnt & " files listed in the manifest (for the game)." & @LF & $result & @LF
										_Crypt_Startup()
										For $f = 1 To $filelist[0]
											$file = $filelist[$f]
											$filepth = $foldpth & "\" & $file
											_PathSplit($filepth, $drv, $dir, $flename, $fext)
											If $fext = ".exe" Or $fext = ".bin" Or $fext = ".dmg" Or $fext = ".pkg" Or $fext = ".sh" Or $fext = ".zip" Then
												_FileWriteLog($logfle, $file, -1)
												$tested = $tested + 1
												If StringInStr($file, "\") > 0 Then $file = $flename & $fext
												$flename = StringLeft($file, 20)
												If $flename <> $file Then $flename = $flename & "...."
												GUICtrlSetData($Label_top, $flename)
												GUICtrlSetData($Label_bed, StringUpper(StringTrimLeft($fext, 1)))
												$result = $result & @LF & "Validating = " & $file
												$bytes = FileGetSize($filepth)
												$filesize = IniRead($downfiles, $file, "bytes", 0)
												If $filesize = 0 Then
													$result = $result & @LF & "File Size is missing."
													_FileWriteLog($logfle, "File Size is missing.", -1)
												Else
													;$bytes = FileGetSize($filepth)
													If $bytes = $filesize Then
														$result = $result & @LF & "File Size passed."
														_FileWriteLog($logfle, "File Size passed.", -1)
													Else
														$result = $result & @LF & "File Size failed."
														_FileWriteLog($logfle, "File Size failed.", -1)
													EndIf
												EndIf
												$checksum = IniRead($downfiles, $file, "checksum", "")
												If $fext = ".exe" Or $fext = ".bin" Or $fext = ".dmg" Or $fext = ".pkg" Or $fext = ".sh" Then
													;$checksum = IniRead($downfiles, $file, "checksum", "")
													If $checksum = "" Then
														;$result = $result & @LF & "MD5 (checksum) is missing."
														$result = $result & " MD5 (checksum) is missing."
														_FileWriteLog($logfle, "MD5 (checksum) is missing.", -1)
														If $filesize > 0 Then
															If $bytes = $filesize Then
																GetChecksumQuery()
															EndIf
														Else
															GetChecksumQuery()
														EndIf
													Else
														$hash = _Crypt_HashFile($filepth, $CALG_MD5)
														$hash = StringTrimLeft($hash, 2)
														If $hash = $checksum Then
															;$result = $result & @LF & "MD5 (checksum) passed."
															$result = $result & " MD5 (checksum) passed."
															_FileWriteLog($logfle, "MD5 (checksum) passed.", -1)
															_FileWriteLog($logfle, "ADDING FILE to Database.", -1)
															If $bytes <> $filesize Then _FileWriteLog($logfle, "File Size Mismatch.", -1)
															_FileWriteLog($logfle, "MD5 (checksum) added.", -1)
															IniWrite($existDB, $file, $slug, $bytes & "|" & $checksum)
														Else
															;$result = $result & @LF & "MD5 (checksum) failed."
															$result = $result & " MD5 (checksum) failed."
															_FileWriteLog($logfle, "MD5 (checksum) failed.", -1)
														EndIf
													EndIf
												ElseIf $fext = ".zip" Then
													$ret = _Zip_List($filepth)
													$ret = $ret[0]
													If $ret > 0 Then
														;$result = $result & @LF & "ZIP check passed."
														$result = $result & " ZIP check passed."
														_FileWriteLog($logfle, "ZIP check passed.", -1)
														If $filesize = 0 Or $bytes = $filesize Then
															_FileWriteLog($logfle, "ADDING FILE to Database.", -1)
															IniWrite($existDB, $file, $slug, $bytes & "|" & $checksum)
														EndIf
													Else
														;$result = $result & @LF & "ZIP check failed."
														$result = $result & " ZIP check failed."
														_FileWriteLog($logfle, "ZIP check failed.", -1)
													EndIf
												EndIf
											EndIf
										Next
										$result = $result & @LF & @LF & "The " & $tested & " files listed above, were tested (checked)."
										_FileWriteLog($logfle, $tested & " files were tested (checked).", -1)
										_Crypt_Shutdown()
										FileWriteLine($logfle, "")
										;MsgBox(262208, "Validate Results", $result, 0, $GOGcliGUI)
										MsgBox(262208, "Validate Results (Final Report)", $result & @LF & @LF _
											& "ADVICE - If both values are missing, then likely" & @LF _
											& "the file is also missing from the manifest. This" & @LF _
											& "could mean it has been replaced by an update" & @LF _
											& "if your manifest is up-to-date." & @LF & @LF _
											& "NOTE - This is the validation result only, and is" & @LF _
											& "not related to any database addition process.", 0, $GOGcliGUI)
										GUICtrlSetData($Label_top, "")
										GUICtrlSetData($Label_bed, "")
									Else
										MsgBox(262192, "Source Error", "Folder or content issue (i.e. no files found).", 0, $GOGcliGUI)
									EndIf
								Else
									_FileWriteLog($logfle, "Validate cancelled.", -1)
								EndIf
							Else
								_FileWriteLog($logfle, "Games folder does not exist.", -1)
								MsgBox(262192, "Path Error", "Games folder does not exist!" & @LF & @LF & "( i.e. Drive is disconnected )", 0, $GOGcliGUI)
							EndIf
						ElseIf $ratify = 1 Then
							; Validate File
							GUICtrlSetData($Label_mid, "Validating Game File")
							_FileWriteLog($logfle, "Validating Game File.", -1)
							GetFileDownloadDetails()
							;MsgBox(262192, "Verify Error", "This feature is not yet supported!", 2, $GOGcliGUI)
							If FileExists($gamesfold) Then
								If $title <> "" Then
									_FileWriteLog($logfle, $title, -1)
									If $valfold = "" Or Not FileExists($valfold) Then
										GetGameFolderNameAndPath($title, $slug)
										If FileExists($gamefold) Then
											$valfold = $gamefold
										Else
											$valfold = $gamesfold
										EndIf
									EndIf
								Else
									$valfold = $gamesfold
								EndIf
								$pth = FileOpenDialog("Select a file to validate.", $valfold, "Game files (*.exe;*.bin;*.dmg;*.pkg;*.sh;*.zip)", 3, "", $GOGcliGUI)
								If @error = 0 Then
									$filepth = $pth
									_PathSplit($filepth, $drv, $dir, $flename, $fext)
									$valfold = StringTrimRight($drv & $dir, 1)
									_FileWriteLog($logfle, $valfold, -1)
									$file = $flename & $fext
									_FileWriteLog($logfle, $file, -1)
									$flename = StringLeft($file, 20)
									If $flename <> $file Then $flename = $flename & "...."
									GUICtrlSetData($Label_top, $flename)
									GUICtrlSetData($Label_bed, StringUpper(StringTrimLeft($fext, 1)))
									;$result = "Validating = " & $file
									$result = $file & @LF
									$bytes = FileGetSize($filepth)
									$filesize = IniRead($downfiles, $file, "bytes", 0)
									If $filesize = 0 Then
										$result = $result & @LF & "File Size is missing."
										_FileWriteLog($logfle, "File Size is missing.", -1)
									Else
										;$bytes = FileGetSize($filepth)
										If $bytes = $filesize Then
											$result = $result & @LF & "File Size passed."
											_FileWriteLog($logfle, "File Size passed.", -1)
										Else
											$result = $result & @LF & "File Size failed."
											_FileWriteLog($logfle, "File Size failed.", -1)
										EndIf
									EndIf
									$checksum = IniRead($downfiles, $file, "checksum", "")
									If $fext = ".exe" Or $fext = ".bin" Or $fext = ".dmg" Or $fext = ".pkg" Or $fext = ".sh" Then
										;$checksum = IniRead($downfiles, $file, "checksum", "")
										If $checksum = "" Then
											$result = $result & @LF & "MD5 (checksum) is missing."
											_FileWriteLog($logfle, "MD5 (checksum) is missing.", -1)
											$same = ""
											If $filesize > 0 Then
												If $bytes = $filesize Then
													GetChecksumQuery(1)
												EndIf
											Else
												GetChecksumQuery(1)
											EndIf
										Else
											_Crypt_Startup()
											$hash = _Crypt_HashFile($filepth, $CALG_MD5)
											_Crypt_Shutdown()
											$hash = StringTrimLeft($hash, 2)
											If $hash = $checksum Then
												$result = $result & @LF & "MD5 (checksum) passed."
												_FileWriteLog($logfle, "MD5 (checksum) passed.", -1)
												_FileWriteLog($logfle, "ADDING FILE to Database.", -1)
												If $bytes <> $filesize Then _FileWriteLog($logfle, "File Size Mismatch.", -1)
												_FileWriteLog($logfle, "MD5 (checksum) added.", -1)
												IniWrite($existDB, $file, $slug, $bytes & "|" & $checksum)
											Else
												$result = $result & @LF & "MD5 (checksum) failed."
												_FileWriteLog($logfle, "MD5 (checksum) failed.", -1)
											EndIf
										EndIf
									ElseIf $fext = ".zip" Then
										$ret = _Zip_List($filepth)
										$ret = $ret[0]
										If $ret > 0 Then
											$result = $result & @LF & "ZIP check passed."
											_FileWriteLog($logfle, "ZIP check passed.", -1)
											If $filesize = 0 Or $bytes = $filesize Then
												_FileWriteLog($logfle, "ADDING FILE to Database.", -1)
												IniWrite($existDB, $file, $slug, $bytes & "|" & $checksum)
											EndIf
										Else
											$result = $result & @LF & "ZIP check failed."
											_FileWriteLog($logfle, "ZIP check failed.", -1)
										EndIf
									EndIf
									FileWriteLine($logfle, "")
									MsgBox(262208, "Validate Results (Final Report)", $result & @LF & @LF _
										& "ADVICE - If both values are missing, then likely" & @LF _
										& "the file is also missing from the manifest. This" & @LF _
										& "could mean it has been replaced by an update" & @LF _
										& "if your manifest is up-to-date." & @LF & @LF _
										& "NOTE - This is the validation result only, and is" & @LF _
										& "not related to any database addition process.", 0, $GOGcliGUI)
									GUICtrlSetData($Label_top, "")
									GUICtrlSetData($Label_bed, "")
								Else
									_FileWriteLog($logfle, "Validate cancelled.", -1)
								EndIf
							Else
								_FileWriteLog($logfle, "Games folder does not exist.", -1)
								MsgBox(262192, "Path Error", "Games folder does not exist!" & @LF & @LF & "( i.e. Drive is disconnected )", 0, $GOGcliGUI)
							EndIf
						EndIf
					Else
						MsgBox(262192, "Details Error", "Game data could not be found!", 0, $GOGcliGUI)
					EndIf
					SetStateOfControls($GUI_ENABLE, "all")
					GUICtrlSetData($Label_mid, "")
					If $alert = 0 Then
						If $ind > -1 Then _GUICtrlListView_ClickItem($Listview_games, $ind, "left", False, 1, 1)
					EndIf
				EndIf
			EndIf
			If $alert > 0 Then
				GUICtrlSetData($Label_top, "Changed Filename(s)")
				GUICtrlSetData($Label_mid, "Check the 'Alerts.txt' File")
				GUICtrlSetData($Label_bed, $alert & " file(s) changed")
				MsgBox(262192, "Name Change Alert", $alert & " file name(s) detected as changed." & @LF & @LF _
					& "This means the manifest needs to be updated (entries replaced)" & @LF _
					& "for the game or games (one or more) that was just downloaded" & @LF _
					& "or checked etc. Other new game files might also be available to" & @LF _
					& "download for the game(s) in question, so check after updating.", 0, $GOGcliGUI)
				$alert = 0
			EndIf
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
			;_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
		Case $msg = $Button_dir
			; Open the program folder
			If _IsPressed("11") Then GUISetState(@SW_MINIMIZE, $GOGcliGUI)
			ShellExecute(@ScriptDir)
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
		Case $msg = $Item_view_man
			; View Manifests List
			If FileExists($manlist) Then
				ShellExecute($manlist)
			EndIf
		Case $msg = $Item_view_down
			; View Downloads List
			If FileExists($downlist) Then ShellExecute($downlist)
		Case $msg = $Item_verify_game
			; Validate Game for DOWNLOAD button
			If $verify = 4 Then
				$verify = 1
				GUICtrlSetData($Button_down, "VALIDATE" & @LF & "GAME")
				If $ratify = 1 Then
					$ratify = 4
					GUICtrlSetState($Item_verify_file, $ratify)
				EndIf
			Else
				$verify = 4
				GUICtrlSetData($Button_down, "DOWNLOAD")
			EndIf
			GUICtrlSetState($Item_verify_game, $verify)
		Case $msg = $Item_verify_file
			; Validate File for DOWNLOAD button
			If $ratify = 4 Then
				$ratify = 1
				GUICtrlSetData($Button_down, "VALIDATE" & @LF & "FILE")
				If $verify = 1 Then
					$verify = 4
					GUICtrlSetState($Item_verify_game, $verify)
				EndIf
			Else
				$ratify = 4
				GUICtrlSetData($Button_down, "DOWNLOAD")
			EndIf
			GUICtrlSetState($Item_verify_file, $ratify)
		Case $msg = $Item_manifest_fix
			; Check & Fix The Manifest
			If FileExists($manifest) Then
				SetStateOfControls($GUI_DISABLE, "all")
				GUICtrlSetImage($Pic_cover, $blackjpg)
				GUICtrlSetData($Label_mid, "Checking The Manifest")
				$read = FileRead($manifest)
				If $read <> "" Then
					_FileWriteLog($logfle, "Checking for corrupted manifest entries.", -1)
					$chunk = ""
					$fixed = 0
					$result = ""
					$sects = 0
					$parts = StringSplit($read, '"Games":', 1)
					For $p = 1 To $parts[0]
						$chunk = $parts[$p]
						$ids = StringSplit($chunk, '"Id":', 1)
						If $ids[0] > 2 Then
							$part = ""
							$sects = $sects + 1
							If $result = "" Then
								$result = "(" & $sects & ")"
							Else
								$result = $result & @LF & "(" & $sects & ")"
							EndIf
							_FileWriteLog($logfle, "Corrupted manifest entry contains the following.", -1)
							For $s = 1 To $ids[0]
								$sect = $ids[$s]
								If StringInStr($sect, '"Title":') > 0 Then
									$part = StringSplit($sect, '",', 1)
									$part = $part[1]
									$part = StringReplace($part, '"Title": "', ' - ')
									$part = StringReplace($part, "," & @LF, "")
									$part = StringStripWS($part, 7)
									$result = $result & @LF & $part
									_FileWriteLog($logfle, $part, -1)
								EndIf
							Next
							$chunk = '{' & @LF & '  "Games":' & $chunk
							$chunk = StringStripWS($chunk, 2)
							If StringRight($chunk, 1) = '{' Then
								$chunk = StringTrimRight($chunk, 1)
							Else
								$chunk = @LF & StringStripWS($chunk, 2)
							EndIf
							; Testing
							;$chunk = StringRight($chunk, 300)
							;MsgBox(262208, "Results", '"' & $chunk & '"')
							;$pos = StringInStr($manifest, $chunk)
							;MsgBox(262208, "$pos", $pos)
							;$remove = 1
							;If $remove = 1 Then
								$rep = _ReplaceStringInFile($manifest, $chunk, "")
								If $rep = 0 Then
									;MsgBox(262208, "$rep", $rep)
									$chunk =StringStripWS($chunk, 1)
									$rep = _ReplaceStringInFile($manifest, $chunk, "")
								EndIf
								If $rep = 1 Then
									$fixed = $fixed + 1
									_FileWriteLog($logfle, "Fixed (removed).", -1)
								EndIf
								;MsgBox(262208, "$rep", $rep)
							;EndIf
							;ExitLoop
						EndIf
					Next
					If $sects > 0 Then
						MsgBox(262208, "Results", $sects & " corrupted manifest entry(s)." & @LF _
							& $fixed & " corrupted entry(s) fixed (removed)."& @LF _
							& "See the 'Log' file for details."& @LF _
							& "You will need to add at least one entry back for each.", 0, $GOGcliGUI)
							;& "You will need to add at least one entry back for each." & @LF & @LF _
							;& $result, 0, $GOGcliGUI)
					Else
						_FileWriteLog($logfle, "No corrupted manifest entries found.", -1)
						MsgBox(262208, "Results", "No corrupted manifest entries found.", 0, $GOGcliGUI)
					EndIf
					Local $keycheck = IniRead($inifle, "Manifest Check", "cdkeys", "")
					If $keycheck = "" Then
						; Once Off Check for CDKey.
						$read = FileRead($manifest)
						If $read <> "" Then
							Local $k, $keys = 0
							FileWriteLine($logfle, "")
							_FileWriteLog($logfle, "Checking for CDKeys (Once Off).", -1)
							IniWrite($inifle, "Manifest Check", "cdkeys", "1")
							GUICtrlSetData($Label_mid, "Checking For CDKeys")
							$chunk = ""
							$parts = StringSplit($read, '"Games":', 1)
							For $k = 1 To $parts[0]
								$chunk = $parts[$k]
								$IDD = StringSplit($chunk, '"Id":', 1)
								If $IDD[0] = 2 Then
									$IDD = $IDD[2]
									$IDD = StringSplit($IDD, ',', 1)
									$IDD = $IDD[1]
									$IDD = StringStripWS($IDD, 3)
									$titleD = StringSplit($chunk, '"Title": "', 1)
									If $titleD[0] > 1 Then
										$titleD = $titleD[2]
										$titleD = StringSplit($titleD, '",', 1)
										$titleD = $titleD[1]
										$titleD = StringStripWS($titleD, 3)
										;$titleD = FixTitle($titleD)
										$titleD = StringReplace($titleD, "\u0026", "&")
										; Check for CDKey
										$cdkey = StringSplit($chunk, '"CdKey":', 1)
										If $cdkey[0] = 2 Then
											$cdkey = $cdkey[2]
											$cdkey = StringSplit($cdkey, '",', 1)
											$cdkey = $cdkey[1]
											$cdkey = StringReplace($cdkey, '"', '')
											$cdkey = StringStripWS($cdkey, 3)
											If $cdkey <> "" Then
												$keys = $keys + 1
												IniWrite($cdkeys, $IDD, "title", $titleD)
												IniWrite($cdkeys, $IDD, "keycode", $cdkey)
												_FileWriteLog($logfle, $titleD, -1)
												_FileWriteLog($logfle, "CDKey found.", -1)
											EndIf
										EndIf
									EndIf
								EndIf
							Next
							_FileWriteLog($logfle, $keys & " CDKey entries found.", -1)
							MsgBox(262208, "Results", $keys & " CDKey entries found.", 0, $GOGcliGUI)
						EndIf
					EndIf
					Local $dlccheck = IniRead($inifle, "Manifest Check", "dlc", "")
					If $dlccheck = "" Then
						; Once Off Check for DLCs.
						$read = FileRead($manifest)
						If $read <> "" Then
							Local $d, $dlcs = 0
							FileWriteLine($logfle, "")
							_FileWriteLog($logfle, "Checking for DLCs (Once Off).", -1)
							IniWrite($inifle, "Manifest Check", "dlc", "1")
							GUICtrlSetData($Label_mid, "Checking For DLCs")
							$chunk = ""
							$parts = StringSplit($read, '"Games":', 1)
							For $d = 1 To $parts[0]
								$chunk = $parts[$d]
								$IDD = StringSplit($chunk, '"Id":', 1)
								If $IDD[0] = 2 Then
									$IDD = $IDD[2]
									$IDD = StringSplit($IDD, ',', 1)
									$IDD = $IDD[1]
									$IDD = StringStripWS($IDD, 3)
									$titleD = StringSplit($chunk, '"Title": "', 1)
									If $titleD[0] > 1 Then
										$titleD = $titleD[2]
										$titleD = StringSplit($titleD, '",', 1)
										$titleD = $titleD[1]
										$titleD = StringStripWS($titleD, 3)
										;$titleD = FixTitle($titleD)
										$titleD = StringReplace($titleD, "\u0026", "&")
										; Check for DLC
										$DLC = StringSplit($chunk, '"DLC"', 1)
										If $DLC[0] > 1 Then
											$DLC = $DLC[0] - 1
											If $DLC > 0 Then
												$dlcs = $dlcs + 1
												IniWrite($dlcfile, $IDD, "title", $titleD)
												IniWrite($dlcfile, $IDD, "dlc", $DLC)
												_FileWriteLog($logfle, $titleD, -1)
												_FileWriteLog($logfle, "DLC(s) found.", -1)
											EndIf
										EndIf
									EndIf
								EndIf
							Next
							_FileWriteLog($logfle, $dlcs & " DLC entries found.", -1)
							MsgBox(262208, "Results", $dlcs & " DLC entries found.", 0, $GOGcliGUI)
						EndIf
					EndIf
					FileWriteLine($logfle, "")
				EndIf
				SetStateOfControls($GUI_ENABLE, "all")
				GUICtrlSetData($Label_mid, "")
			EndIf
			;_GUICtrlListView_SetItemSelected($Listview_games, $ind, True, True)
			;GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_lists_updated
			; Lists - Games Updated
			If FileExists($updated) Then ShellExecute($updated)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_lists_tags
			; Lists - Tags
			If FileExists($tagfle) Then ShellExecute($tagfle)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_lists_latest
			; Lists - Latest Additions
			If FileExists($addlist) Then ShellExecute($addlist)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_lists_dlcs
			; Lists - DLCs
			If FileExists($dlcfile) Then ShellExecute($dlcfile)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_lists_keys
			; Lists - CDKeys
			If FileExists($cdkeys) Then ShellExecute($cdkeys)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_down_all
			; Download ALL Manifests
			If $manall = 4 Then
				$manall = 1
				GUICtrlSetData($Button_man, "MANIFEST" & @LF & "FOR ALL")
				GUICtrlSetTip($Button_man, "Get manifest data for all games!")
				If $addto = 1 Then
					$addto = 4
					GUICtrlSetState($Item_database_add, $addto)
					$query = ""
				EndIf
			Else
				$manall = 4
				GUICtrlSetData($Button_man, "ADD TO" & @LF & "MANIFEST")
				GUICtrlSetTip($Button_man, "Add selected game to manifest!")
			EndIf
			GUICtrlSetState($Item_down_all, $manall)
		Case $msg = $Item_database_view
			; View The Database
			If FileExists($existDB) Then ShellExecute($existDB)
			GUICtrlSetState($Listview_games, $GUI_FOCUS)
		Case $msg = $Item_database_relax
			; Database - Relax The Rules
			If $relax = 4 Then
				$relax = 1
			Else
				$relax = 4
			EndIf
			GUICtrlSetState($Item_database_relax, $relax)
			IniWrite($inifle, "Exists Database", "relax", $relax)
		Case $msg = $Item_database_add
			; ADD To Database
			If $addto = 4 Then
				$addto = 1
				GUICtrlSetData($Button_man, "ADD TO" & @LF & "DATABASE")
				GUICtrlSetTip($Button_man, "ADD selected game & files to 'Exists' database!")
				If $manall = 1 Then
					$manall = 4
					GUICtrlSetState($Item_down_all, $manall)
				EndIf
			Else
				$addto = 4
				GUICtrlSetData($Button_man, "ADD TO" & @LF & "MANIFEST")
				GUICtrlSetTip($Button_man, "Add selected game to manifest!")
				$query = ""
			EndIf
			GUICtrlSetState($Item_database_add, $addto)
		Case $msg = $Item_compare_yellow
			; Comparison Settings - No Size (YELLOW)
			If $yellow = 4 Then
				$yellow = 1
			Else
				$yellow = 4
			EndIf
			GUICtrlSetState($Item_compare_yellow, $yellow)
			IniWrite($inifle, "Compare Options", "yellow", $yellow)
		Case $msg = $Item_compare_wipe
			; Wipe Comparison File
			$ans = MsgBox(262177 + 256, "Wipe Query", _
				"OK = Wipe (clear) the 'Comparisons.txt' file." & @LF & _
				"CANCEL = Abort any wipe.", 0, $GOGcliGUI)
			If $ans = 1 Then
				If FileExists($compare) Then _FileCreate($compare)
			EndIf
		Case $msg = $Item_compare_view
			; View Comparison File
			If FileExists($compare) Then ShellExecute($compare)
		Case $msg = $Item_compare_report
			; Comparison Settings - Report Missing Folders
			If $record = 4 Then
				$record = 1
			Else
				$record = 4
			EndIf
			GUICtrlSetState($Item_compare_report, $record)
			IniWrite($inifle, "Compare Options", "report", $record)
		Case $msg = $Item_compare_rep
			; Comparison Report
			If FileExists($reportexe) Then Run($reportexe)
		Case $msg = $Item_compare_red
			; Comparison Settings - Missing Files (RED)
			If $red = 4 Then
				$red = 1
			Else
				$red = 4
			EndIf
			GUICtrlSetState($Item_compare_red, $red)
			IniWrite($inifle, "Compare Options", "red", $red)
		Case $msg = $Item_compare_overlook
			; Comparison Settings - Ignore Missing Manifest Entry
			If $overlook = 4 Then
				$overlook = 1
			Else
				$overlook = 4
			EndIf
			GUICtrlSetState($Item_compare_overlook, $overlook)
			IniWrite($inifle, "Compare Options", "overlook", $overlook)
		Case $msg = $Item_compare_orange
			; Comparison Settings - Wrong Size (ORANGE)
			If $orange = 4 Then
				$orange = 1
			Else
				$orange = 4
			EndIf
			GUICtrlSetState($Item_compare_orange, $orange)
			IniWrite($inifle, "Compare Options", "orange", $orange)
		Case $msg = $Item_compare_one
			; Compare One Game
			If $compone = 4 Then
				$compone = 1
				If $compall = 1 Then
					$compall = 4
					GUICtrlSetState($Item_compare_all, $compall)
				EndIf
				GUICtrlSetData($Button_get, "COMPARE" & @LF & "ONE GAME")
				GUICtrlSetTip($Button_get, "Compare one game in the games folder with manifest!")
			Else
				$compone = 4
				GUICtrlSetData($Button_get, "CHECK or GET" & @LF & "GAMES LIST")
				GUICtrlSetTip($Button_get, "Get game titles from GOG library!")
			EndIf
			GUICtrlSetState($Item_compare_one, $compone)
		Case $msg = $Item_compare_ignore
			; Comparison Settings - Ignore Missing Folders
			If $ignore = 4 Then
				$ignore = 1
			Else
				$ignore = 4
			EndIf
			GUICtrlSetState($Item_compare_ignore, $ignore)
			IniWrite($inifle, "Compare Options", "ignore", $ignore)
		Case $msg = $Item_compare_declare
			; Comparison Settings - Report Missing Manifest Entry
			If $declare = 4 Then
				$declare = 1
			Else
				$declare = 4
			EndIf
			GUICtrlSetState($Item_compare_declare, $declare)
			IniWrite($inifle, "Compare Options", "declare", $declare)
		Case $msg = $Item_compare_aqua
			; Comparison Settings - No Manifest Entry (AQUA)
			If $aqua = 4 Then
				$aqua = 1
			Else
				$aqua = 4
			EndIf
			GUICtrlSetState($Item_compare_aqua, $aqua)
			IniWrite($inifle, "Compare Options", "aqua", $aqua)
		Case $msg = $Item_compare_all
			; Compare ALL Games
			If $compall = 4 Then
				$compall = 1
				If $compone = 1 Then
					$compone = 4
					GUICtrlSetState($Item_compare_one, $compone)
				EndIf
				GUICtrlSetData($Button_get, "COMPARE" & @LF & "ALL GAMES")
				GUICtrlSetTip($Button_get, "Compare all games in the games folder with manifest!")
			Else
				$compall = 4
				GUICtrlSetData($Button_get, "CHECK or GET" & @LF & "GAMES LIST")
				GUICtrlSetTip($Button_get, "Get game titles from GOG library!")
			EndIf
			GUICtrlSetState($Item_compare_all, $compall)
		Case $msg = $Item_clear_man
			; Clear Manifests List
			GUICtrlSetState($Item_database_add, $GUI_ENABLE)
			GUICtrlSetState($Item_down_all, $GUI_ENABLE)
			GUICtrlSetData($Button_man, "ADD TO" & @LF & "MANIFEST")
			GUICtrlSetTip($Button_man, "Add selected game to manifest!")
			_FileCreate($manlist)
			$manifests = ""
		Case $msg = $Item_clear_down
			; Clear Downloads List
			$buttxt = GUICtrlRead($Button_down)
			If $buttxt <> "VALIDATE" & @LF & "GAME" And $buttxt <> "VALIDATE" & @LF & "FILE" Then
				GUICtrlSetData($Button_down, "DOWNLOAD")
				GUICtrlSetTip($Button_down, "Download the selected game!")
				GUICtrlSetState($Item_verify_file, $GUI_ENABLE)
				GUICtrlSetState($Item_verify_game, $GUI_ENABLE)
				_FileCreate($downlist)
				$downloads = ""
			EndIf
		Case $msg = $Item_alerts_view
			; View Alerts
			If FileExists($alerts) Then ShellExecute($alerts)
		Case $msg = $Item_alerts_clear
			; Clear Alerts
			If FileExists($alerts) Then _FileCreate($alerts)
		Case $msg = $Label_slug
			; Click to
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
			GUICtrlSetData($Label_top, "")
			GUICtrlSetData($Label_mid, "")
			GUICtrlSetData($Label_bed, "")
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
			If $DLC = 0 Then $DLC = IniRead($dlcfile, $ID, "dlc", "0")
			GUICtrlSetData($Input_dlc, $DLC)
			$updates = IniRead($gamesini, $ID, "updates", "")
			GUICtrlSetData($Input_ups, $updates)
			$cdkey = IniRead($cdkeys, $ID, "keycode", "")
			If $cdkey = "" Then
				GUICtrlSetData($Input_key, 0)
			Else
				GUICtrlSetData($Input_key, 1)
			EndIf
			$tagtxt = IniRead($tagfle, $ID, "comment", "")
			If $tagtxt <> "" Then
				MsgBox(262208, "Tag Comment", $tagtxt, 0, $GOGcliGUI)
			EndIf
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
	Local $Button_close, $Button_cookie, $Checkbox_dos, $Checkbox_exist, $Checkbox_image, $Checkbox_keep, $Checkbox_latest, $Checkbox_relax
	Local $Checkbox_select, $Checkbox_valid, $Combo_lang, $Combo_OS, $Combo_two, $Edit_info, $Group_down, $Group_lang, $Label_OS
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
	$Edit_info = GUICtrlCreateEdit("", 11, 10, 228, 65, $ES_WANTRETURN + $WS_VSCROLL + $ES_AUTOVSCROLL + $ES_MULTILINE + $ES_READONLY)
	;
	$Button_cookie = GuiCtrlCreateButton("CREATE COOKIE", 10, 85, 160, 50)
	GUICtrlSetFont($Button_cookie, 9, 600)
	GUICtrlSetTip($Button_cookie, "Create the basic cookie file!")
	;
	$Button_close = GuiCtrlCreateButton("EXIT", 180, 85, 60, 50, $BS_ICON)
	GUICtrlSetTip($Button_close, "Exit / Close / Quit the window!")
	;
	$Checkbox_keep = GUICtrlCreateCheckbox("Save cover images locally when shown", 24, 142, 210, 20)
	GUICtrlSetTip($Checkbox_keep, "Save cover images locally when obtained!")
	;
	$Checkbox_dos = GUICtrlCreateCheckbox("Minimize DOS Console window process", 24, 162, 210, 20)
	GUICtrlSetTip($Checkbox_dos, "Minimize a DOS Console window process when it starts!")
	;
	$Checkbox_exist = GUICtrlCreateCheckbox("Enable the 'Exists' database for usage", 24, 182, 210, 20)
	GUICtrlSetTip($Checkbox_exist, "Enable the 'Exists' database for use!")
	$Checkbox_relax = GUICtrlCreateCheckbox("Relax the rules (file size only needed)", 34, 202, 200, 20)
	GUICtrlSetTip($Checkbox_relax, "Relax the rules (file size only required) if checksum missing!")
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
	GUICtrlSetTip($Checkbox_latest, "Get latest manifest data for the game!")
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
	GUICtrlSetState($Checkbox_exist, $exists)
	GUICtrlSetState($Checkbox_relax, $relax)
	If $exists = 4 Then GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
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
	;$window = $SetupGUI


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
					SetStateOfControls($GUI_ENABLE)
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
		Case $msg = $Checkbox_relax
			; Relax the rules (file size only required) if checksum missing
			If GUICtrlRead($Checkbox_relax) = $GUI_CHECKED Then
				$relax = 1
				MsgBox(262208, "Relax The Rules", _
					"For a file name to be excluded from the download list" & @LF & _
					"it normally needs to match both the 'file size' and the" & @LF & _
					"'checksum (MD5)' value. With 'Relax' enabled, it only" & @LF & _
					"needs to match 'file size' when checksum is missing.", 0, $SetupGUI)
			Else
				$relax = 4
			EndIf
			IniWrite($inifle, "Exists Database", "relax", $relax)
			GUISwitch($GOGcliGUI)
			GUICtrlSetState($Item_database_relax, $relax)
			GUISwitch($SetupGUI)
		Case $msg = $Checkbox_latest
			; Get latest manifest data for the game
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
		Case $msg = $Checkbox_exist
			; Enable the 'Exists' database for usage
			If GUICtrlRead($Checkbox_exist) = $GUI_CHECKED Then
				$exists = 1
				GUICtrlSetState($Checkbox_relax, $GUI_ENABLE)
			Else
				$exists = 4
				GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
			EndIf
			IniWrite($inifle, "Exists Database", "use", $exists)
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
	Local $Button_download, $Button_quit, $Button_uncheck, $Checkbox_cancel, $Checkbox_relax, $Checkbox_skip, $Combo_OSfle, $Combo_shutdown, $Group_exist
	Local $Group_files, $Group_OS, $Group_select, $Label_done, $Label_percent, $Label_shut, $Label_speed, $Label_warn, $ListView_files, $Progress_bar
	Local $Radio_selall, $Radio_selext, $Radio_selgame, $Radio_selpat, $Radio_selset
	Local $amount, $begin, $cancel, $checked, $code, $col1, $col2, $col3, $col4, $color, $dllcall, $downloading, $edge, $ents, $exist, $fext, $gotten
	Local $IDD, $idx, $imageD, $missing, $osfle, $prior, $secs, $sect, $sections, $SelectorGUI, $shutdown, $skip, $slugD, $speed, $styles, $sum, $taken
	Local $theme, $titleD, $tmpman, $val, $wide
	;
	$styles = $WS_OVERLAPPED + $WS_CAPTION + $WS_MINIMIZEBOX ; + $WS_POPUP
	$SelectorGUI = GuiCreate("Game Files Selector - " & $caption, $width - 5, $height, $left, $top, $styles + $WS_SIZEBOX + $WS_VISIBLE, $WS_EX_TOPMOST, $GOGcliGUI)
	GUISetBkColor(0xBBFFBB, $SelectorGUI)
	; CONTROLS
	$Group_files = GuiCtrlCreateGroup("Files To Download", 10, 10, $width - 25, 302)
	GUICtrlSetResizing($Group_files, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	$ListView_files = GUICtrlCreateListView("||||", 20, 30, $width - 45, 270, $LVS_SHOWSELALWAYS + $LVS_SINGLESEL + $LVS_REPORT + $LVS_NOCOLUMNHEADER, _
													$LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES + $LVS_EX_CHECKBOXES) ;
	GUICtrlSetBkColor($ListView_files, 0xF0D0F0)
	GUICtrlSetResizing($ListView_files, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	;
	$Label_shut = GuiCtrlCreateLabel("SHUTDOWN", $width - 325, 5, 76, 21, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetResizing($Label_shut, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetFont($Label_shut, 7, 600, 0, "Small Fonts")
	GUICtrlSetBkColor($Label_shut, $COLOR_SKYBLUE) ;$COLOR_BLACK
	GUICtrlSetColor($Label_shut, $COLOR_WHITE)
	$Combo_shutdown = GUICtrlCreateCombo("", $width - 249, 5, 83, 21)
	GUICtrlSetResizing($Combo_shutdown, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetTip($Combo_shutdown, "Shutdown options!")
	;
	$Checkbox_cancel = GUICtrlCreateCheckbox("Cancel ", $width - 156, 6, 50, 20)
	GUICtrlSetResizing($Checkbox_cancel, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetTip($Checkbox_cancel, "Cancel downloading after the current download has finished!")
	;
	$Label_done = GuiCtrlCreateLabel("0 Kbs", $width - 96, 6, 71, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetResizing($Label_done, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetBkColor($Label_done, $COLOR_GREEN)
	GUICtrlSetColor($Label_done, $COLOR_WHITE)
	GUICtrlSetTip($Label_done, "Downloaded!")
	;
	$Label_warn = GuiCtrlCreateLabel("", 10, 318, 340, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN) ;$width -
	GUICtrlSetBkColor($Label_warn, $COLOR_RED)
	GUICtrlSetColor($Label_warn, $COLOR_YELLOW)
	GUICtrlSetFont($Label_warn, 8, 600)
	GUICtrlSetResizing($Label_warn, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKSIZE)
	;GUICtrlSetResizing($Label_warn, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKHEIGHT)
	;
	$Checkbox_relax = GUICtrlCreateCheckbox("Relax", 360, 318, 50, 20)
	GUICtrlSetResizing($Checkbox_relax, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKSIZE)
	GUICtrlSetTip($Checkbox_relax, "Relax the exclusion rules for download list files!")
	;
	;$Progress_bar = GUICtrlCreateProgress($width - 166, 317, 80, 20, $PBS_SMOOTH)
	$Progress_bar = GUICtrlCreateProgress($width - 176, 317, 90, 20)
	GUICtrlSetResizing($Progress_bar, $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKAUTO + $GUI_DOCKAUTO)
	$Label_percent = GUICtrlCreateLabel("0%", $width - 170, 318, 85, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor($Label_percent, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($Label_percent, $COLOR_BLACK)
	GUICtrlSetFont($Label_percent, 9, 600)
	GUICtrlSetResizing($Label_percent, $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT + $GUI_DOCKAUTO + $GUI_DOCKAUTO)
	;
	$Label_speed = GuiCtrlCreateLabel("0 Kb/s", $width - 76, 318, 61, 20, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
	GUICtrlSetResizing($Label_speed, $GUI_DOCKRIGHT + $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetBkColor($Label_speed, $COLOR_BLUE)
	GUICtrlSetColor($Label_speed, $COLOR_WHITE)
	GUICtrlSetTip($Label_speed, "Downloading speed!")
	;
	$Group_select = GuiCtrlCreateGroup("Select Files", 10, $height - 65, 255, 55)
	GUICtrlSetResizing($Group_select, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Radio_selall = GUICtrlCreateRadio("ALL", 20, $height - 44,  40, 20)
	GUICtrlSetFont($Radio_selall, 7, 400, 0, "Small Fonts")
	GUICtrlSetResizing($Radio_selall, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selall, "Select ALL file entries!")
	$Radio_selgame = GUICtrlCreateRadio("GAME", 60, $height - 44,  51, 20)
	GUICtrlSetFont($Radio_selgame, 7, 400, 0, "Small Fonts")
	GUICtrlSetResizing($Radio_selgame, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selgame, "Select GAME file entries!")
	$Radio_selext = GUICtrlCreateRadio("EXTRA", 111, $height - 44,  55, 20)
	GUICtrlSetFont($Radio_selext, 7, 400, 0, "Small Fonts")
	GUICtrlSetResizing($Radio_selext, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selext, "Select EXTRA file entries!")
	$Radio_selset = GUICtrlCreateRadio("setup", 166, $height - 44,  45, 20)
	GUICtrlSetFont($Radio_selset, 7, 400, 0, "Small Fonts")
	GUICtrlSetResizing($Radio_selset, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selset, "Select SETUP file entries!")
	$Radio_selpat = GUICtrlCreateRadio("patch", 211, $height - 44,  42, 20)
	GUICtrlSetFont($Radio_selpat, 7, 400, 0, "Small Fonts")
	GUICtrlSetResizing($Radio_selpat, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Radio_selpat, "Select PATCH file entries!")
	GUICtrlSetBkColor($Radio_selall, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selgame, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selext, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selset, 0xFFD5FF)
	GUICtrlSetBkColor($Radio_selpat, 0xFFD5FF)
	;
	$Group_OS = GuiCtrlCreateGroup("OS Select", $width - 325, $height - 65, 90, 55)
	GUICtrlSetResizing($Group_OS, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	$Combo_OSfle = GUICtrlCreateCombo("", $width - 315, $height - 45, 70, 21)
	GUICtrlSetResizing($Combo_OSfle, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Combo_OSfle, "OS for files!")
	;
	$Group_exist = GuiCtrlCreateGroup("Existing", $width - 225, $height - 65, 58, 55)
	GUICtrlSetResizing($Group_exist, $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	$Checkbox_skip = GUICtrlCreateCheckbox("Skip ", $width - 215, $height - 44, 40, 20)
	GUICtrlSetResizing($Checkbox_skip, $GUI_DOCKAUTO + $GUI_DOCKSIZE)
	GUICtrlSetTip($Checkbox_skip, "Skip downloading existing files!")
	;
	$Button_download = GuiCtrlCreateButton("DOWNLOAD", $width - 160, $height - 60, 90, 28)
	GUICtrlSetFont($Button_download, 8, 600)
	GUICtrlSetResizing($Button_download, $GUI_DOCKRIGHT + $GUI_DOCKAUTO)
	GUICtrlSetTip($Button_download, "Download selected files!")
	;
	$Button_uncheck = GuiCtrlCreateButton("Deselect ALL", $width - 160, $height - 28, 90, 18)
	GUICtrlSetFont($Button_uncheck, 7, 600, 0, "Small Fonts")
	GUICtrlSetResizing($Button_uncheck, $GUI_DOCKRIGHT + $GUI_DOCKAUTO)
	GUICtrlSetTip($Button_uncheck, "Deselect ALL files!")
	;
	$Button_quit = GuiCtrlCreateButton("EXIT", $width - 60, $height - 60, 45, 50, $BS_ICON)
	GUICtrlSetResizing($Button_quit, $GUI_DOCKLEFT + $GUI_DOCKALL + $GUI_DOCKSIZE)
	GUICtrlSetTip($Button_quit, "Exit / Close / Quit the window!")
	;
	; SETTINGS
	GUICtrlSetImage($Button_quit, $user, $icoX, 1)
	;
	; Testing only
	$dllcall = ""
	$theme = ""
	If $theme = 1 Then
		If FileExists(@SystemDir & "\UxTheme.dll") Then
			$dllcall = 1
			DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($Progress_bar), "wstr", 0, "wstr", 0)
			GUICtrlSetStyle($Progress_bar, BitOr($GUI_SS_DEFAULT_PROGRESS, $PBS_SMOOTH))
			;GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
			;GUICtrlSetColor($Progress_bar, $COLOR_RED)
			;GUICtrlSetBkColor($Progress_bar, $COLOR_BLACK)
			;GUICtrlSetBkColor($Label_percent, $GUI_BKCOLOR_TRANSPARENT)
			;
			;GUICtrlSetData($Progress_bar, 50)
			;GUICtrlSendMsg($Progress_bar, $PBM_SETSTATE, 2, 50)
			;;_SendMessage(GUICtrlGetHandle($Progress_bar), $PBM_SETSTATE, 2) ; Red
			;GUICtrlSetData($Label_percent, "50%")
		EndIf
	EndIf
	;
	GUICtrlSetData($Combo_shutdown, "none|Hibernate|Logoff|Powerdown|Reboot|Shutdown|Standby", "none")
	;
	$pinged = ""
	If $caption = "Downloads List" Then
		If $getlatest = 4 And $exists = 1 Then
			$ping = Ping("gog.com", 4000)
			If $ping = 0 Then
				MsgBox(262192, "Warning", "File names could not be checked, no web connection!" & @LF & @LF _
					& "IMPORTANT - This could mean that latest file versions" & @LF _
					& "may not be shown. Reload (toggle Relax) to try again.", 0, $SelectorGUI)
			Else
				SplashTextOn("", "Please Wait!" & @LF & @LF & "(Checking File Names)" & @LF & "(Loading List)", 200, 140, Default, Default, 33)
			EndIf
		Else
			$ping = 0
		EndIf
		If $ping = 0 Then SplashTextOn("", "Please Wait!" & @LF & @LF & "(Loading List)", 180, 130, Default, Default, 33)
		$col1 = 0
		$prior = ""
		$sections = IniReadSectionNames($downfiles)
		For $s = 1 To $sections[0]
			$sect = $sections[$s]
			If $sect <> "Title" Then
				$col4 = IniRead($downfiles, $sect, "file", "")
				If $ping > 0 Then
					$pinged = 1
					GUICtrlSetState($Button_download, $GUI_DISABLE)
					GUICtrlSetState($ListView_files, $GUI_DISABLE)
					If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
					GUICtrlSetState($Radio_selall, $GUI_DISABLE)
					GUICtrlSetState($Radio_selgame, $GUI_DISABLE)
					GUICtrlSetState($Radio_selext, $GUI_DISABLE)
					GUICtrlSetState($Radio_selset, $GUI_DISABLE)
					GUICtrlSetState($Radio_selpat, $GUI_DISABLE)
					GUICtrlSetState($Combo_OSfle, $GUI_DISABLE)
					GUICtrlSetState($Button_uncheck, $GUI_DISABLE)
					GUICtrlSetState($Button_quit, $GUI_DISABLE)
					$file = $col4
					_FileWriteLog($logfle, "CHECKING FILENAME - " & $file, -1)
					$URL = IniRead($downfiles, $file, "URL", "")
					If $URL <> "" Then
						$params = '-c Cookie.txt gog-api url-path-info -p=' & $URL & ' >"' & $fileinfo & '"'
						$pid = RunWait(@ComSpec & ' /c echo CHECKING FILENAME ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
						Sleep(500)
						_FileReadToArray($fileinfo, $array)
						If @error = 0 Then
							If $array[0] = 3 Then
								$val = StringReplace($array[1], "File Name: ", "")
								If $val = $file Then
									_FileWriteLog($logfle, "Checked Okay.", -1)
								Else
									$sect = $file
									$file = $val
									$col4 = $file
									IniWrite($downfiles, $sect, "file", $file)
									$checksum = StringReplace($array[2], "Checksum: ", "")
									IniWrite($downfiles, $sect, "checksum", $checksum)
									$filesize = StringReplace($array[3], "Size: ", "")
									IniWrite($downfiles, $sect, "bytes", $filesize)
									_FileWriteLog($logfle, "Changed - " & $file, -1)
									_FileWriteLog($alerts, $sect & " changed to " & $file, -1)
									$alert = $alert + 1
								EndIf
							Else
								_FileWriteLog($logfle, "Checking Erred (2).", -1)
							EndIf
						Else
							_FileWriteLog($logfle, "Checking Erred (1).", -1)
						EndIf
					EndIf
					GUICtrlSetState($Button_download, $GUI_ENABLE)
					GUICtrlSetState($ListView_files, $GUI_ENABLE)
					If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_ENABLE)
					GUICtrlSetState($Radio_selall, $GUI_ENABLE)
					GUICtrlSetState($Radio_selgame, $GUI_ENABLE)
					GUICtrlSetState($Radio_selext, $GUI_ENABLE)
					GUICtrlSetState($Radio_selset, $GUI_ENABLE)
					GUICtrlSetState($Radio_selpat, $GUI_ENABLE)
					GUICtrlSetState($Combo_OSfle, $GUI_ENABLE)
					GUICtrlSetState($Button_uncheck, $GUI_ENABLE)
					GUICtrlSetState($Button_quit, $GUI_ENABLE)
				EndIf
				If $exists = 1 Then
					$missing = IniRead($downfiles, $sect, "missing", "")
					If $missing = "checksum" Then
						If $relax = 1 Then ContinueLoop
					EndIf
				EndIf
				$col1 = $col1 + 1
				$col2 = IniRead($downfiles, $sect, "type", "")
				$col3 = IniRead($downfiles, $sect, "size", "")
				$titleD = IniRead($downfiles, $sect, "game", "")
				$entry = $col1 & "|" & $col2 & "|" & $col3 & "|" & $col4
				;MsgBox(262208, "Entry Information", $entry, 0, $SelectorGUI)
				$idx = GUICtrlCreateListViewItem($entry, $ListView_files)
				If $prior = "" Then
					$prior = $titleD
					$color = 0xB9FFFF
				ElseIf $prior <> $titleD Then
					$prior = $titleD
					If $color = 0xB9FFFF Then
						$color = 0xFFFFB0
					Else
						$color = 0xB9FFFF
					EndIf
				EndIf
				GUICtrlSetBkColor($idx, $color)
				If $missing = "checksum" Then GUICtrlSetColor($idx, $COLOR_WHITE)
			EndIf
		Next
		;Sleep(5000)
		SplashOff()
	Else
		GetFileDownloadDetails($ListView_files)
	EndIf
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
	GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
	;
	;GUICtrlSetData($Label_warn, "Ensure desired download settings have been set on the SETUP window.")
	GUICtrlSetData($Label_warn, "Ensure wanted download options are set in SETUP window.")
	;
	If $exists = 4 Then
		GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
	Else
		GUICtrlSetState($Checkbox_relax, $relax)
	EndIf
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
	;
	$skip = IniRead($inifle, "Existing Files", "skip", "")
	If $skip = "" Then
		$skip = 1
		IniWrite($inifle, "Existing Files", "skip", $skip)
	EndIf
	GUICtrlSetState($Checkbox_skip, $skip)

	GuiSetState()
	While 1
		$msg = GuiGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_quit
			; Exit / Close / Quit the window
			$exists = IniRead($inifle, "Exists Database", "use", "")
			$relax = IniRead($inifle, "Exists Database", "relax", "")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
			Else
				GUICtrlSetData($Group_files, "Files To Download")
			EndIf
			GUICtrlSetState($Radio_selall, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selgame, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selext, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selset, $GUI_UNCHECKED)
			GUICtrlSetState($Radio_selpat, $GUI_UNCHECKED)
		Case $msg = $Button_download
			; Download selected files
			;MsgBox(262192, "Download Error", "This feature is not yet supported!", 1.5, $SelectorGUI)
			Local $test = ""
			If GUICtrlRead($Checkbox_cancel) = $GUI_CHECKED Then
				MsgBox(262192, "Download Error", "Cancel is selected!", 0, $SelectorGUI)
			Else
				$cancel = ""
				$ping = Ping("gog.com", 4000)
				If $ping > 0 Or $test = 1 Then
					GUICtrlSetState($Button_download, $GUI_DISABLE)
					GUICtrlSetState($ListView_files, $GUI_DISABLE)
					If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
					GUICtrlSetState($Radio_selall, $GUI_DISABLE)
					GUICtrlSetState($Radio_selgame, $GUI_DISABLE)
					GUICtrlSetState($Radio_selext, $GUI_DISABLE)
					GUICtrlSetState($Radio_selset, $GUI_DISABLE)
					GUICtrlSetState($Radio_selpat, $GUI_DISABLE)
					GUICtrlSetState($Combo_OSfle, $GUI_DISABLE)
					GUICtrlSetState($Button_uncheck, $GUI_DISABLE)
					GUICtrlSetState($Button_quit, $GUI_DISABLE)
					$downloading = ""
					_GUICtrlListView_SetItemSelected($ListView_files, -1, True, False)
					For $a = 0 To $ents - 1
						If _GUICtrlListView_GetItemChecked($ListView_files, $a) = True Then
							$entry = _GUICtrlListView_GetItemText($ListView_files, $a, 3)
							If StringLeft($entry, 14) <> "Downloading..." And StringLeft($entry, 9) <> "PASSED..." And StringLeft($entry, 7) <> "DONE..." _
								And StringLeft($entry, 11) <> "MD5check..." And StringLeft($entry, 10) <> "MD5okay..." _
								And StringLeft($entry, 11) <> "ZIPcheck..." And StringLeft($entry, 10) <> "ZIPokay..." Then
								If StringLeft($entry, 9) = "FAILED..." Or StringLeft($entry, 9) = "MD5bad..." Or StringLeft($entry, 9) = "ZIPbad..." Then
									$entry = StringTrimLeft($entry, 9)
									_GUICtrlListView_SetItemText($ListView_files, $a, $entry, 3)
								ElseIf StringLeft($entry, 10) = "SKIPPED..." Then
									$entry = StringTrimLeft($entry, 10)
									_GUICtrlListView_SetItemText($ListView_files, $a, $entry, 3)
								EndIf
								If $downloading = "" Then
									$downloading = $entry
								Else
									$downloading = $downloading & "|" & $entry
								EndIf
							EndIf
						EndIf
					Next
					If $downloading <> "" Then
						;MsgBox(262192, "Selected Files", $downloading, 2, $SelectorGUI)
						If $minimize = 1 Then
							$flag = @SW_MINIMIZE
						Else
							$flag = @SW_SHOW
						EndIf
						GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
						If $pinged = "" Then $alert = 0
						$md5check = ""
						$zipcheck = ""
						;$nmb = 0
						FileChangeDir(@ScriptDir)
						$files = StringSplit($downloading, "|", 1)
						For $f = 1 To $files[0]
							$file = $files[$f]
							$titleD = IniRead($downfiles, $file, "game", "")
							$slugD = IniRead($downfiles, $file, "slug", "")
							$URL = IniRead($downfiles, $file, "URL", "")
							If $URL <> "" Then
								; This may have been set prior or during
								If GUICtrlRead($Checkbox_skip) = $GUI_CHECKED Then
									; Skip Existing Files
									If $skip = 4 Then
										; Changed during, record the change
										$skip = 1
										IniWrite($inifle, "Existing Files", "skip", $skip)
									EndIf
									GetGameFolderNameAndPath($titleD, $slugD)
									If FileExists($gamefold) Then
										$download = $gamefold & "\" & $file
										If FileExists($download) Then
											_FileWriteLog($logfle, "SKIPPED - " & $file, -1)
											$i = _GUICtrlListView_FindInText($ListView_files, $file, -1, True, False)
											If $i > -1 Then
												_GUICtrlListView_SetItemSelected($ListView_files, $i, True, True)
												_GUICtrlListView_EnsureVisible($ListView_files, $i, False)
												$row = $Button_quit + $i + 1
												GUICtrlSetBkColor($row, $COLOR_SILVER)  ;$COLOR_MEDGRAY
												_GUICtrlListView_SetItemText($ListView_files, $i, "SKIPPED..." & $file, 3)
												_FileWriteLog($logfle, "File exists.", -1)
											EndIf
											ContinueLoop
										EndIf
									EndIf
								EndIf
								If $model > 7 Then
									$drv = StringLeft($gamesfold, 3)
								Else
									$drv = StringLeft(@ScriptDir, 3)
								EndIf
								$space = DriveSpaceFree($drv)
								$free = Floor($space * 1048576)
								$filesize = IniRead($downfiles, $file, "bytes", 0)
								If $filesize < $free Then
									;$titleD = IniRead($downfiles, $file, "game", "")
									;$slugD = IniRead($downfiles, $file, "slug", "")
									$IDD = IniRead($downfiles, $file, "ID", "")
									$checksum = IniRead($downfiles, $file, "checksum", "")
									$i = _GUICtrlListView_FindInText($ListView_files, $file, -1, True, False)
									If $i > -1 Then
										$row = $Button_quit + $i + 1
										GUICtrlSetBkColor($row, $COLOR_YELLOW)
										_GUICtrlListView_SetItemSelected($ListView_files, $i, True, True)
										_GUICtrlListView_EnsureVisible($ListView_files, $i, False)
										_GUICtrlListView_SetItemText($ListView_files, $i, "Downloading..." & $file, 3)
										If $test = 1 Then
											Sleep(5000)
										Else
											If $getlatest = 4 And $pinged = "" Then
												; Check for correct file name
												_FileWriteLog($logfle, "CHECKING FILENAME - " & $file, -1)
												$params = '-c Cookie.txt gog-api url-path-info -p=' & $URL & ' >"' & $fileinfo & '"'
												$pid = RunWait(@ComSpec & ' /c echo CHECKING FILENAME ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
												Sleep(500)
												_FileReadToArray($fileinfo, $array)
												If @error = 0 Then
													If $array[0] = 3 Then
														$val = StringReplace($array[1], "File Name: ", "")
														If $val = $file Then
															_FileWriteLog($logfle, "Checked Okay.", -1)
														Else
															$sect = $file
															$file = $val
															IniWrite($downfiles, $sect, "file", $file)
															$checksum = StringReplace($array[2], "Checksum: ", "")
															IniWrite($downfiles, $sect, "checksum", $checksum)
															$filesize = StringReplace($array[3], "Size: ", "")
															IniWrite($downfiles, $sect, "bytes", $filesize)
															_FileWriteLog($logfle, "Changed - " & $file, -1)
															_FileWriteLog($alerts, $sect & " changed to " & $file, -1)
															$alert = $alert + 1
														EndIf
													Else
														_FileWriteLog($logfle, "Checking Erred (2).", -1)
													EndIf
												Else
													_FileWriteLog($logfle, "Checking Erred (1).", -1)
												EndIf
											EndIf
											_FileWriteLog($logfle, "DOWNLOADING - " & $file, -1)
											GUICtrlSetData($Progress_bar, 0)
											GUICtrlSetData($Label_percent, "0%")
											$begin = ""
											$found = ""
											If $model > 7 And FileExists($gamesfold) Then
												$params = "-c Cookie.txt gog-api download-url-path -p=" & $URL & " -r=" & $gamesfold
												$download = $gamesfold & "\" & $file
											Else
												$params = "-c Cookie.txt gog-api download-url-path -p=" & $URL
												$download = @ScriptDir & "\" & $file
											EndIf
											;$pid = RunWait(@ComSpec & ' /c echo DOWNLOADING ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
											$pid = Run(@ComSpec & ' /c echo DOWNLOADING ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
											While ProcessExists($pid) <> 0
												Sleep(500)
												If $filesize <> 0 Then
													If $found = "" Then $found = FileExists($download)
													If $found = 1 Then
														$handle = FileOpen($download, 0)
														DllCall("Kernel32.dll", "BOOLEAN", "FlushFileBuffers", "HANDLE", $handle)
														$done = FileGetSize($download)
														FileClose($handle)
														If $done <> 0 Then
															If $begin = "" Then $begin = TimerInit()
															$progress = $done
															$percent = ($progress / $filesize) * 100
															GUICtrlSetData($Progress_bar, $percent)
															$percent = Floor($percent) & "%"
															GUICtrlSetData($Label_percent, $percent)
															;GUICtrlSetTip($Progress_bar, $percent)
															$taken = TimerDiff($begin)
															$secs = $taken / 1000
															; KBs
															$gotten = $done / 1024
															If $gotten < 1024 Then
																; Kb/s
																$done = Floor($gotten) & " Kbs"
															Else
																; Mb/s
																$done = $gotten / 1024
																If $done < 1024 Then
																	$done = Round($done, 1) & " Mbs"
																Else
																	$done = Round($done / 1024, 2) & " Gbs"
																EndIf
															EndIf
															GUICtrlSetData($Label_done, $done)
															; MBs
															$gotten = $gotten / 1024
															$speed = Round($gotten / $secs, 1) & " Mb/s"
															If $speed < 1 Then $speed = Floor($speed * 1024) & " Kb/s"
															GUICtrlSetData($Label_speed, $speed)
														EndIf
													EndIf
												EndIf
											WEnd
											GUICtrlSetData($Label_done, "0 Kbs")
											GUICtrlSetData($Label_speed, "0 Kb/s")
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
														; Size compare passed
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
														;$nmb = $nmb + 1
														;IniWrite($existDB, $slugD, "file_" & $nmb, $filesize)
														;IniWrite($existDB, $sect, "bytes", $filesize)
														IniWrite($existDB, $file, $slugD, $filesize & "|" & $checksum)
													Else
														; Size compare failed
														GUICtrlSetBkColor($row, $COLOR_RED)
														_GUICtrlListView_SetItemText($ListView_files, $i, "FAILED..." & $file, 3)
														_FileWriteLog($logfle, "File Size check failed.", -1)
														; NOTE - Could add an optional ContinueLoop to skip further checking.
														; An option could be added to the SETUP window's 'Download Options' for this.
														; 'Skip validation if file size check fails'
														; But probably not recommended, as validation is the ultimate check.
														; Everything relies on GOG providing correct values anyway.
														; It is conceivable that either value could be wrong on a rare occasion,
														; but maybe not both.
														; Anyway, in the case of ZIP testing, the process is quick if a failure.
														; It may also be the case for MD5 checking.
													EndIf
													$fext = StringRight($file, 4)
													$filepth = ""
													$zippath = ""
													$gamepic = ""
													GetGameFolderNameAndPath($titleD, $slugD)
													If Not FileExists($gamefold) Then DirCreate($gamefold)
													;
													; NOTE - If $gamesfold is on a different drive to download folder, then a free space check should be done.
													;
													If FileExists($gamefold) Then
														FileMove($download, $gamefold & "\", 1)
														If $cover = 1 Then
															$gamepic = $gamefold & "\Folder.jpg"
														EndIf
														If $validate = 1 Then
															If $checksum <> "" Then
																$filepth = $gamefold & "\" & $file
															ElseIf $fext = ".zip" Then
																$zippath = $gamefold & "\" & $file
															EndIf
														EndIf
													ElseIf FileExists($gamesfold) Then
														; Shouldn't really be here. In theory $gamesfold could be download folder, so no move needed.
														FileMove($download, $gamesfold & "\", 1)
														If $cover = 1 Then
															$gamepic = $gamesfold & "\" & $name & ".jpg"
														EndIf
														If $validate = 1 Then
															If $checksum <> "" Then
																$filepth = $gamesfold & "\" & $file
															ElseIf $fext = ".zip" Then
																$zippath = $gamesfold & "\" & $file
															EndIf
														EndIf
													EndIf
													If $validate = 1 Then
														If $filepth <> "" Then
															$checkval = $filepth & "|" & $checksum & "|" & $i & "|" & $slugD
															If $md5check = "" Then
																$md5check = $checkval
															Else
																$md5check = $md5check & "||" & $checkval
															EndIf
														EndIf
														If $zippath <> "" Then
															$checkval = $zippath & "|" & $i & "|" & $slugD
															If $zipcheck = "" Then
																$zipcheck = $checkval
															Else
																$zipcheck = $zipcheck & "||" & $checkval
															EndIf
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
										_GUICtrlListView_SetItemSelected($ListView_files, $i, True, True)
										_GUICtrlListView_EnsureVisible($ListView_files, $i, False)
										$row = $Button_quit + $i + 1
										GUICtrlSetBkColor($row, $COLOR_FUCHSIA)
										_GUICtrlListView_SetItemText($ListView_files, $i, "SKIPPED..." & $file, 3)
									EndIf
									_FileWriteLog($logfle, "Not enough drive space.", -1)
									$space = Round($space, 3)
									MsgBox(262192, "Drive Space Error", "Not enough free space on destination drive, only " & $space & " Mb's", 7, $SelectorGUI)
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
								GUICtrlSetData($Label_percent, "")
								$md5check = StringSplit($md5check, "||", 1)
								For $m = 1 To $md5check[0]
									$checkval = $md5check[$m]
									$checkval = StringSplit($checkval, "|", 1)
									$filepth = $checkval[1]
									$checksum = $checkval[2]
									$i = $checkval[3]
									$slugD = $checkval[4]
									$i = Number($i)
									_GUICtrlListView_SetItemSelected($ListView_files, $i, True, True)
									_GUICtrlListView_EnsureVisible($ListView_files, $i, False)
									$row = $Button_quit + $i + 1
									If FileExists($filepth) Then
										$file = StringSplit($filepth, "\", 1)
										$file = $file[$file[0]]
										_GUICtrlListView_SetItemText($ListView_files, $i, "MD5check..." & $file, 3)
										GUICtrlSetStyle($Progress_bar, $PBS_MARQUEE)
										GUICtrlSetData($Progress_bar, 0)
										If $dllcall = 1 Then
											GUICtrlSetColor($Progress_bar, 0xDD0000)
										Else
											GUICtrlSendMsg($Progress_bar, $PBM_SETMARQUEE, 1, 50)
										EndIf
										GUICtrlSetData($Label_percent, "")
										;GUICtrlSetData($Progress_bar, 0)
										;GUICtrlSetData($Label_percent, "0%")
										;$filesize = IniRead($downfiles, $file, "bytes", 0)
										;If $filesize > 0 Then
										;	$factor = IniRead($inifle, "Download Options", "md5_factor", "")
										;	$begin = TimerInit()
										;EndIf
										_Crypt_Startup()
										$hash = _Crypt_HashFile($filepth, $CALG_MD5)
										_Crypt_Shutdown()
										;If $filesize > 0 Then
										;	$taken = TimerDiff($begin)
										;	$factor = $taken / $filesize
										;	IniWrite($inifle, "Download Options", "md5_factor", $factor)
										;EndIf
										Sleep(1000)
										GUICtrlSendMsg($Progress_bar, $PBM_SETMARQUEE, 0, 50)
										GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
										GUICtrlSetData($Progress_bar, 100)
										If $dllcall = "" Then
											GUICtrlSendMsg($Progress_bar, $PBM_SETSTATE, 2, 50)
										EndIf
										GUICtrlSetData($Label_percent, "100%")
										Sleep(2000)
										$hash = StringTrimLeft($hash, 2)
										If $hash = $checksum Then
											; Checksum Passed.
											GUICtrlSetBkColor($row, $COLOR_LIME)
											_GUICtrlListView_SetItemText($ListView_files, $i, "MD5okay..." & $file, 3)
											_FileWriteLog($logfle, $file, -1)
											_FileWriteLog($logfle, "MD5 Check passed.", -1)
										Else
											; Checksum Failed.
											GUICtrlSetBkColor($row, $COLOR_RED)
											_GUICtrlListView_SetItemText($ListView_files, $i, "MD5bad..." & $file, 3)
											_FileWriteLog($logfle, $file, -1)
											_FileWriteLog($logfle, "MD5 Check failed.", -1)
											;MsgBox(262192, "Checksum Failure", "MD5 = " & $checksum & @LF & "Hash = " & $hash, 0, $SelectorGUI)
											; Delete database entry due to incomplete pass.
											IniDelete($existDB, $file, $slugD)
										EndIf
										;$foldpth = StringTrimRight($filepth, StringLen($file) + 1)
										If $dllcall = "" Then
											GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
											_SendMessage(GUICtrlGetHandle($Progress_bar), $PBM_SETSTATE, 1)
										EndIf
									EndIf
								Next
							EndIf
							If $zipcheck <> "" Then
								; Check zip file integrity
								$zipcheck = StringSplit($zipcheck, "||", 1)
								For $z = 1 To $zipcheck[0]
									$checkval = $zipcheck[$z]
									$checkval = StringSplit($checkval, "|", 1)
									$zippath = $checkval[1]
									$i = $checkval[2]
									$slugD = $checkval[3]
									$i = Number($i)
									_GUICtrlListView_SetItemSelected($ListView_files, $i, True, True)
									_GUICtrlListView_EnsureVisible($ListView_files, $i, False)
									$row = $Button_quit + $i + 1
									If FileExists($zippath) Then
										$file = StringSplit($zippath, "\", 1)
										$file = $file[$file[0]]
										_GUICtrlListView_SetItemText($ListView_files, $i, "ZIPcheck..." & $file, 3)
										GUICtrlSetStyle($Progress_bar, $PBS_MARQUEE)
										GUICtrlSetData($Progress_bar, 0)
										If $dllcall = 1 Then
											GUICtrlSetColor($Progress_bar, $COLOR_YELLOW)
										Else
											GUICtrlSendMsg($Progress_bar, $PBM_SETMARQUEE, 1, 50)
										EndIf
										GUICtrlSetData($Label_percent, "")
										$ret = _Zip_List($zippath)
										$ret = $ret[0]
										If $ret > 0 Then
											; Zip Passed.
											GUICtrlSetBkColor($row, $COLOR_AQUA)
											_GUICtrlListView_SetItemText($ListView_files, $i, "ZIPokay..." & $file, 3)
											_FileWriteLog($logfle, $file, -1)
											_FileWriteLog($logfle, "ZIP Check passed.", -1)
										Else
											; Zip Failed.
											GUICtrlSetBkColor($row, $COLOR_RED)
											_GUICtrlListView_SetItemText($ListView_files, $i, "ZIPbad..." & $file, 3)
											_FileWriteLog($logfle, $file, -1)
											_FileWriteLog($logfle, "ZIP Check failed.", -1)
											; Delete database entry due to incomplete pass.
											IniDelete($existDB, $file, $slugD)
										EndIf
										Sleep(1000)
										GUICtrlSendMsg($Progress_bar, $PBM_SETMARQUEE, 0, 50)
										GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
										GUICtrlSetData($Progress_bar, 100)
										If $dllcall = "" Then
											GUICtrlSendMsg($Progress_bar, $PBM_SETSTATE, 3, 50)
										EndIf
										GUICtrlSetData($Label_percent, "100%")
										Sleep(2000)
										If $dllcall = "" Then
											GUICtrlSetStyle($Progress_bar, $PBS_SMOOTH)
											_SendMessage(GUICtrlGetHandle($Progress_bar), $PBM_SETSTATE, 1)
										EndIf
									EndIf
								Next
							EndIf
							FileWriteLine($logfle, "")
							If $dllcall = 1 Then GUICtrlSetColor($Progress_bar, $COLOR_LIME)
						EndIf
						_GUICtrlListView_SetItemSelected($ListView_files, -1, False, False)
						_GUICtrlListView_SetColumnWidth($ListView_files, 3, $LVSCW_AUTOSIZE)
					Else
						MsgBox(262192, "Program Error", "Nothing to download!", 2, $SelectorGUI)
					EndIf
					$shutdown = GUICtrlRead($Combo_shutdown)
					If $shutdown <> "none" Then
						Local $code
						$ans = MsgBox(262193, "Shutdown Query", _
							"PC is set to shutdown in 99 seconds." & @LF & @LF & _
							"OK = Shutdown." & @LF & _
							"CANCEL = Abort shutdown.", 99, $SelectorGUI)
						If $ans = 1 Or $ans = -1 Then
							If $shutdown = "Shutdown" Then
								; Shutdown
								$code = 1 + 4 + 16
							ElseIf $shutdown = "Hibernate" Then
								; Hibernate
								$code = 64
							ElseIf $shutdown = "Standby" Then
								; Standby
								$code = 32
							ElseIf $shutdown = "Powerdown" Then
								; Powerdown
								$code = 8 + 4 + 16
							ElseIf $shutdown = "Logoff" Then
								; Logoff
								$code = 0 + 4 + 16
							ElseIf $shutdown = "Reboot" Then
								; Reboot
								$code = 2 + 4 + 16
							EndIf
							Shutdown($code)
							Exit
						EndIf
					EndIf
					GUICtrlSetState($Button_download, $GUI_ENABLE)
					GUICtrlSetState($ListView_files, $GUI_ENABLE)
					If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_ENABLE)
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
		Case $msg = $Checkbox_skip
			; Skip downloading existing files
			If GUICtrlRead($Checkbox_skip) = $GUI_CHECKED Then
				$skip = 1
			Else
				$skip = 4
			EndIf
			IniWrite($inifle, "Existing Files", "skip", $skip)
		Case $msg = $Checkbox_relax
			; Relax the rules for download list files
			$ans = MsgBox(262177 + 256, "Relax Query & Advice", _
				"This option change is temporary and does not" & @LF & _
				"make a permanent change to existing settings." & @LF & @LF & _
				"This option change also reloads the file list." & @LF & @LF & _
				"Do you want to continue?", 0, $GOGcliGUI)
			If $ans = 1 Then
				;If $exists = 4 Then $exists = 1
				If GUICtrlRead($Checkbox_relax) = $GUI_CHECKED Then
					$relax = 1
				Else
					$relax = 4
				EndIf
				_GUICtrlListView_DeleteAllItems($ListView_files)
				If $caption = "Downloads List" Then
					If $getlatest = 4 And $exists = 1 And $pinged = "" Then
						; Try again to check file names.
						$ping = Ping("gog.com", 4000)
						If $ping = 0 Then
							MsgBox(262192, "Warning", "File names could not be checked, no web connection!" & @LF & @LF _
								& "IMPORTANT - This could mean that latest file versions" & @LF _
								& "may not be shown. Reload (toggle Relax) to try again.", 0, $SelectorGUI)
						Else
							SplashTextOn("", "Please Wait!" & @LF & @LF & "(Checking File Names)" & @LF & "(Loading List)", 200, 140, Default, Default, 33)
						EndIf
					Else
						$ping = 0
					EndIf
					If $ping = 0 Then SplashTextOn("", "Please Wait!" & @LF & @LF & "(Loading List)", 180, 130, Default, Default, 33)
					$col1 = 0
					$prior = ""
					$sections = IniReadSectionNames($downfiles)
					For $s = 1 To $sections[0]
						$sect = $sections[$s]
						If $sect <> "Title" Then
							$col4 = IniRead($downfiles, $sect, "file", "")
							If $ping > 0 Then
								$pinged = 1
								GUICtrlSetState($Button_download, $GUI_DISABLE)
								GUICtrlSetState($ListView_files, $GUI_DISABLE)
								If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_DISABLE)
								GUICtrlSetState($Radio_selall, $GUI_DISABLE)
								GUICtrlSetState($Radio_selgame, $GUI_DISABLE)
								GUICtrlSetState($Radio_selext, $GUI_DISABLE)
								GUICtrlSetState($Radio_selset, $GUI_DISABLE)
								GUICtrlSetState($Radio_selpat, $GUI_DISABLE)
								GUICtrlSetState($Combo_OSfle, $GUI_DISABLE)
								GUICtrlSetState($Button_uncheck, $GUI_DISABLE)
								GUICtrlSetState($Button_quit, $GUI_DISABLE)
								$file = $col4
								_FileWriteLog($logfle, "CHECKING FILENAME - " & $file, -1)
								$URL = IniRead($downfiles, $file, "URL", "")
								If $URL <> "" Then
									$params = '-c Cookie.txt gog-api url-path-info -p=' & $URL & ' >"' & $fileinfo & '"'
									$pid = RunWait(@ComSpec & ' /c echo CHECKING FILENAME ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
									Sleep(500)
									_FileReadToArray($fileinfo, $array)
									If @error = 0 Then
										If $array[0] = 3 Then
											$val = StringReplace($array[1], "File Name: ", "")
											If $val = $file Then
												_FileWriteLog($logfle, "Checked Okay.", -1)
											Else
												$sect = $file
												$file = $val
												$col4 = $file
												IniWrite($downfiles, $sect, "file", $file)
												$checksum = StringReplace($array[2], "Checksum: ", "")
												IniWrite($downfiles, $sect, "checksum", $checksum)
												$filesize = StringReplace($array[3], "Size: ", "")
												IniWrite($downfiles, $sect, "bytes", $filesize)
												_FileWriteLog($logfle, "Changed - " & $file, -1)
												_FileWriteLog($alerts, $sect & " changed to " & $file, -1)
												$alert = $alert + 1
											EndIf
										Else
											_FileWriteLog($logfle, "Checking Erred (2).", -1)
										EndIf
									Else
										_FileWriteLog($logfle, "Checking Erred (1).", -1)
									EndIf
								EndIf
								GUICtrlSetState($Button_download, $GUI_ENABLE)
								GUICtrlSetState($ListView_files, $GUI_ENABLE)
								If $exists = 1 Then GUICtrlSetState($Checkbox_relax, $GUI_ENABLE)
								GUICtrlSetState($Radio_selall, $GUI_ENABLE)
								GUICtrlSetState($Radio_selgame, $GUI_ENABLE)
								GUICtrlSetState($Radio_selext, $GUI_ENABLE)
								GUICtrlSetState($Radio_selset, $GUI_ENABLE)
								GUICtrlSetState($Radio_selpat, $GUI_ENABLE)
								GUICtrlSetState($Combo_OSfle, $GUI_ENABLE)
								GUICtrlSetState($Button_uncheck, $GUI_ENABLE)
								GUICtrlSetState($Button_quit, $GUI_ENABLE)
							EndIf
							$missing = IniRead($downfiles, $sect, "missing", "")
							If $missing = "checksum" Then
								If $relax = 1 Then ContinueLoop
							EndIf
							$col1 = $col1 + 1
							$col2 = IniRead($downfiles, $sect, "type", "")
							$col3 = IniRead($downfiles, $sect, "size", "")
							;$col4 = IniRead($downfiles, $sect, "file", "")
							$titleD = IniRead($downfiles, $sect, "game", "")
							$entry = $col1 & "|" & $col2 & "|" & $col3 & "|" & $col4
							;MsgBox(262208, "Entry Information", $entry, 0, $SelectorGUI)
							$idx = GUICtrlCreateListViewItem($entry, $ListView_files)
							If $prior = "" Then
								$prior = $titleD
								$color = 0xB9FFFF
							ElseIf $prior <> $titleD Then
								$prior = $titleD
								If $color = 0xB9FFFF Then
									$color = 0xFFFFB0
								Else
									$color = 0xB9FFFF
								EndIf
							EndIf
							GUICtrlSetBkColor($idx, $color)
							If $missing = "checksum" Then GUICtrlSetColor($idx, $COLOR_WHITE)
						EndIf
					Next
					SplashOff()
				Else
					GetFileDownloadDetails($ListView_files)
				EndIf
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
			Else
				GUICtrlSetState($Checkbox_relax, $relax)
			EndIf
		Case $msg = $Combo_OSfle
			; OS for files
			$osfle = GUICtrlRead($Combo_OSfle)
			IniWrite($inifle, "Selector", "OS", $osfle)
			;
			_GUICtrlListView_SetItemChecked($ListView_files, -1, False)
			If $ents > 0 Then
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
			Else
				GUICtrlSetData($Group_files, "Files To Download")
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
					GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Files To Download")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
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
					GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Files To Download")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
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
					GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Files To Download")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
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
					GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Files To Download")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
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
					GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")")
				Else
					GUICtrlSetData($Group_files, "Files To Download")
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $checked & ")  (" & $amount & ")")
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
								$checked = 0
							ElseIf StringRight($fext, 3) = ".sh" And $osfle <> "Win-Lin" And $osfle <> "Mac-Lin" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$checked = 0
							ElseIf ($fext = ".exe" Or $fext = ".bin") And $osfle <> "Win-Lin" And $osfle <> "Win-Mac" Then
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$checked = 0
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
								$checked = 1
							EndIf
						Else
							If $osfle = "Windows" Then
								If $fext = ".exe" Or $fext = ".bin" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = 0
								EndIf
							ElseIf $osfle = "Mac" Then
								If $fext = ".dmg" Or $fext = ".pkg" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = 0
								EndIf
							ElseIf $osfle = "Linux" Then
								If StringRight($fext, 3) = ".sh" Then
									_GUICtrlListView_SetItemChecked($ListView_files, $a, True)
									$checked = 1
								Else
									_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
									$checked = 0
								EndIf
							Else
								_GUICtrlListView_SetItemChecked($ListView_files, $a, False)
								$checked = 0
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
				GUICtrlSetData($Group_files, "Files To Download (" & $ents & ")  Selected  (" & $ents & ")  (" & $amount & ")")
			Else
				GUICtrlSetData($Group_files, "Files To Download")
			EndIf
		Case Else
			;;;
		EndSelect
	WEnd
EndFunc ;=> FileSelectorGUI


Func BackupManifestEtc()
	Local $addbak, $bdate, $compbak, $cookbak, $databak, $dlcbak, $endadd, $endbak, $endcomp, $endcook, $enddata, $enddlc
	Local $endgam, $endkey, $endlog, $endman, $endset, $endtag, $endtit, $endupd, $gambak, $keybak, $logbak, $manbak, $ndate
	Local $nmb, $oldbak, $setbak, $tagbak, $titbak, $updbak
	;
	If FileExists($manifest) Then
		If Not FileExists($backups) Then
			; Create Backup folder and backup Manifest file etc for the first time.
			DirCreate($backups)
			FileCopy($addlist, $backups & "\Added.txt_1.bak")
			FileCopy($cdkeys, $backups & "\CDkeys.ini_1.bak")
			FileCopy($compare, $backups & "\Comparisons.txt_1.bak")
			FileCopy($cookies, $backups & "\Cookie.txt_1.bak")
			FileCopy($dlcfile, $backups & "\DLCs.ini_1.bak")
			FileCopy($existDB, $backups & "\Database.ini_1.bak")
			FileCopy($gamelist, $backups & "\Games.txt_1.bak")
			FileCopy($gamesini, $backups & "\Games.ini_1.bak")
			FileCopy($inifle, $backups & "\Settings.ini_1.bak")
			FileCopy($logfle, $backups & "\Log.txt_1.bak")
			FileCopy($manifest, $backups & "\Manifest.txt_1.bak")
			FileCopy($tagfle, $backups & "\Tags.ini_1.bak")
			FileCopy($titlist, $backups & "\Titles.txt_1.bak")
			FileCopy($updated, $backups & "\Updated.txt_1.bak")
		Else
			; Shuffle backups along as needed and replace oldest. NOTE - Oldest backup is always "_1.bak"
			; Backup the game titles files. GROUP BACKUP.
			$ndate = FileGetTime($gamelist, 0, 1)
			$endbak = $backups & "\Games.txt_5.bak"
			If FileExists($endbak) Then
				$bdate = FileGetTime($endbak, 0, 1)
				If $bdate <> $ndate Then
					; Add current game titles files as newest backups.
					$oldbak = $backups & "\Games.txt"
					$titbak = $backups & "\Titles.txt"
					$endtit = $titbak & "_5.bak"
					$gambak = $backups & "\Games.ini"
					$endgam = $gambak & "_5.bak"
					$addbak = $backups & "\Added.txt"
					$endadd = $addbak & "_5.bak"
					$updbak = $backups & "\Updated.txt"
					$endupd = $addbak & "_5.bak"
					For $nmb = 1 To 4
						FileMove($oldbak & "_" & ($nmb + 1) & ".bak", $oldbak & "_" & $nmb & ".bak", 1)
						FileMove($titbak & "_" & ($nmb + 1) & ".bak", $titbak & "_" & $nmb & ".bak", 1)
						FileMove($gambak & "_" & ($nmb + 1) & ".bak", $gambak & "_" & $nmb & ".bak", 1)
						FileMove($addbak & "_" & ($nmb + 1) & ".bak", $addbak & "_" & $nmb & ".bak", 1)
						FileMove($updbak & "_" & ($nmb + 1) & ".bak", $updbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($gamelist, $endbak, 1)
					FileCopy($titlist, $endtit, 1)
					FileCopy($gamesini, $endgam, 1)
					FileCopy($addlist, $endadd, 1)
					FileCopy($updated, $endupd, 1)
				EndIf
			Else
				; Add current game titles files as newest backups in an empty slot.
				For $nmb = 1 To 5
					$oldbak = $backups & "\Games.txt_" & $nmb & ".bak"
					$titbak = $backups & "\Titles.txt_" & $nmb & ".bak"
					$gambak = $backups & "\Games.ini_" & $nmb & ".bak"
					$addbak = $backups & "\Added.txt_" & $nmb & ".bak"
					$updbak = $backups & "\Updated.txt_" & $nmb & ".bak"
					If Not FileExists($oldbak) Then
						If $nmb = 1 Then
							FileCopy($gamelist, $oldbak)
							FileCopy($titlist, $titbak, 1)
							FileCopy($gamesini, $gambak, 1)
							FileCopy($addlist, $addbak, 1)
							FileCopy($updated, $updbak, 1)
						Else
							$bdate = FileGetTime($endbak, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($gamelist, $oldbak)
								FileCopy($titlist, $titbak, 1)
								FileCopy($gamesini, $gambak, 1)
								FileCopy($addlist, $addbak, 1)
								FileCopy($updated, $updbak, 1)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endbak = $oldbak
				Next
			EndIf
			; Backup the Manifest file etc. GROUP BACKUP.
			$ndate = FileGetTime($manifest, 0, 1)
			$endman = $backups & "\Manifest.txt_5.bak"
			If FileExists($endman) Then
				$bdate = FileGetTime($endman, 0, 1)
				If $bdate <> $ndate Then
					; Add current Manifest file & related as newest backups.
					$manbak = $backups & "\Manifest.txt"
					$keybak = $backups & "\CDkeys.ini"
					$endkey = $keybak & "_5.bak"
					$dlcbak = $backups & "\DLCs.ini"
					$enddlc = $dlcbak & "_5.bak"
					For $nmb = 1 To 4
						FileMove($manbak & "_" & ($nmb + 1) & ".bak", $manbak & "_" & $nmb & ".bak", 1)
						FileMove($keybak & "_" & ($nmb + 1) & ".bak", $keybak & "_" & $nmb & ".bak", 1)
						FileMove($dlcbak & "_" & ($nmb + 1) & ".bak", $dlcbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($manifest, $endman, 1)
					FileCopy($cdkeys, $endkey, 1)
					FileCopy($dlcfile, $enddlc, 1)
				EndIf
			Else
				; Add current Manifest file & related as newest backups in an empty slot.
				For $nmb = 1 To 5
					$manbak = $backups & "\Manifest.txt_" & $nmb & ".bak"
					$keybak = $backups & "\CDkeys.ini_" & $nmb & ".bak"
					$dlcbak = $backups & "\DLCs.ini_" & $nmb & ".bak"
					If Not FileExists($manbak) Then
						If $nmb = 1 Then
							FileCopy($manifest, $manbak)
							FileCopy($cdkeys, $keybak, 1)
							FileCopy($dlcfile, $dlcbak, 1)
						Else
							$bdate = FileGetTime($endman, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($manifest, $manbak)
								FileCopy($cdkeys, $keybak, 1)
								FileCopy($dlcfile, $dlcbak, 1)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endman = $manbak
				Next
			EndIf
			; Backup the Tags file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($tagfle, 0, 1)
			$endtag = $backups & "\Tags.ini_5.bak"
			If FileExists($endtag) Then
				$bdate = FileGetTime($endtag, 0, 1)
				If $bdate <> $ndate Then
					; Add current Tags file as newest backup.
					$tagbak = $backups & "\Tags.ini"
					For $nmb = 1 To 4
						FileMove($tagbak & "_" & ($nmb + 1) & ".bak", $tagbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($tagfle, $endtag, 1)
				EndIf
			Else
				; Add current Tags file as newest backup in an empty slot.
				For $nmb = 1 To 5
					$tagbak = $backups & "\Tags.ini_" & $nmb & ".bak"
					If Not FileExists($tagbak) Then
						If $nmb = 1 Then
							FileCopy($tagfle, $tagbak)
						Else
							$bdate = FileGetTime($endtag, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($tagfle, $tagbak)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endtag = $tagbak
				Next
			EndIf
			; Backup the Log file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($logfle, 0, 1)
			$endlog = $backups & "\Log.txt_5.bak"
			If FileExists($endlog) Then
				$bdate = FileGetTime($endlog, 0, 1)
				If $bdate <> $ndate Then
					; Add current Log file as newest backup.
					$logbak = $backups & "\Log.txt"
					For $nmb = 1 To 4
						FileMove($logbak & "_" & ($nmb + 1) & ".bak", $logbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($logfle, $endlog, 1)
				EndIf
			Else
				; Add current Log file as newest backup in an empty slot.
				For $nmb = 1 To 5
					$logbak = $backups & "\Log.txt_" & $nmb & ".bak"
					If Not FileExists($logbak) Then
						If $nmb = 1 Then
							FileCopy($logfle, $logbak)
						Else
							$bdate = FileGetTime($endlog, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($logfle, $logbak)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endlog = $logbak
				Next
			EndIf
			; Backup the Compare file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($compare, 0, 1)
			$endcomp = $backups & "\Comparisons.txt_5.bak"
			If FileExists($endcomp) Then
				$bdate = FileGetTime($endcomp, 0, 1)
				If $bdate <> $ndate Then
					; Add current Compare file as newest backup.
					$compbak = $backups & "\Comparisons.txt"
					For $nmb = 1 To 4
						FileMove($compbak & "_" & ($nmb + 1) & ".bak", $compbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($compare, $endcomp, 1)
				EndIf
			Else
				; Add current Compare file as newest backup in an empty slot.
				For $nmb = 1 To 5
					$compbak = $backups & "\Comparisons.txt_" & $nmb & ".bak"
					If Not FileExists($compbak) Then
						If $nmb = 1 Then
							FileCopy($compare, $compbak)
						Else
							$bdate = FileGetTime($endcomp, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($compare, $compbak)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endcomp = $compbak
				Next
			EndIf
			; Backup the Database file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($existDB, 0, 1)
			$enddata = $backups & "\Database.ini_5.bak"
			If FileExists($enddata) Then
				$bdate = FileGetTime($enddata, 0, 1)
				If $bdate <> $ndate Then
					; Add current Database file as newest backup.
					$databak = $backups & "\Database.ini"
					For $nmb = 1 To 4
						FileMove($databak & "_" & ($nmb + 1) & ".bak", $databak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($existDB, $enddata, 1)
				EndIf
			Else
				; Add current Database file as newest backup in an empty slot.
				For $nmb = 1 To 5
					$databak = $backups & "\Database.ini_" & $nmb & ".bak"
					If Not FileExists($databak) Then
						If $nmb = 1 Then
							FileCopy($existDB, $databak)
						Else
							$bdate = FileGetTime($enddata, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($existDB, $databak)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$enddata = $databak
				Next
			EndIf
			; Backup the Settings file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($inifle, 0, 1)
			$endset = $backups & "\Settings.ini_5.bak"
			If FileExists($endset) Then
				$bdate = FileGetTime($endset, 0, 1)
				If $bdate <> $ndate Then
					; Add current Settings file as newest backup.
					$setbak = $backups & "\Settings.ini"
					For $nmb = 1 To 4
						FileMove($setbak & "_" & ($nmb + 1) & ".bak", $setbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($inifle, $endset, 1)
				EndIf
			Else
				; Add current Settings file as newest backup in an empty slot.
				$read = FileRead($inifle)
				For $nmb = 1 To 5
					$setbak = $backups & "\Settings.ini_" & $nmb & ".bak"
					If Not FileExists($setbak) Then
						If $nmb = 1 Then
							FileCopy($inifle, $setbak)
						Else
							If $read <> FileRead($endset) Then
								$bdate = FileGetTime($endset, 0, 1)
								If $bdate <> $ndate Then
									FileCopy($inifle, $setbak)
								EndIf
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endset = $setbak
				Next
			EndIf
			; Backup the Cookie file etc. INDEPEDENT BACKUP.
			$ndate = FileGetTime($cookies, 0, 1)
			$endcook = $backups & "\Cookie.txt_5.bak"
			If FileExists($endcook) Then
				$bdate = FileGetTime($endcook, 0, 1)
				If $bdate <> $ndate Then
					; Add current Cookie file as newest backup.
					$cookbak = $backups & "\Cookie.txt"
					For $nmb = 1 To 4
						FileMove($cookbak & "_" & ($nmb + 1) & ".bak", $cookbak & "_" & $nmb & ".bak", 1)
					Next
					FileCopy($cookies, $endcook, 1)
				EndIf
			Else
				; Add current Cookie file as newest backup in an empty slot.
				For $nmb = 1 To 5
					$cookbak = $backups & "\Cookie.txt_" & $nmb & ".bak"
					If Not FileExists($cookbak) Then
						If $nmb = 1 Then
							FileCopy($cookies, $cookbak)
						Else
							$bdate = FileGetTime($endcook, 0, 1)
							If $bdate <> $ndate Then
								FileCopy($cookies, $cookbak)
							EndIf
						EndIf
						ExitLoop
					EndIf
					$endcook = $cookbak
				Next
			EndIf
		EndIf
	EndIf
EndFunc ;=> BackupManifestEtc

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
	$cdkey = ""
	GUICtrlSetData($Input_key, $cdkey)
EndFunc ;=> ClearFieldValues

Func CompareFilesToManifest($numb)
	Local $c, $date, $dir, $fext, $filelist, $flename, $kind, $report, $result, $tested, $tot
	_FileWriteLog($logfle, "COMPARING - " & $title, -1)
	GetGameFolderNameAndPath($title, $slug)
	If FileExists($gamefold) Then
		_FileWriteLog($logfle, $gamefold, -1)
		_FileWriteLog($logfle, "Checking MANIFEST", -1)
		$identry = '"Id": ' & $ID & ','
		If StringInStr($read, $identry) > 0 Then
			If $numb = "one" Then GUICtrlSetData($Label_bed, "GAME FOUND")
			$game = StringSplit($read, $identry, 1)
			$game = $game[2]
			$game = StringSplit($game, '"Id":', 1)
			$game = $game[1]
			If $game <> "" Then
				;MsgBox(262208, "Game Results", $game, 0, $GOGcliGUI)
				GUICtrlSetData($Label_mid, "Comparing Game Files")
				_FileWriteLog($logfle, "Comparing Game Files.", -1)
				GetFileDownloadDetails()
				$entries = IniReadSectionNames($downfiles)
				$tot = $entries[0]
				If $tot > 0 Then
					_FileWriteLog($logfle, $tot & " files listed in the manifest.", -1)
					$filelist = _FileListToArrayRec($gamefold, "*.*", 1, 1, 0, 1)
					If @error Then $filelist = ""
					If IsArray($filelist) Then
						$files = ""
						$result = ""
						$tested = 0
						; Check files with manifest entries
						For $f = 1 To $filelist[0]
							$file = $filelist[$f]
							$filepth = $gamefold & "\" & $file
							_PathSplit($filepth, $drv, $dir, $flename, $fext)
							If $fext = ".exe" Or $fext = ".bin" Or $fext = ".dmg" Or $fext = ".pkg" Or $fext = ".sh" Or $fext = ".zip" Then
								$report = ""
								If $numb = "one" Then
									_FileWriteLog($logfle, $file, -1)
									If $result = "" Then
										$result = $file
									Else
										$result = $result & @LF & $file
									EndIf
								Else
									$report = $name & " | " & $file
									$date = @YEAR & "-" & @MON & "-" & @MDAY
								EndIf
								$tested = $tested + 1
								If StringInStr($file, "\") > 0 Then $file = $flename & $fext
								If $files = "" Then
									$files = "|" & $file & "|"
								Else
									$files = $files & $file & "|"
								EndIf
								$filesize = IniRead($downfiles, $file, "bytes", 0)
								If $filesize = 0 Then
									$kind = IniRead($downfiles, $file, "type", "")
									If $kind = "" Then
										If $numb = "one" Then
											$result = $result & @LF & "Manifest entry for file is missing."
											_FileWriteLog($logfle, "Manifest entry for file is missing.", -1)
										Else
											$report = $report & " | no | yes | no | " & $date
										EndIf
									Else
										If $numb = "one" Then
											$result = $result & @LF & "File Size is missing."
											_FileWriteLog($logfle, "File Size is missing.", -1)
										Else
											$report = $report & " | yes | yes | no | " & $date
										EndIf
									EndIf
								Else
									$bytes = FileGetSize($filepth)
									If $bytes = $filesize Then
										If $numb = "one" Then
											$result = $result & @LF & "File Size passed."
											_FileWriteLog($logfle, "File Size passed.", -1)
										Else
											$report = $report & " | yes | yes | pass | " & $date
										EndIf
									Else
										If $numb = "one" Then
											$result = $result & @LF & "File Size failed."
											_FileWriteLog($logfle, "File Size failed.", -1)
										Else
											$report = $report & " | yes | yes | fail | " & $date
										EndIf
									EndIf
								EndIf
								If $report <> "" Then FileWriteLine($compare, $report)
							EndIf
						Next
						; Check manifest entries with files
						$date = @YEAR & "-" & @MON & "-" & @MDAY
						For $c = 1 To $tot
							$entry = $entries[$c]
							If StringInStr($files, "|" & $entry & "|") < 1 Then
								If $numb = "one" Then
									_FileWriteLog($logfle, $entry, -1)
									If $result = "" Then
										$result = $entry
									Else
										$result = $result & @LF & $entry
									EndIf
									$result = $result & @LF & "File is missing from game folder."
									_FileWriteLog($logfle, "File is missing from game folder.", -1)
								Else
									$report = $name & " | " & $entry & " | yes | no | NA | " & $date
									FileWriteLine($compare, $report)
								EndIf
							EndIf
						Next
						If $numb = "one" Then MsgBox(262208, "Compare Results", $result, 0, $GOGcliGUI)
					Else
						$erred = 5
						_FileWriteLog($logfle, "Game folder content issue.", -1)
						MsgBox(262192, "Source Error", "Folder or content issue (i.e. no files found).", 0, $GOGcliGUI)
					EndIf
				Else
					$erred = 4
					_FileWriteLog($logfle, "Manifest Error - No game files found.", -1)
					MsgBox(262192, "Manifest Error", "No game files found.", 0, $GOGcliGUI)
				EndIf
			Else
				$erred = 3
				_FileWriteLog($logfle, "Game data could not be extracted.", -1)
				MsgBox(262192, "Details Error", "Game data could not be extracted!", 0, $GOGcliGUI)
			EndIf
		Else
			$erred = 2
			_FileWriteLog($logfle, "Game manifest entry not found.", -1)
			If $declare = 1 Then
				$date = @YEAR & "-" & @MON & "-" & @MDAY
				$report = $name & " | manifest entry missing | NA | NA | NA | " & $date
				FileWriteLine($compare, $report)
			EndIf
			If $overlook = 4 Then MsgBox(262192, "Entry Error", "Manifest does not contain selected game!" & @LF & @LF & "Use 'ADD TO MANIFEST' first.", 0, $GOGcliGUI)
		EndIf
	Else
		$erred = 1
		_FileWriteLog($logfle, "Game folder not found.", -1)
		If $record = 1 Then
			$date = @YEAR & "-" & @MON & "-" & @MDAY
			$report = $name & " | folder missing | NA | NA | NA | " & $date
			FileWriteLine($compare, $report)
		EndIf
		If $ignore = 4 Then MsgBox(262192, "Path Error", "Game folder does not exist!" & @LF & @LF & "( i.e. not yet created )", 0, $GOGcliGUI)
	EndIf
EndFunc ;=> CompareFilesToManifest

Func FillTheGamesList()
	Local $idx, $sect, $sects
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
			If FileExists($tagfle) Then
				$sects = IniReadSectionNames($tagfle)
				If Not @error Then
					For $s = 1 To $sects[0]
						$sect = $sects[$s]
						$idx = _GUICtrlListView_FindText($Listview_games, $sect, -1, False, False)
						If $idx > -1 Then
							$row = $lowid + $idx + 1
							$updates = IniRead($gamesini, $sect, "updates", "")
							If $updates = 0 Then
								GUICtrlSetBkColor($row, $COLOR_AQUA)
							Else
								GUICtrlSetBkColor($row, 0x8080FF)
							EndIf
						EndIf
					Next
				EndIf
			EndIf
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

Func GetChecksumQuery($rat = "")
	If $same <> "" Then
		$ans = $same
	Else
		$ans = MsgBox(262179 + 256, "Initial Report & Database Add Query", "Checksum value is missing from the manifest. So cannot compare." & @LF & @LF & _
			$file & @LF & @LF & _
			"Get checksum of existing file for the 'Exists' database?" & @LF & @LF & _
			"YES = Get checksum & add file values to database." & @LF & _
			"NO = Just add file values to database." & @LF & _
			"CANCEL = Don't add file values to database.", 0, $GOGcliGUI)
		If $rat = "" Then
			$res = MsgBox(262177 + 256, "Further Queries", "Do you want to use the same response for" & @LF & "any further queries, to avoid delays?", 0, $GOGcliGUI)
			If $res = 1 Then
				$same = $ans
			EndIf
		EndIf
	EndIf
	If $ans = 6 Then
		_Crypt_Startup()
		$hash = _Crypt_HashFile($filepth, $CALG_MD5)
		_Crypt_Shutdown()
		$checksum = StringTrimLeft($hash, 2)
	EndIf
	If $ans <> 2 Then
		_FileWriteLog($logfle, "ADDING FILE to Database.", -1)
		If $checksum <> "" Then
			_FileWriteLog($logfle, "MD5 (checksum) obtained & added.", -1)
		EndIf
		IniWrite($existDB, $file, $slug, $bytes & "|" & $checksum)
	EndIf
EndFunc ;=> GetChecksumQuery

Func GetFileDownloadDetails($listview = "")
	Local $alias, $col1, $col2, $col3, $col4, $fext, $l, $language, $languages, $loop, $OPS, $proceed, $sect, $val, $values
	;$caption
	_FileCreate($downfiles)
	Sleep(500)
	If $listview <> "" Then
		IniWrite($downfiles, "Title", "caption", $caption)
		If $getlatest = 4 And $exists = 1 And $pinged = "" Then
			$ping = Ping("gog.com", 4000)
			If $ping = 0 Then
				MsgBox(262192, "Warning", "File names could not be checked, no web connection!" & @LF & @LF _
					& "IMPORTANT - This could mean that latest file versions" & @LF _
					& "may not be shown. Reload (toggle Relax) to try again.", 0, $GOGcliGUI)
			Else
				$pinged = 1
				SplashTextOn("", "Please Wait!" & @LF & @LF & "(Checking File Names)" & @LF & "(Loading List)", 200, 140, Default, Default, 33)
			EndIf
		Else
			$ping = 0
		EndIf
		If $ping = 0 Then SplashTextOn("", "Please Wait!" & @LF & @LF & "(Loading List)", 180, 130, Default, Default, 33)
	Else
		$ping = 0
	EndIf
	;
	$alias = ""
	$checksum = ""
	$col1 = 0
	$col2 = ""
	$col3 = ""
	$col4 = ""
	$filesize = ""
	$language = ""
	$languages = ""
	$loop = 0
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
		ElseIf StringInStr($line, '"Languages":') > 0 Then
			$line = StringSplit($line, '"Languages": [', 1)
			$line = $line[2]
			If StringInStr($line, '",') > 0 Then
				$line = StringSplit($line, '",', 1)
				$languages = $line[1]
			Else
				$languages = $line
				$loop = 1
			EndIf
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
			$proceed = 1
			If $exists = 1 Then
				If $ping > 0 Then
					$file = $col4
					_FileWriteLog($logfle, "CHECKING FILENAME - " & $file, -1)
					;$URL = IniRead($downfiles, $file, "URL", "")
					If $URL <> "" Then
						$params = '-c Cookie.txt gog-api url-path-info -p=' & $URL & ' >"' & $fileinfo & '"'
						$pid = RunWait(@ComSpec & ' /c echo CHECKING FILENAME ' & $file & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
						Sleep(500)
						_FileReadToArray($fileinfo, $array)
						If @error = 0 Then
							If $array[0] = 3 Then
								$val = StringReplace($array[1], "File Name: ", "")
								If $val = $file Then
									_FileWriteLog($logfle, "Checked Okay.", -1)
								Else
									$sect = $file
									$file = $val
									$col4 = $file
									;IniWrite($downfiles, $sect, "file", $file)
									$checksum = StringReplace($array[2], "Checksum: ", "")
									;IniWrite($downfiles, $sect, "checksum", $checksum)
									$filesize = StringReplace($array[3], "Size: ", "")
									;IniWrite($downfiles, $sect, "bytes", $filesize)
									_FileWriteLog($logfle, "Changed - " & $file, -1)
									_FileWriteLog($alerts, $sect & " changed to " & $file, -1)
									$alert = $alert + 1
								EndIf
							Else
								_FileWriteLog($logfle, "Checking Erred (2).", -1)
							EndIf
						Else
							_FileWriteLog($logfle, "Checking Erred (1).", -1)
						EndIf
					EndIf
				EndIf
				; Check to skip existing in Database.
				$values = IniRead($existDB, $col4, $slug, "")
				If $values <> "" Then
					$values = StringSplit($values, "|")
					If $values[1] = $filesize Then
						; File Size Match
						If $relax = 1 And $values[2] = "" Then
							; Relaxed Match.
							$proceed = ""
						ElseIf $values[2] = $checksum Then
							; Checksum Match
							$fext = StringRight($col4, 4)
							If $values[2] = "" And $fext <> ".zip" Then
								; Don't exclude just based on size, unless a zip.
							Else
								; Perfect Match, so exclude.
								$proceed = ""
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			If $proceed = 1 Then
				; Check to skip duplicates.
				If IniRead($downfiles, $col4, "file", "") <> $col4 Then
					IniWrite($downfiles, $col4, "game", $title)
					IniWrite($downfiles, $col4, "slug", $slug)
					IniWrite($downfiles, $col4, "ID", $ID)
					IniWrite($downfiles, $col4, "file", $col4)
					IniWrite($downfiles, $col4, "language", $language)
					IniWrite($downfiles, $col4, "languages", $languages)
					IniWrite($downfiles, $col4, "OS", $OPS)
					IniWrite($downfiles, $col4, "URL", $URL)
					IniWrite($downfiles, $col4, "title", $alias)
					IniWrite($downfiles, $col4, "bytes", $filesize)
					IniWrite($downfiles, $col4, "size", $col3)
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
		ElseIf $loop = 1 Then
			;MsgBox(262192, "Line", $line, 2, $GOGcliGUI)
			$line = StringStripWS($line, 3)
			If $line = '],' Then
				$languages = StringReplace($languages, '"', '')
				$loop = 0
			Else
				$languages = $languages & $line
				$languages = StringReplace($languages, '""', ', ')
			EndIf
		EndIf
	Next
	If $listview <> "" Then
		;Sleep(5000)
		SplashOff()
	EndIf
EndFunc ;=> GetFileDownloadDetails

Func GetGameFolderNameAndPath($titleF, $slugF)
	$gamefold = $gamesfold
	If $type = "Slug" Then
		$name = $slugF
	ElseIf $type = "Title" Then
		$name = FixTitle($titleF)
	EndIf
	If $alpha = 1 Then
		$alf = StringUpper(StringLeft($name, 1))
		$gamefold = $gamefold & "\" & $alf
	EndIf
	$gamefold = $gamefold & "\" & $name
EndFunc ;=> GetGameFolderNameAndPath

Func GetManifestForTitle()
	Local $ids, $l, $pos, $prior, $titleM
	_FileWriteLog($logfle, "GET MANIFEST - " & $title, -1)
	$titleM = '"' & $title & '"'
	;MsgBox(262208, "Title", $titleM, 0, $GOGcliGUI)
	;$read = ""
	If $manall = 1 And $getlatest = 4 Then
		If FileExists($manifest) Then
			$identry = '"Id": ' & $ID & ','
			$read = FileRead($manifest)
			If StringInStr($read, $identry) > 0 Then
				GUICtrlSetData($Label_mid, "Skipped Existing")
				_FileWriteLog($logfle, "NO REPLACE - Skipped Existing.", -1)
				FileWriteLine($logfle, "")
				Sleep(1000)
				Return
			Else
				GUICtrlSetData($Label_mid, "Adding Game to Manifest")
			EndIf
		EndIf
	EndIf
	$params = StringStripWS($lang & " " & $second, 3)
	$params = StringReplace($params, " ", " -l=")
	$OP = StringReplace($OS, " ", " -o=")
	$params = "-c Cookie.txt manifest generate -l=" & $params & ' -o=' & $OP & ' -i=' & $titleM
	;$params = "-c Cookie.txt manifest generate -l english -o windows linux mac -i " & $titleM
	If StringInStr($title, "&") > 0 Then
		$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
	Else
		$pid = RunWait(@ComSpec & ' /c ECHO ' & $title & ' && gogcli.exe ' & $params, @ScriptDir, $flag)
	EndIf
	Sleep(1000)
	If FileExists($json) Then
		$game = FileRead($json)
		If $game <> "" Then
			; Something was returned, check for game ID in the return.
			$identry = '"Id": ' & $ID & ','
			If StringInStr($game, $identry) > 0 Then
				$ids = StringSplit($game, '"Id":', 1)
				If $ids[0] > 2 Then
					; More than one game returned, need to extract the right one.
					_FileWriteLog($logfle, "Multiple games return.", -1)
					$lines = StringSplit($game, @LF, 1)
					$game = $lines[1] & @LF & $lines[2] & @LF & $lines[3]
					For $l = 4 To $lines[0]
						$line = $lines[$l]
						If StringInStr($line, $identry) > 0 Then
							;$game = $game & @LF & $line
							$ids = 1
							$prior = $line
						ElseIf $ids = 1 Then
							If StringInStr($line, '"Id":') > 0 Then
								$ids = 2
							Else
								$game = $game & @LF & $prior
								If $line = "}" Then
									$game = $game & @LF & $line
									ExitLoop
								EndIf
								$prior = $line
							EndIf
						ElseIf $l = $lines[0] Then
							$game = StringStripWS($game, 2)
							$game = StringTrimRight($game, 1)
							$game = $game & @LF & $prior
							If $line = "}" Then
								$game = $game & @LF & $line
							EndIf
						Else
							$prior = $line
						EndIf
					Next
					$ids = ""
				Else
					$ids = 1
				EndIf
				If FileExists($manifest) Then
					If $read = "" Then $read = FileRead($manifest)
					If StringInStr($read, $identry) < 1 Then
						; Add to manifest
						FileWrite($manifest, @LF & $game)
						_FileWriteLog($logfle, "ADD to manifest.", -1)
					Else
						; Replace in manifest
						GUICtrlSetData($Label_mid, "Replacing Game in Manifest")
						$read = FileRead($manifest)
						Sleep(1000)
						FileCopy($manifest, $manifest & ".bak", 1)
						$head = StringSplit($read, $identry, 1)
						$tail = $head[2]
						$head = $head[1]
						$pos = StringInStr($tail, @LF & "}")
						$tail = StringMid($tail, $pos + 2)
						;$tail = StringSplit($tail, @LF & "}", 1)
						;$tail = $tail[2]
						$game = StringSplit($game, $identry, 1)
						$game = $game[2]
						$read = $head & $identry & $game & $tail
						_FileCreate($manifest)
						FileWrite($manifest, $read)
						_FileWriteLog($logfle, "REPLACE in manifest.", -1)
					EndIf
					Sleep(1000)
				Else
					; Start the manifest
					If $ids = 1 Then
						FileCopy($json, $manifest)
					Else
						FileWrite($manifest, $game)
					EndIf
					_FileWriteLog($logfle, "ADD to manifest.", -1)
				EndIf
				; Check for CDKey
				$cdkey = StringSplit($game, '"CdKey":', 1)
				If $cdkey[0] = 2 Then
					$cdkey = $cdkey[2]
					$cdkey = StringSplit($cdkey, '",', 1)
					$cdkey = $cdkey[1]
					$cdkey = StringReplace($cdkey, '"', '')
					$cdkey = StringStripWS($cdkey, 3)
					If $cdkey <> "" Then
						IniWrite($cdkeys, $ID, "title", $title)
						IniWrite($cdkeys, $ID, "keycode", $cdkey)
						_FileWriteLog($logfle, "CDKey found.", -1)
					EndIf
				EndIf
				; Check for DLC
				$DLC = StringSplit($game, '"DLC"', 1)
				If $DLC[0] > 1 Then
					$DLC = $DLC[0] - 1
					If $DLC > 0 Then
						IniWrite($dlcfile, $ID, "title", $title)
						IniWrite($dlcfile, $ID, "dlc", $DLC)
						_FileWriteLog($logfle, "DLC(s) found.", -1)
					EndIf
				EndIf
				FileWriteLine($logfle, "")
			Else
				; Game ID not found in return.
				$erred = 3
			EndIf
		Else
			; JSON file is empty
			$erred = 2
		EndIf
	Else
		; JSON file not found
		$erred = 1
	EndIf
	If $erred > 0 Then
		_FileWriteLog($logfle, "MANIFEST Retrieval FAILED.", -1)
		FileWriteLine($logfle, "")
		MsgBox(262192, "Add Error", "Retrieval failed! Error " & $erred, 0, $GOGcliGUI)
	EndIf
	;GUICtrlSetData($Label_mid, "")
EndFunc ;=> GetManifestForTitle

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
	Local $new, $p, $titles, $uplist
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

Func RetrieveDataFromGOG($listed, $list)
	Local $e, $IDD, $ids, $l, $paramsD, $pos, $prior, $titleD
	; Retrieve game file data for all listed from GOG
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
							$params = "-c Cookie.txt manifest generate -l=" & $params & " -o=" & $OP
							$entries = StringSplit($listed, @CRLF, 1)
							For $e = 1 To $entries[0]
								$line = $entries[$e]
								If $line <> "" Then
									$entry = StringSplit($line, "|", 1)
									$titleD = $entry[1]
									$IDD = $entry[2]
									$paramsD = $params & ' -i="' & $titleD & '"'
									If StringInStr($titleD, "&") > 0 Then
										$pid = RunWait(@ComSpec & ' /c gogcli.exe ' & $params, @ScriptDir, $flag)
									Else
										$pid = RunWait(@ComSpec & ' /c ECHO ' & $titleD & ' && gogcli.exe ' & $paramsD, @ScriptDir, $flag)
									EndIf
									Sleep(1000)
									If FileExists($json) Then
										$game = FileRead($json)
										If $game <> "" Then
											; Something was returned, check for game ID in the return.
											$identry = '"Id": ' & $IDD & ','
											If StringInStr($game, $identry) > 0 Then
												_FileWriteLog($logfle, "GET MANIFEST - " & $titleD, -1)
												$ids = StringSplit($game, '"Id":', 1)
												If $ids[0] > 2 Then
													; More than one game returned, need to extract the right one.
													_FileWriteLog($logfle, "Multiple games return.", -1)
													$lines = StringSplit($game, @LF, 1)
													$game = $lines[1] & @LF & $lines[2] & @LF & $lines[3]
													For $l = 4 To $lines[0]
														$line = $lines[$l]
														If StringInStr($line, $identry) > 0 Then
															;$game = $game & @LF & $line
															$ids = 1
															$prior = $line
														ElseIf $ids = 1 Then
															If StringInStr($line, '"Id":') > 0 Then
																$ids = 2
															Else
																$game = $game & @LF & $prior
																If $line = "}" Then
																	$game = $game & @LF & $line
																	ExitLoop
																EndIf
																$prior = $line
															EndIf
														ElseIf $l = $lines[0] Then
															$game = StringStripWS($game, 2)
															$game = StringTrimRight($game, 1)
															$game = $game & @LF & $prior
															If $line = "}" Then
																$game = $game & @LF & $line
															EndIf
														Else
															$prior = $line
														EndIf
													Next
													$ids = ""
												Else
													$ids = 1
												EndIf
												If FileExists($manifest) Then
													$name = StringLeft($titleD, 20)
													If $name <> $titleD Then $name = $name & "...."
													GUICtrlSetData($Label_top, $name)
													GUICtrlSetData($Label_bed, $IDD)
													$read = FileRead($manifest)
													If StringInStr($read, $identry) < 1 Then
														; Add to manifest
														GUICtrlSetData($Label_mid, "Adding Game to Manifest")
														FileWrite($manifest, @LF & $game)
														_FileWriteLog($logfle, "ADD to manifest", -1)
													Else
														; Replace in manifest
														GUICtrlSetData($Label_mid, "Replacing Game in Manifest")
														FileCopy($manifest, $manifest & ".bak", 1)
														$head = StringSplit($read, $identry, 1)
														$tail = $head[2]
														$head = $head[1]
														;$tail = StringSplit($tail, @LF & "}", 1)
														;$tail = $tail[2]
														$pos = StringInStr($tail, @LF & "}")
														$tail = StringMid($tail, $pos + 2)
														$game = StringSplit($game, $identry, 1)
														$game = $game[2]
														$read = $head & $identry & $game & $tail
														_FileCreate($manifest)
														FileWrite($manifest, $read)
														_FileWriteLog($logfle, "REPLACE in manifest", -1)
													EndIf
													Sleep(1000)
												Else
													; Start the manifest
													If $ids = 1 Then
														FileCopy($json, $manifest)
													Else
														FileWrite($manifest, $game)
													EndIf
													_FileWriteLog($logfle, "ADD to manifest", -1)
												EndIf
												; Check for CDKey
												$cdkey = StringSplit($game, '"CdKey":', 1)
												If $cdkey[0] = 2 Then
													$cdkey = $cdkey[2]
													$cdkey = StringSplit($cdkey, '",', 1)
													$cdkey = $cdkey[1]
													$cdkey = StringReplace($cdkey, '"', '')
													$cdkey = StringStripWS($cdkey, 3)
													If $cdkey <> "" Then
														IniWrite($cdkeys, $IDD, "title", $titleD)
														IniWrite($cdkeys, $IDD, "keycode", $cdkey)
														_FileWriteLog($logfle, "CDKey found.", -1)
													EndIf
												EndIf
												; Check for DLC
												$DLC = StringSplit($game, '"DLC"', 1)
												If $DLC[0] > 1 Then
													$DLC = $DLC[0] - 1
													If $DLC > 0 Then
														IniWrite($dlcfile, $IDD, "title", $titleD)
														IniWrite($dlcfile, $IDD, "dlc", $DLC)
														_FileWriteLog($logfle, "DLC(s) found.", -1)
													EndIf
												EndIf
												FileWriteLine($logfle, "")
												If $list = "manifest" Then _ReplaceStringInFile($manlist, $line, "")
											Else
												; Game ID not found in return.
												$game = ""
												_FileWriteLog($logfle, "MANIFEST FAILED - " & $titleD, -1)
												FileWriteLine($logfle, "")
												MsgBox(262192, "Add Error", "Retrieval failed!" & @LF & @LF & $titleD, 0, $GOGcliGUI)
											EndIf
										EndIf
									EndIf
								EndIf
							Next
							If $list = "manifest" Then
								$res = _FileReadToArray($manlist, $array)
								If $res = 1 Then
									$array = _ArrayUnique($array, 0, 1)
									_FileWriteFromArray($manlist, $array, 1)
								EndIf
								$cnt = _FileCountLines($manlist)
								If $cnt < 1 Then
									; Clear Manifests List
									GUICtrlSetState($Item_database_add, $GUI_ENABLE)
									GUICtrlSetState($Item_down_all, $GUI_ENABLE)
									GUICtrlSetData($Button_man, "ADD TO" & @LF & "MANIFEST")
									GUICtrlSetTip($Button_man, "Add selected game to manifest!")
									_FileCreate($manlist)
									$manifests = ""
								EndIf
							EndIf
							GUICtrlSetData($Label_top, "")
							GUICtrlSetData($Label_bed, "")
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
EndFunc ;=> RetrieveDataFromGOG

Func SetStateOfControls($state, $which = "")
	GUICtrlSetState($Listview_games, $state)
	GUICtrlSetState($Button_find, $state)
	GUICtrlSetState($Button_sub, $state)
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
	GUICtrlSetState($Button_tag, $state)
	If $which = "all" Then
		GUICtrlSetState($Button_setup, $state)
		GUICtrlSetState($Button_log, $state)
		GUICtrlSetState($Button_dir, $state)
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



;===============================================================================
;
; Function Name:    _Zip_List()
; Description:      Returns an Array containing of all the files contained in a ZIP Archieve.
; Parameter(s):     $hZipFile - Complete path to zip file that will be created (or handle if existant)
; Requirement(s):   none.
; Return Value(s):  On Success - 0
;                   On Failure - sets @error 1~3
;					@error = 1 no Zip file
;					@error = 2 no dll
;					@error = 3 dll isn't registered
; Author(s):        torels_ (extracted from Zip.au3 and modified by TheSaint)
;
;===============================================================================
Func _Zip_List($zipfile)
	Local $aArray[1], $hList, $oApp, $sItem
	Local $DLLChk = _Zip_DllChk()
	If $DLLChk <> 0 Then Return SetError($DLLChk, 0, 0) ;no dll
	$oApp = ObjCreate("Shell.Application")
	$hList = $oApp.Namespace($zipfile).Items
	For $sItem in $hList
		_ArrayAdd($aArray, $sItem.name)
	Next
	$aArray[0] = UBound($aArray) - 1
	Return $aArray
EndFunc   ;==>_Zip_List

;===============================================================================
;
; Function Name:    _Zip_DllChk()
; Description:      Internal error handler.
; Parameter(s):     none.
; Requirement(s):   none.
; Return Value(s):  Failure - @extended = 1
; Author(s):        smashley (extracted from Zip.au3 by TheSaint)
;
;===============================================================================
Func _Zip_DllChk()
	If Not FileExists(@SystemDir & "\zipfldr.dll") Then Return 2
	If Not RegRead("HKEY_CLASSES_ROOT\CLSID\{E88DCCE0-B7B3-11d1-A9F0-00AA0060FA31}", "") Then Return 3
	Return 0
EndFunc   ;==>_Zip_DllChk
