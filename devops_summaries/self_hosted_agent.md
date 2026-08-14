# Self-hosted Agents — Senior DevOps Summary

Purpose: concise checklist and commands for provisioning and operating self-hosted CI/CD agents (Windows/Linux) for .NET teams.

Key considerations:
- Authentication: create least-privilege PAT or service principal; rotate regularly.
- Isolation: run agents in containers (Podman/Docker) or dedicated VMs; avoid shared user contexts.
- Updates: automate agent binary updates and OS patching.
- Security: use managed identities where possible; restrict network egress; enable disk encryption.

Quick setup (Linux, interactive):

1. Create PAT in your CI system (Azure/GitLab/GitHub) with appropriate scope.
2. Download and configure agent:

```
mkdir myagent && cd myagent
curl -O https://vstsagentpackage.azureedge.net/agent/2.x/agents.tar.gz
tar zxvf agents.tar.gz
./config.sh --unattended --url <CI_URL> --auth pat --token <PAT> --pool default --work _work
```

3. Run as service (Linux systemd):

```
sudo ./svc.sh install
sudo ./svc.sh start
```

Windows (PowerShell):

```
.\config.cmd --unattended --url <CI_URL> --auth pat --token <PAT> --pool default --work _work
.\svc.sh install
.\svc.sh start
```

.NET-specific tips:
- Ensure `DOTNET_ROOT` and required runtimes are installed and accessible to the agent service user.
- For builds, use SDK images or multi-stage Docker `mcr.microsoft.com/dotnet/sdk` to keep hosts clean.
- Cache NuGet packages in a secured feed or local cache to speed pipelines.

Maintenance & diagnostics:
- Rotate tokens: schedule PAT rotation with automation.
- Logs: agent logs live in `_diag` and `_work/_temp`; collect for failures.
- Reprovision: treat agents as cattle — codify in IaC and recreate rather than repair.

Notes:
- Prefer ephemeral, containerized agents for sensitive builds. Use persistent agents only when necessary (hardware access, long-running tasks).
