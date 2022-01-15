;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;;  AutoIt Version: 3.3.14.2                                                             ;;
;;                                                                                       ;;
;;  Template AutoIt script.                                                              ;;
;;                                                                                       ;;
;;  AUTHOR:  Timboli                                                                     ;;
;;                                                                                       ;;
;;  SCRIPT FUNCTION:  Program creates a database file from a GOG manifest and shows it.  ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#include <Constants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <Misc.au3>
#include <File.au3>

_Singleton("manifest-to-db-timboli", 1)

Global $ans, $cdkey, $checksum, $entries, $entry, $estimate, $file, $g, $game, $games, $get, $grab, $header, $l, $line
Global $lines, $main, $manifest, $manifestDB, $name, $read, $res, $size, $stage, $total, $type

$manifest = @ScriptDir & "\Manifest.txt"
$manifestDB = @ScriptDir & "\Manifest.log"

If FileExists($manifest) Then
	SplashTextOn("", "Please Wait!", 200, 120, Default, Default, 33)
	$read = FileRead($manifest)
	If $read <> "" Then
		If StringInStr($read, @LF) > 0 Then
			$total = 0
			$file = FileOpen($manifestDB, 2)
			$games = StringSplit($read, '  "Games": [' & @LF, 1)
			For $g = 2 To $games[0]
				$game = $games[$g]
				If $game <> "" Then
					$entry = ""
					$main = ""
					$stage = ""
					$ID = "na"
					$title = "na"
					$cdkey = "na"
					$type = "na"
					$name = "na"
					$estimate = "na"
					$size = "na"
					$checksum = "na"
					$get = 1
					$grab = 1
					$lines = StringSplit($game, @LF, 1)
					For $l = 1 To $lines[0]
						$line = $lines[$l]
						If StringInStr($line, '"Id":') > 0 Then
							$ID = $line
							$ID = StringSplit($ID, '"Id":', 1)
							$ID = $ID[2]
							$ID = StringSplit($ID, ',', 1)
							$ID = $ID[1]
							$ID = StringStripWS($ID, 3)
						ElseIf StringInStr($line, '"Title":') > 0 Then
							$title = $line
							$title = StringSplit($title, '"Title": "', 1)
							$title = $title[2]
							$title = StringSplit($title, '",', 1)
							$title = $title[1]
							$title = StringReplace($title, '\u0026', '&')
							$title = StringReplace($title, '\"', '"')
							$title = StringStripWS($title, 3)
							If $type = "na" Then
								; First instance of title (game title)
								$main = $title
							Else
								; Other instances of title (file titles)
								If $entry = "" And $main <> "" And $stage = "" Then
									; First file title, but not enough data yet.
									$entry = $main & @TAB & $ID & @TAB & $cdkey & @TAB & $type & @TAB & $title
									$stage = 1
									; Get EstimatedSize and VerifiedSize just once
									$get = 1
									$grab = 1
								ElseIf $stage = 1 Then
									; Enough data for previous file title so save it to file.
									$entry = $entry & @TAB & $name & @TAB & $estimate & @TAB & $size & @TAB & $checksum
									FileWriteLine($file, $entry)
									; NOTE - All but the final subsequent file title will get here.
									; If only one file title it will likewise never reach here.
									; Subsequent file titles, but not enough data yet.
									$entry = $main & @TAB & $ID & @TAB & $cdkey & @TAB & $type & @TAB & $title
									; Get EstimatedSize and VerifiedSize just once
									$get = 1
									$grab = 1
								EndIf
							EndIf
						ElseIf StringInStr($line, '"CdKey":') > 0 Then
							$cdkey = $line
							$cdkey = StringSplit($cdkey, '"CdKey": "', 1)
							$cdkey = $cdkey[2]
							$cdkey = StringSplit($cdkey, '",', 1)
							$cdkey = $cdkey[1]
							$cdkey = StringStripWS($cdkey, 3)
							If $cdkey = "" Then
								$cdkey = "na"
							Else
								$cdkey = "yes"
							EndIf
						ElseIf StringInStr($line, '"Installers":') > 0 Then
							$type = "GAME"
						ElseIf StringInStr($line, '"Extras":') > 0 Then
							$type = "EXTRA"
						ElseIf StringInStr($line, '"Name":') > 0 Then
							$name = $line
							$name = StringSplit($name, '"Name": "', 1)
							$name = $name[2]
							$name = StringSplit($name, '",', 1)
							$name = $name[1]
							$name = StringStripWS($name, 3)
							If $name = "" Then $name = "na"
						ElseIf StringInStr($line, '"EstimatedSize":') > 0 Then
							; Only grab once per title.
							If $get = 1 Then
								$estimate = $line
								$estimate = StringSplit($estimate, '"EstimatedSize": "', 1)
								$estimate = $estimate[2]
								$estimate = StringSplit($estimate, '",', 1)
								$estimate = $estimate[1]
								$estimate = StringStripWS($estimate, 3)
								If $estimate = "" Then $estimate = "na"
								$get = ""
							EndIf
						ElseIf StringInStr($line, '"VerifiedSize":') > 0 Then
							; Only grab once per title.
							If $grab = 1 Then
								$size = $line
								$size = StringSplit($size, '"VerifiedSize":', 1)
								$size = $size[2]
								$size = StringSplit($size, ',', 1)
								$size = $size[1]
								$size = StringStripWS($size, 3)
								If $size = "" Then $size = "na"
								If StringIsDigit($size) = 1 Then
									$total = $total + $size
								Else
									$size = "na"
								EndIf
								$grab = ""
							EndIf
						ElseIf StringInStr($line, '"Checksum":') > 0 Then
							$checksum = $line
							$checksum = StringSplit($checksum, '"Checksum": "', 1)
							$checksum = $checksum[2]
							$checksum = StringSplit($checksum, '"', 1)
							$checksum = $checksum[1]
							$checksum = StringStripWS($checksum, 3)
							If $checksum = "" Then $checksum = "na"
;~ 						ElseIf StringInStr($line, '"Language":') > 0 Then
;~ 							$line = StringSplit($line, '"Language": "', 1)
;~ 							$line = $line[2]
;~ 							$line = StringSplit($line, '",', 1)
;~ 							$language = $line[1]
						ElseIf $line = '  ],' Then
							; Ignore and skip remainder of game entry.
							ExitLoop
						EndIf
					Next
					If $entry <> "" Then
						; Should be enough data for final file title so save it to file.
						$entry = $entry & @TAB & $name & @TAB & $estimate & @TAB & $size & @TAB & $checksum
						FileWriteLine($file, $entry)
					EndIf
				EndIf
			Next
			FileClose($file)
			$games = $games[0]
			If $total < 1024 Then
				$total = $total & " bytes"
			ElseIf $total < 1048576 Then
				$total = $total / 1024
				$total =  Round($total) & " Kb"
			ElseIf $total < 1073741824 Then
				$total = $total / 1048576
				$total =  Round($total, 1) & " Mb"
			ElseIf $total < 1099511627776 Then
				$total = $total / 1073741824
				$total = Round($total, 2) & " Gb"
			Else
				$total = $total / 1099511627776
				$total = Round($total, 3) & " Tb"
			EndIf
			MsgBox(262192, "Result", "Games = " & $games & @LF & "Size = " & $total, 0)
			If FileExists($manifestDB) Then
				;ShellExecute($manifestDB)
				SplashTextOn("", "Please Wait!", 200, 120, Default, Default, 35)
				_FileReadToArray($manifestDB, $entries, 1, @TAB)
				If @error = 0 Then
					$ans = MsgBox(262144 + 35 + 256, "Sort Query", "Sort entries by game title?" & @LF _
						& @LF & "YES = Game Title." _
						& @LF & "NO = More Choices." _
						& @LF & "CANCEL = No sorting.", 0)
					If $ans = 6 Then
						SplashTextOn("", "Sorting Titles!", 180, 120, -1, -1, 33)
						_ArraySort($entries, 0, 1, 0, 0)
						SplashOff()
					EndIf
					; Display results.
					$header = "Game Title|Game ID|CD Key|Type|File Title|File|Estimate|Bytes|Checksum"
					$res = _ArrayDisplay($entries, "Manifest", "", 16, Default, $header, Default, $COLOR_SILVER)
				EndIf
			EndIf
		EndIf
	EndIf
	SplashOff()
EndIf

Exit
