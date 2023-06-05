
# ======== VPC BEGIN =============

resource "aws_vpc" "os-blockchain-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-BC-VPC"
  }
}

# ======== Public Subnets BEGIN =============
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.prefix}-Public Subnet 1"
  }
}


resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${var.prefix}-Public Subnet 2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = "${var.aws_region}c"
  tags = {
    Name = "${var.prefix}-Public Subnet 3"
  }
}

# ======== Private Subnets BEGIN =============

resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.prefix}-Private Subnet 1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${var.prefix}-Private Subnet 2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.os-blockchain-vpc.id
  availability_zone = "${var.aws_region}c"
  tags = {
    Name = "${var.prefix}-Private Subnet 3"
  }
}

# ======== Public Route Table BEGIN =============
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.os-blockchain-vpc.id
  tags = {
    Name = "${var.prefix}-Public Route Table"
  }
}


# ======== Private Route Table BEGIN =============
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.os-blockchain-vpc.id
  tags = {
    Name = "${var.prefix}-Private Route Table"
  }
}

# ======== Public Route Table Association BEGIN =============
resource "aws_route_table_association" "public-subnet-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-subnet-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}
resource "aws_route_table_association" "public-subnet-3-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-3.id
}

# ======== Private Route Table Association BEGIN =============
resource "aws_route_table_association" "private-subnet-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-subnet-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-2.id
}
resource "aws_route_table_association" "private-subnet-3-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-3.id
}

# ======== EIP BEGIN =============
resource "aws_eip" "eip-for-nat-gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "${var.prefix}-Production EIP"
  }
}

# ======== NAT GW Allocation BEGIN =============

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "${var.prefix}-Production NAT-GW"
  }
  depends_on = [aws_eip.eip-for-nat-gw]
}


# ======== Route table NAT-GW association BEGIN =============
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.os-blockchain-vpc.id
  tags = {
    Name = "${var.prefix}-Production IGW"
  }
}


resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.production-igw.id
  destination_cidr_block = "0.0.0.0/0"
}



