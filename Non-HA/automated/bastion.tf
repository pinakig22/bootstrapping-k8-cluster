################################################################################
# Author      : Pinaki Ghosh
# Date Created: 05 Nov 2023
################################################################################

## Bastion Security Group
#data "aws_security_group" "bastion-sg" {
#  tags = {
#    name   = "Name"
#    values = "bastion-sg"
#  }
#  vpc_id = module.vpc.vpc_id
#}


## Bastion Launch Template
resource "aws_launch_template" "bastion-lt" {
  name                   = "bastion-lt"
  image_id               = var.bastion_ami
  instance_type          = var.bastion_inst_type
  key_name               = "mumbai-key-pair"
 # vpc_security_group_ids = [data.aws_security_group.bastion-sg.id]

  block_device_mappings {
    # Root device name of the AMI
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }
}

## Bastion ASG
resource "aws_autoscaling_group" "bastion-asg" {
  name = "baston-asg"
  launch_template {
    id = aws_launch_template.bastion-lt.id
    version = "$Latest"
  }

  max_size = 1
  min_size = 1
  desired_capacity = 1

  vpc_zone_identifier = [module.vpc.public_subnets[0]]

  default_cooldown = 300
  health_check_grace_period =  0
  health_check_type = "EC2"

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "bastion-asg-non-ha"
  }

}