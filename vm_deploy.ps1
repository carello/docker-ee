
param(
	[parameter(Mandatory = $true)]
	[string]$CSVname
	)

#Getting VMS from .csv
 $VMs = Import-CSV $CSVname -Header GuestName,mgmtipAddress,mgmtipSubnetMask,mgmtipGateway

#Loop to Provision VMs

 ForEach($VM in $VMs){

 #Get the cspec Template
 	$cspec = Get-OSCustomizationSpec -Name "docker-custom"

#Create the temporary cspec
	$tempCspec = Get-OSCustomizationSpec -Name $cspec | New-OSCustomizationSpec -Name "$($VM.GuestName)_cspec"

#Change the NIC information in the temporary Cspec
	Get-OSCustomizationSpec $tempCspec | Get-OscustomizationNicMapping | Where-Object {$_.Position -eq "1"} | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $VM.mgmtipAddress -SubnetMask $VM.mgmtipSubnetMask -DefaultGateway $VM.mgmtipGateway -Confirm:$false
	Write-Host "Network 1 IP is Set"
	Get-OSCustomizationSpec $tempCspec | Get-OscustomizationNicMapping | Where-Object {$_.Position -eq "2"} | Set-OSCustomizationNicMapping -IpMode UseDHCP -Confirm:$false
	Write-Host "Network 2 IP is Set"
	Get-OSCustomizationSpec $tempCspec | Get-OscustomizationNicMapping | Where-Object {$_.Position -eq "3"} | Set-OSCustomizationNicMapping -IpMode UseDHCP -Confirm:$false
	Write-Host "Network 3 IP is Set"


#Deploy the VM
	New-VM -Name $VM.GuestName -Template docker-template -Datastore pure-docker -ResourcePool hx-cluster -Location Docker -RunAsync

#Get the VM Name and use mapped temporary Cspec
	$VM = Get-VM -name $VM.GuestName
	$VM | Set-VM -OSCustomizationSpec $tempCspec -Confirm:$false -ErrorVariable Err -WA SilentlyContinue -EA Stop | Out-Null

#Delete the temporary Cspec
	Remove-OSCustomizationSpec -CustomizationSpec $tempCspec -Confirm:$false
#PowerOn VM
	Get-VM $VM | Start-VM
	}
