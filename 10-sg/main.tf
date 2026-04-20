module "sg" {
    count = length(var.sg_names)
    source = "git::https://github.com/vikasarisela/Terraform-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = var.sg_names[count.index]
    description = "Created for ${var.sg_names[count.index]}"
    vpc_id =   local.vpc_id
}