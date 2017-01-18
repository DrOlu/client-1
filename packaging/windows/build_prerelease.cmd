setlocal
:: Build keybase.exe with prerelease options

if NOT DEFINED DOKAN_PATH set DOKAN_PATH=%GOPATH%\bin\dokan-dev\dokan-v1.0.0-RC4.2
echo DOKAN_PATH %DOKAN_PATH%

echo GOPATH %GOPATH%
:: CGO causes dll loading security vulnerabilities
set CGO_ENABLED=0
echo GOROOT %GOROOT%
set GOARCH=386
pushd %GOPATH%\src\github.com\keybase\client\go\keybase
go version
go generate

if DEFINED BUILD_NUMBER set KEYBASE_WINBUILD=%BUILD_NUMBER%

if NOT DEFINED GOOS set GOOS=windows


for /f %%i in ('winresource.exe -cv') do set KEYBASE_VERSION=%%i
echo KEYBASE_VERSION %KEYBASE_VERSION%
for /f %%i in ('winresource.exe -cb') do set KEYBASE_BUILD=%%i
echo KEYBASE_BUILD %KEYBASE_BUILD%
popd

:: Updater
pushd %GOPATH%\src\github.com\keybase\go-updater\service
go build -a -o upd.exe
popd

:: Runquiet
pushd %GOPATH%\src\github.com\keybase\client\go\tools\runquiet
..\..\keybase\winresource.exe  -d "Keybase quiet start utility" -n "runquiet.exe" -i ../../../media/icons/Keybase.ico
go build -ldflags "-H windowsgui"
popd

:: dokanclean
pushd %GOPATH%\src\github.com\keybase\client\go\tools\dokanclean
go build -a
popd

:: release
pushd %GOPATH%\src\github.com\keybase\release
go build -a
popd

:: build 32 bit first
call :buildservices
set GOARCH=amd64
call :buildservices

goto :EOF

::---------------------------------------------------------------
:: subroutine buildservices: build keybase.exe and kbfsdokan.exe
:buildservices
pushd %GOPATH%\src\github.com\keybase\client\go\keybase

setlocal
echo GOARCH %GOARCH%
if _%GOARCH%_ == _386_ (
    del keybase.exe
) else (
   IF EXIST %GOARCH% RMDIR /S /Q %GOARCH%
   set OUTPUTARG=-o %GOARCH%\keybase.exe
)

:: Redo the resource to get the right architecture in
winresource.exe -kbfsicon ../../media/icons/windows/keybase-root-icon.ico
go build -a %OUTPUTARG% -tags "prerelease production" -ldflags="-X github.com/keybase/client/go/libkb.PrereleaseBuild=%KEYBASE_BUILD%"


:: Then build kbfsdokan.
:: First, sanity-check the hashes
copy %DOKAN_PATH%\Win32\Release\dokan1.lib %GOPATH%\src\github.com\keybase\kbfs\dokan

::for /f "usebackq tokens=2*" %%i in (`powershell Get-FileHash -Algorithm sha1 %GOPATH%\src\github.com\keybase\kbfs\dokan\dokan.lib`) do set DOKANLIBHASH=%%i
::if NOT %DOKANLIBHASH%==1C9316A567B805C4A6ADAF0ABE1424FFFB36A3BD exit /B 1
::for /f "usebackq tokens=2*" %%i in (`powershell Get-FileHash -Algorithm sha1 %GOPATH%\bin\dokan-dev\dokan-v0.8.0\Win32\Release\dokan.dll`) do set DOKANDLLHASH=%%i
::if NOT %DOKANDLLHASH%==5C4FC6B6E3083E575EED06DE3115A6D05B30DB02 exit /B 1

pushd %GOPATH%\src\github.com\keybase\kbfs\kbfsdokan

if _%GOARCH%_ == _386_ (
    del kbfsdokan.exe
   set MINGWDIR=%MINGWPATH32%
) else (
   set MINGWDIR=%MINGWPATH64%
   IF EXIST %GOARCH% RMDIR /S /Q %GOARCH%
   set OUTPUTARGKBFS=-o %GOARCH%\kbfsdokan.exe
)
set PATH=%PATH%;%MINGWDIR%

:: winresource invokes git to get the current revision
for /f %%i in ('git -C %GOPATH%\src\github.com\keybase\kbfs rev-parse --short HEAD') do set KBFS_HASH=%%i
for /f "tokens=1 delims=+" %%i in ("%KEYBASE_BUILD%") do set KBFS_BUILD=%%i+%KBFS_HASH%
echo KBFS_BUILD %KBFS_BUILD%
set CGO_ENABLED=1
go build -a %OUTPUTARGKBFS% -tags "prerelease production" -ldflags="-X github.com/keybase/kbfs/libkbfs.PrereleaseBuild=%KBFS_BUILD%"

popd

    exit /b
