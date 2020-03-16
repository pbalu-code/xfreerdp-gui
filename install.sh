#!/bin/bash
set -e
if [ ! -d /opt/xfreerdp ]; then
  mkdir /opt/xfreerdp || { echo 'Create folder failed' ; exit 1; }
fi
wget -q https://raw.githubusercontent.com/pbalu-code/xfreerdp-gui/master/xfreerdp-gui.sh -O /opt/xfreerdp/xfreerdp-gui.sh && \
chmod +x /opt/xfreerdp/xfreerdp-gui.sh && \
wget -q https://github.com/pbalu-code/xfreerdp-gui/raw/master/FreeRDP_Icon.png -O /opt/xfreerdp/FreeRDP_Icon.png
if [ $? -eq 0 ]; then
  echo "Basic scripts are installed / Updated."
else
  echo "Error in download section"
  exit 1
fi
wget -q https://raw.githubusercontent.com/pbalu-code/xfreerdp-gui/master/xFreeRDP.desktop -O /usr/share/applications/xFreeRDP.desktop && \
chmod +x /usr/share/applications/xFreeRDP.desktop
if [ $? -eq 0 ]; then
  echo "Icon installed / Updated - xFreeRDP"
else
  echo "Error when creating or updateing Icon"
  exit 1
fi
exit 0
