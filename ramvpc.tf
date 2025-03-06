resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "pub_sbnt" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        name = "my_pub_sbnt"
    }
}
resource "aws_subnet" "pvt_sbnt" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    tags = {
        name = "my_pvt_sbnt"
    }
}
resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
    tags = {
        name = "my_pub_rt"
    }
}
resource "aws_route_table_association" "pub_rt_assc" {
    subnet_id = aws_subnet.pub_sbnt
    route_table_id = aws_route_table.pub_rt.id
}
resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.my_ngw.id
    }
    tags = {
        name = "my_pvt_rt"
    }
}
resource "aws_route_table_association" "pvt_rt_assc"{
    subnet_id = aws_subnet.pvt_sbnt.id
    route_table_id = aws_route_table.pvt_rt.id
}
resource "aws_security_group" "pub_sg" {
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name = "pub_sg"
    }
}
resource "aws_security_group" "pvt_sg" {
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name = "pvt_sg"
    }
}
resource "aws_instance" "pub_ec2" {
    subnet_id = aws_subnet.pub_sbnt
    ami = "ami-0d682f26195e9ec0f"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.pub_sg.id]
    tags = {
        "Name"= "my_pub_ec2"
    }
}
resource "aws_instance" "pvt_ec2" {
    subnet_id = aws_subnet.pvt_sbnt
    ami = "ami-0d682f26195e9ec0f"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.pvt_sg.id]
    tags = {
        "Name"= "my_pvt_ec2"
    }
}
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        name = "my_igw"
    }
}
resource "aws_eip" "my_eip" {
    vpc = true
}
resource "aws_nat_gateway" "my_ngw" {
    subnet_id = aws_subnet.pub_sbnt.id
    allocation_id = aws_eip.my_eip.id
    tags = {
        name = "my_ngw"
    }
}
