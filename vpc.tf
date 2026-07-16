resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-a"
    Tier = "public"
  }
}
resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-b"
    Tier = "public"
  }
}
resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-c"
    Tier = "public"
  }
}


resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-a"
    Tier = "private"
  }
}
resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-private-b"
    Tier = "private"
  }
}
resource "aws_subnet" "private-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.project_name}-private-c"
    Tier = "private"
  }
}






resource "aws_eip" "nat-public-a" {
  depends_on = [
    aws_internet_gateway.gateway
  ]

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-public-a"
  }
}
resource "aws_eip" "nat-public-b" {
  depends_on = [
    aws_internet_gateway.gateway
  ]

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-public-b"
  }
}
resource "aws_eip" "nat-public-c" {
  depends_on = [
    aws_internet_gateway.gateway
  ]

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-public-c"
  }
}








resource "aws_nat_gateway" "nat-public-a" {
  allocation_id = aws_eip.nat-public-a.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "${var.project_name}-nat-public-a"
  }
}
resource "aws_nat_gateway" "nat-public-b" {
  allocation_id = aws_eip.nat-public-b.id
  subnet_id     = aws_subnet.public-b.id

  tags = {
    Name = "${var.project_name}-nat-public-b"
  }
}
resource "aws_nat_gateway" "nat-public-c" {
  allocation_id = aws_eip.nat-public-c.id
  subnet_id     = aws_subnet.public-c.id

  tags = {
    Name = "${var.project_name}-nat-public-c"
  }
}










##########################
# Public route table (single, towards the IGW)
##########################

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.rt-public.id
}




resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-public-a.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-a"
  }
}
resource "aws_route_table" "private-b" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-public-b.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-b"
  }
}
resource "aws_route_table" "private-c" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-public-c.id
  }

  tags = {
    Name = "${var.project_name}-rt-private-c"
  }
}




resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private-a.id
}
resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private-b.id
}
resource "aws_route_table_association" "private-c" {
  subnet_id      = aws_subnet.private-c.id
  route_table_id = aws_route_table.private-c.id
}
