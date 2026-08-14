# Infrastructure-as-Code (IaC) Cheatsheet — Senior DevOps Summary

Scope: Terraform, Bicep, ARM — patterns and commands for reliable infra deployments.

Terraform quick commands:

```
terraform init
terraform plan -out tfplan
terraform apply tfplan
terraform fmt -check
terraform validate
terraform state list
terraform destroy
```

Best practices:
- Remote state: use Azure Storage, S3+DynamoDB, or Terraform Cloud with state locking.
- Modules: create small reusable modules with clear inputs/outputs.
- Workspaces: use feature branches or per-environment workspaces carefully; prefer separate state per environment.
- Secret handling: never commit secrets; use KeyVault/Secrets Manager and reference via provider integrations.

Bicep / ARM notes:
- Compile & deploy: `bicep build main.bicep` then `az deployment group create --resource-group rg --template-file main.json`.
- Use parameter files per environment; keep modules for repeated patterns.

CI integration:
- Run `terraform fmt` and `validate` as PR checks.
- Plan outputs should be stored as artifacts and require approval for applies in production.

Idempotency & drift:
- Regular drift detection: schedule `terraform plan` checks and alert on diffs.

.NET-focused infra patterns:
- App Services vs AKS: choose App Service for PaaS simplicity, AKS for container orchestration.
- Storage: use managed identities to grant apps access to storage/accounts.

State recovery:
- Backup remote state; test restore procedures.
