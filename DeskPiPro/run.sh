#!/usr/bin/env bash

## for the web ui
fun() {  while true; do nc -l -p 8099 -e  echo -e 'HTTP/1.1 200 OK\r\nServer: DeskPiPro\r\nDate:$(date)\r\nContent-Type: text/html; charset=UTF8\r\nCache-Control: no-store, no cache, must-revalidate\r\n\r\n<!DOCTYPE html><html><body><p>DeskPi Pro Active Cooling!</body></html>\r\n\n\n'; done }; fun&

## make everything into a float
mkfloat(){
  str=$1
  if [[ $str != *"."* ]]; then
    str=$str".0"
  fi
  echo $str;
}

## Float comparison so that we don't need to call non-bash processes
fcomp() {
  local oldIFS="$IFS" op=$2 x y digitx digity
  IFS='.' x=( ${1##+([0]|[-]|[+])}) y=( ${3##+([0]|[-]|[+])}) IFS="$oldIFS"
  while [[ "${x[1]}${y[1]}" =~ [^0] ]]; do
      digitx=${x[1]:0:1} digity=${y[1]:0:1}
      (( x[0] = x[0] * 10 + ${digitx:-0} , y[0] = y[0] * 10 + ${digity:-0} ))
      x[1]=${x[1]:1} y[1]=${y[1]:1} 
  done
  [[ ${1:0:1} == '-' ]] && (( x[0] *= -1 ))
  [[ ${3:0:1} == '-' ]] && (( y[0] *= -1 ))
  (( ${x:-0} $op ${y:-0} ))
} 

# Read configured variables
CorF=$(cat /data/options.json |jq -r '.CorF')
t1=$(mkfloat $(cat /data/options.json |jq -r '.LowRange'))
t2=$(mkfloat $(cat /data/options.json |jq -r '.MediumRange'))
t3=$(mkfloat $(cat /data/options.json |jq -r '.HighRange'))
quiet=$(cat /data/options.json |jq -r '.QuietProfile')
serialDevice=$(cat /data/options.json |jq -r '.SerialDevice')

lastPosition=0
curPosition=-1
cpuTemp=0

ingress(){
  while true; do nc -l -p 8099 -e sh -c echo -e 'HTTP/1.1 200 OK\r\nServer: DeskPiPro\r\nDate:$(date)\r\nContent-Type: text/html; charset=UTF8\r\nCache-Control: no-store, no cache, must-revalidate\r\n\r\n<!DOCTYPE html><html><body><p>Fan Speed:'$lastPosition'\r\n Temp:$cpuTemp</body></html>\r\n\n\n 2>&1'  ; done
}

# Dynamic Check: Look for alternative serial pathways if configured one is missing
if [ ! -e "$serialDevice" ]; then
  echo "Configured device $serialDevice not found. Scanning for active serial interfaces..."
  if [ -e /dev/ttyUSB0 ]; then
    serialDevice="/dev/ttyUSB0"
  elif [ -e /dev/ttyAMA0 ]; then
    serialDevice="/dev/ttyAMA0"
  elif [ -e /dev/ttyS0 ]; then
    serialDevice="/dev/ttyS0"
  else
    echo "CRITICAL: No valid USB or hardware serial interfaces found inside the container."
    echo "Listing contents of /dev directory:"
    ls /dev/
    exit 1
  fi
fi

echo "Successfully connected to serial device: $serialDevice"
ingress &

until false; do
  read cpuRawTemp</sys/class/thermal/thermal_zone0/temp 
  cpuTemp=$(( $cpuRawTemp/1000 )) 
  unit="C"
  if [ $CorF == "F" ]; then 
    cpuTemp=$(( ( $cpuTemp * 9/5 ) + 32 ));
    unit="F"
  fi
  value=$(mkfloat $cpuTemp)
  echo "Current Temperature $cpuTemp °$unit"
  if ( fcomp $value '<=' $t1 ); then
    curPosition=1; 
  elif ( fcomp $t1 '<=' $value && fcomp $value '<=' $t2 ); then
    curPosition=2; 
  elif ( fcomp $t2 '<=' $value && fcomp $value '<=' $t3 ); then
    curPosition=3; 
  else
    curPosition=4;
  fi
  if [ $lastPosition != $curPosition ]; then
    case $curPosition in
    1)
      echo "Level 1 - Fan 0% (OFF)";
      echo -ne "pwm_000">$serialDevice
    ;;
    2)
      if [ $quiet != true ]; then
        echo "Level 2 - Fan 33% (Low)";
        echo -ne "pwm_033">$serialDevice
      else
        echo "Quiet Level 2 - Fan 20% (Low)";
        echo -ne "pwm_020">$serialDevice
      fi
      ;;
    3)
      if [ $quiet != true ]; then
        echo "Level 3 - Fan 66% (Medium)";
        echo -ne "pwm_066">$serialDevice
      else
        echo "Quiet Level 3 - Fan 50% (Medium)";
        echo -ne "pwm_050">$serialDevice
      fi
      ;;
    *)
      echo "Level4 - Fan 100% (High)";
      echo -ne "pwm_100">$serialDevice
      ;;
    esac
    lastPosition=$curPosition;
  fi
  sleep 30;
done