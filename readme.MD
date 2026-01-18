# Terraform AWS VPC

This module creates the following resources.
* VPC
* IGW
* 2 public subnets in us-east-1a and us-east-1b AZ
* 2 private subnets in us-east-1a and us-east-1b AZ
* 2 database subnets in us-east-1a and us-east-1b AZ
* 1 public Route table
* 1 private Route table
* 1 database Route table
* 1 EIP for NAT
* NAT Gateway in public subnet 1a AZ
* IGW route is added to public route
* NAT Gateway route to private and database route tables
* Route table association with subnet
* VPC to default VPC peering
* public route table to default VPC route
* Default VPC main route table to created VPC route


# Inputs

*  vpc_cdir- (Required). User must supply the CIDR for VPC
* project_name - (Required). User must supply the project name
* environment -(Required). User must supply the environment
* vpc_tags - (Optional)
* igw_tags -- (Optional)
* public_subnet_cidrs -(Required). User must supply the public subnect cidrs
* public_subnet_tags - (Optional)
* private_subnet_cidrs -(Required). User must supply the private subnect cidrs
* private_subnet_tags - (Optional)
* database_subnet_cidrs -(Required). User must supply the database subnect cidrs
* database_subnet_tags - (Optional)
* public_route_table_tags - (Optional)
* private_route_table_tags - (Optional)
* database_route_table_tags - (Optional)
* eip_tags - (Optional)
* nat_tags - (Optional)
* is_peering_required - (Optional)




