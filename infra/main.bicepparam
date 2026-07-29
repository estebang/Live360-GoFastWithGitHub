// ============================================================================
// Parameters File - Replace these values for your deployment
// ============================================================================

using './main.bicep'

param location = 'eastus'  // Azure region
param appName = 'tailspintoys'  // Application name
param environment = 'prod'  // Environment (prod, staging, dev)
param appServiceSku = 'S1'  // SKU size - NOTE: Slots require S1+ (Standard or Premium). B1/B2 (Basic) do not support slots.
