```
Azure DevOps Pipeline
        |
        | HTTPS
        v
Azure DevOps
        |
        | assigns job
        v
Your Windows PC
┌──────────────────────────────┐
│ Azure DevOps Self-Hosted     │
│ Agent                        │
│                              │
│ .NET SDK                     │
│ Git                          │
│ SonarScanner                 │
│ Node.js (if needed)          │
│ Docker (if needed)           │
└──────────────────────────────┘
```