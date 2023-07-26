---
title: "How to run a PowerShell script file with Verbose, Confirm or WhatIf"
date: "2018-01-23" 
categories:
  - dbatools
  - dbachecks
  - Blog
  - PowerShell

tags:
  - pester
  - PowerShell
  - SQL Agent Jobs
  - confirm
  - verbose


image: assets/uploads/2018/01/02-Showing-the-results.png
---
Before you run a PowerShell command that makes a change to something you should check that it is going to do what you expect. You can do this by using the WhatIf parameter for commands that support it. For example, if you wanted to create a New SQL Agent Job Category you would use the [awesome dbatools module](http://dbatools.io) and write some code like this

    New-DbaAgentJobCategory -SqlInstance ROB-XPS -Category 'Backup'

before you run it, you can check what it is going to do using

    New-DbaAgentJobCategory -SqlInstance ROB-XPS -Category 'Backup' -WhatIf

which gives a result like this

![](https://blog.robsewell.com/assets/uploads/2018/01/01-Whatif.png)

This makes it easy to do at the command line but when we get confident with PowerShell we will want to write scripts to perform tasks using more than one command. So how can we ensure that we can check that those will do what we are expecting without actually running the script and see what happens? Of course, there are Unit and integration testing that should be performed using [Pester](https://blog.robsewell.com/writing-dynamic-and-random-tests-cases-for-pester/) when developing the script but there will still be occasions when we want to see what this script will do this time in this environment.

Lets take an example. We want to place our SQL Agent jobs into specific custom categories depending on their name. We might write a script like this

    <#
    .SYNOPSIS
    Adds SQL Agent Jobs to categories and creates the categories if needed
    
    .DESCRIPTION
    Adds SQL Agent Jobs to categories and creates the categories if needed. Creates
    Backup', 'Index', 'TroubleShooting','General Info Gathering' categories and adds
    the agent jobs depending on name to the category
    
    .PARAMETER Instance
    The Instance to run the script against
    #>
    
    Param(
        [string]$Instance
    )
    
    $Categories = 'Backup', 'Index','DBCC', 'TroubleShooting', 'General Info Gathering'
    
    $Categories.ForEach{
        ## Create Category if it doesnot exist
        If (-not  (Get-DbaAgentJobCategory -SqlInstance $instance -Category $PSItem)) {
            New-DbaAgentJobCategory -SqlInstance $instance -Category $PSItem -CategoryType LocalJob
        }
    }
    
    ## Get the agent jobs and iterate through them
    (Get-DbaAgentJob -SqlInstance $instance).ForEach{
        ## Depending on the name of the Job - Put it in a Job Category
        switch -Wildcard ($PSItem.Name) {
            '*DatabaseBackup*' { 
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category 'Backup'
            }
            '*Index*' { 
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category 'Index'
            }
            '*DatabaseIntegrity*' { 
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category 'DBCC'
            }
            '*Log SP_*' { 
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category 'TroubleShooting'
            }
            '*Collection*' { 
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category 'General Info Gathering'
            }
            ## Otherwise put it in the uncategorised category
            Default {
                Set-DbaAgentJob -SqlInstance $instance -Job $PSItem -Category '[Uncategorized (Local)]'
            }
        }
    }

You can run this script against any SQL instance by calling  it and passing an instance parameter from the command line like this

     & C:\temp\ChangeJobCategories.ps1 -instance ROB-XPS

If you wanted to see what would happen, you could edit the script and add the WhatIf parameter to every changing command but that’s not really a viable solution. What you can do is

    $PSDefaultParameterValues['*:WhatIf'] = $true

this will set all commands that accept WhatIf to use the WhatIf parameter. This means that if you are using functions that you have written internally you must ensure that you write your functions to use the common parameters

Once you have set the default value for WhatIf as above, you can simply call your script and see the WhatIf output

     & C:\temp\ChangeJobCategories.ps1 -instance ROB-XPS

which will show the WhatIf output for the script

![](https://blog.robsewell.com/assets/uploads/2018/01/02-Showing-the-results.png)

Once you have checked that everything is as you expected then you can remove the default value for the WhatIf parameter and run the script

    $PSDefaultParameterValues['*:WhatIf'] = $false
    & C:\temp\ChangeJobCategories.ps1 -instance ROB-XPS

and get the expected output

![](https://blog.robsewell.com/assets/uploads/2018/01/03-run-the-script-1.png)

If you wish to see the verbose output or ask for confirmation before any change you can set those default parameters like this

    ## To Set Verbose output
    $PSDefaultParameterValues['*:Verbose'] = $true
    
    ## To Set Confirm
    $PSDefaultParameterValues['*:Confirm'] = $true

and set them back by setting to false
