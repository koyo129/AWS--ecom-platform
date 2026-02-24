terraform {
  backend "s3" {
    bucket = "awsinfraproj"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
