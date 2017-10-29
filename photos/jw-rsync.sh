rsync -a --progress --rsh='ssh -p2222' 192.168.2.207:/storage/{sdcard0,sdcard1}/* /home/jwrobel/tmp/phones/jw-twilight \
  --exclude '.thumbnail*' \
  --exclude '.thumb*' \
  -f '+ Pictures/***' \
  -f '+ Textra/***' \
  -f '+ DCIM/***' \
  -f '+ Download/***' \
  -f '+ SmartVoiceRecorder/***' \
  -f '+ CamScanner/***' \
  -f '+ clockworkmod/***' \
  -f '- *'

