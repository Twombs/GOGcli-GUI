@echo off

goto GAMELIST

:HELP
gogcli.exe -h
gogcli.exe gog-api -h
goto END

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

:TESTING
gogcli.exe gog-api download-url-path -h
echo -----------------------
gogcli.exe gog-api game-details -h
echo -----------------------
gogcli.exe gog-api owned-games -h
echo -----------------------
gogcli.exe gog-api url-path-filename -h
echo -----------------------
gogcli.exe gog-api url-path-info -h
echo -----------------------
gogcli.exe gog-api user-info -h
echo -----------------------
gogcli.exe storage validate -h
goto END

:END
pause
cls
exit
