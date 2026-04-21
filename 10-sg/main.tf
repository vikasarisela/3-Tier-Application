module "sg" {
    count = length(var.sg_names)
    source = "git::https://github.com/vikasarisela/Terraform-sg-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = var.sg_names[count.index]
    sg_description  = "Created for ${var.sg_names[count.index]}"
    vpc_id =   local.vpc_id
}

# Open port 80 on the frontend EC2 Security Group and allow traffic only from module.sg[11].sg_id (the ALB Security Group).
resource "aws_security_group_rule" "frontendinstance_accpeting_from_alb" {
   type = "ingress"
  security_group_id = module.sg[9].sg_id   #frontend SG ID
  source_security_group_id = module.sg[11].sg_id
  from_port   = 80
  protocol = "tcp"
  to_port     = 80
}
#“Allow HTTP traffic (port 80)”
# “ALB forwards traffic to whatever port is defined in the target group”
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