@echo off

if exist "%CD%\PalServer.exe" (
	set GAME_PATH=%CD%
	goto :Main
)

set /p GAME_PATH=��������Ϸ����˰�װĿ¼(ֱ�ӻس�Ĭ�ϵ�ǰĿ¼):
if "%GAME_PATH%"=="" (
	set GAME_PATH=%CD%
)
echo ��Ϸ����˰�װĿ¼:%GAME_PATH%
goto :Main

:Download_steamcmd
	::���steamcmd
	if exist "%GAME_PATH%\steamcmd\steamcmd.exe" (
		goto :eof
	)
	mkdir steamcmd
	cd steamcmd
	curl -o steamcmd.zip https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip
	powershell -Command "Expand-Archive -Path '%GAME_PATH%\steamcmd\steamcmd.zip' -DestinationPath '%GAME_PATH%\steamcmd'"
	del steamcmd.zip
goto :eof

:Update_gameserver
"%GAME_PATH%\steamcmd\steamcmd.exe" +force_install_dir "%GAME_PATH%" +login anonymous +app_update 2394010 +quit
goto :eof

:Main
	cd "%GAME_PATH%"
	call :Download_steamcmd
	cd "%GAME_PATH%"
	call :Update_gameserver
	if not exist "%GAME_PATH%\PalServer.exe" (
		echo ��װ�����ʧ�ܣ�����ϵ����
		pause
		goto :eof
	)
	
	::д�������ļ�
	if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini" (
		:Set_config
		echo inconfig
		if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\" (
			mkdir "%GAME_PATH%\Pal\Saved\Config\WindowsServer\"
		)
		echo �����������ļ���վ��https://pal-world-server-config.vercel.app/
		echo ��վ�����ԣ�https://github.com/knva/PalWorld_server_config
		start https://pal-world-server-config.vercel.app/
		echo ���ú÷��������þ͵����ҳ���Ϸ������������ļ�
		echo ���浽Ŀ¼��%GAME_PATH%\Pal\Saved\Config\WindowsServer\
		echo ������ɺ�س�
		explorer "%GAME_PATH%\Pal\Saved\Config\WindowsServer\"
		pause
		
		if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini" (
			echo δ����ȷ��ȡ�����ļ�,������
			goto :Set_config
		)
	)
	::��ȡ�����ļ�
	for /f "tokens=*" %%a in (%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini) do (
		set GAME_CONFIG_STR=%%a
	)
	::echo config:%GAME_CONFIG_STR%
	::��ȡ��Ϸ�˿�
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%GAME_CONFIG_STR%'; if($inputString -match 'PublicPort=[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set GAME_PORT=%re_result:~11%
	echo ��Ϸ�������˿�Ϊ��%GAME_PORT%
	::��ȡ��������������
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%GAME_CONFIG_STR%'; if($inputString -match 'ServerPlayerMaxNum=[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set GAME_MAX_PLAYERS=%re_result:~19%
	echo ��Ϸ�������������Ϊ��%GAME_MAX_PLAYERS%
	
	::��ȡ����ip
	for /f "delims=" %%i in ('curl -s "https://www.taobao.com/help/getip.php"') do set "responseData=%%i"
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%responseData%'; if($inputString -match '[0-9]+.[0-9]+.[0-9]+.[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set PUBLIC_IP=%re_result%
	
	echo �������ӵ�ַ��127.0.0.1:%GAME_PORT%
	echo �������ӵ�ַ��%PUBLIC_IP%:%GAME_PORT%
	
	PalServer.exe -port=%GAME_PORT% -players=%GAME_MAX_PLAYERS% -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
goto :eof

