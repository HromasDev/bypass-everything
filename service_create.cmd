@echo off
setlocal

set ARGS=--wf-tcp=443-65535 --wf-udp=443-65535 ^
--filter-udp=443 --hostlist="%~dp0list-everything.txt" --dpi-desync=fake --dpi-desync-udplen-increment=10 --dpi-desync-repeats=6 --dpi-desync-udplen-pattern=0xDEADBEEF --dpi-desync-fake-quic="%~dp0quic_initial_www_google_com.bin" --new ^
--filter-udp=50000-65535 --dpi-desync=fake,tamper --dpi-desync-any-protocol --dpi-desync-fake-quic="%~dp0quic_initial_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%~dp0list-everything.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%~dp0tls_clienthello_www_google_com.bin"

call :srvinst winws1
goto :eof

:srvinst
echo Stopping service %1 if it exists...
net stop %1 2>nul
sc delete %1 2>nul

echo Creating service %1...
sc create %1 binPath= "\"%~dp0winws.exe\" %ARGS%" DisplayName= "zapret: discord : %1"

if %errorlevel% neq 0 (
    echo Failed to create service %1
    goto :eof
)

echo Starting service %1...
sc start %1

if %errorlevel% neq 0 (
    echo Failed to start service %1
    goto :eof
)

sc description %1 "zapret DISCORD bypass software"
pause
