---
name: azure-devops
description: 'Work with Azure DevOps (ADO) — work items, boards, pipelines, PRs, repos. Prefer the `az devops` / `az boards` / `az repos` / `az pipelines` CLI over other approaches. USE FOR: listing/updating work items, querying the current sprint, checking builds, creating or reviewing PRs. Includes my default org/project/team.'
argument-hint: 'e.g. "list my work items this sprint"'
---

# Azure DevOps (ADO)

## When to Use
- Listing, querying, or updating work items / boards
- Checking pipelines and builds
- Creating or reviewing pull requests
- Any ADO task

## Prefer the CLI
Always use the Azure CLI DevOps commands (`az devops`, `az boards`, `az repos`, `az pipelines`) for ADO work. Only fall back to other approaches if the CLI can't do it.

## My Defaults
Use these unless the current repo or task clearly points to a different org/project/team.

| Setting | Value |
|---------|-------|
| Organization | `https://microsoft.visualstudio.com/` |
| Project | `Xbox` |
| Team | `TeamSainiSachin` (iteration path root `[Xbox]\TeamSainiSachin`) |

## Setup (run once)
```powershell
# Extension (if missing)
az extension add --name azure-devops
# Auth (opens browser)
az login
# Default org/project
az devops configure --defaults organization=https://microsoft.visualstudio.com/ project=Xbox
```

## Common Commands

List my work items in the current sprint:
```powershell
az boards query --wiql "SELECT [System.Id],[System.WorkItemType],[System.Title],[System.State],[System.IterationPath] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.IterationPath] = @CurrentIteration('[Xbox]\TeamSainiSachin') ORDER BY [System.ChangedDate] DESC" -o table
```

Show / update a work item:
```powershell
az boards work-item show --id <ID> -o table
az boards work-item update --id <ID> --state "Active"
```

Pipelines & PRs:
```powershell
az pipelines runs list --top 10 -o table
az repos pr list --status active -o table
```

## Creating Work Items
Default fields to set on new items:
`Microsoft.VSTS.Common.Release=<YYYY.MM>` `OSG.Product=Xbox Web` `OSG.ProductFamily=Xbox`, plus `--area`, `--iteration`, `--assigned-to`.

Deliverable:
```powershell
az boards work-item create --type "Deliverable" --title "<title>" --area "Xbox\Commerce\Store and Publishing Experiences\TeamSainiSachin" --iteration "Xbox\Monthly\<sprint>" --assigned-to "utsaxena@microsoft.com" --fields "Microsoft.VSTS.Scheduling.OriginalEstimate=<days>" "Microsoft.VSTS.Common.Release=2026.07" "OSG.Product=Xbox Web" "OSG.ProductFamily=Xbox" --query "id" -o tsv
```

Task — **`Microsoft.VSTS.CMMI.TaskType` is required** (use `Dev Task`), and always set **`OSG.RemainingDays` = OriginalEstimate** (remaining days defaults to 0 otherwise):
```powershell
az boards work-item create --type "Task" --title "<title>" --area "..." --iteration "..." --assigned-to "utsaxena@microsoft.com" --fields "Microsoft.VSTS.CMMI.TaskType=Dev Task" "Microsoft.VSTS.Scheduling.OriginalEstimate=<days>" "OSG.RemainingDays=<days>" "Microsoft.VSTS.Common.Release=2026.07" "OSG.Product=Xbox Web" "OSG.ProductFamily=Xbox" --query "id" -o tsv
```

Link a task to its parent:
```powershell
az boards work-item relation add --id <childId> --relation-type parent --target-id <parentId> -o none
```

## Notes
- Append `2>&1` to surface CLI errors in the terminal output.
- If `@CurrentIteration` fails, confirm the team's iteration path root matches the table above.
- In PowerShell, avoid `--query "fields.\"X.Y\""` (breaks quoting). Query full JSON and filter, or use `-o tsv` with a simple query like `--query "id"`.
- Run one `az` command (or a single-line loop) at a time; pasting large multi-line scripts into the terminal can get garbled.
