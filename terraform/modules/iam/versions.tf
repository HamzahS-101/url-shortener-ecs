# Added so TFLint's terraform_required_version and terraform_required_providers rules pass.
# Minimum versions only; the root module sets the exact pins.
terraform {
  required_version = ">= 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.72"
    }
  }
}
