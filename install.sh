#!/bin/bash
set -e
if [ ! -d /opt/xfreerdp ]; then
mkdir /opt/xfreerdp && \
wget -q https://raw.githubusercontent.com/pbalu-code/xfreerdp-gui/master/xfreerdp-gui.sh -O /opt/xfreerdp/xfreerdp-gui.sh && \
chmod +x /opt/xfreerdp/xfreerdp-gui.sh && \
wget -q https://github.com/pbalu-code/xfreerdp-gui/raw/master/FreeRDP_Icon.png -O /opt/xfreerdp/FreeRDP_Icon.png
echo "Basic scripts are installed."
else
  echo "The folder /opt/xfreerdp is already exist."
  exit 1
fi

if [ ! -f /usr/share/applications/xFreeRDP.desktop ]
then
  wget -q https://raw.githubusercontent.com/pbalu-code/xfreerdp-gui/master/xFreeRDP.desktop -O /usr/share/applications/xFreeRDP.desktop && \
  chmod +x /usr/share/applications/xFreeRDP.desktop
  echo "Icon installed - xFreeRDP"
else
  echo "Icon script already exist"
  exit 1
fi
exit 0
