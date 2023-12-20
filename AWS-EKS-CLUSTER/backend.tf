terraform {
  backend "s3" {
    bucket = "terraformfiles-volume"
    key    = "eks/terraform.tfstate"
    region = "ap-northeast-3"
  }
}