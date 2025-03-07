#/bin/bash
#File: update-semaphore.sh
#Optional: provide version number with script (i.e. 2.11.2)

#set -x

TEMP="/tmp"

[ -x "$(command -v semaphore)" ] && [ "/snap/bin/semaphore" != "$(command -v semaphore)" ] || { echo 'ERROR: CANNOT EXECUTE SEMAPHORE! EXITING...'; exit $?; }

INSTALLED=$(semaphore version | cut -f1 -d'-')
[ $?=0 ] || { echo 'ERROR: UNABLE TO DETERMINE INSTALLED VERSION OF SEMAPHORE! EXITING...' ; exit $?; }

LATEST=$(curl -Ls -f -o /dev/null -w %{url_effective} https://github.com/semaphoreui/semaphore/releases/latest | sed 's/.*tag\/v//; q99')
[ $?=0 ] || { echo 'ERROR: UNABLE TO DETERMINE LATEST VERSION OF SEMAPHORE ON GITHUB! EXITING...' ; exit $?; }

VERSION=${1:-$LATEST}

echo "INSTALLED VERSION:  "$INSTALLED
echo "LATEST VERSION:     "$LATEST
echo "REQUESTED VERSION:  "$VERSION

if [ $INSTALLED != $VERSION ]; then
   echo $'\nUPDATING SEMAPHORE...'
   echo $'[ Downloading Semaphore '$VERSION' from GitHub ]'
   wget -P "$TEMP" -nv https://github.com/semaphoreui/semaphore/releases/download/v"$VERSION"/semaphore_"$VERSION"_linux_amd64.deb || { echo 'ERROR: UNABLE TO DOWNLOAD SEMAPHORE!' ; exit $?; }
   echo '[ Installing Semaphore '$VERSION' Package ]'
   sudo dpkg -i "$TEMP"/semaphore_"$VERSION"_linux_amd64.deb || { echo 'ERROR: UNABLE TO INSTALL SEMAPHORE!' ; exit $?; }
   echo '[ Restarting Semaphore Service ]'
   sudo systemctl restart semaphore || { echo 'ERROR: UNABLE TO RESTART SEMAPHORE! Check service for details.' ; exit $?; }
   echo '[ Removing Semaphore '$VERSION' DEB File ]'
   rm "$TEMP"/semaphore_"$VERSION"_linux_amd64.deb || echo 'INFO: Unable to cleanup .deb files but continuing anyway...'
   echo $'\nDONE'
   exit 0
else
   echo $'\nNo Update Necessary. Version '$VERSION' is already installed.'
fi
