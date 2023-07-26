---
title: "Pester 4.2.0 has a Because…… because :-)"
date: "2018-01-18" 
categories:
  - dbatools
  - dbachecks
  - Blog
  - PowerShell

tags:
  - pester
  - PowerShell

image: assets/uploads/2018/01/01-Because-1.png
---
I was going through my demo for the [South Coast User Group meeting](http://meetu.ps/e/DdYV6/gHMdv/g) tonight and decided to add some details about the Because parameter available in the Pester pre-release version 4.2.0.

To install a pre-release version you need to get the latest  [PowerShellGet](https://go.microsoft.com/fwlink/?linkid=846259) module. This is pre-installed with PowerShell v6 but for earlier versions open PowerShell as administrator and run

    Install-Module  PowerShellGet

You can try out the Pester pre-release version (once you have the latest PowerShellGet) by installing it from the [PowerShell Gallery](http://powershellgallery.com) with

    Install-Module -Name Pester -AllowPrerelease -Force # -Scope CurrentUser # if not admin

There are a number of improvements as you can see in [the change log](https://github.com/pester/Pester/blob/master/CHANGELOG.md) I particularly like the

> *   Add -BeTrue to test for truthy values
> *   Add -BeFalse to test for falsy values

This release adds the Because parameter to the all assertions. This means that you can add a reason why the test has failed. As [JAKUB JAREŠ writes here](http://jakubjares.com/2017/12/19/using-because/)

*   Reasons force you think more
*   Reasons document your intent
*   Reasons make your TestCases clearer
*   So you can do something like this

    Describe "This shows the Because"{
        It "Should be true" {
            $false | Should -BeTrue -Because "The Beard said so"
        }
    }

Which gives an error message like this 🙂

![](https://blog.robsewell.com/assets/uploads/2018/01/01-Because-1.png)

As you can see the Expected gives the expected value and then your Because statement and then the actual result. Which means that you could write validation tests like

    Describe "My System" {
        Context "Server" {
            It "Should be using XP SP3" {
                (Get-CimInstance -ClassName win32_operatingsystem)    .Version | Should -Be '5.1.2600' -Because "We     have failed to bother to update the App and it     only works on XP"
            }
            It "Should be running as rob-xps\\mrrob" {
                whoami | Should -Be 'rob-xps\\mrrob' -Because     "This is the user with the permissions"
            }
            It "Should have SMB1 enabled" {
                (Get-SmbServerConfiguration).EnableSMB1Protocol |     Should -BeTrue -Because "We don't care about the     risk"
            }
        }
    }

and get a result like this

[![](https://blog.robsewell.com/assets/uploads/2018/01/02-example.png)](https://blog.robsewell.com/assets/uploads/2018/01/02-example.png)

Or if you were looking to validate your SQL Server you could write something like this

    It "Backups Should have Succeeeded" {
        $Where = {$\_IsEnabled -eq $true -and $\_.Name -like     '\*databasebackup\*'}
        $Should = @{
            BeTrue = $true
            Because =  "WE NEED BACKUPS - OMG"
        }
        (Get-DbaAgentJob -SqlInstance $instance| Where-Object     $where).LastRunOutcome -NotContains 'Failed' | Should     @Should
    }

or maybe your security policies allow Windows Groups as logins on your SQL instances. You could easily link to the documentation and explain why this is important. This way you could build up a set of tests to validate your SQL Server is just so for your environment

    It "Should only have Windows groups as logins" {
        $Should = @{
            Befalse = $true
            Because = "Our Security Policies say we must only     have Windows groups as logins - See this document"
        }
        (Get-DbaLogin -SqlInstance $instance -WindowsLogins).    LoginType -contains 'WindowsUser' | Should @Should
    }

Just for fun, these would look like this

[![](https://blog.robsewell.com/assets/uploads/2018/01/03-for-fun.png)](https://blog.robsewell.com/assets/uploads/2018/01/03-for-fun.png)

and the code looks like

    $Instances = 'Rob-XPS', 'Rob-XPS\\Bolton'
    
    foreach ($instance in $Instances) {
        $Server, $InstanceName = $Instance.Split('/')
        if ($InstanceName.Length -eq 0) {$InstanceName =     'MSSSQLSERVER'}
    
        Describe "Testing the instance $instance" {
            Context "SQL Agent Jobs" {
                It "Backups Should have Succeeeded" {
                    $Where = {$\_IsEnabled -eq $true -and $\_.    Name -like '\*databasebackup\*'}
                    $Should = @{
                        BeTrue = $true
                        Because =  "WE NEED BACKUPS - OMG "
                    }
                    (Get-DbaAgentJob -SqlInstance $instance|     Where-Object $where).LastRunOutcome     -NotContains 'Failed' | Should @Should
                }
                Context "Logins" {
                    It "Should only have Windows groups as     logins" {
                        $Should = @{
                            Befalse = $true
                            Because = "Our Security Policies say     we must only have Windows groups as     logins - See this document"
                        }
                        (Get-DbaLogin -SqlInstance $instance     -WindowsLogins).LoginType -contains     'WindowsUser' | Should @Should
                    }
                }
            }
        }
    }

This will be a useful improvement to Pester when it is released and enable you to write validation checks with explanations.

> Come and Learn Some PowerShell Magic* at [#SQLBits](https://twitter.com/hashtag/SQLBits?src=hash&ref_src=twsrc%5Etfw) with [@cl](https://twitter.com/cl?ref_src=twsrc%5Etfw) and I  
> Details [https://t.co/7OfK75e6Y1](https://t.co/7OfK75e6Y1)  
> Registration [https://t.co/RDSkPlfMMx](https://t.co/RDSkPlfMMx)  
> *PowerShell is not magic – it just might appear that way [pic.twitter.com/5czPzYR3QD](https://t.co/5czPzYR3QD)
> 
> — Rob Sewell (@sqldbawithbeard) [November 27, 2017](https://twitter.com/sqldbawithbeard/status/935143475418402816?ref_src=twsrc%5Etfw)

[Chrissy has written about dbachecks](https://dbatools.io/new-module-coming-soon/) the new up and coming community driven open source PowerShell module for SQL DBAs to validate their SQL Server estate. we have taken some of the ideas that we have presented about a way of using [dbatools](http://dbatools.io) with [Pester](https://github.com/Pester/Pester) to validate that everything is how it should be and placed them into a meta data driven framework to make things easy for anyone to use. It is looking really good and I am really excited about it. It will be released very soon.

Chrissy and I will be doing a pre-con at [SQLBits](http://sqlbits.com) where we will talk in detail about how this works. [You can find out more and sign up here](http://sqlbits.com/information/event17/Reliable_Repeatable__Automated_PowerShell_for_DBAs/trainingdetails.aspx)
