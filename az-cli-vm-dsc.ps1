Write-Host ********************* Azure CLI 2.0 ********************************************************
## Author : Ashwin Sebastian


$subsId="" # Enter Subscription ID
$appId=""  # Enter service principal app id
$appSecret="" # Enter app secret key
$tenantId="" # Enter tenant id
$vmName='vm'
$vmImage='Win2012R2Datacenter'
$vmusername='adminuser'
$vmpassword='Ashpassword123'
$region='westus' 
$charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$uniqueString = ""

for ($i = 0; $i -lt 5; $i++ ) {
    $uniqueString += $charSet | Get-Random
}

$rgName='azCliRG-' + $uniqueString

Write-Host Login into Azure account.
$login=az login --service-principal -u $appId -p $appSecret --tenant $tenantId
Write-Host Successfully Logged into Azure account.

Write-Host Setting default azure subscription to $subsId
az account set -s $subsId

Write-Host Creating a resource group with name $rgName in region $region
az group create -n $rgName -l $region

Write-Host ********************* Your resource are starting to deploy *********************************

Write-Host Creating a Windows VM
$vmconfig=az vm create --resource-group $rgName --name $vmName --image $vmImage --admin-username $vmusername --admin-password $vmpassword
$port=az vm open-port --port 80 --resource-group $rgName --name $vmName
Write-Host Successfully created a Windows VM

Write-Host Creating DSC extension...

$settings='{\"modulesUrl\":\"https://github.com/sysgain/arm-presentation/blob/master/dsc/dscconfig.zip?raw=true\",\"configurationFunction\":\"dscconfig.ps1\dscconfig\",\"properties\":{\"nodeName\":\"' + $vmName + '\",\"sourcePath\":\"https://github.com/sysgain/arm-presentation/blob/master/website.zip?raw=true\"}}"'
$dsc=az vm extension set --name DSC -g $rgName --vm-name $vmName --publisher Microsoft.Powershell --version 2.20 --settings $settings

Write-Host ********************* Your resources have deployed successfully !!! ************************