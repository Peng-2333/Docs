小毛病
======

通过添加 .nojekyll 文件解决 GitHub Pages 的问题
------------------------------------------------

在使用 GitHub Pages 部署 Sphinx 文档时，默认启用了 Jekyll, 这会导致以 ``_`` 开头的目录（如 ``_static``）被忽略，导致资源文件无法加载。
需要在部署目录中添加一个空的 ``.nojekyll`` 文件，禁用 Jekyll。

步骤：
,,,,,,,,

1. **创建 `.nojekyll` 文件**：
   在 `docs` 目录下创建一个名为 `.nojekyll` 的空文件。

.. code-block:: bash

    echo. > docs\.nojekyll


实际现在使用的make.bat文件（添加了些许注释）

.. code-block:: batch

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




    REM 以下为新增功能

    REM Step 1: 在 build/html 目录中创建 .nojekyll 文件
    echo Creating .nojekyll file...
    echo. > "%BUILDDIR%\html\.nojekyll"

    REM Step 2: 删除根目录下现有的 /docs 目录（如果存在）
    if exist "%TARGETDIR%" (
        echo Deleting existing docs directory...
        rmdir /s /q "%TARGETDIR%"
    )

    REM Step 3: 拷贝 build/html 目录下的所有内容到根目录的 /docs 目录
    echo Copying build/html to docs...
    xcopy "%BUILDDIR%\html\*" "%TARGETDIR%\" /E /I /H /Y >NUL

    REM Step 4: 删除 build/html 目录以节省空间
    echo Deleting build/html directory...
    rmdir /s /q "%BUILDDIR%\html"

    echo Deployment completed successfully.

    REM 以上为新增功能



    goto end

    :help
    %SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%

    :end

    popd
