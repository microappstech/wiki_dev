# Azure DevOps Reference

## Project setup
- Create organization at dev.azure.com
- Create project: `Azure DevOps > New project`
- Set repository and board visibility

## Repos
- Clone: `git clone <repo-url>`
- Create branch: `git checkout -b feature/<name>`
- Push branch: `git push -u origin feature/<name>`

## Pipelines
- Use YAML pipeline in repo: `azure-pipelines.yml`
- Common pipeline triggers:
  `trigger: [main]`
  `pr: [main]`
- Job example:
  pool:
    vmImage: ubuntu-latest
  steps:
    - script: echo Build

## Boards and sprints
- Create iterations for sprint cadence.
- Add work items to backlog.
- Assign tasks to sprint iteration.
- Use board columns: New, Active, Resolved, Done.

## Artifacts
- Create feed: `Artifacts > New feed`
- Publish packages with Azure Pipelines.

## CLI reference
- Install extension: `az extension add --name azure-devops`
- Sign in: `az login`
- Set org: `az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>`
- List pipelines: `az pipelines list`
