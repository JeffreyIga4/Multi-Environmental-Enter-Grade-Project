#!/bin/bash
set -e

RESOURCE_GROUP_NAME="terraform-state-rg"
LOCATION="canadacentral"

STAGE_SA_ACCOUNT="tfstagebackend2026jeff"
DEV_SA_ACCOUNT="tfdevbackend2026jeff"
CONTAINER_NAME="tfstate"

# Create resource group
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION"

# Create storage account for staging environment
az storage account create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$STAGE_SA_ACCOUNT" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2

# Create storage account for dev environment
az storage account create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$DEV_SA_ACCOUNT" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2

# Create blob container for staging environment
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STAGE_SA_ACCOUNT" \
  --auth-mode login

# Create blob container for dev environment
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$DEV_SA_ACCOUNT" \
  --auth-mode login