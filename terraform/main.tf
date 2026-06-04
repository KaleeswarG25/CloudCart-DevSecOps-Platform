locals {
  instance_sizes = {
    default = "t3.micro"
    dev     = "t3.micro"
    stage   = "t3.micro"
    prod    = "t3.micro"
  }
  chosen_instance_type = lookup(local.instance_sizes, terraform.workspace, "t2.micro")
}

module "vpc" {
  source        = "./modules/vpc"
  environment   = terraform.workspace
  vpc_cidr      = "10.0.0.0/16"
  subnet_1_cidr = "10.0.1.0/24"
  subnet_2_cidr = "10.0.2.0/24"
}

module "security_group" {
  source      = "./modules/security-group"
  environment = terraform.workspace
  vpc_id      = module.vpc.vpc_id
}

/*
module "ec2" {
  source            = "./modules/ec2"
  environment       = terraform.workspace
  subnet_id         = module.vpc.subnet_1_id
  security_group_id = module.security_group.sg_id
  instance_type     = local.chosen_instance_type
}
*/

output "app_live_url" {
  value = "http://${module.alb.alb_dns_name}"
}
# ... previous modules ...
module "alb" {
  source            = "./modules/alb" # 👈 Make sure this has exactly "./modules/alb"
  environment       = terraform.workspace
  vpc_id            = module.vpc.vpc_id
  security_group_id = module.security_group.sg_id
  subnet_ids        = [module.vpc.subnet_1_id, module.vpc.subnet_2_id]
}

module "asg" {
  source            = "./modules/asg" # 👈 Make sure this has exactly "./modules/asg"
  environment       = terraform.workspace
  subnet_ids        = [module.vpc.subnet_1_id, module.vpc.subnet_2_id]
  security_group_id = module.security_group.sg_id
  instance_type     = local.chosen_instance_type
  target_group_arn  = module.alb.tg_arn
}
