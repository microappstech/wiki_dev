```
lusrmgr.msc
```

### Get user's id

``` 
(Get-LocalUser -Name "AzureAgentUser").SID.Value
```

sc.exe sdset w3svc "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCR;;;IU)(A;;CCLCSWLOCR;;;SU)(A;;RPWPCR;;;YOUR_USER_SID)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)"

icacls "C:\inetpub\wwwroot" /grant AzureAgentUser:(OI)(CI)M

net stop w3svc
net start w3svc
