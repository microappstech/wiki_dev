


```

---------------------------------------------------------------------------------------------------
│                    Code                          │                  Git Push                    │
│                                                  │                     │                        │
│ ├── 1. Secret Scan       → Gitleaks              │                     ▼                        │
│ │                                                │               🔑 Gitleaks                   │
│ ├── 2. SAST              → SonarQube             │                     │                        │
│ │                                                │                     ▼                        │
│ ├── 3. NuGet Scan        → dotnet vulnerable     │               🧑‍💻 SonarQube                   │
│ │                                                │                     │                        │
│ ├── 4. Build                                     │                     ▼                        │
│ │                                                │            📦 Dependency Scan                │
│ ├── 5. Unit Tests        → xUnit                 │                     │                        │
│ │                                                │                     ▼                        │
│ ├── 6. SBOM              → Syft                  │                   Build                      │
│ │                                                │                     │                        │
│ ├── 7. Docker Build                              │                     ▼                        │
│ │                                                │               xUnit Tests                    │
│ ├── 8. Docker Scan        → Trivy                │                     │                        │
│ │                                                │                     ▼                        │
│ ├── 9. Deploy to Staging                         │               Docker Build                   │
│ │                                                │                     │                        │
│ ├── 10. DAST             → OWASP ZAP             │                     ▼                        │
│ │                                                │                  🐳 Trivy                    │
│ └── 11. Manual Approval                          │                     │                        │
│                                                  │                     ▼                        │
│                    ↓                             │              Generate SBOM                   │
│                                                  │                     │                        │
│               Production                         │                     ▼                        │
│                                                  │                🚀 Staging                    │
│                                                  │                     │                        │
│                                                  │                     ▼                        │
│                                                  │               🌐 OWASP ZAP                   │
│                                                  │                     │                        │
│                                                  │                     ▼                        │
│                                                  │             🔐 Security Gate                 │
│                                                  │                     │                        │
│                                                  │               ┌─────┴─────┐                  │
│                                                  │               │           │                  │
│                                                  │              ❌           ✅                │
│                                                  │             STOP       Approval              │
│                                                  │                           │                  │
│                                                  │                           ▼                  │
│                                                  │                     🏭 Production            │
---------------------------------------------------------------------------------------------------
```


| Security                  | Tool                               | Priority    |
| ------------------------- | ---------------------------------- | ----------- |
| 🔑 Secrets                | **Gitleaks**                       | 🔴 Critical |
| 🧑‍💻 SAST                   | **SonarQube**                      | 🔴 Critical |
| 📦 NuGet vulnerabilities  | `dotnet list package --vulnerable` | 🔴 Critical |
| 🐳 Docker vulnerabilities | **Trivy**                          | 🔴 Critical |
| 🌐 Web/API security       | **OWASP ZAP**                      | 🔴 Critical |
| 📋 SBOM                   | **Syft**                           | 🟠 High     |
| 🏗️ Infrastructure         | **Trivy/Checkov**                  | 🟠 High     |
| 🧪 Tests                  | **xUnit**                          | 🔴 Critical |
