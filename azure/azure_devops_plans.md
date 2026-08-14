# Azure DevOps Plans Comparison

## Overview
- Azure DevOps Services is billed per organization.
- Core features: Repos, Boards, Pipelines, Test Plans, Artifacts.
- Free tier is enough for small teams and basic CI/CD.
- Paid items are per user and per parallel job or storage.

## Free tier highlights
- 5 free Basic users per organization.
- Unlimited free stakeholders.
- Unlimited private Git repositories.
- Azure Boards: all basic work tracking included.
- Azure Repos: unlimited Git repos, 5 GB of storage per organization.
- Pipelines: 1 free Microsoft-hosted parallel job, 1,800 minutes per month.
- Artifacts: 2 GB free storage.
- Test Plans: no free seat except stakeholder view-only access.

## User licensing
- Stakeholder: free, limited to view/update work items, boards, and dashboards.
- Basic: free for first 5 users; paid beyond that.
- Basic + Test Plans: includes test management and execution.
- Visual Studio subscribers: may include Azure DevOps access depending on subscription.

## Pricing categories
- Basic user: paid after first 5 free users.
- Basic + Test Plans user: includes Test Plans and Basic access.
- Test Plans user: adds manual and exploratory test features.
- Azure Pipelines parallel jobs: paid beyond the free hosted job/minutes.
- Artifacts storage: paid beyond free 2 GB.

## Service comparison

### Repos
- Free: unlimited private/public Git repos.
- Free: unlimited collaborators.
- Paid: no additional cost for repo count.
- Good for: code hosting, branch policies, PRs, protected branches.

### Boards / sprint and backlog management
- Free: full Boards functionality for up to 5 Basic users.
- Free: unlimited stakeholders for backlog and board access.
- Paid: additional Basic licenses for team members.
- Good for: sprint planning, backlog, work item tracking, dashboards.

### Pipelines
- Free Microsoft-hosted parallel job: 1 job, 1,800 minutes / month.
- Free self-hosted parallel job: unlimited concurrency but depends on your hardware.
- Paid hosted parallel jobs: add more parallel jobs as needed.
- Paid minutes: if you need more than the free hosted minutes.
- Good for: CI/CD, YAML pipelines, multi-stage deployments.

### Test Plans
- Free: stakeholder can view tests but not execute or author.
- Paid: Basic + Test Plans user required for test case management.
- Good for: manual testing, exploratory testing, test suites.

### Artifacts
- Free: 2 GB storage and 2 GB pipeline caching.
- Paid: additional storage and package throughput.
- Good for: NuGet, npm, Maven, Python packages, feed management.

## Recommended plan by use case
- Small team (up to 5 developers): free Basic users + 1 hosted pipeline.
- Growing team: pay for additional Basic users as needed.
- Test-heavy team: use Basic + Test Plans for testers.
- Large CI/CD volume: add hosted parallel jobs or self-hosted agents.
- Package management: keep under 2 GB or add Artifacts storage.

## Practical notes
- Repository access does not require Azure subscription billing by itself.
- Pipelines and Artifacts usage can generate costs even on free Basic user plans.
- Use self-hosted agents when you need long-running builds or many parallel jobs.
- Keep free user count under 5 for a fully free organization.
- Use stakeholder access for product owners and business users.

## File reference
- `azure_devops.md` for workflow and CLI commands.
- `azure_devops_plans.md` for pricing and plan comparison.
