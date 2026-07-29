// ============================================================================
// Parameters File - Replace these values for your deployment
// ============================================================================

using './main.bicep'

param location = 'eastus'  // Azure region
param appName = 'tailspintoys'  // Application name
param environment = 'prod'  // Environment (prod, staging, dev)
param appServiceSku = 'B2'  // SKU size (B1=small/cheap, B2=medium, S1/S2=standard, P1V2=premium)
