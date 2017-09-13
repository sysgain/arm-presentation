Write-Host ********************* Azure CLI 2.0 ********************************************************
## Author : Ashwin Sebastian




#################### Variabble Section ###########################################
$subsId="" # Enter Subscription ID
$appId="" # Enter app Id
$appSecret="" # Enter app secret key
$tenantId="" # Enter tenant id
$region='westus' #Specify Azure region
$vmCount=2  # Specify VM count
$charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$uniqueString = ""
for ($i = 0; $i -lt 5; $i++ ) {
    $uniqueString += $charSet | Get-Random
}
$prefix="my-"
$rgName="azCliRG-" + $uniqueString
$lbPipName=$prefix + $uniqueString + "-lbpip"
$dnsName="app-" + $uniqueString
$vnetName=$prefix + $uniqueString + "-vnet"
$subnetName="subnet"
$avsetName=$prefix + $uniqueString + "-avset"
$lbName=$prefix + $uniqueString + "-lb"
$nicName=$prefix + $uniqueString + "-nic"
$vmssName="node"
$dscExtName=$prefix + $uniqueString + "-dscExt"
$bkpool="bkpool"
$ipConfig="ipConfig"
$osDiskName="osDisk_" + $uniqueString + "_vm"
$modulesUrl="https://github.com/sysgain/arm-presentation/blob/master/dsc/dscconfig.zip?raw=true"
$sourcePath="https://github.com/sysgain/arm-presentation/blob/master/website.zip?raw=true"




$vnetAddressPrefix="10.0.0.0/16"

$vmUsername="adminuser"
$vmPassword="Ashpassword123"
$vmImage="Win2012R2Datacenter"


#################### End of Variable Section #####################################


############## Login to Azure #####################################################
Write-Host Login into Azure account.
$login=az login --service-principal -u $appId -p $appSecret --tenant $tenantId
az account set -s $subsId
az account show
Write-Host Successfully Logged into Azure account.

################ Resource group ##########################
Write-Host Creating a resource group with name $rgName in region $region
$rg=az group create -n $rgName -l $region

Write-Host ********************* Your resource are starting to deploy *********************************
################ Public IP address ###########################
Write-Host Creating a public IP address for Load balancer...
$lbPip=az network public-ip create -g $rgName -n $lbPipName --dns-name $dnsName --allocation-method Dynamic
Write-Host Successfully created a public IP address for Load balancer


############### VNET ########################################
Write-Host Creating a VNET...
$vnet=az network vnet create -g $rgName -n $vnetName --address-prefix $vnetAddressPrefix
$subnet=az network vnet subnet create -g $rgName --address-prefix 10.0.0.0/24 -n $subnetName --vnet-name $vnetName 
Write-Host Successfully created VNET


####################### Load Balancer #########################
Write-Host Creating a load balancer...

$lb=az network lb create -g $rgName -n $lbName --public-ip-address $lbPipName --frontend-ip-name $ipConfig --backend-pool-name $bkpool 
$probHttp=az network lb probe create --lb-name $lbName --name http-hlt --port 80 --protocol Tcp -g $rgName
$probRdp=az network lb probe create --lb-name $lbName --name rdp-hlt --port 3389 --protocol Tcp -g $rgName
$lbRule=az network lb rule create -g $rgName --lb-name $lbName --name http --protocol Tcp --frontend-port 80 --backend-port 80 --backend-pool-name $bkpool --frontend-ip-name $ipConfig --probe-name http-hlt
$lbNatRule=az network lb inbound-nat-pool create -g $rgName --lb-name $lbName --name rdp --protocol Tcp --backend-port 3389 --frontend-port-range-start 4000 --frontend-port-range-end 4050 --frontend-ip-name $ipConfig


Write-Host Successfully created a load balancer

#################### VM Scale Set ############################

Write-Host Creating VM Scale set...

$vmss = az vmss create --image $vmImage -n $vmssName -g $rgName --admin-username $vmUsername --admin-password $vmPassword --backend-pool-name $bkpool --instance-count $vmCount --lb-nat-pool-name rdp --lb $lbName --subnet $subnetName --vnet-name $vnetName --disable-overprovision 

Write-Host Successfully creating VM Scale set.

Write-Host ********************* Your resource are deployed successfully !!! *********************************








