data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_network_acl" "main" {
  vpc_id = module.vpc.vpc_id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "main"
  }
}

resource "aws_network_acl_association" "private_acl_association" {
  count          = var.az_count
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_network_acl_association" "acl_association" {
  count          = var.az_count
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = module.vpc.vpc_id
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(module.vpc.vpc_cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = module.vpc.vpc_id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = module.vpc.vpc_id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  depends_on             = [aws_internet_gateway.gw]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = var.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = aws_subnet.private[count.index].cidr_block
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

