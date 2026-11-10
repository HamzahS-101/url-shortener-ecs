terraform {
  backend "s3" {
    bucket       = "url-shortener-188735374190"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
