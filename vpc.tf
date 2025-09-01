 #VPC creation
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {name="myvpc"}
}
# public SUBNET  creation
resource "aws_subnet" "PUBLIC" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
}

# private SUBNET creation with different cidr_block
resource "aws_subnet" "PRIVATE" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
}

#  Internet Gateway creation for public SUBNET 
# resource "aws_internet_gateway" "MYIGW" {
#   vpc_id = aws_vpc.myvpc.id
# }

#  ROUTE TABLE creation for public SUBNET  ,routes all traffic to IGW
resource "aws_route_table" "MYRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0" # Route all external traffic to the internet
    gateway_id = aws_internet_gateway.MYIGW.id
  }
}

# Create a Route Table for Private Subnet (routes traffic through NAT Gateway)
resource "aws_route_table" "CRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0" # Route all external traffic through the NAT Gateway
    gateway_id = aws_nat_gateway.mynat.id
  }
}

# Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "MYEIP" {
  domain = "vpc"
}

#  NAT Gateway in the Public SUBNET to enable internet access for Private Subnet
resource "aws_nat_gateway" "mynat" {
  subnet_id     = aws_subnet.PUBLIC.id         # NAT Gateway must be in a Public Subnet
  allocation_id = aws_eip.MYEIP.id             # Associate the Elastic IP with the NAT Gateway
  depends_on    = [aws_internet_gateway.MYIGW] # Ensure IGW is created first
}

output "myaz" {
  value = aws_subnet.PUBLIC.availability_zone
}