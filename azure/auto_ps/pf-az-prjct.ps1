param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [string]$Description = "",

    [string]$ConfigPath = "./config.json"
)

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

$Organization = $config.organization
$Pat          = $config.pat

if ([string]::IsNullOrWhiteSpace($Organization)) {
    throw "Azure DevOps organization is missing."
}

if ([string]::IsNullOrWhiteSpace($Pat)) {
    throw "Azure DevOps PAT is missing."
}

$ApiVersion = "7.1"

$BaseUrl = "https://dev.azure.com/$Organization"

$Token = [Convert]::ToBase64String(
    [Text.Encoding]::ASCII.GetBytes(":$Pat")
)

$Headers = @{
    Authorization = "Basic $Token"
    Accept        = "application/json"
}

$ProjectEncoded = [Uri]::EscapeDataString($ProjectName)

# ============================================================
# HELPERS
# ============================================================
function Invoke-AdoRest {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "POST", "PUT", "PATCH", "DELETE")]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [Alias("Uri")]
        [string]$Url,

        [object]$Body = $null,

        [string]$ContentType = "application/json"
    )

    $headers = @{
        Authorization = "Basic " + [Convert]::ToBase64String(
            [Text.Encoding]::ASCII.GetBytes(":$Pat")
        )
        Accept = "application/json"
    }

    $params = @{
        Method      = $Method
        Uri         = $Url
        Headers     = $headers
        ContentType = $ContentType
    }

    if ($null -ne $Body) {
        $params.Body = ConvertTo-Json -InputObject $Body -Depth 20 -Compress
    }

    Write-Host ""
    Write-Host "$Method $Url" -ForegroundColor Cyan

    try {
        return Invoke-RestMethod @params
    }
    catch {
        Write-Host ""
        Write-Host "Azure DevOps API request failed:" -ForegroundColor Red
        Write-Host $_.ErrorDetails.Message -ForegroundColor Red
        throw
    }
}

function Wait-Seconds {
    param(
        [int]$Seconds = 2
    )

    Start-Sleep -Seconds $Seconds
}

# ============================================================
# GET PROJECT
# ============================================================

function Get-AdoProject {

    $uri =
        "$BaseUrl/_apis/projects/" +
        "$ProjectEncoded" +
        "?api-version=$ApiVersion"

    try {
        return Invoke-AdoRest `
            -Method GET `
            -Uri $uri
    }
    catch {
        return $null
    }
}

# ============================================================
# CREATE PROJECT
# ============================================================

function Ensure-AdoProject {

    Write-Host ""
    Write-Host "Checking project..." -ForegroundColor Cyan

    $existing = Get-AdoProject

    if ($null -ne $existing) {

        Write-Host `
            "Project already exists: $ProjectName" `
            -ForegroundColor Yellow

        return $existing
    }

    Write-Host `
        "Creating project: $ProjectName" `
        -ForegroundColor Green

    $body = @{
        name        = $ProjectName
        description = $Description
        visibility  = "private"

        capabilities = @{
            versioncontrol = @{
                sourceControlType = "Git"
            }

            processTemplate = @{
                templateTypeId = $config.processTemplateId
            }
        }
    }

    $uri =
        "$BaseUrl/_apis/projects" +
        "?api-version=$ApiVersion"

    $operation = Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body

    Write-Host "Project creation queued." -ForegroundColor Green

    # Project creation is asynchronous.
    # Poll until it is available.
    for ($i = 0; $i -lt 60; $i++) {

        Wait-Seconds 2

        $project = Get-AdoProject

        if ($null -ne $project) {

            Write-Host `
                "Project is ready." `
                -ForegroundColor Green

            return $project
        }

        Write-Host "." -NoNewline
    }

    throw "Timed out waiting for project creation."
}

# ============================================================
# GET REPOSITORY
# ============================================================

function Get-AdoRepository {

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories" +
        "?api-version=$ApiVersion"

    $result = Invoke-AdoRest `
        -Method GET `
        -Uri $uri

    foreach ($repo in $result.value) {

        if ($repo.name -eq $RepositoryName) {
            return $repo
        }
    }

    return $null
}

# ============================================================
# CREATE REPOSITORY
# ============================================================

function Ensure-Repository {

    $existing = Get-AdoRepository

    if ($null -ne $existing) {

        Write-Host `
            "Repository already exists: $RepositoryName" `
            -ForegroundColor Yellow

        return $existing
    }

    Write-Host `
        "Creating repository: $RepositoryName" `
        -ForegroundColor Green

    $body = @{
        name = $RepositoryName

        project = @{
            id = $Project.id
        }
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories" +
        "?api-version=$ApiVersion"

    return Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body
}

# ============================================================
# GET REFS
# ============================================================

function Get-GitRefs {

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/refs" +
        "?filter=heads/&api-version=$ApiVersion"

    return Invoke-AdoRest `
        -Method GET `
        -Uri $uri
}

# ============================================================
# CREATE INITIAL COMMIT
# ============================================================

function Ensure-InitialCommit {

    $refs = Get-GitRefs

    if ($refs.count -gt 0) {

        Write-Host `
            "Repository already contains commits." `
            -ForegroundColor Yellow

        $master = $refs.value |
            Where-Object {
                $_.name -eq "refs/heads/master"
            }

        if ($null -ne $master) {
            return $master.objectId
        }

        return $refs.value[0].objectId
    }

    Write-Host `
        "Creating initial master commit..." `
        -ForegroundColor Green

    $zero =
        "0000000000000000000000000000000000000000"

    $body = @{
        refUpdates = @(
            @{
                name        = "refs/heads/master"
                oldObjectId = $zero
            }
        )

        commits = @(
            @{
                comment = "Initial project commit"

                changes = @(
                    @{
                        changeType = "add"

                        item = @{
                            path = "/README.md"
                        }

                        newContent = @{
                            content =
                                "# $ProjectName`n"
                            contentType = "rawtext"
                        }
                    }
                )
            }
        )
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/pushes" +
        "?api-version=$ApiVersion"

    $result = Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body

    return $result.commits[0].commitId
}

# ============================================================
# CREATE BRANCH
# ============================================================

function Ensure-Branch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BranchName,

        [Parameter(Mandatory = $true)]
        [string]$SourceCommitId
    )

    $refsUrl =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/refs" +
        "?filter=heads/$BranchName&api-version=$ApiVersion"

    $existing = Invoke-AdoRest `
        -Method GET `
        -Uri $refsUrl

    if ($existing.count -gt 0) {
        Write-Host `
            "Branch '$BranchName' already exists." `
            -ForegroundColor Yellow

        return
    }

    $refsUpdateUrl =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/refs" +
        "?api-version=$ApiVersion"

    $zero =
        "0000000000000000000000000000000000000000"

    $body = @(
        @{
            name        = "refs/heads/$BranchName"
            oldObjectId = $zero
            newObjectId = $SourceCommitId
        }
    )

    Write-Host `
        "Creating branch '$BranchName' from commit $SourceCommitId..." `
        -ForegroundColor Green

    Invoke-AdoRest `
        -Method POST `
        -Uri $refsUpdateUrl `
        -Body $body | Out-Null
}

# ============================================================
# DEFAULT BRANCH
# ============================================================

function Set-DefaultBranch {

    Write-Host `
        "Setting default branch to develop..." `
        -ForegroundColor Green

    $body = @{
        defaultBranch = "refs/heads/develop"
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)" +
        "?api-version=$ApiVersion"

    Invoke-AdoRest `
        -Method PATCH `
        -Uri $uri `
        -Body $body | Out-Null
}

# ============================================================
# MASTER BRANCH POLICY
# ============================================================

function Ensure-MasterPolicy {

    Write-Host `
        "Checking master branch policy..." `
        -ForegroundColor Cyan

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/policy/configurations" +
        "?api-version=$ApiVersion"

    $policies = Invoke-AdoRest `
        -Method GET `
        -Uri $uri

    foreach ($policy in $policies.value) {

        if (
            $policy.type.id `
            -eq "fa4e907d-c16b-4a4c-9dfa-4906e5d171dd"
        ) {

            foreach ($scope in $policy.settings.scope) {

                if (
                    $scope.repositoryId `
                    -eq $Repository.id `
                    -and
                    $scope.refName `
                    -eq "refs/heads/master"
                ) {

                    Write-Host `
                        "Master policy already exists." `
                        -ForegroundColor Yellow

                    return
                }
            }
        }
    }

    Write-Host `
        "Creating master branch protection..." `
        -ForegroundColor Green

    $body = @{
        isEnabled  = $true
        isBlocking = $true

        type = @{
            id =
                "fa4e907d-c16b-4a4c-9dfa-4906e5d171dd"
        }

        settings = @{
            minimumApproverCount = 1
            creatorVoteCounts    = $false

            scope = @(
                @{
                    repositoryId = $Repository.id
                    refName      = "refs/heads/master"
                    matchKind    = "exact"
                }
            )
        }
    }

    Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body | Out-Null
}

# ============================================================
# CLASSIFICATION NODES
# ============================================================

function Ensure-Area {

    param(
        [string]$AreaName
    )

    Write-Host `
        "Ensuring area: $AreaName" `
        -ForegroundColor Green

    $encoded =
        [Uri]::EscapeDataString($AreaName)

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/classificationnodes/Areas" +
        "/$encoded" +
        "?api-version=$ApiVersion"

    $parentUri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/classificationnodes/Areas" +
        "?api-version=$ApiVersion"

    try {

        Invoke-AdoRest `
            -Method GET `
            -Uri $uri | Out-Null

        Write-Host `
            "Area already exists: $AreaName" `
            -ForegroundColor Yellow

        return
    }
    catch {
    }

    $body = @{
        name = $AreaName
    }

    Invoke-AdoRest `
        -Method POST `
        -Uri $parentUri `
        -Body $body | Out-Null
}

function Ensure-Iteration {

    param(
        [string]$IterationName
    )

    Write-Host `
        "Ensuring iteration: $IterationName" `
        -ForegroundColor Green

    $encoded =
        [Uri]::EscapeDataString($IterationName)

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/classificationnodes/Iterations" +
        "/$encoded" +
        "?api-version=$ApiVersion"

    $parentUri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/classificationnodes/Iterations" +
        "?api-version=$ApiVersion"

    try {

        Invoke-AdoRest `
            -Method GET `
            -Uri $uri | Out-Null

        Write-Host `
            "Iteration already exists: $IterationName" `
            -ForegroundColor Yellow

        return
    }
    catch {
    }

    $body = @{
        name = $IterationName
    }

    Invoke-AdoRest `
        -Method POST `
        -Uri $parentUri `
        -Body $body | Out-Null
}

# ============================================================
# PIPELINE YAML
# ============================================================

$PipelineYaml = @"
trigger:
- develop

pool:
  vmImage: ubuntu-latest

steps:
- script: echo "Hello from Azure DevOps!"
  displayName: "Test automation"
"@

# ============================================================
# ADD PIPELINE YAML TO DEVELOP
# ============================================================

function Ensure-PipelineYaml {

    Write-Host `
        "Ensuring azure-pipelines-ci.yml..." `
        -ForegroundColor Green

    $refs = Get-GitRefs

    $develop = $refs.value |
        Where-Object {
            $_.name -eq "refs/heads/develop"
        }

    if ($null -eq $develop) {
        throw "develop branch does not exist."
    }

    $itemUri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/items" +
        "?path=/azure-pipelines-ci.yml" +
        "&versionDescriptor.version=develop" +
        "&versionDescriptor.versionType=branch" +
        "&api-version=$ApiVersion"

    try {

        Invoke-AdoRest `
            -Method GET `
            -Uri $itemUri | Out-Null

        Write-Host `
            "Pipeline YAML already exists." `
            -ForegroundColor Yellow

        return
    }
    catch {
    }

    $body = @{
        refUpdates = @(
            @{
                name =
                    "refs/heads/develop"

                oldObjectId =
                    $develop.objectId
            }
        )

        commits = @(
            @{
                comment =
                    "Add Azure Pipelines CI configuration"

                changes = @(
                    @{
                        changeType = "add"

                        item = @{
                            path =
                                "/azure-pipelines-ci.yml"
                        }

                        newContent = @{
                            content = $PipelineYaml
                            contentType = "rawtext"
                        }
                    }
                )
            }
        )
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/git/repositories/" +
        "$($Repository.id)/pushes" +
        "?api-version=$ApiVersion"

    try {

        Invoke-AdoRest `
            -Method POST `
            -Uri $uri `
            -Body $body | Out-Null
    }
    catch {

        # File may already exist.
        Write-Host `
            "YAML may already exist. Continuing..." `
            -ForegroundColor Yellow
    }
}

# ============================================================
# PIPELINE
# ============================================================

function Get-Pipeline {

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/pipelines" +
        "?api-version=$ApiVersion"

    $result = Invoke-AdoRest `
        -Method GET `
        -Uri $uri

    return $result.value |
        Where-Object {
            $_.name -eq $PipelineName
        } |
        Select-Object -First 1
}

function Ensure-Pipeline {

    $existing = Get-Pipeline

    if ($null -ne $existing) {

        Write-Host `
            "Pipeline already exists: $PipelineName" `
            -ForegroundColor Yellow

        return $existing
    }

    Write-Host `
        "Creating pipeline: $PipelineName" `
        -ForegroundColor Green

    $body = @{
        name = $PipelineName

        configuration = @{
            type = "yaml"

            path =
                $config.pipeline.yamlPath

            repository = @{
                id   = $Repository.id
                type = "azureReposGit"
            }
        }
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/pipelines" +
        "?api-version=$ApiVersion"

    return Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body
}

# ============================================================
# WORK ITEMS
# ============================================================

function New-WorkItem {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host `
        "Creating $Type : $Title" `
        -ForegroundColor Green

    $operations = @(
        @{
            op    = "add"
            path  = "/fields/System.Title"
            value = $Title
        }
    )

    $encodedType =
        [Uri]::EscapeDataString($Type)

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/workitems/" +
        "`$$encodedType" +
        "?api-version=$ApiVersion"

    return Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $operations `
        -ContentType "application/json-patch+json"
}

function Find-WorkItem {

    param(
        [string]$Type,
        [string]$Title
    )

    $wiql = @"
SELECT
    [System.Id]
FROM WorkItems
WHERE
    [System.TeamProject] = '$ProjectName'
    AND [System.WorkItemType] = '$Type'
    AND [System.Title] = '$Title'
"@

    $body = @{
        query = $wiql
    }

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/wiql" +
        "?api-version=$ApiVersion"

    $result = Invoke-AdoRest `
        -Method POST `
        -Uri $uri `
        -Body $body

    if ($result.workItems.Count -gt 0) {

        return $result.workItems[0].id
    }

    return $null
}

function Ensure-WorkItem {

    param(
        [string]$Type,
        [string]$Title
    )

    $existing =
        Find-WorkItem `
            -Type $Type `
            -Title $Title

    if ($null -ne $existing) {

        Write-Host `
            "$Type already exists: $Title (#$existing)" `
            -ForegroundColor Yellow

        return $existing
    }

    $item =
        New-WorkItem `
            -Type $Type `
            -Title $Title

    return $item.id
}

# ============================================================
# LINK WORK ITEMS
# ============================================================

function Link-WorkItems {

    param(
        [int]$ParentId,
        [int]$ChildId
    )

    Write-Host `
        "Linking #$ParentId -> #$ChildId" `
        -ForegroundColor DarkCyan

    $organizationUrl =
        "https://dev.azure.com/$Organization"

    $childUrl =
        "$organizationUrl/$ProjectEncoded/" +
        "_apis/wit/workItems/$ChildId"

    $operations = @(
        @{
            op   = "add"
            path = "/relations/-"

            value = @{
                rel = "System.LinkTypes.Hierarchy-Forward"
                url = $childUrl
            }
        }
    )

    $uri =
        "$BaseUrl/$ProjectEncoded/_apis/wit/workitems/" +
        "$ParentId" +
        "?api-version=$ApiVersion"

    Invoke-AdoRest `
        -Method PATCH `
        -Uri $uri `
        -Body $operations `
        -ContentType "application/json-patch+json" |
        Out-Null
}

# ============================================================
# MAIN
# ============================================================

Write-Host ""
Write-Host "========================================" `
    -ForegroundColor Cyan

Write-Host " Azure DevOps Project Provisioner" `
    -ForegroundColor Cyan

Write-Host "========================================" `
    -ForegroundColor Cyan

# Repository name
$RepositoryName = $config.repositoryName

if ([string]::IsNullOrWhiteSpace($RepositoryName)) {
    $RepositoryName = $ProjectName
}

# Pipeline name
$PipelineName = $config.pipeline.name

if ([string]::IsNullOrWhiteSpace($PipelineName)) {
    $PipelineName = "$ProjectName CI"
}

# ------------------------------------------------------------
# 1. PROJECT
# ------------------------------------------------------------

$Project = Ensure-AdoProject

# ------------------------------------------------------------
# 2. REPOSITORY
# ------------------------------------------------------------

$Repository = Ensure-Repository

# ------------------------------------------------------------
# 3. INITIAL COMMIT
# ------------------------------------------------------------

$InitialCommit =
    Ensure-InitialCommit

# ------------------------------------------------------------
# 4. DEVELOP
# ------------------------------------------------------------

Ensure-Branch `
    -BranchName "develop" `
    -SourceCommit $InitialCommit

# ------------------------------------------------------------
# 5. DEFAULT BRANCH
# ------------------------------------------------------------

Set-DefaultBranch

# ------------------------------------------------------------
# 6. MASTER POLICY
# ------------------------------------------------------------

Ensure-MasterPolicy

# ------------------------------------------------------------
# 7. AREAS
# ------------------------------------------------------------

foreach ($area in $config.areas) {

    Ensure-Area `
        -AreaName $area
}

# ------------------------------------------------------------
# 8. ITERATIONS
# ------------------------------------------------------------

foreach ($iteration in $config.iterations) {

    Ensure-Iteration `
        -IterationName $iteration
}

# ------------------------------------------------------------
# 9. PIPELINE YAML
# ------------------------------------------------------------

Ensure-PipelineYaml

# ------------------------------------------------------------
# 10. PIPELINE
# ------------------------------------------------------------

$Pipeline = Ensure-Pipeline

# ------------------------------------------------------------
# 11. EPIC
# ------------------------------------------------------------

$EpicId =
    Ensure-WorkItem `
        -Type $config.workItems.epicType `
        -Title $ProjectName

# ------------------------------------------------------------
# 12. FEATURE
# ------------------------------------------------------------

$FeatureId =
    Ensure-WorkItem `
        -Type $config.workItems.featureType `
        -Title "Application Development"

Link-WorkItems `
    -ParentId $EpicId `
    -ChildId $FeatureId

# ------------------------------------------------------------
# 13. UNIT TESTS
# ------------------------------------------------------------

$UnitTestsId =
    Ensure-WorkItem `
        -Type $config.workItems.unitTestsType `
        -Title "Unit Tests"

Link-WorkItems `
    -ParentId $EpicId `
    -ChildId $UnitTestsId

# ------------------------------------------------------------
# 14. SECURITY
# ------------------------------------------------------------

$SecurityId =
    Ensure-WorkItem `
        -Type $config.workItems.securityType `
        -Title "Security"

Link-WorkItems `
    -ParentId $EpicId `
    -ChildId $SecurityId

# ============================================================
# RESULT
# ============================================================

Write-Host ""
Write-Host "========================================" `
    -ForegroundColor Green

Write-Host " Provisioning completed!" `
    -ForegroundColor Green

Write-Host "========================================" `
    -ForegroundColor Green

Write-Host ""
Write-Host "Project:" $ProjectName
Write-Host "Repository:" $Repository.name
Write-Host "Default branch: develop"
Write-Host "Protected branch: master"
Write-Host "Pipeline:" $Pipeline.name
Write-Host "Epic ID:" $EpicId
Write-Host "Feature ID:" $FeatureId
Write-Host "Unit Tests ID:" $UnitTestsId
Write-Host "Security ID:" $SecurityId

Write-Host ""
Write-Host "Azure DevOps URL:"
Write-Host "https://dev.azure.com/$Organization/$ProjectEncoded"
