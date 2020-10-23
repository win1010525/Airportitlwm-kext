# Airportitlwm-kext
An IO80211 added version of Airportitlwm.  
This is same as zxystd's Airportitlwm  
But it is put in IO80211Family.kext to make sure Clover and OC 0.6.0 and lower can use it.  
All bugs should open issues on zxystd's master branch.  
Open issues here: https://github.com/OpenIntelWireless/itlwm/issues/new/choose
   
# Installation
1.Clover:  
  Put it into Clover\kexts\Other\   
![image](https://github.com/win1010525/Airportitlwm-kext/blob/master/images/Clover.png)   
  OpenCore:
  (1):Put it into OC\Kexts\   
![image](https://github.com/win1010525/Airportitlwm-kext/blob/master/images/OC-1.png)    
2.This kext can't load if your OpenCore's SecureBootModel is Disabled. You should set it to Default.  
![image](https://github.com/win1010525/Airportitlwm-kext/blob/master/images/SecureBootModel.png)   
3.Handoff  
  If your Handoff doesn't work:  
  Try to log out your Mac's Apple ID and sign in again.  
