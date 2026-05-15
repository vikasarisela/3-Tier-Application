module "components" {
  source = "../../Terraform-threetierapp-component"
  component = var.component
  rule_priority = var.rule_priority
}

module "components" {
  for_each = var.components
  source = "https://github.com/vikasarisela/Terraform-threetierapp-component.git?ref=main"
  component = each.key
  rule_priority = each.value.rule_priority
}

# 1. AWS instance creation 
# 2. Connect to the instance and configure for example catalogue module
# 3. Stop the instance
# 4. ami from instance 
# 5. Create target group 
# 6. Create launch template 
# 7. Create ASG
# 8. Create ASG Policy
# 9. load balancer listener rule added from respective component redirects according to user click
# 10 terminate the instance 