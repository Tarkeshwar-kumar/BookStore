provider "aws" {
    region = "ap-southeast-1"
    profile = "bookStore"
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
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "bookStore-eks-sg-b" {
  vpc_id = aws_vpc.bookStore-eks-vpc.id
  depends_on = [ aws_vpc.bookStore-eks-vpc ]
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}

resource "aws_iam_role" "bookStore-eks-control-plane-role" {
  name = "bookStore-eks-control-plane-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = [
            "eks.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_eks_cluster" "bookStore-app-eks-cluster" {
  name = "bookStore-eks-cluster"
  role_arn = aws_iam_role.bookStore-eks-control-plane-role.arn
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
  version = "1.32"
  depends_on = [ aws_subnet.bookStore-eks-sg-a, aws_subnet.bookStore-eks-sg-b, aws_vpc.bookStore-eks-vpc, aws_iam_role.bookStore-eks-control-plane-role ]
}