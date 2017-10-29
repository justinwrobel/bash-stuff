rsync -a --progress --rsh='ssh -p2222' 192.168.2.188:/storage/{sdcard0,extSdCard}/* /home/jwrobel/tmp/phones/shannon \
  --exclude '.thumbnail*' \
  --exclude '.thumb*' \
  -f '+ Pictures/***' \
  -f '+ DCIM/***' \
  -f '+ Download/***' \
  -f '+ SmartVoiceRecorder/***' \
  -f '+ CamScanner/***' \
  -f '- .thumbnail*' \
  -f '- *'

