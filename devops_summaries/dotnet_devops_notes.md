# .NET DevOps Notes — Senior Summary & Commands

Core CLI commands:

```
dotnet restore
dotnet build -c Release
dotnet test -c Release --logger trx
dotnet publish -c Release -o out
```

Docker / container patterns:
- Multi-stage Dockerfile (build with SDK, runtime image for final):

```
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

Versioning & artifacts:
- Use `dotnet pack` for NuGet packages; sign packages if required.
- Use semantic versioning; embed build metadata for reproducibility.

NuGet & feeds:
- Set up internal NuGet feeds (Azure Artifacts, GitLab Packages) and cache in CI agents.

Testing & coverage:
- Run unit tests and publish test results and code coverage as pipeline artifacts.
- For integration tests, prefer ephemeral environments (containers or Kubernetes namespaces).

Performance and diagnostics:
- Enable collection of app metrics (Prometheus exporters or Application Insights).
- Capture dump/core on failures; use dotnet-dump or ProcDump on Windows.

CI pipeline tips:
- Cache `~/.nuget/packages` or use the pipeline cache to speed restores.
- Separate build, test, publish stages; require signed commits for release builds.

Runtime configuration:
- Use environment variables or mounted ConfigMaps/Secrets for configuration; avoid in-image secrets.
- Set `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1` in container images if you want invariant globalization.

Security:
- Run containers non-root where possible; scan images with Trivy.
- Keep SDK off runtime images; use multi-stage builds to reduce attack surface.
