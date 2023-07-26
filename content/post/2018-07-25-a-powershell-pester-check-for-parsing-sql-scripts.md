---
title: "A PowerShell Pester Check for parsing SQL scripts"
date: "2018-07-25" 
categories:
  - Blog

tags:
  - dbatools
  - pester
  - PowerShell

---
I like [to write Pester checks](https://blog.robsewell.com/?s=pester) to make sure that all is as expected! This is just a quick post as much to help me remember this script 🙂

This is a quick Pester test I wrote to ensure that some SQL Scripts in a directory would parse so there was some guarantee that they were valid T-SQL. It uses the SQLParser.dll and because it was using a build server without SQL Server I have to load the required DLLs from the [dbatools](http://dbatools.io) module (Thank you dbatools 🙂 )

It simply runs through all of the .sql files and runs the parser against them and checks the errors. In the case of failures it will output where it failed in the error message in the failed Pester result as well.

You will need [dbatools module installed](http://dbatools.io/install) on the instance and at least [version 4 of the Pester module](https://github.com/pester/Pester/wiki/Installation-and-Updatehttps://github.com/pester/Pester/wiki/Installation-and-Update) as well

```
Describe "Testing SQL" {
    Context "Running Parser" {
        ## Load assembly
        $Parserdll = (Get-ChildItem 'C:\\Program Files\\WindowsPowerShell\\Modules\\dbatools' -Include Microsoft.SqlServer.Management.SqlParser.dll -Recurse)\[0\].FullName
        \[System.Reflection.Assembly\]::LoadFile($Parserdll) | Out-Null
        $TraceDll = (Get-ChildItem 'C:\\Program Files\\WindowsPowerShell\\Modules\\dbatools' -Include Microsoft.SqlServer.Diagnostics.Strace.dll -Recurse)\[0\].FullName
        \[System.Reflection.Assembly\]::LoadFile($TraceDll) | Out-Null
        $ParseOptions = New-Object Microsoft.SqlServer.Management.SqlParser.Parser.ParseOptions
        $ParseOptions.BatchSeparator = 'GO'
        $files = Get-ChildItem -Path $Env:Directory -Include *.sql -Recurse ## This variable is set as a Build Process Variable or put your path here
        $files.ForEach{
            It "$($Psitem.FullName) Should Parse SQL correctly" {
                $filename = $Psitem.FullName
                $sql = Get-Content -LiteralPath "$fileName"
                $Script = \[Microsoft.SqlServer.Management.SqlParser.Parser.Parser\]::Parse($SQL, $ParseOptions)
                $Script.Errors | Should -BeNullOrEmpty
            }
        }
    }
}
```
