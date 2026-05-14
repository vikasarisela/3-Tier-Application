module "components" {
  source = "../../Terraform-threetierapp-component"
  component = var.component
  rule_priority = var.rule_priority
}