# Azure Security Reference

## Identity and access
- Enforce least privilege with RBAC.
- Assign roles at resource group scope, not subscription when possible.
- Use Azure AD groups for access control.
- Enable MFA for all users.

## Policy and compliance
- Enable Azure Policy.
- Apply built-in definitions: `Security Center` and `Allowed locations`.
- Use `az policy assignment create` for enforcement.

## Key Vault
- Create vault: `az keyvault create -g <rg> -n <vault>`
- Add secret: `az keyvault secret set --vault-name <vault> --name <name> --value <value>`
- Use managed identity access to Key Vault.

## Defender and security center
- Enable Microsoft Defender for Cloud.
- Review secure score recommendations.
- Enable just-in-time VM access.

## Monitoring
- Enable Azure Monitor and Log Analytics.
- Configure alerts for failed sign-in and policy compliance.

## Network security
- Use NSGs for subnet and NIC traffic control.
- Enforce private endpoints for storage and databases.
- Use Azure Firewall or Application Gateway with WAF.
