---
title: "Creating SQL Server Containers for versions 2012-2017"
date: "2018-05-10"
categories:
  - Blog

tags:
  - containers
  - dbafromthecold
  - dbatools
  - docker
  - powershell

---
I am working on my [dbatools](http://dbatools.io) and [dbachecks](http://dbachecks.io) presentations for [SQL Saturday Finland](http://www.sqlsaturday.com/735/eventhome.aspx), [SQLDays](https://sqlday.pl/), [SQL Saturday Cork](http://www.sqlsaturday.com/742/EventHome.aspx) and [SQLGrillen](https://sqlgrillen.de/) I want to show the two modules running against a number of SQL Versions so I have installed

*   2 Domain Controllers
*   2 SQL 2017 instances on Windows 2016 with an Availability Group and WideWorldImporters database
*   1 Windows 2016 jump box with all the programmes I need
*   1 Windows 2016 with containers

using a VSTS build and this set of [ARM templates and scripts](https://github.com/SQLDBAWithABeard/ARMTemplates/tree/master/DeployAlwaysOn)

I wanted to create containers running SQL2017, SQL2016, SQL2014 and SQL2012 and restore versions of the AdventureWorks database onto each one.

Move Docker Location
--------------------

I redirected my docker location from my `C:\` drive to my `E:\` drive so I didnt run out of space. I did this by creating a `daemon.json` file in `C:\ProgramData\docker\config` and adding

`{"data-root": "E:\containers"}`

and restarting the docker service which created folders like this

![01 - folders.png](https://blog.robsewell.com/assets/uploads/2018/05/01-folders.png)

Then I ran

`docker volume create SQLBackups`

to create a volume to hold the backups that I could mount on the containers

AdventureWorks Backups
----------------------

I downloaded [all the AdventureWorks backups from GitHub](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks) and copied them to `E:\containers\volumes\sqlbackups\_data`

`Get-ChildItem $Home\Downloads\AdventureWorks* | Copy-Item -Destination E:\containers\volumes\sqlbackups\_data`

Getting the Images
------------------

To download the [SQL 2017 image from the DockerHub](https://hub.docker.com/r/microsoft/mssql-server-windows-developer/) I ran

`docker pull microsoft/mssql-server-windows-developer:latest`

and waited for it to download and extract

I also needed the images for other versions. My good friend Andrew Pruski [b](https://dbafromthecold.com/) | [t](https://twitter.com/dbafromthecold) has versions available for us to use on [his Docker Hub ](https://hub.docker.com/u/dbafromthecold/) so it is just a case of running

```
docker pull dbafromthecold/sqlserver2016dev:sp1
docker pull dbafromthecold/sqlserver2014dev:sp2
docker pull dbafromthecold/sqlserver2012dev:sp4
```
and waiting for those to download and extract (This can take a while!)

Create the containers
---------------------

Creating the containers is as easy as

`docker run -d -p ExposedPort:InternalPort --name NAME -v VolumeName:LocalFolder -e sa\_password=THEPASSWORD -e ACCEPT\_EULA=Y IMAGENAME`

so all I needed to run to create 4 SQL containers one of each version was
```
docker run -d -p 15789:1433 --name 2017 -v sqlbackups:C:\SQLBackups -e sa\_password=PruskiIsSQLContainerMan! -e ACCEPT\_EULA=Y microsoft/mssql-server-windows-developer
docker run -d -p 15788:1433 --name 2016 -v sqlbackups:C:\SQLBackups -e sa\_password=PruskiIsSQLContainerMan! -e ACCEPT\_EULA=Y dbafromthecold/sqlserver2016dev:sp1
docker run -d -p 15787:1433 --name 2014 -v sqlbackups:C:\SQLBackups -e sa\_password=PruskiIsSQLContainerMan! -e ACCEPT\_EULA=Y dbafromthecold/sqlserver2014dev:sp2
docker run -d -p 15786:1433 --name 2012 -v sqlbackups:C:\SQLBackups -e sa\_password=PruskiIsSQLContainerMan! -e ACCEPT\_EULA=Y dbafromthecold/sqlserver2012dev:sp4
```
and just a shade over 12 seconds later I have 4 SQL instances ready for me 🙂

![02 - creating containers.png](https://blog.robsewell.com/assets/uploads/2018/05/02-creating-containers.png)

![03 - Containers at the ready.png](https://blog.robsewell.com/assets/uploads/2018/05/03-Containers-at-the-ready.png)

Storing Credentials
-------------------

This is not something I would do in a Production environment but I save my credentials using this method that Jaap Brasser [b](http://www.jaapbrasser.com/) | [t](https://twitter.com/jaap_brasser) [shared here](https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/)

`Get-Credential | Export-Clixml -Path $HOME\Documents\sa.cred`

which means that I can get the credentials in my PowerShell session (as long as it is the same user that created the file) using

`$cred = Import-Clixml $HOME\Documents\sa.cred`

Restoring the databases
-----------------------

I restored all of the AdventureWorks databases that each instance will support onto each instance, so 2017 has all of them whilst 2012 only has the 2012 versions.

First I needed to get the filenames of the backup files into a variable

`$filenames = (Get-ChildItem '\bearddockerhost\e$\containers\volumes\sqlbackups\_data').Name`

and the container connection strings, which are the hostname and the port number

`$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'`

then I can restore the databases using [dbatools](http://dbatools.io) using a switch statement on the version which I get with the NameLevel property of `Get-DbaSqlBuildReference`
```
$cred = Import-Clixml $HOME\Documents\sa.cred
$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$filenames = (Get-ChildItem '\bearddockerhost\e$\containers\volumes\sqlbackups\_data').Name
$containers.ForEach{
    $Container = $Psitem
    $NameLevel = (Get-DbaSqlBuildReference-SqlInstance $Container-SqlCredential $cred).NameLevel
    switch ($NameLevel) {
        2017 {
            Restore-DbaDatabase-SqlInstance $Container-SqlCredential $cred-Path C:\sqlbackups\ -useDestinationDefaultDirectories -WithReplace |Out-Null
            Write-Verbose-Message "Restored Databases on 2017"
        }
        2016 {
            $Files = $Filenames.Where{$PSitem -notlike '\*2017\*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase-SqlInstance $Container-SqlCredential $cred-Path $Files-useDestinationDefaultDirectories -WithReplace
            Write-Verbose-Message "Restored Databases on 2016"
        }
        2014 {
            $Files = $Filenames.Where{$PSitem -notlike '\*2017\*' -and $Psitem -notlike '\*2016\*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase-SqlInstance $Container-SqlCredential $cred-Path $Files-useDestinationDefaultDirectories -WithReplace
            Write-Verbose-Message "Restored Databases on 2014"
        }
        2012 {
            $Files = $Filenames.Where{$PSitem -like '\*2012\*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase-SqlInstance $Container-SqlCredential $cred-Path $Files-useDestinationDefaultDirectories -WithReplace
            Write-Verbose-Message "Restored Databases on 2012"
        }
        Default {}
    }
}
```
I need to create the file paths for each backup file by getting the correct backups and appending the names to `C:\SQLBackups` which is where the volume is mounted inside the container

As Get-DbaDatabase gives the container ID as the Computer Name I have highlighted each container below

![04 - databases.png](https://blog.robsewell.com/assets/uploads/2018/05/04-databases.png)

That is how easy it is to create a number of SQL containers of differing versions for your presentations or exploring needs

Happy Automating!



