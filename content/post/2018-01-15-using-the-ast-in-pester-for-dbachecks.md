---
title: "Using the AST in Pester for dbachecks"
date: "2018-01-15" 
categories:
  - dbatools
  - dbachecks
  - Blog
  - PowerShell

tags:
  - dbachecks
  - dbatools
  - pester
  - AST
  - SQLBits


image: assets/uploads/2018/01/02-Pester-results-1.png
---
TagLine – My goal – Chrissy will appreciate Unit Tests one day 🙂

[Chrissy has written about dbachecks](https://dbatools.io/new-module-coming-soon/) the new up and coming community driven open source PowerShell module for SQL DBAs to validate their SQL Server estate. we have taken some of the ideas that we have presented about a way of using [dbatools](http://dbatools.io) with [Pester](https://github.com/Pester/Pester) to validate that everything is how it should be and placed them into a meta data driven framework to make things easy for anyone to use. It is looking really good and I am really excited about it. It will be released very soon.

Chrissy and I will be doing a pre-con at [SQLBits](http://sqlbits.com) where we will talk in detail about how this works. [You can find out more and sign up here](http://sqlbits.com/information/event17/Reliable_Repeatable__Automated_PowerShell_for_DBAs/trainingdetails.aspx)

[Cláudio Silva](https://claudioessilva.eu/) has improved my [PowerBi For Pester](https://blog.robsewell.com/a-pretty-powerbi-pester-results-template-file/) file and made it beautiful and whilst we were discussing this we found that if the Pester Tests were not formatted correctly the Power Bi looked … well rubbish to be honest! Chrissy asked if we could enforce some rules for writing our Pester tests.

The rules were

The Describe title should be in double quotes  
The Describe should use the plural Tags parameter  
The Tags should be singular  
The first Tag should be a unique tag in Get-DbcConfig  
The context title should end with $psitem  
The code should use Get-SqlInstance or Get-ComputerName  
The Code should use the forEach method  
The code should not use $_  
The code should contain a Context block

She asked me if I could write the Pester Tests for it and this is how I did it. I needed to look at the Tags parameter for the Describe. It occurred to me that this was a job for the Abstract Syntax Tree (AST). I don’t know very much about the this but I sort of remembered reading a blog post by [Francois-Xavier Cat about using it with Pester](http://www.lazywinadmin.com/2016/08/powershellpester-make-sure-your.html) so I went and read that and [found an answer on Stack Overflow](https://stackoverflow.com/questions/39909021/parsing-powershell-script-with-ast) as well. These looked just like what I needed so I made use of them. Thank you very much to Francois-Xavier and wOxxOm for sharing.

The first thing I did was to get the Pester Tests which we have located in a checks folder and loop through them and get the content of the file with the Raw parameter

    Context "$($_.Name) - Checking Describes titles and tags" {

Then I decided to look at the Describes using the method that wOxxOm (I know no more about this person!) showed.

    $Describes = \[Management.Automation.Language.Parser\]    ::ParseInput($check, \[ref\]$tokens, \[ref\]$errors).
    FindAll(\[Func\[Management.Automation.Language.Ast, bool\]\] {
            param($ast)
            $ast.CommandElements -and
            $ast.CommandElements\[0\].Value -eq 'describe'
        }, $true) |
        ForEach {
        $CE = $_.CommandElements
        $secondString = ($CE |Where { $_.StaticType.name -eq     'string' })\[1\]
        $tagIdx = $CE.IndexOf(($CE |Where ParameterName -eq'Tags')    ) + 1
        $tags = if ($tagIdx -and $tagIdx -lt $CE.Count) {
            $CE\[$tagIdx\].Extent
        }
        New-Object PSCustomObject -Property @{
            Name = $secondString
            Tags = $tags
        }
    }

As I understand it, this code is using the Parser on the $check (which contains the code from the file) and finding all of the Describe commands and creating an object of the title of the Describe with the StaticType equal to String and values from the Tag parameter.

When I ran this against the database tests file I got the following results

![](https://blog.robsewell.com/assets/uploads/2018/01/01-describes-1.png)

Then it was a simple case of writing some tests for the values

    @($describes).Foreach{
        $title = $PSItem.Name.ToString().Trim('"').Trim('''')
        It "$title Should Use a double quote after the Describe" {
            $PSItem.Name.ToString().Startswith('"')| Should be     $true
            $PSItem.Name.ToString().Endswith('"')| Should be $true
        }
        It "$title should use a plural for tags" {
            $PsItem.Tags| Should Not BeNullOrEmpty
        }
        # a simple test for no esses apart from statistics and     Access!!
        if ($null -ne $PSItem.Tags) {
            $PSItem.Tags.Text.Split(',').Trim().Where{($_ -ne     '$filename') -and ($_ -notlike '\*statistics\*') -and     ($_ -notlike '\*BackupPathAccess\*') }.ForEach{
                It "$PsItem Should Be Singular" {
                    $_.ToString().Endswith('s')| Should Be $False
                }
            }
            It "The first Tag Should Be in the unique Tags     returned from Get-DbcCheck" {
                $UniqueTags -contains $PSItem.Tags.Text.Split(',')    \[0\].ToString()| Should Be $true
            }
        }
        else {
            It "You haven't used the Tags Parameter so we can't     check the tags" {
                $false| Should be $true
            }
        }
    }

The Describes variable is inside @() so that if there is only one the ForEach Method will still work. The unique tags are returned from our command Get-DbcCheck which shows all of the checks. We will have a unique tag for each test so that they can be run individually.

Yes, I have tried to ensure that the tags are singular by ensuring that they do not end with an s (apart from statistics) and so had to not check  BackupPathAccess and statistics. Filename is a variable that we add to each Describe Tags so that we can run all of the tests in one file. I added a little if block to the Pester as well so that the error if the Tags parameter was not passed was more obvious

I did the same with the context blocks as well

    Context "$($_.Name) - Checking Contexts" {
        ## Find the Contexts
        $Contexts = \[Management.Automation.Language.Parser\]    ::ParseInput($check, \[ref\]$tokens, \[ref\]$errors).
        FindAll(\[Func\[Management.Automation.Language.Ast, bool\]    \] {
                param($ast)
                $ast.CommandElements -and
                $ast.CommandElements\[0\].Value -eq 'Context'
            }, $true) |
            ForEach {
            $CE = $_.CommandElements
            $secondString = ($CE |Where { $_.StaticType.name -eq     'string' })\[1\]
            New-Object PSCustomObject -Property @{
                Name = $secondString
            }
        }
        @($Contexts).ForEach{
            $title = $PSItem.Name.ToString().Trim('"').Trim('''')
            It "$Title Should end with `$psitem So that the     PowerBi will work correctly" {
                $PSItem.Name.ToString().Endswith('psitem"')|     Should Be $true
            }
        }
    }

This time we look for the Context command and ensure that the string value ends with psitem as the PowerBi parses the last value when creating columns

Finally I got all of the code and check if it matches some coding standards

    Context "$($_.Name) - Checking Code" {
        ## This just grabs all the code
        $AST = \[System.Management.Automation.Language.Parser\]    ::ParseInput($Check, \[ref\]$null, \[ref\]$null)
        $Statements = $AST.EndBlock.statements.Extent
        ## Ignore the filename line
        @($Statements.Where{$_.StartLineNumber -ne 1}).ForEach{
            $title = \[regex\]::matches($PSItem.text, "Describe(.    *)-Tag").groups\[1\].value.Replace('"', '').Replace    ('''', '').trim()
            It "$title Should Use Get-SqlInstance or     Get-ComputerName" {
                ($PSItem.text -Match 'Get-SqlInstance') -or     ($psitem.text -match 'Get-ComputerName')| Should     be $true
            }
            It "$title Should use the ForEach Method" {
                ($Psitem.text -match 'Get-SqlInstance\\).ForEach    {') -or ($Psitem.text -match 'Get-ComputerName\\).    ForEach{')| Should Be $true# use the \ to escape     the )
        }
        It "$title Should not use `$_" {
            ($Psitem.text -match '$_')| Should Be $false
        }
        It "$title Should Contain a Context Block" {
            $Psitem.text -match 'Context'| Should Be $True
        }
    }

I trim the title from the Describe block so that it is easy to see where the failures (or passes) are with some regex and then loop through each statement apart from the first line to ensure that the code is using our internal commands Get-SQLInstance or Get-ComputerName to get information, that we are looping through each of those arrays using the ForEach method rather than ForEach-Object and using $psitem rather than $_ to reference the “This Item” in the array and that each Describe block has a context block.

This should ensure that any new tests that are added to the module follow the guidance we have set up on the Wiki and ensure that the Power Bi results still look beautiful!

Anyone can run the tests using

    Invoke-Pester .\\tests\\Unit.Tests.ps1 -show Fails

before they create a Pull request and it looks like

![](https://blog.robsewell.com/assets/uploads/2018/01/02-Pester-results-1.png)

if everything is Green then they can submit their Pull Request 🙂 If not they can see quickly that something needs to be fixed. (fail early 🙂 )

![03 fails.png](https://blog.robsewell.com/assets/uploads/2018/01/03-fails.png)
