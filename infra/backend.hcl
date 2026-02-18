# Optional; pipeline uses environments/dev/state.hcl for backend config
bucket         = "REPLACE_ME-state-bucket"
key            = "REPLACE_ME/terraform.tfstate"
region         = "eu-west-2"
dynamodb_table = "REPLACE_ME-state-lock"
encrypt        = true
