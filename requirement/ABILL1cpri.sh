#!/bin/bash
ssh fsp-1-1c "fpga_rw ra 0xdf201004">val.log
val=`cat val.log`
echo $val

if [ $val = "0x00000010" ]; then
    echo "ABIL L1 CPRI status good"
else
    echo "failed, man ,check it."
	cat /tmp/startup_NODEOAM.log | grep "CPRI link"
fi



