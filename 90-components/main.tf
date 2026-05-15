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

