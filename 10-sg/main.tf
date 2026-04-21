module "sg" {
    count = length(var.sg_names)
    source = "git::https://github.com/vikasarisela/Terraform-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = var.sg_names[count.index]
    sg_description  = "Created for ${var.sg_names[count.index]}"
    vpc_id =   local.vpc_id
}



# {
#   "modules": [
#     {
#       "address": "module.sg[0]",
#       "outputs": {
#         "sg_id": {
#           "value": "sg-111"
#         }
#       }
#     },
#     {
#       "address": "module.sg[1]",
#       "outputs": {
#         "sg_id": {
#           "value": "sg-222"
#         }
#       }
#     }
#   ]
# }