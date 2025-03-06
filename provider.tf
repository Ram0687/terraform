terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.85.0"
        }
    }
    backend "s3" {
        bucket = "ram.terraform.mini"
        key = "ram/terraform.tfstate"
        region = "ap-south-1"
    }
}
provider "aws" {
    region = "ap-south-1"
}

