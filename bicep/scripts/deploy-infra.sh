#!/bin/bash
repoRoot=$(
    cd "$(dirname "${BASH_SOURCE[0]}")/../../"
    pwd -P
)

##############################################################################
# colors for formatting the output
##############################################################################
# shellcheck disable=SC2034
{
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
}
##############################################################################
#- print functions
##############################################################################
function printMessage(){
    echo -e "${GREEN}$1${NC}" 
}
function printWarning(){
    echo -e "${YELLOW}$1${NC}" 
}
function printError(){
    echo -e "${RED}$1${NC}" 
}
function printProgress(){
    echo -e "${BLUE}$1${NC}" 
}
##############################################################################
#- checkLoginAndSubscription 
##############################################################################
function checkLoginAndSubscription() {
    az account show -o none
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        printError "\nYou seems disconnected from Azure, stopping the script."
        exit 1
    fi
}
##############################################################################
#- function used to check whether an error occurred
##############################################################################
function checkError() {
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        echo -e "${RED}\nAn error occurred exiting from the current bash${NC}"
        exit 1
    fi
}
#######################################################
#- function used to print out script usage
#######################################################
function usage() {
    echo
    echo "Arguments:"
    echo -e " -r  [RESOURCE_GROUP] set resource group"
    echo -e " -s  [SUBSCRIPTION_ID] set SUBSCRIPTION_ID"

    echo
    echo "Example:"
    echo -e " bash ./deploy-infra.sh -e DEV -r DevResourceGroup -s [SUB_ID] -t [TENANT_ID]"    
}


NETWORK_ISOLATION=false
# shellcheck disable=SC2034
while getopts "r:s:t:" opt; do
    case $opt in
    r) RESOURCE_GROUP=$OPTARG ;;  
    s) SUBSCRIPTION_ID=$OPTARG ;; 
    t) TENANT_ID=$OPTARG ;; 
    :)
        printError "Error: -${OPTARG} requires a value"
        exit 1
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done

# Validation
if [[ -z "${RESOURCE_GROUP}" ]]; then
    printError "Required parameters are missing"
    usage
    exit 1
fi

if [[ $SUBSCRIPTION_ID ]]; then
    printProgress "Interactive Azure login..."
    if [[ -z $TENANT_ID ]]; then
        az login || exit 1
    else
        az login -t $TENANT_ID || exit 1
    fi  
    if [[ ! -z $SUBSCRIPTION_ID ]]; then
        az account set -s $SUBSCRIPTION_ID
    fi     
fi
checkLoginAndSubscription

# az account show

printProgress "Getting Resource Group Name..."
resourceGroupName="${RESOURCE_GROUP}"
printProgress "Resource Group Name: ${resourceGroupName}"



pathToBicep="${repoRoot}/bicep/main.bicep"


#Deploy infrastructure using main.bicep file
printProgress "Deploying resources in resource group ${resourceGroupName}..."
az deployment group create --mode Incremental --resource-group $resourceGroupName --template-file $pathToBicep  --parameters environmentType=DEV

#Getting Azure Key Vault and Azure ML workspace names from the deployment named "main" and "azuremlWorkspace"


nameAmlWorkspace=$(az deployment group show --resource-group ${resourceGroupName} --name azuremlWorkspace --query properties.outputs.nameMachineLearning.value -o tsv)
nameAiSearch=$(az deployment group show --resource-group ${resourceGroupName} --name aiSearch --query properties.outputs.searchName.value -o tsv)
nameAOAI=$(az deployment group show --resource-group ${resourceGroupName} --name azureOpenAI --query properties.outputs.azureOpenAIName.value -o tsv)
# Getting Azure AI Search endpoint and key
aiSearchEndpoint=https://${nameAiSearch}.search.windows.net
aiSearchKey=$(az search admin-key show --service-name ${nameAiSearch} --resource-group ${resourceGroupName} --query primaryKey --output tsv)

# Getting Azure OpenAI endpoint and key
aoaiEndpoint=$(az cognitiveservices account show --name ${nameAOAI} --resource-group ${resourceGroupName} --query properties.endpoint --output tsv)
aoaiKey=$(az cognitiveservices account keys list --name ${nameAOAI} --resource-group ${resourceGroupName} --query key1 --output tsv)

echo $nameAmlWorkspace
#Exporting variable names in llmops_config.json file at the root of the repo
if [ -z "$nameAmlWorkspace" ];  then
    printProgress "Missing nameAmlWorkspace"
    exit 1
fi
if [ -z "$nameAiSearch" ];  then
    printProgress "Missing nameAiSearch"
    exit 1
fi
if [ -z "$nameAOAI" ];  then
    printProgress "Missing nameAOAI"
    exit 1
fi
if [ -z "$aiSearchEndpoint" ];  then
    printProgress "Missing aiSearchEndpoint"
    exit 1
fi
if [ -z "$aiSearchKey" ];  then
    printProgress "Missing aiSearchKey"
    exit 1
fi
if [ -z "$aoaiEndpoint" ];  then
    printProgress "Missing aoaiEndpoint"
    exit 1
fi
if [ -z "$aoaiKey" ];  then
    printProgress "Missing aoaiKey"
    exit 1
fi

cp ${repoRoot}/book/.env.sample ${repoRoot}/book/.env
sed -i "s|AZURE_SEARCH_SERVICE_ENDPOINT=.*|AZURE_SEARCH_SERVICE_ENDPOINT=\"$aiSearchEndpoint\"|g" ${repoRoot}/book/.env
sed -i "s|AZURE_SEARCH_ADMIN_KEY=.*|AZURE_SEARCH_ADMIN_KEY=\"$aoaiKey\"|g" ${repoRoot}/book/.env
sed -i "s|AZURE_OPENAI_ENDPOINT=.*|AZURE_OPENAI_ENDPOINT=\"$aoaiEndpoint\"|g" ${repoRoot}/book/.env
sed -i "s|AZURE_OPENAI_KEY=.*|AZURE_OPENAI_KEY=\"$aiSearchKey\"|g" ${repoRoot}/book/.env
sed -i "s|workspace_name=.*|workspace_name=\"$nameAmlWorkspace\"|g" ${repoRoot}/book/.env
sed -i "s|resource_group_name=.*|resource_group_name=\"$resourceGroupName\"|g" ${repoRoot}/book/.env
sed -i "s|subscription_id=.*|subscription_id=\"$SUBSCRIPTION_ID\"|g" ${repoRoot}/book/.env

printMessage "Deployment in resource group ${resourceGroupName} successful!"