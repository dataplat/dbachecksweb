---
title: "Using the PowerShell AST to find a ForEach Method"
date: "2018-08-16" 
categories:
  - Blog

tags:
  - ast
  - automation
  - dbachecks
  - pester
  - PowerShell


image: assets/uploads/2018/08/server.png

---
In [dbachecks](http://dbachecks.io) we enable people to see what checks are available by running Get-DbcCheck. This gives a number of properties including the ‘type’ of check. This refers to the configuration item or parameter that is required to have a value for this check to run.

For example – Any check to do with SQL Agent is of type Sqlinstance because it requires an instance to be specified but a check for SPN is of type ComputerName because it requires a computer name to run.

Automation for the win
----------------------

Because I believe in automation I do not want to have to hard code these values anywhere but create them when the module is imported so we use a json file to feed Get-DbcCheck and populate the Json file when we import the module. This is done using the [method that I described here](/using-the-ast-in-pester-for-dbachecks/) and means that whenever a new check is added it is automatically available in Get-DbcCheck without any extra work.

We use code like this
```
## Parse the file with AST
$CheckFileAST = [Management.Automation.Language.Parser]::ParseInput($check, [ref]$null, [ref]$null)
## Old code we can use the describes
$Describes = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
        param ($ast)
        $ast.CommandElements -and
        $ast.CommandElements[0].Value -eq 'describe'
    }, $true)

@($describes).ForEach{
    $groups += $filename
    $Describe = $_.CommandElements.Where{$PSItem.StaticType.name -eq 'string'}[1]
    $title = $Describe.Value
    $Tags = $PSItem.CommandElements.Where{$PSItem.StaticType.name -eq 'Object[]' -and $psitem.Value -eq $null}.Extent.Text.ToString().Replace(', $filename', '')
    # CHoose the type
    if ($Describe.Parent -match "Get-Instance") {
        $type = "Sqlinstance"
    }
    elseif ($Describe.Parent -match "Get-ComputerName" -or $Describe.Parent -match "AllServerInfo") {
        $type = "ComputerName"
    }
    elseif ($Describe.Parent -match "Get-ClusterObject") {
        $Type = "ClusteNode"
    }
```
First we parse the code with the AST and store that in the CheckFileAST variable, then we use the FindAll method to find any command elements that match “Describe” which conveniently gets our describes and then we can simply match the Parent object which holds some code to each function that we use to get our values to be passed to the tests `Get-ComputerName`, `Get-Instance`, `Get-ClusterObject` and set the type appropriately.

which when run against a check like this
```
Describe "Backup Path Access" -Tags BackupPathAccess, Storage, DISA, $filename {
    @(Get-Instance).ForEach{
        if ($NotContactable -contains $psitem) {
            Context "Testing Backup Path Access on $psitem" {
                It "Can't Connect to $Psitem" {
                    $false| Should -BeTrue -Because "The instance should be available to be connected to!"
                }
            }
        }
        else {
            Context "Testing Backup Path Access on $psitem" {
                $backuppath = Get-DbcConfigValue policy.storage.backuppath
                if (-not$backuppath) {
                    $backuppath = (Get-DbaDefaultPath-SqlInstance $psitem).Backup
                }
                It "can access backup path ($backuppath) on $psitem" {
                    Test-DbaSqlPath-SqlInstance $psitem -Path $backuppath| Should -BeTrue -Because 'The SQL Service account needs to have access to the backup path to backup your databases'
                }
            }
        }
    }
}
```
will find the describe block and get the title “Backup Path Access”  and the tags BackupPathAccess, Storage, DISA, $filename and then find the Get-Instance and set the type to SqlInstance

Until Rob breaks it!
--------------------

This has worked wonderfully well for 6 months or so of the life of dbachecks but this week I broke it!

The problem was the performance of the code. It is taking a long time to run the tests and I am looking at ways to improve this. I was looking at the Server.Tests file because I thought why not start with one of the smaller files.

It runs the following checks

- Server Power Plan Configuration  
- SPNs  
- Disk Space  
- Ping Computer  
- CPUPrioritisation  
- Disk Allocation Unit  
- Instance Connection

and it was looping through the computer names for each check like this
```
Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
    @(Get-ComputerName).ForEach{
    }
}
Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
    @(Get-Instance).ForEach{
    }
}
Describe "SPNs" -Tags SPN, $filename {
    @(Get-ComputerName).ForEach{
    }
}
Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
    @(Get-ComputerName).ForEach{
    }
}
Describe "Ping Computer" -Tags PingComputer, $filename {
    @(Get-ComputerName).ForEach{
    }
}
Describe "CPUPrioritisation" -Tags CPUPrioritisation, $filename {
    @(Get-ComputerName).ForEach{
    }
}
Describe "Disk Allocation Unit" -Tags DiskAllocationUnit, $filename {
    @(Get-ComputerName).ForEach{
    }
}
```
I altered it to have only one loop for the computer names like so
```
@(Get-ComputerName).ForEach{
    Describe "Server Power Plan Configuration" -Tags PowerPlan, $filename {
    }
    Describe "SPNs" -Tags SPN, $filename {
    }
    Describe "Disk Space" -Tags DiskCapacity, Storage, DISA, $filename {
    }
    Describe "Ping Computer" -Tags PingComputer, $filename {
    }
    Describe "CPUPrioritisation" -Tags CPUPrioritisation, $filename {
    }
    Describe "Disk Allocation Unit" -Tags DiskAllocationUnit, $filename {
    }
}
Describe "Instance Connection" -Tags InstanceConnection, Connectivity, $filename {
    @(Get-Instance).ForEach{
    }
}
```
and immediately in testing my checks for the Server Tag decreased in time by about 60% 🙂

I was very happy.

Then I added it to the dbachecks module on my machine, loaded the module and realised that my Json file for `Get-DbcCheck `was no longer being populated for the type because this line
```
elseif ($Describe.Parent-match"Get-ComputerName"-or$Describe.Parent-match"AllServerInfo")
```
was no longer true.

AST for other things
--------------------

So I googled [Management.Automation.Language.Ast](http://Management.Automation.Language.Ast) the first result lead me to [docs.microsoft](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.language.invokememberexpressionast?view=powershellsdk-1.1.0) There are a number of different language elements available there and I found [InvokeMemberExpressionAst](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.language.invokememberexpressionast?view=powershellsdk-1.1.0) which will let me find any methods that have been invoked, so now I can find the loops with
```
$ComputerNameForEach = $CheckFileAST.FindAll([Func[Management.Automation.Language.Ast, bool]] {
        param ($ast)
        $ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst]
    }, $true)
```
When I examined the object returned I could see that I could further limit the result to get only the method for Get-ComputerName and then if I choose the Extent I can get the code of that loop
```
## New code uses a Computer Name loop to speed up execution so need to find that as well
$ComputerNameForEach=$CheckFileAST.FindAll([Func[Management.Automation.Language.Ast,bool]] {
param ($ast)
$ast-is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and$ast.expression.Subexpression.Extent.Text-eq'Get-ComputerName'
}, $true).Extent
```
and now I can match the Tags to the type again :-)
```
if ($ComputerNameForEach-match$title) {
$type="ComputerName"
}
```
and now `Get-DbcCheck` is returning the right results and the checks are a little faster

[![](assets/uploads/2018/08/server.png)](assets/uploads/2018/08/server.png)

You can find [dbachecks on the PowerShell Gallery](http://powershellgallery.com/packages/dbachecks) or install it using

Install-Module dbachecks -Scope CurrentUser




