#!/bin/sh

function readkey() {
  local ans

  echo "Press Enter to continue..."
  read ans
  
  return
}

dir=$PWD
clear

echo "#             *********** nYume Server 1.0 installation ***********"
echo "#"

if [ "$UID" != "0" ]; then
  echo "# You need to login as root to install and run nYume server!"
  readkey
  exit
fi

echo "# Now, nYume server will be installed"
echo "# Installation dir: $dir"
echo "#"
readkey

echo "# You need to login as root. Please input your root password"

echo "default=$dir/localhost" > vhost.cfg
echo "localhost=$dir/localhost" >> vhost.cfg
chmod 0755 $dir/localhost
chmod 0755 $dir/localhost/cgiapp.exe
chmod 0755 nYume

echo "#"
echo "# nYume has been installed on your computer"
echo "# Now, it will be runned at ip 127.0.0.1 on port 81"
echo "#"
echo "# You can test nYume and read documentation by navigating"
echo "# your browser to http://localhost:81/"
echo "#"
readkey

clear
./nYume