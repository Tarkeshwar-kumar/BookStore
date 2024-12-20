provider "aws" {
    region = "ap-southeast-1"
}




resource "aws_vpc" "bookStore-eks-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name= "bookStore-eks-vpc"
    app= "booStore"
  }
}


resource "aws_subnet" "bookStore-eks-sg-a" {
  vpc_id = aws_vpc.bookStore-eks-vpc.id
  depends_on = [ aws_vpc.bookStore-eks-vpc ]
  cidr_block = "10.0.1.0/16"
}

resource "aws_subnet" "bookStore-eks-sg-b" {
  vpc_id = aws_vpc.bookStore-eks-vpc.id
  depends_on = [ aws_vpc.bookStore-eks-vpc ]
  cidr_block = "10.0.1.0/16"
}

resource "aws_eks_cluster" "bookStore-app-eks-cluster" {
  name = "bookStore-eks-cluster"
  role_arn = "to be define"
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids = [
        aws_subnet.bookStore-eks-sg-a.id,
        aws_subnet.bookStore-eks-sg-b.id
    ]
  }
  tags = {
    app= "bookStore"
    name= "bookStore-app-eks-cluster"
  }
  depends_on = [ aws_subnet.bookStore-eks-sg-a, aws_subnet.bookStore-eks-sg-b, aws_vpc.bookStore-eks-vpc ]
  
}