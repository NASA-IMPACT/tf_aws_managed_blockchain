#
#
#
#
#
#
#
#
#
#
#
#resource "aws_security_group" "blockchain_workshop_security_group_ingress" {
#  // CF Property(IpProtocol) = -1
#  // CF Property(FromPort) = -1
#  // CF Property(GroupId) = aws_security_group.blockchain_workshop_security_group.id
#  // CF Property(ToPort) = -1
#  vpc_id = aws_security_group.blockchain_workshop_security_group.id
#  tags = [
#    {
#      Key = "BlockchainWorkshop"
#      Value = "BaseSecurityGroupIngress"
#    }
#  ]
#}
#
#resource "aws_internet_gateway" "blockchain_workshop_internet_gateway" {
#  tags = [
#    {
#      Key = "BlockchainWorkshop"
#      Value = "InternetGateway"
#    }
#  ]
#}
#
#resource "aws_ec2_transit_gateway_vpc_attachment" "blockchain_workshop_attach_gateway" {
#  vpc_id = aws_internet_gateway.blockchain_workshop_internet_gateway.id
#}
#
#resource "aws_route_table" "blockchain_workshop_route_table" {
#  vpc_id = aws_vpc.blockchain_workshop_vpc.arn
#  tags = [
#    {
#      Key = "BlockchainWorkshop"
#      Value = "RouteTable"
#    }
#  ]
#}
#
#resource "aws_route" "blockchain_workshop_route" {
#  route_table_id = aws_route_table.blockchain_workshop_route_table.id
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id = aws_internet_gateway.blockchain_workshop_internet_gateway.id
#}
#
#resource "aws_route_table_association" "blockchain_workshop_subnet_route_table_association" {
#  subnet_id = aws_subnet.blockchain_workshop_public_subnet.id
#  route_table_id = aws_route_table.blockchain_workshop_route_table.id
#}
#
#resource "aws_vpc_endpoint" "blockchain_workshop_vpc_endpoint" {
#  vpc_id = aws_vpc.blockchain_workshop_vpc.arn
#  private_dns_enabled = True
#  service_name = var.blockchain_vpc_endpoint_service_name
#  vpc_endpoint_type = "Interface"
#  subnet_ids = [
#    aws_subnet.blockchain_workshop_public_subnet.id
#  ]
#  security_group_ids = [
#    aws_security_group.blockchain_workshop_security_group.arn
#  ]
#}
#
#resource "aws_ec2_instance_state" "blockchain_workshop_ec2" {
#  // CF Property(KeyName) = var.key_name
#  // CF Property(ImageId) = "ami-0434d5878c6ad6d4c"
#  instance_id = aws_iam_instance_profile.blockchain_workshop_root_instance_profile.arn
#  // CF Property(NetworkInterfaces) = [
#  //   {
#  //     AssociatePublicIpAddress = True
#  //     DeviceIndex = 0
#  //     GroupSet = [
#  //       aws_security_group.blockchain_workshop_security_group.arn
#  //     ]
#  //     SubnetId = aws_subnet.blockchain_workshop_public_subnet.id
#  //   }
#  // ]
#  // CF Property(Tags) = [
#  //   {
#  //     Key = "Name"
#  //     Value = "ManagedBlockchainWorkshopEC2ClientInstance"
#  //   }
#  // ]
#}
#
#resource "aws_load_balancer_policy" "blockchain_workshop_elb" {
#  // CF Property(SecurityGroups) = [
#  //   aws_security_group.blockchain_workshop_security_group.arn
#  // ]
#  // CF Property(Subnets) = [
#  //   aws_subnet.blockchain_workshop_public_subnet.id
#  // ]
#  // CF Property(Instances) = [
#  //   aws_ec2_instance_state.blockchain_workshop_ec2.id
#  // ]
#  // CF Property(Listeners) = [
#  //   {
#  //     LoadBalancerPort = "80"
#  //     InstancePort = "3000"
#  //     Protocol = "TCP"
#  //   }
#  // ]
#  // CF Property(HealthCheck) = {
#  //   Target = "HTTP:3000/health"
#  //   HealthyThreshold = "3"
#  //   UnhealthyThreshold = "5"
#  //   Interval = "10"
#  //   Timeout = "5"
#  // }
#  // CF Property(Tags) = [
#  //   {
#  //     Key = "Name"
#  //     Value = "BlockchainWorkshopELB"
#  //   }
#  // ]
#}
#
#output "vpcid" {
#  description = "VPC ID"
#  value = aws_vpc.blockchain_workshop_vpc.arn
#}
#
#output "public_subnet_id" {
#  description = "Public Subnet ID"
#  value = aws_subnet.blockchain_workshop_public_subnet.id
#}
#
#output "security_group_id" {
#  description = "Security Group ID"
#  value = aws_security_group.blockchain_workshop_security_group.id
#}
#
#output "ec2_url" {
#  description = "Public DNS of the EC2 Fabric client node instance"
#  value = aws_ec2_instance_state.blockchain_workshop_ec2.state
#}
#
#output "ec2_id" {
#  description = "Instance ID of the EC2 Fabric client node instance"
#  value = aws_ec2_instance_state.blockchain_workshop_ec2.id
#}
#
#output "elbdns" {
#  description = "Public DNS of the ELB"
#  value = aws_load_balancer_policy.blockchain_workshop_elb.load_balancer_name
#}
#
#output "blockchain_vpc_endpoint" {
#  description = "VPC Endpoint ID"
#  value = aws_vpc_endpoint.blockchain_workshop_vpc_endpoint.id
#}
