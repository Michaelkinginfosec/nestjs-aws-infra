resource "aws_vpc" "michael_nest_vpc"{
    cidr_block = "10.0.0.0/20"

    tags = {
      Name = "michaelking-nest-vpc"
    }
}


resource "aws_subnet" "michael_nest_public_subnet"{
    vpc_id = aws_vpc.michael_nest_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-north-1a"

    tags = {
        Name = "michaelking-public-subnet"
    }
}


resource "aws_subnet" "michael_nest_private_subnet"{
    vpc_id = aws_vpc.michael_nest_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-north-1a"

    tags = {
        Name = "michaelking-private-subnet"
    }
}

resource "aws_internet_gateway" "michael_nest_vpc_ig"{
    vpc_id = aws_vpc.michael_nest_vpc.id

    tags = {
      Name = "michaelking-internet-gateway"
    }
}

# routing table 

resource "aws_route_table" "michael_nest_rt"{
    vpc_id = aws_vpc.michael_nest_vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.michael_nest_vpc_ig.id
    }

    tags = {
      Name = "michaelking-route-table"
    }
}

resource "aws_route_table_association" "michael_nest_rt_association" {
  subnet_id     = aws_subnet.michael_nest_public_subnet.id
  route_table_id = aws_route_table.michael_nest_rt.id
}

resource "aws_eip" "michael_nest_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "michaelking-nat-eip"
  }
}
resource "aws_nat_gateway" "michael_nest_nat" {
  allocation_id = aws_eip.michael_nest_nat_eip.id
  subnet_id     = aws_subnet.michael_nest_public_subnet.id

  tags = {
    Name = "michaelking-nat-gateway"
  }
}

resource "aws_route_table" "michael_nest_private_rt" {
  vpc_id = aws_vpc.michael_nest_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.michael_nest_nat.id
  }

  tags = {
    Name = "michaelking-private-route-table"
  }
}

resource "aws_route_table_association" "michael_nest_private_rt_association" {
  subnet_id      = aws_subnet.michael_nest_private_subnet.id
  route_table_id = aws_route_table.michael_nest_private_rt.id
}