@echo off
cls

echo #             *********** nYume Server 1.0 installation ***********
echo #
echo # Now, nYume server will be installed
echo # Installation dir: %CD%
echo #
pause

echo default=%CD%\localhost>vhost.cfg
echo localhost=%CD%\localhost>>vhost.cfg

echo #
echo # nYume has been installed on your computer
echo # Now, it will be runned at ip 127.0.0.1 on port 80
echo #
echo # You can test nYume and read documentation by navigating
echo # your browser to http://localhost/
echo #
pause

cls
nYume
