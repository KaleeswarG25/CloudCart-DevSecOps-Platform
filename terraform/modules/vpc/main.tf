resource "aws_vpc" "cloudcart_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "cloudcart-${var.environment}-vpc" }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.cloudcart_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "cloudcart-${var.environment}-public-subnet-1" }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.cloudcart_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "cloudcart-${var.environment}-public-subnet-2" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  tags   = { Name = "cloudcart-${var.environment}-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloudcart_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "cloudcart-${var.environment}-rt" }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
# ..

# STEP 1: Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.cloudcart_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "cloudcart-${var.environment}-private-1"
  }
}

# STEP 2: Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.cloudcart_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "cloudcart-${var.environment}-private-2"
  }
}

# STEP 3: Allocate Elastic IP for NAT
/*
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


/* STEP 4: Create NAT Gateway (placed inside public_subnet_1)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags          = { Name = "cloudcart-${var.environment}-nat-gw" }
}


# STEP 5: Create Private Route Table pointing to NAT Gateway
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cloudcart_vpc.id

  tags = {
    Name = "cloudcart-${var.environment}-private-rt"
  }
}
# STEP 6: Associate Private Subnets to the Private Route Table
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
