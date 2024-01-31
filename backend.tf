terraform {
  backend "s3" {
    bucket = "srgrcp-terraform-00"
    key    = "terraform/kubernetes-iac.tfstate"
    region = "us-east-1"
  }
}
