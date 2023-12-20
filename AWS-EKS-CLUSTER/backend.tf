terraform {
  backend "s3" {
    bucket = "terraform-s3-bucket-qt"
    key    = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}