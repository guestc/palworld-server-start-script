@echo off

if exist "%CD%\PalServer.exe" (
	set GAME_PATH=%CD%
	goto :Main
)

set /p GAME_PATH=请输入游戏服务端安装目录(直接回车默认当前目录):
if "%GAME_PATH%"=="" (
	set GAME_PATH=%CD%
)
echo 游戏服务端安装目录:%GAME_PATH%
goto :Main

:Download_steamcmd
	::检测steamcmd
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
		echo 安装或更新失败，请联系作者
		pause
		goto :eof
	)
	
	::写入配置文件
	if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini" (
		:Set_config
		echo inconfig
		if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\" (
			mkdir "%GAME_PATH%\Pal\Saved\Config\WindowsServer\"
		)
		echo 即将打开配置文件网站：https://pal-world-server-config.vercel.app/
		echo 网站由来自：https://github.com/knva/PalWorld_server_config
		start https://pal-world-server-config.vercel.app/
		echo 配置好服务器设置就点击网页最上方的下载配置文件
		echo 保存到目录：%GAME_PATH%\Pal\Saved\Config\WindowsServer\
		echo 保存完成后回车
		explorer "%GAME_PATH%\Pal\Saved\Config\WindowsServer\"
		pause
		
		if not exist "%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini" (
			echo 未能正确读取配置文件,请重试
			goto :Set_config
		)
	)
	::读取配置文件
	for /f "tokens=*" %%a in (%GAME_PATH%\Pal\Saved\Config\WindowsServer\PalWorldSettings.ini) do (
		set GAME_CONFIG_STR=%%a
	)
	::echo config:%GAME_CONFIG_STR%
	::读取游戏端口
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%GAME_CONFIG_STR%'; if($inputString -match 'PublicPort=[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set GAME_PORT=%re_result:~11%
	echo 游戏服务器端口为：%GAME_PORT%
	::读取服务器人数上限
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%GAME_CONFIG_STR%'; if($inputString -match 'ServerPlayerMaxNum=[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set GAME_MAX_PLAYERS=%re_result:~19%
	echo 游戏服务器最大人数为：%GAME_MAX_PLAYERS%
	
	::获取公网ip
	for /f "delims=" %%i in ('curl -s "https://www.taobao.com/help/getip.php"') do set "responseData=%%i"
	for /f "delims=" %%a in ('powershell -Command "$inputString = '%responseData%'; if($inputString -match '[0-9]+.[0-9]+.[0-9]+.[0-9]+') { $matches[0] }"') do set "re_result=%%a"
	set PUBLIC_IP=%re_result%
	
	echo 本地连接地址：127.0.0.1:%GAME_PORT%
	echo 外网连接地址：%PUBLIC_IP%:%GAME_PORT%
	
	PalServer.exe -port=%GAME_PORT% -players=%GAME_MAX_PLAYERS% -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
goto :eof
