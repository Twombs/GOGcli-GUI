@echo off

goto SAVEHELP

:HELP
echo "BASIC HELP COMMANDS"
gogcli.exe -h
echo -----------------------
echo .
echo "API HELP COMMANDS"
gogcli.exe gog-api -h
echo -----------------------
echo .
echo "DOWNLOAD URL HELP COMMANDS"
gogcli.exe gog-api download-url-path -h
echo -----------------------
echo .
echo "GAME DETAILS HELP COMMANDS"
gogcli.exe gog-api game-details -h
echo -----------------------
echo .
echo "OWNED GAMES HELP COMMANDS"
gogcli.exe gog-api owned-games -h
echo -----------------------
echo .
echo "GAME FILENAME HELP COMMANDS"
gogcli.exe gog-api url-path-filename -h
echo -----------------------
echo .
echo "URL PATH INFO HELP COMMANDS"
gogcli.exe gog-api url-path-info -h
echo -----------------------
echo .
echo "USER INFO HELP COMMANDS"
gogcli.exe gog-api user-info -h
echo -----------------------
echo .
echo "STORAGE VALIDATION HELP COMMANDS"
gogcli.exe storage validate -h
echo -----------------------
echo .
echo "MANIFEST HELP COMMANDS"
gogcli.exe manifest -h
oto END

:USERINFO
gogcli.exe gog-api user-info -c Cookie.txt
goto END

:GAMELIST
echo "Obtaining Games List" - Please Wait!
gogcli.exe -c Cookie.txt gog-api owned-games -p 1 > Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 2 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 3 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 4 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 5 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 6 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 7 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 8 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 9 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 10 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 11 >> Games.txt
gogcli.exe -c Cookie.txt gog-api owned-games -p 12 >> Games.txt
goto END

:GAME
gogcli.exe -c Cookie.txt gog-api game-details -i 4 > Game_4.txt
goto END

:DOWNLOAD
gogcli.exe -c Cookie.txt gog-api download-url-path -p /downloads/freespace_expansion/8133
goto END

:FILENAME
gogcli.exe -c Cookie.txt gog-api url-path-filename -p /downloads/freespace_expansion/en1installer0
goto END

:URLINFO
gogcli.exe -c Cookie.txt gog-api url-path-info -p /downloads/freespace_expansion/en1installer0 > Fileinfo.txt
gogcli.exe -c Cookie.txt gog-api url-path-info -p /downloads/freespace_expansion/8133 >> Fileinfo.txt
goto END

:MANIFEST
gogcli.exe -c Cookie.txt manifest generate -l english -o windows linux -i Descent: Freespace Battle Pack
goto END

:SAVEHELP
echo "BASIC HELP COMMANDS" > Help.wri
gogcli.exe -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "API HELP COMMANDS" >> Help.wri
gogcli.exe gog-api -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "DOWNLOAD URL HELP COMMANDS" >> Help.wri
gogcli.exe gog-api download-url-path -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "GAME DETAILS HELP COMMANDS" >> Help.wri
gogcli.exe gog-api game-details -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "OWNED GAMES HELP COMMANDS" >> Help.wri
gogcli.exe gog-api owned-games -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "GAME FILENAME HELP COMMANDS" >> Help.wri
gogcli.exe gog-api url-path-filename -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "URL PATH INFO HELP COMMANDS" >> Help.wri
gogcli.exe gog-api url-path-info -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "USER INFO HELP COMMANDS" >> Help.wri
gogcli.exe gog-api user-info -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "STORAGE VALIDATION HELP COMMANDS" >> Help.wri
gogcli.exe storage validate -h >> Help.wri
echo ----------------------- >> Help.wri
echo . >> Help.wri
echo "MANIFEST HELP COMMANDS" >> Help.wri
gogcli.exe manifest -h >> Help.wri
echo . >> Help.wri
gogcli.exe manifest generate -h >> Help.wri
goto END

:END
pause
cls
exit
