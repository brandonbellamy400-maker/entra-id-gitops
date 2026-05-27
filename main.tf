 # 1. Connect to your existing Resource Group
resource "azurerm_resource_group" "iam_rg" {
  name     = "rg-iam-automation"
  location = "East US" 
}

# 2. Connect to your existing Consumption Logic App
resource "azurerm_logic_app_workflow" "offboard_orchestrator" {
  name                = "logic-entra-lifecycle-worker"
  location            = azurerm_resource_group.iam_rg.location
  resource_group_name = azurerm_resource_group.iam_rg.name

  identity {
    type = "SystemAssigned"
  }
}

# 3. Establish the secure incoming HTTP endpoint for your pipeline
resource "azurerm_logic_app_trigger_custom" "http_trigger" {
  name         = "When_MS_Graph_LCW_Triggers_Webhook"
  logic_app_id = azurerm_logic_app_workflow.offboard_orchestrator.id

  body = jsonencode({
    type = "Request"
    kind = "Http"
    inputs = {
      method = "POST"
      schema = {
        type = "object"
        properties = {
          userId = { type = "string" }
        }
        required = ["userId"]
      }
    }
  })
}