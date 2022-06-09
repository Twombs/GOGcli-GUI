#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#include <Constants.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>
#include <Misc.au3>
#include <Inet.au3>
#include <File.au3>

Global $a, $array, $bytes, $checksum, $cliptxt, $cookie, $linksfile, $downurl, $entry, $file, $fileinfo, $gogcli, $lasturl, $line, $logerr, $mass, $params, $URL, $val

_Singleton("gog-file-info-timboli", 0)

$cookie = @ScriptDir & "\Cookie.txt"
$fileinfo = @ScriptDir & "\Fileinfo.txt"
$gogcli = @ScriptDir & "\gogcli.exe"
$linksfile = @ScriptDir & "\Downlinks.ini"

$lasturl = IniRead($linksfile, "Last Download", "url", "")

While 1
	$cliptxt = ClipGet()
	If StringInStr($cliptxt, $lasturl) < 1 Then
		If StringLeft($cliptxt, 4) <> "http" Then
			$URL = ""
		Else
			If StringInStr($cliptxt, "www.gog.com") < 1 Then
				$URL = ""
			Else
				$URL = $cliptxt
			EndIf
		EndIf
	Else
		$URL = ""
	EndIf
	$val = InputBox("Game URL Query", "A GOG game file download URL is required." & @LF & @LF & $lasturl, $URL, "", 500, 155, Default, Default)
	If @error = 0 Then
		; https://www.gog.com/downloads/dying_light_the_following_enhanced_edition/en1installer0
		; /downloads/bio_menace/en1installer0
		$downurl = StringReplace($val, "http://www.gog.com", "")
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
								MsgBox(262192, "Download Error", "Missing information for download file - " & $logerr & ".", 0)
							Else
								$lasturl = $downurl
								IniWrite($linksfile, "Last Download", "url", $lasturl)
								IniWrite($linksfile, $downurl, "file", $file)
								IniWrite($linksfile, $downurl, "size", $bytes)
								IniWrite($linksfile, $downurl, "checksum", $checksum)
								$entry = "File Name: " & $file & @LF & "Verified File Size: " & $bytes & " bytes" & @LF & "Checksum: " & $checksum
								MsgBox(262192 + 16, "Download Result", $entry, 0)
							EndIf
						Else
							MsgBox(262192, "Program Error", "Required Fileinfo.txt file not found!", 0)
						EndIf
					Else
						MsgBox(262192, "Web Error", "No connection detected!", 0)
					EndIf
				Else
					MsgBox(262192, "Program Error", "Required Cookie.txt file not found!", 0)
				EndIf
			Else
				MsgBox(262192, "Program Error", "Required program gogcli.exe not found!", 0)
			EndIf
		Else
			MsgBox(262192, "Program Error", "No GOG game file download URL provided!", 0)
		EndIf
	Else
		ExitLoop
	EndIf
WEnd

Exit
