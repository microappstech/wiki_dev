| Type                   | What it finds                                | Popular tools                                         |
| ---------------------- | -------------------------------------------- | ----------------------------------------------------- |
| **SAST**               | Vulnerabilities in source code               | Semgrep, SonarQube, CodeQL, Checkmarx, Fortify        |
| **SCA**                | Vulnerable NuGet/npm/etc. dependencies       | OWASP Dependency-Check, Snyk, Mend, GitHub Dependabot |
| **DAST**               | Vulnerabilities in a running web application | OWASP ZAP, Burp Suite, Nuclei, Invicti                |
| **Pentest**            | Deeper manual/automated attack testing       | Burp Suite, OWASP ZAP, Nmap, Nuclei, Metasploit       |
| **Secrets scanning**   | Passwords/API keys/tokens in Git             | Gitleaks, TruffleHog, GitGuardian                     |
| **Container scanning** | Vulnerabilities in Docker images             | Trivy, Grype, Docker Scout                            |
| **IaC scanning**       | Terraform/Docker/K8s configuration issues    | Checkov, Trivy, tfsec                                 |
| **API security**       | REST/GraphQL/API vulnerabilities             | Burp Suite, OWASP ZAP, Postman, Nuclei                |
| **Dependency/runtime** | Known vulnerable packages/runtime            | Trivy, OWASP Dependency-Check, Snyk                   |
| **Network scanning**   | Open ports/services/configuration            | Nmap, Nessus, OpenVAS/Greenbone                       |
