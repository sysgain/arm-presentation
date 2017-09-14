Write-Host ********************* Azure CLI 2.0 ********************************************************

## Please Create a Service Principal Application ID and its Secret key and assign RBAC to Contributer and enter its detail below

#################### Variabble Section ###########################################
$subsId="cf45c459-955b-4ad2-b1d4-04172ed9bc26" # Enter Subscription ID
$appId="" # Enter app Id
$appSecret="" # Enter app secret key
$tenantId="" # Enter tenant id
$region='westus' #Specify Azure region

$charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$uniqueString = ""
for ($i = 0; $i -lt 5; $i++ ) {
    $uniqueString += $charSet | Get-Random
}

$diskName="mngDisk-" + $uniqueString
$rgName="azCliStore-" + $uniqueString
############## Login to Azure #####################################################
Write-Host Login into Azure account.
$login=az login --service-principal -u $appId -p $appSecret --tenant $tenantId
az account set -s $subsId
az account show
Write-Host Successfully Logged into Azure account.

################ Resource group ##########################
Write-Host Creating a resource group with name $rgName in region $region
$rg=az group create -n $rgName -l $region

Write-Host ********************* Your managed disk is starting to deploy *********************************
################ Managed Disk ##########################

az disk create -n $diskName -g $rgName --sku Standard_LRS --size-gb 127
