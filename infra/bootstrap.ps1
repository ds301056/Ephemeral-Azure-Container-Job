# Bootstrap Azure resources for Ephemeral Container Job
# PowerShell version for Windows

# Configuration (modify these if needed)
$RESOURCE_GROUP = "rg-ephemeral-demo"
$REGION = "eastus"
$ACR_NAME = "acrephemeraldemo$(Get-Date -Format 'HHmmss')"
$ACA_ENV_NAME = "aca-env-demo"
$JOB_NAME = "trending-job"

Write-Host "Starting Azure infrastructure bootstrap..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Create Resource Group
Write-Host "Creating resource group: $RESOURCE_GROUP" -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $REGION --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create resource group" -ForegroundColor Red
    exit 1
}

# 2. Create Azure Container Registry
Write-Host "Creating Azure Container Registry: $ACR_NAME" -ForegroundColor Yellow
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create ACR" -ForegroundColor Red
    exit 1
}

# 3. Get ACR credentials
Write-Host "Retrieving ACR credentials..." -ForegroundColor Yellow
$ACR_SERVER = az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer -o tsv
$ACR_USERNAME = az acr credential show --name $ACR_NAME --query username -o tsv
$ACR_PASSWORD = az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv

# 4. Create Container Apps Environment
Write-Host "Creating Container Apps Environment: $ACA_ENV_NAME" -ForegroundColor Yellow
az containerapp env create --name $ACA_ENV_NAME --resource-group $RESOURCE_GROUP --location $REGION --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create Container Apps Environment" -ForegroundColor Red
    exit 1
}

# 5. Create Container Apps Job
Write-Host "Creating Container Apps Job: $JOB_NAME" -ForegroundColor Yellow
az containerapp job create --name $JOB_NAME --resource-group $RESOURCE_GROUP --environment $ACA_ENV_NAME --trigger-type Manual --replica-timeout 300 --replica-retry-limit 1 --replica-completion-count 1 --parallelism 1 --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" --cpu 0.25 --memory 0.5Gi --registry-server $ACR_SERVER --registry-username $ACR_USERNAME --registry-password $ACR_PASSWORD --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create Container Apps Job" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "SUCCESS: Bootstrap complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Save these values for GitHub Secrets:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AZURE_RESOURCE_GROUP=$RESOURCE_GROUP"
Write-Host "AZURE_REGION=$REGION"
Write-Host "ACR_LOGIN_SERVER=$ACR_SERVER"
Write-Host "ACR_USERNAME=$ACR_USERNAME"
Write-Host "ACR_PASSWORD=$ACR_PASSWORD"
Write-Host ""
Write-Host "Get AZURE_SUBSCRIPTION_ID by running:" -ForegroundColor Yellow
Write-Host "az account show --query id -o tsv"
Write-Host ""
Write-Host "Get AZURE_CREDENTIALS by running:" -ForegroundColor Yellow
Write-Host 'az ad sp create-for-rbac --name ephemeral-job-sp --role contributor --scopes /subscriptions/$(az account show --query id -o tsv) --sdk-auth'