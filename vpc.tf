#VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cdir
  instance_tenancy = "default"
  enable_dns_hostnames=true
  tags =merge(
     var.vpc_tags,
    local.common_tags,
   
    {
        Name= local.common_name_suffix
    }
  )
}
#IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags =merge(
     var.igw_tags,
    local.common_tags,
   
    {
        Name= local.common_name_suffix
    }
  )
}

# Public subnets
resource "aws_subnet" "public" {
count =length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags =merge(
     var.public_subnet_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-public-${local.az_names[count.index]}" #roboshop=dev-public-us-east-1
    }
  )
}
#private subnetx
resource "aws_subnet" "private" {
count =length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
 
  tags =merge(
     var.private_subnet_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-private-${local.az_names[count.index]}" #roboshop=dev-private-us-east-1
    }
  )
}
#database syubnets
resource "aws_subnet" "database" {
count =length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
 
  tags =merge(
     var.database_subnet_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-database-${local.az_names[count.index]}" #roboshop=dev-private-us-east-1
    }
  )
}

#public Route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

  tags = merge(
     var.public_route_table_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-public"
    }
  )
}
#private Route table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(
     var.private_route_table_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-private"
    }
  )
}
#database Route table

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(
     var.database_route_table_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-database"
    }
  )
}

# public route

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id=aws_internet_gateway.main.id
}

#ELastic Ip adress
resource "aws_eip" "nat" {
 
  domain   = "vpc"
  tags = merge(
     var.eip_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}-nat"
    }
  )
}

# NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
     var.nat_tags,
    local.common_tags,
   
    {
        Name= "${local.common_name_suffix}" #roboshop-dev
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# private egress route through nat
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id=aws_nat_gateway.nat.id
}
# database egress route through nat
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
   nat_gateway_id=aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
    count=length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count=length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count=length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

