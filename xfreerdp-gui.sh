  #!/bin/bash
  #### Dependencies: freerdp-x11 gawk x11-utils yad zenity

  string=""
  if ! hash xfreerdp 2>/dev/null; then
      string="\nfreerdp-x11"
  fi
  if ! hash awk 2>/dev/null; then
      string="\ngawk" 
  fi
  if ! hash xdpyinfo 2>/dev/null; then
      string="${string}\nx11-utils"
  fi
  if ! hash yad 2>/dev/null; then
      string="${string}\nyad"
  fi
  if [ -n "$string" ]; then
    if hash amixer 2>/dev/null; then
      amixer set Master 80% > /dev/null 2>&1; 
    else
      pactl set-sink-volume 0 80%
    fi
    if hash speaker-test 2>/dev/null; then
      ((speaker-test -t sine -f 880 > /dev/null 2>&1)& pid=$!; sleep 0.2s; kill -9 $pid) > /dev/null 2>&1 
    else 
      if hash play 2>/dev/null; then
        play -n synth 0.1 sin 880 > /dev/null 2>&1 
      else
        cat /dev/urandom | tr -dc '0-9' | fold -w 32 | sed 60q | aplay -r 9000 > /dev/null 2>&1
      fi
    fi
    (zenity --info --title="Requirements" --width=300 --text="You need to install this(ese) package(s):

    <b>$string</b>

    ") > /dev/null 2>&1 
    exit
  fi

#####################################################################################
  #### Get informations
  dim=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')
  wxh1=$(echo $dim | sed -r 's/x.*//')"x"$(echo $dim | sed -r 's/.*x//')
  wxh2=$(($(echo $dim | sed -r 's/x.*//')-70))"x"$(($(echo $dim | sed -r 's/.*x//')-70))

  while true
  do
    LOGIN=
    PASSWORD=
    DOMAIN=
    SERVER=
    PORT=
    RESOLUTION=
    GEOMETRY=
    BPP=  
    OPTIONS=  
      varFull=
      varMULTIMON=
      varCERTOK=
      varMODEM=
      varFONTS=
    varLog=
    [ -n "$USER" ] && until xdotool search "xfreerdp-gui" windowactivate key Right Tab 2>/dev/null ; do sleep 0.03; done &
      FORMULARY=$(yad --center --width=500 \
          --window-icon="gtk-execute" --image="FreeRDP_Icon.png" --item-separator=","                                              \
          --title "xfreerdp-gui"                                                                                              \
          --form                                                                                                              \
          --field="Server*" $SERVER "IP-Address"                                                               \
          --field="Port*"  $PORT "3389"                                                                                        \
          --field="Domain*" $DOMAIN "Your.AD.domain"                                                                            \
          --field="Username*" $LOGIN "Login Name"                                                                  \
          --field="Password*":H $PASSWORD ""                                                                                  \
          --field="Resolution":CBE $RESOLUTION "$wxh1,$wxh2,640x480,720x480,800x600,1024x768,1280x1024,1600x1200,1920x1080,"  \
          --field="BPP":CBE $BPP "24,16,32,"                                                                                  \
          --field="Other Options" $OPTIONS ""                                                                                 \
          --field="Multimon":CHK $varMULTIMON 																					  \
          --field="Ignore Cert":CHK $varCERTOK 																					  \
          --field="Full Screen":CHK $varFull                                                                                  \
          --field="network:modem":CHK $varMODEM                                           \
          --field="Fonts":CHK $varFONTS                  \
          --field="Show Log":CHK $varLog                                                                                      \
          --button="Cancel":1 --button="Connect":0)
      [ $? != 0 ] && exit
      SERVER=$(echo $FORMULARY     | awk -F '|' '{ print $1 }')
      PORT=$(echo $FORMULARY       | awk -F '|' '{ print $2 }')
      DOMAIN=$(echo $FORMULARY     | awk -F '|' '{ print $3 }')
      LOGIN=$(echo $FORMULARY      | awk -F '|' '{ print $4 }')
      PASSWORD=$(echo $FORMULARY   | awk -F '|' '{ print $5 }')
      RESOLUTION=$(echo $FORMULARY | awk -F '|' '{ print $6 }')
      BPP=$(echo $FORMULARY        | awk -F '|' '{ print $7 }')
      OPTIONS=$(echo $FORMULARY    | awk -F '|' '{ print $8 }')
      varMULTIMON=$(echo $FORMULARY        | awk -F '|' '{ print $9 }')
      varCERTOK=$(echo $FORMULARY        | awk -F '|' '{ print $10 }')
      varFull=$(echo $FORMULARY    | awk -F '|' '{ print $11 }')
      if [ "$varFull" = "TRUE" ]; then
          GEOMETRY="/f"
      else
          GEOMETRY=""
      fi
      if [ "$varMULTIMON" = "TRUE" ]; then
          MULTIMON="/multimon"
      else
          MULTIMON=""
      fi  
      if [ "$varCERTOK" = "TRUE" ]; then
          CERTOK="/cert-ignore"
      else
          CERTOK=""
      fi  
      varMODEM=$(echo $FORMULARY | awk -F '|' '{ print $12 }')
      if [ "$varMODEM" = "TRUE" ]; then
          MODEM="/network:modem"
      else
          MODEM=""
      fi
      varFONTS=$(echo $FORMULARY | awk -F '|' '{ print $13 }')
      if [ "$varFONTS" = "TRUE" ]; then
          FONTS="/fonts"
      else
          FONTS=""
      fi
      varLog=$(echo $FORMULARY | awk -F '|' '{ print $14 }')

      RES=$(xfreerdp \
      			$MULTIMON  \
					  $GEOMETRY  \
					  /v:"$SERVER":$PORT \
                      /u:"$LOGIN" \
                      /p:"$PASSWORD" \
                      /sound  \
                      /from-stdin \
                      /decorations /window-drag \
                      /compression 	\
                      $MODEM \
                      $FONTS \
                      $CERTOK \
                      $OPTIONS \
                       -menu-anims 2>&1)

       TEST="xfreerdp $MULTIMON $GEOMETRY /v:$SERVER:$PORT /u:$LOGIN /p:$PASSWORD /sound  /from-stdin  /decorations /window-drag \
                      /compression 	\
                      $MODEM \
                      $FONTS \
                      $CERTOK \
                      $OPTIONS -menu-anims"

      if [ "$1" == "-test" ]; then
          echo "Command will be: "
           echo $TEST
      else
              echo $RES | grep -q "Authentication failure" &&                                                  \
              yad --center --image="error" --window-icon="error" --title "Authentication failure"              \
              --text="<b>Could not authenticate to server\!</b>\n\n<i>Please check your password.</i>"         \
                --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread && continue
              echo $RES | grep -q "connection failure" &&                                                      \
              yad --center --image="error" --window-icon="error" --title "Connection failure"                  \
              --text="<b>Could not connect to the server\!</b>\n\n<i>Please check the network connection.</i>" \
              --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread && continue

              if [ "$varLog" = "TRUE" ]; then
                  yad --text "$RES" --title "Log of Events" --width=600 --wrap --no-buttons
              fi
      fi
      break
  done

  #####################################################################################