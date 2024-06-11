@echo off
setlocal enabledelayedexpansion

rem Fetch the content of the GitHub URL and save it to a temporary file
curl -s https://raw.githubusercontent.com/Tuizo/mods-cubas4/main/links.txt > links.txt

rem Initialize a list to track the files that should be present
set "fileList="

rem Get the current date in YYYY-MM-DD format
for /f "tokens=2 delims=:" %%i in ('echo.^|date') do set "prompt=%%i"
for /f "tokens=1-3 delims=.-/ " %%a in ('date /t') do (
    set "YYYY=%%c"
    set "MM=%%a"
    set "DD=%%b"
)
set "currentDate=%YYYY%-%MM%-%DD%"

rem Loop through each line in the temporary file
for /f "tokens=*" %%a in (links.txt) do (
    rem Extract the file name from the URL
    for %%f in (%%a) do (
        set "fileName=%%~nxf"
        
        rem Add the file name to the list
        set "fileList=!fileList! %%~nxf"
        
        rem Check if the file already exists
        if exist "%%~nxf" (
            echo File %%~nxf already exists, skipping download.
        ) else (
            echo Downloading %%~nxf
            curl -O %%a
            echo Downloaded ^| %%~nxf ^| %currentDate% >> #mod_log.txt
        )
    )
)

rem Clean up the temporary file
del links.txt

rem Loop through each file in the current directory
for %%f in (*.jar) do (
    rem Check if the file is in the list of files that should be present
    echo !fileList! | find " %%~nxf " >nul
    if errorlevel 1 (
        rem File not found in the list, delete it
        echo Deleting file %%~nxf as it is no longer in the GitHub list.
        del "%%~nxf"
        echo Removed ^| %%~nxf ^| %currentDate% >> #mod_log.txt
    )
)

echo.
echo Seus mods foram atualizados!
timeout 3
