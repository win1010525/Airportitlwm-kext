# Notice  
Sorry, because of academic problems, I may not update it in a month. Please use zxystd driver first, airdrop development is about to be completed.  

# Airportitlwm-kext
An IO80211 added version of Airportitlwm.  
This is same as zxystd's Airportitlwm  
But it is put in IO80211Family.kext to make sure Clover and OC 0.6.0 and lower can use it.  
All bugs should open issues on zxystd's master branch.  
Open issues here: https://github.com/OpenIntelWireless/itlwm/issues/new/choose
   
# Installation
1.Clover:  
Put it into Clover\kexts\Other\   
![image](https://github.com/win1010525/Airportitlwm-kext/blob/main/images/Clover.png)   
OpenCore:
Just use zxystd's kext and follow the Doc.   
2.This kext can't load if your OpenCore's SecureBootModel is Disabled. You should set it to Default.  
![image](https://github.com/win1010525/Airportitlwm-kext/blob/main/images/SecureBootModel.png)   
You doesn't need that on Big Sur.  
3.Handoff  
If your Handoff doesn't work:  
Try to log out your Mac's Apple ID and sign in again.  
4.Airdrop  
Airdrop doesn't work right now, you can only find the device with the same Apple ID. But you still can't send files.  
5.Apple Watch Unlock  
It works, but very instable. If it doesnt work, try to reset keychain or login Apple ID again.

Written by win1010525.
Copyright 2020-2021 <a href="https://github.com/win1010525">win1010525</a> All rights reserved.  

# 请部分中国网友（尤其是CSDN）尊重一下版权！别人写的东西你复制过去叫原创好意思吗？
