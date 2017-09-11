$appId='' #enter service principal app id
$appSecret='' #enter app secret key
$tenantId='' #enter tenant id
$rgName='myCliRG'
$vmName='vm'
$vmImage='win2016datacenter'
$vmusername='adminuser'
$vmpassword='Ashpassword123'
$region='westus' 
$charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$uniqueString = ""

for ($i = 0; $i -lt 7; $i++ ) {
    $uniqueString += $charSet | Get-Random
}

$rgName='myCliRG-' + $uniqueString

Write-Host Login into Azure account.
$login=az login --service-principal -u $appId -p $appSecret --tenant $tenantId
Write-Host Successfully Logged into Azure account.

Write-Host Setting default azure subscription to Sysgain-CloudTry-Dev
az account set -s 7eab3893-bd71-4690-84a5-47624df0b0e5
az account show

Write-Host Creating a resource group with name $rgName
az group create -n $rgName -l $region

Write-Host Creating a VM Windows 2016 Datacenter 
$vmconfig=az vm create --resource-group $rgName --name $vmName --image $vmImage --admin-username $vmusername --admin-password $vmpassword
az vm open-port --port 80 --resource-group $rgName --name $vmName
Write-Host Successfully Created a VM Windows 2016 Datacenter 