@ECHO OFF

REM 切换到脚本所在的目录
pushd %~dp0

REM 命令文件用于 Sphinx 文档构建
REM Command file for Sphinx documentation

REM 如果 SPHINXBUILD 未设置，则使用默认的 sphinx-build
if "%SPHINXBUILD%" == "" (
	set SPHINXBUILD=sphinx-build
)

REM 设置源目录、构建目录和目标目录
set SOURCEDIR=source
set BUILDDIR=build

REM 新增用于GitHub Pages的页面文件存放的文件夹路径
set TARGETDIR=docs

REM 检查是否安装了 Sphinx
%SPHINXBUILD% >NUL 2>NUL
if errorlevel 9009 (
	echo.
	echo.The 'sphinx-build' command was not found. Make sure you have Sphinx
	echo.installed, then set the SPHINXBUILD environment variable to point
	echo.to the full path of the 'sphinx-build' executable. Alternatively you
	echo.may add the Sphinx directory to PATH.
	echo.
	echo.If you don't have Sphinx installed, grab it from
	echo.https://www.sphinx-doc.org/
	exit /b 1
)

REM 如果没有传递参数，显示帮助信息
if "%1" == "" goto help

REM 执行构建命令
%SPHINXBUILD% -M %1 %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%

REM 检查构建是否成功
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

REM --------------------------
REM 以下为新增功能（处理 CNAME 文件）
REM --------------------------

echo.
echo ===========================
echo Checking CNAME before deleting "%TARGETDIR%"...
echo ===========================
echo.

REM 如果 docs 目录存在，先检查 CNAME 文件的情况
if exist "%TARGETDIR%" (
    if exist "%TARGETDIR%\CNAME" (
        echo Found CNAME in %TARGETDIR% folder.
        if exist "%~dp0CNAME" (
            echo WARNING: Root directory already has a CNAME file. Skipping extraction from %TARGETDIR%.
        ) else (
            echo Extracting CNAME from %TARGETDIR% to root folder...
            copy /y "%TARGETDIR%\CNAME" "%~dp0" >NUL
            echo Extraction completed.
        )
    ) else (
        echo CNAME not found in %TARGETDIR% folder.
        if exist "%~dp0CNAME" (
            echo WARNING: Root directory already has a CNAME file. Skip creating a new one.
        ) else (
            echo Creating new CNAME file in root folder: docs.peng2333.com
            echo docs.peng2333.com > "%~dp0CNAME"
            echo CNAME file created in root folder.
        )
    )
) else (
    echo WARNING: "%TARGETDIR%" folder does not exist.
    echo Checking root-level CNAME file...
    if exist "%~dp0CNAME" (
        echo WARNING: Root directory already has a CNAME file. Skip creating a new one.
    ) else (
        echo Creating new CNAME file in root folder: docs.peng2333.com
        echo docs.peng2333.com > "%~dp0CNAME"
        echo CNAME file created in root folder.
    )
)

REM Step 2: 删除根目录下现有的 /docs 目录（如果存在）
if exist "%TARGETDIR%" (
    echo.
    echo Deleting existing %TARGETDIR% directory...
    rmdir /s /q "%TARGETDIR%"
)

REM Step 3: 拷贝 build/html 目录下的所有内容到根目录的 /docs 目录
echo.
echo Copying "%BUILDDIR%\html" to "%TARGETDIR%"...
xcopy "%BUILDDIR%\html\*" "%TARGETDIR%\" /E /I /H /Y >NUL

REM Step 4: 为 GitHub Pages 创建（或刷新）.nojekyll 文件
echo.
echo Creating .nojekyll file in %TARGETDIR%...
echo. > "%TARGETDIR%\.nojekyll"

REM 复制根目录的 CNAME 到新的 docs 目录
echo.
echo Copying root CNAME to %TARGETDIR% folder...
if exist "%~dp0CNAME" (
    copy /y "%~dp0CNAME" "%TARGETDIR%\CNAME" >NUL
    echo Root CNAME file copied to %TARGETDIR%.
) else (
    echo WARNING: No CNAME file found in root folder, skipping.
)

REM Step 5: 删除 build/html 目录以节省空间
echo.
echo Deleting "%BUILDDIR%\html" directory...
rmdir /s /q "%BUILDDIR%\html"

echo.
echo Deployment completed successfully.

REM 结束后删除根目录的CNAME文件
echo.
echo Removing root-level CNAME...
if exist "%~dp0CNAME" (
    del /f /q "%~dp0CNAME"
    echo Root-level CNAME has been deleted.
) else (
    echo No root-level CNAME found, skipping delete.
)

REM 以上为新增功能



goto end

:help
%SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%

:end

popd
