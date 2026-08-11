# Pushing the nuget into feed azure artifact
## Pack the nuget 
we can pack using the command 
    ``` dotnet pack -c release --output "C:\...." ```
or building the projects with this configuration and we are gonna get the pack in output buil 

```
### Configuration
  <PropertyGroup>
	<GeneratePackageOnBuild>true</GeneratePackageOnBuild>
	<Version>1.0.0</Version>
	<Authors>Owner</Authors>
	<Company>Owner</Company>
	<Description>The desc</Description>	  
  </PropertyGroup>
```

## Add source feed 
with replacing the {vars}
dotnet nuget add source "https://pkgs.dev.azure.com/{organization}/{project}/_packaging/{Feed}/nuget/v3/index.json" --name "AzureArtifacts"  --username "YOUR_AZURE_DEVOPS_USERNAME"  --password "YOUR_PAT"   --store-password-in-clear-text

## Push the packed into the feed connected
```
dotnet nuget push ".\xxxxx.1.0.0.nupkg" --source "AzureArtifacts" --api-key "YOUR_AZURE_DEVOPS_USERNAME"
```

