@echo off
setlocal enabledelayedexpansion

rem --- Configuration ---
set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
rem Nota: La URL de Tor Expert Bundle puede necesitar ser actualizada a la última versión desde https://www.torproject.org/download/tor/
set "SEVENZIP_URL=https://www.7-zip.org/a/7z2405-x64.exe"
set "FFMPEG_URL=https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
set "INSTALL_DIR=%~dp0"

goto setup
rem ============================================================================
rem  SETUP AND INSTALLATION
rem ============================================================================

:setup
rem --- Check for administrator rights ---
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

rem --- Download and install yt-dlp ---
if exist "%INSTALL_DIR%yt-dlp.exe" (
    echo yt-dlp.exe already exists. Skipping download.
) else (
    echo Downloading yt-dlp...
    powershell -Command "Invoke-WebRequest -Uri '%YTDLP_URL%' -OutFile '%INSTALL_DIR%yt-dlp.exe'"
)

rem --- Download and install Tor Browser ---
if exist "%INSTALL_DIR%tor.exe" (
    echo tor.exe already exists. Skipping download.
) else (
    echo Finding latest Tor Expert Bundle version...
    rem Using the user-provided .tar.gz link.
    set "TOR_URL=https://archive.torproject.org/tor-package-archive/torbrowser/14.5.8/tor-expert-bundle-windows-x86_64-14.5.8.tar.gz"
    
    rem --- Download and extract 7-Zip if not present ---
    if not exist "%INSTALL_DIR%7z.exe" (
        echo Downloading 7-Zip...
        powershell -Command "Invoke-WebRequest -Uri '%SEVENZIP_URL%' -OutFile '%INSTALL_DIR%7z_installer.exe'"
        echo Extracting 7-Zip...
        rem The /S switch is for silent install, /D specifies the output directory. We are extracting the tools.
        start /wait "" "%INSTALL_DIR%7z_installer.exe" /S /D="%INSTALL_DIR%"
        del "%INSTALL_DIR%7z_installer.exe"
    )

    echo Downloading Tor Expert Bundle from !TOR_URL!
    powershell -Command "Invoke-WebRequest -Uri '!TOR_URL!' -OutFile '%INSTALL_DIR%tor.tar.gz'"
    
    echo Extracting Tor...
    "%INSTALL_DIR%7z.exe" x "%INSTALL_DIR%tor.tar.gz" -o"%INSTALL_DIR%" -y >nul && "%INSTALL_DIR%7z.exe" x "%INSTALL_DIR%tor.tar" -o"%INSTALL_DIR%" -y >nul
    echo Moving Tor files...
    move /Y "%INSTALL_DIR%Tor\*" "%INSTALL_DIR%"
    del "%INSTALL_DIR%tor.tar.gz"
    del "%INSTALL_DIR%tor.tar"
    rmdir /S /Q "%INSTALL_DIR%Tor"
)

rem --- Download and install ffmpeg ---
if exist "%INSTALL_DIR%ffmpeg.exe" (
    echo ffmpeg.exe already exists. Skipping download.
) else (
    echo Downloading ffmpeg...
    powershell -Command "Invoke-WebRequest -Uri '%FFMPEG_URL%' -OutFile '%INSTALL_DIR%ffmpeg.zip'"
    echo Extracting ffmpeg...
    powershell -Command "Expand-Archive -Path '%INSTALL_DIR%ffmpeg.zip' -DestinationPath '%INSTALL_DIR%' -Force"
    echo Moving ffmpeg files...
    move /Y "%INSTALL_DIR%ffmpeg-master-latest-win64-gpl\bin\*" "%INSTALL_DIR%"
    
    echo Cleaning up ffmpeg installation files...
    del "%INSTALL_DIR%ffmpeg.zip"
    rmdir /S /Q "%INSTALL_DIR%ffmpeg-master-latest-win64-gpl"
)

echo.
echo Configuracion inicial completada.
goto main_menu

rem ============================================================================
rem  MAIN MENU
rem ============================================================================

:main_menu
cls
echo =================================================
echo  MENU DE DESCARGA DE VIDEOS
echo =================================================
echo.
echo Selecciona una opcion:
echo.
echo   1. Descargar Contenido (Modo Normal)
echo   2. Descargar Contenido (Modo Anonimo con Tor)
echo   3. Actualizar yt-dlp a la ultima version
echo   4. Salir
echo.

choice /C 1234 /M "Elige una opcion: "
if %errorlevel%==4 goto :eof
if %errorlevel%==3 goto update_ytdlp
if %errorlevel%==2 goto download_tor
if %errorlevel%==1 goto download_normal

rem This part should not be reached, but as a fallback, go to menu
goto main_menu

rem ============================================================================
rem  DOWNLOAD FUNCTIONS
rem ============================================================================

:download_normal
cls
echo --- MODO DE DESCARGA NORMAL ---
set "PROXY_PARAM="
goto handle_download_logic

:download_tor
cls
echo --- MODO DE DESCARGA ANONIMO (TOR) ---
echo.
echo Iniciando Tor en segundo plano...
start "Tor" /B "%INSTALL_DIR%tor.exe"
echo Esperando a que Tor se conecte a la red (aprox. 15 segundos)...
timeout /t 15 >nul
set "PROXY_PARAM=--proxy socks5://127.0.0.1:9050/"
goto handle_download_logic

:handle_download_logic
echo.
set /p "VIDEO_URL=Introduce la URL del video y presiona Enter: "
if not defined VIDEO_URL (
    echo URL no valida. Volviendo al menu...
    if not "%PROXY_PARAM%"=="" taskkill /IM tor.exe /F >nul 2>&1
    timeout /t 2 >nul
    goto main_menu
)

rem --- Playlist options ---
set "PLAYLIST_OPTIONS="
set "OUTPUT_OPTIONS="
rem Using a safe method to check for substrings, avoiding issues with special characters like '&'
set "TEMP_URL=!VIDEO_URL!"
set "TEMP_URL_NO_LIST=!TEMP_URL:list=!"
set "TEMP_URL_NO_INDEX=!TEMP_URL:index=!"

if not "!TEMP_URL!" == "!TEMP_URL_NO_LIST!" ( goto :is_a_playlist )
if not "!TEMP_URL!" == "!TEMP_URL_NO_INDEX!" ( goto :is_a_playlist )
goto :not_a_playlist

:is_a_playlist
    cls
    echo Se ha detectado una lista de reproduccion.
    echo.
    echo   1. Descargar solo el video actual.
    echo   2. Descargar la lista de reproduccion completa (en una nueva carpeta).
    echo.
    choice /C 12 /M "Elige una opcion: "
    if %errorlevel%==2 (
        set "PLAYLIST_OPTIONS=--yes-playlist"
        set OUTPUT_OPTIONS=-o "%%(playlist_title)s/%%(playlist_index)s - %%(title)s.%%(ext)s"
    ) else (
        set "PLAYLIST_OPTIONS=--no-playlist"
    )

:not_a_playlist
if not defined OUTPUT_OPTIONS set OUTPUT_OPTIONS=-o "%%(title)s.%%(ext)s"
rem --- Format options ---
cls
echo Elige el formato de descarga:
echo.
echo   1. Descargar Video (mejor calidad disponible)
echo   2. Descargar solo Audio (convertir a MP3)
echo.
choice /C 12 /M "Elige una opcion: "
if %errorlevel%==2 (
    set "FORMAT_OPTIONS=-x --audio-format mp3"
) else (
    set "FORMAT_OPTIONS=--recode-video mp4"
)

echo.
echo Iniciando descarga...

rem --- Execute download with all selected options ---
"%INSTALL_DIR%yt-dlp.exe" -P "%INSTALL_DIR%Mis_Descargas" %PROXY_PARAM% %PLAYLIST_OPTIONS% %FORMAT_OPTIONS% %OUTPUT_OPTIONS% "%VIDEO_URL%"

if not "%PROXY_PARAM%"=="" (
    echo.
    echo Deteniendo Tor...
    taskkill /IM tor.exe /F >nul 2>&1
)
goto end_task

:update_ytdlp
cls
echo --- ACTUALIZANDO YT-DLP ---
echo.
"%INSTALL_DIR%yt-dlp.exe" -U
goto end_task

:end_task
echo.
echo Tarea finalizada.
echo.
pause
goto main_menu
