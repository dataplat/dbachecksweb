---
title: "dbachecks – Improved Descriptions"
date: "2018-05-19" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - dbatools


image: assets/uploads/2018/05/04-get-dbacheck-ogv.png

---
With the latest release of [dbachecks](https://www.powershellgallery.com/packages/dbachecks/1.1.128) we have added a new check for testing that foreign keys and constraints are trusted thanks to Cláudio Silva [b](https://claudioessilva.eu/) | [t](https://twitter.com/ClaudioESSilva)

To get the latest release you will need to run

    Update-Module dbachecks

You should do this regularly as we release [new improvements frequently](/version-update-code-signing-and-publishing-to-the-powershell-gallery-with-vsts/).

We have also added better descriptions for the checks which was suggested by the same person who inspired the previous improvement [I blogged about here](/dbachecks-which-configuration-item-for-which-check/)

Instead of the description just being the name of the check it is now more of a, well, a description really 🙂

This has the added effect that it means that just running Get-DbcCheck in the command line will not fit all of the information on a normal screen

[![01 - get-dbccheck.png](assets/uploads/2018/05/01-get-dbccheck.png)](assets/uploads/2018/05/01-get-dbccheck.png)

You can use the [Format-Table](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-5.1) command (or its alias ft at the command line) and select the properties to display using

    Get-DbcCheck | ft -Property UniqueTag, Description -Wrap

[![02 - get-dbccheck format table](assets/uploads/2018/05/02-get-dbccheck-format-table.png)](assets/uploads/2018/05/02-get-dbccheck-format-table.png)

or you can use [Format-List ](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-list?view=powershell-5.1)(or its alias fl at the command line)

    Get-DbcCheck | fl

[![03 get-dbccheck format list.png](assets/uploads/2018/05/03-get-dbccheck-format-list.png)](assets/uploads/2018/05/03-get-dbccheck-format-list.png)

Or you can use [Out-GridView](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-gridview?view=powershell-5.1) (or its alias ogv at the command line) (Incidentally, could you also thumbs up [this issue on Github](https://github.com/PowerShell/PowerShell/issues/3957) to get Out-GridView functionality in PowerShell 6)

    Get-DbcCheck | ogv

[![04 - get-dbacheck ogv](assets/uploads/2018/05/04-get-dbacheck-ogv.png)](assets/uploads/2018/05/04-get-dbacheck-ogv.png)

Happy Validating !






