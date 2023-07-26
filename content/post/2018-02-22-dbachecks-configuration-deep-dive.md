---
title: "dbachecks – Configuration Deep Dive"
date: "2018-02-22" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - dbatools
  - pester
  - PowerShell


image: assets/uploads/2018/02/03-autocomplete.png

---
Today is the day that [we have announced dbachecks](/?p=8997)  a PowerShell module enabling you to validate your SQL Instances. You can read more about it [here where you can learn how to install it and see some simple use cases](/?p=8997)

108 Configurations
------------------

One of the things I have been talking about [in my presentation “Green is Good Red is Bad”](/write-your-first-pester-test-today/) is configuring Pester checks so that you do not have to keep writing new tests for the same thing but with different values.

For example, a different user for a database owner. The code to write the test for the database owner is the same but the value might be different for different applications, environments, clients, teams, domains etc. I gave a couple of different methods for achieving this.

With dbachecks we have made this much simpler enabling you to set configuration items at run-time or for your session and enabling you to export and import them so you can create different configs for different use cases

There are 108 configuration items at present. You can see the current configuration by running

Get-DbcConfig

which will show you the name of the config, the value it is currently set and the description
![](assets/uploads/2018/02/01-configs.png)

You can see all of the configs and their descriptions here  

 **Name** | **Description** 
---|---
 **agent.databasemailprofile** | Name of the Database Mail Profile in SQL Agent 
 **agent.dbaoperatoremail** | Email address of the DBA Operator in SQL Agent 
 **agent.dbaoperatorname** | Name of the DBA Operator in SQL Agent 
 **agent.failsafeoperator** | Email address of the DBA Operator in SQL Agent 
 **app.checkrepos** | Where Pester tests/checks are stored 
 **app.computername** | List of Windows Servers that Windows-based tests will run against 
 **app.localapp** | Persisted files live here 
 **app.maildirectory** | Files for mail are stored here 
 **app.sqlcredential** | The universal SQL credential if Trusted/Windows Authentication is not used 
 **app.sqlinstance** | List of SQL Server instances that SQL-based tests will run against 
 **app.wincredential** | The universal Windows if default Windows Authentication is not used 
 **command.invokedbccheck.excludecheck** | Invoke-DbcCheck: The checks that should be skipped by default. 
 **domain.domaincontroller** | The domain controller to process your requests 
 **domain.name** | The Active Directory domain that your server is a part of 
 **domain.organizationalunit** | The OU that your server should be a part of 
 **mail.failurethreshhold** | Number of errors that must be present to generate an email report 
 **mail.from** | Email address the email reports should come from 
 **mail.smtpserver** | Store the name of the smtp server to send email reports 
 **mail.subject** | Subject line of the email report 
 **mail.to** | Email address to send the report to 
 **policy.backup.datadir** | Destination server data directory 
 **policy.backup.defaultbackupcompreesion** | Default Backup Compression check should be enabled $true or disabled $false 
 **policy.backup.diffmaxhours** | Maxmimum number of hours before Diff Backups are considered outdated 
 **policy.backup.fullmaxdays** | Maxmimum number of days before Full Backups are considered outdated 
 **policy.backup.logdir** | Destination server log directory 
 **policy.backup.logmaxminutes** | Maxmimum number of minutes before Log Backups are considered outdated 
 **policy.backup.newdbgraceperiod** | The number of hours a newly created database is allowed to not have backups 
 **policy.backup.testserver** | Destination server for backuptests 
 **policy.build.warningwindow** | The number of months prior to a build being unsupported that you want warning about 
 **policy.connection.authscheme** | Auth requirement (Kerberos, NTLM, etc) 
 **policy.connection.pingcount** | Number of times to ping a server to establish average response time 
 **policy.connection.pingmaxms** | Maximum response time in ms 
 **policy.dacallowed** | DAC should be allowed $true or disallowed $false 
 **policy.database.autoclose** | Auto Close should be allowed $true or dissalowed $false 
 **policy.database.autocreatestatistics** | Auto Create Statistics should be enabled $true or disabled $false 
 **policy.database.autoshrink** | Auto Shrink should be allowed $true or dissalowed $false 
 **policy.database.autoupdatestatistics** | Auto Update Statistics should be enabled $true or disabled $false 
 **policy.database.autoupdatestatisticsasynchronously** | Auto Update Statistics Asynchronously should be enabled $true or disabled $false 
 **policy.database.filebalancetolerance** | Percentage for Tolerance for checking for balanced files in a filegroups 
 **policy.database.filegrowthexcludedb** | Databases to exclude from the file growth check 
 **policy.database.filegrowthtype** | Growth Type should be 'kb' or 'percent' 
 **policy.database.filegrowthvalue** | The auto growth value (in kb) should be equal or higher than this value. Example: A value of 65535 means at least 64MB.  
 **policy.database.logfilecount** | The number of Log files expected on a database 
 **policy.database.logfilesizecomparison** | How to compare data and log file size, options are maximum or average 
 **policy.database.logfilesizepercentage** | Maximum percentage of Data file Size that logfile is allowed to be. 
 **policy.database.maxvlf** | Max virtual log files 
 **policy.dbcc.maxdays** | Maxmimum number of days before DBCC CHECKDB is considered outdated 
 **policy.diskspace.percentfree** | Percent disk free 
 **policy.dump.maxcount** | Maximum number of expected dumps 
 **policy.hadr.tcpport** | The TCPPort for the HADR check 
 **policy.identity.usagepercent** | Maxmimum percentage of max of identity column 
 **policy.invaliddbowner.excludedb** | Databases to exclude from invalid dbowner checks 
 **policy.invaliddbowner.name** | The database owner account should not be this user 
 **policy.network.latencymaxms** | Max network latency average 
 **policy.ola.commandlogenabled** | Ola's CommandLog Cleanup should be enabled $true or disabled $false 
 **policy.ola.commandlogscheduled** | Ola's CommandLog Cleanup should be scheduled $true or disabled $false 
 **policy.ola.database** | The database where Ola's maintenance solution is installed 
 **policy.ola.deletebackuphistoryenabled** | Ola's Delete Backup History should be enabled $true or disabled $false 
 **policy.ola.deletebackuphistoryscheduled** | Ola's Delete Backup History should be scheduled $true or disabled $false 
 **policy.ola.installed** | Checks to see if Ola Hallengren solution is installed 
 **policy.ola.outputfilecleanupenabled** | Ola's Output File Cleanup should be enabled $true or disabled $false 
 **policy.ola.outputfilecleanupscheduled** | Ola's Output File Cleanup should be scheduled $true or disabled $false 
 **policy.ola.purgejobhistoryenabled** | Ola's Purge Job History should be enabled $true or disabled $false 
 **policy.ola.purgejobhistoryscheduled** | Ola's Purge Job History should be scheduled $true or disabled $false 
 **policy.ola.systemfullenabled** | Ola's Full System Database Backup should be enabled $true or disabled $false 
 **policy.ola.systemfullretention** | Ola's Full System Database Backup retention number of hours 
 **policy.ola.systemfullscheduled** | Ola's Full System Database Backup should be scheduled $true or disabled $false 
 **policy.ola.systemintegritycheckenabled** | Ola's System Database Integrity should be enabled $true or disabled $false 
 **policy.ola.systemintegritycheckscheduled** | Ola's System Database Integrity should be scheduled $true or disabled $false 
 **policy.ola.userdiffenabled** | Ola's Diff User Database Backup should be enabled $true or disabled $false 
 **policy.ola.userdiffretention** | Ola's Diff User Database Backup retention number of hours 
 **policy.ola.userdiffscheduled** | Ola's Diff User Database Backup should be scheduled $true or disabled $false 
 **policy.ola.userfullenabled** | Ola's Full User Database Backup should be enabled $true or disabled $false 
 **policy.ola.userfullretention** | Ola's Full User Database Backup retention number of hours 
 **policy.ola.userfullscheduled** | Ola's Full User Database Backup should be scheduled $true or disabled $false 
 **policy.ola.userindexoptimizeenabled** | Ola's User Index Optimization should be enabled $true or disabled $false 
 **policy.ola.userindexoptimizescheduled** | Ola's User Index Optimization should be scheduled $true or disabled $false 
 **policy.ola.userintegritycheckenabled** | Ola's User Database Integrity should be enabled $true or disabled $false 
 **policy.ola.userintegritycheckscheduled** | Ola's User Database Integrity should be scheduled $true or disabled $false 
 **policy.ola.userlogenabled** | Ola's Log User Database Backup should be enabled $true or disabled $false 
 **policy.ola.userlogretention** | Ola's Log User Database Backup retention number of hours 
 **policy.ola.userlogscheduled** | Ola's Log User Database Backup should be scheduled $true or disabled $false 
 **policy.oleautomation** | OLE Automation should be enabled $true or disabled $false 
 **policy.pageverify** | Page verify option should be set to this value 
 **policy.recoverymodel.excludedb** | Databases to exclude from standard recovery model check 
 **policy.recoverymodel.type** | Standard recovery model 
 **policy.storage.backuppath** | Enables tests to check if servers have access to centralized backup location 
 **policy.validdbowner.excludedb** | Databases to exclude from valid dbowner checks 
 **policy.validdbowner.name** | The database owner account should be this user 
 **policy.whoisactive.database** | Which database should contain the sp_WhoIsActive stored procedure 
 **policy.xevent.requiredrunningsession** | List of XE Sessions that should be running. 
 **policy.xevent.requiredstoppedsession** | List of XE Sessions that should not be running. 
 **policy.xevent.validrunningsession** | List of XE Sessions that can be be running. 
 **skip.backup.testing** | Don't run Test-DbaLastBackup by default (it's not read-only) 
 **skip.connection.ping** | Skip the ping check for connectivity 
 **skip.connection.remoting** | Skip PowerShell remoting check for connectivity 
 **skip.database.filegrowthdisabled** | Skip validation of datafiles which have growth value equal to zero. 
 **skip.database.logfilecounttest** | Skip the logfilecount test 
 **skip.datafilegrowthdisabled** | Skip validation of datafiles which have growth value equal to zero. 
 **skip.dbcc.datapuritycheck** | Skip data purity check in last good dbcc command 
 **skip.diffbackuptest** | Skip the Differential backup test 
 **skip.logfilecounttest** | Skip the logfilecount test 
 **skip.logshiptesting** | Skip the logshipping test 
 **skip.tempdb1118** | Don't run test for Trace Flag 1118 
 **skip.tempdbfilecount** | Don't run test for Temp Database File Count 
 **skip.tempdbfilegrowthpercent** | Don't run test for Temp Database File Growth in Percent 
 **skip.tempdbfilesizemax** | Don't run test for Temp Database Files Max Size 
 **skip.tempdbfilesonc** | Don't run test for Temp Database Files on C 


So there are a lot of configurations that you can use. A lot are already set by default but all of them you can configure for the values that you need for your own estate.

The configurations are stored in the registry at HKCU:\Software\Microsoft\WindowsPowerShell\PSFramework\

![](assets/uploads/2018/02/01-registry.png)

First Configurations
--------------------

First I would run this so that you can see all of the configs in a seperate window (note this does not work on PowerShell v6)

    Get-DbcConfig | Out-GridView

Lets start with the first configurations that you will want to set. This should be the Instances and the Hosts that you want to check

You can get the value of the configuration item using

    Get-DbcConfigValue -Name app.sqlinstance

![](assets/uploads/2018/02/02-config.png)

as you can see in the image, nothing is returned so we have no instances configured at present. We have added tab completion to the name parameter so that you can easily find the right one  

![](assets/uploads/2018/02/03-autocomplete.png)

If you want to look at more information about the configuration item you can use

    Get-DbcConfig -Name app.sqlinstance

![](assets/uploads/2018/02/04-config.png)

which shows you the name, current value and the description

So lets set our first configuration for our SQL instance to localhost. I have included a video so you can see the auto-complete in action as well

    Set-DbcConfig -Name app.sqlinstance localhost

This configuration will be used for any SQL based checks but not for any windows based ones like Services, PowerPlan, SPN, DiskSpace, Cluster so lets set the app.computername configuration as well

![](assets/uploads/2018/02/05-windows-config.png)

This means that when we run invoke-DbcCheck with AllChecks or by specifying a check, it will run against the local machine and default instance unless we specify a sqlinstance when calling Invoke-DbcCheck. So the code below will not use the configuration for app.sqlinstance.

    Invoke-DbcCheck -SqlInstance TheBeard

Exclude a Check
---------------

You can exclude a check using the -ExcludeCheck parameter of Invoke-DbcConfig. In the example below I am running all of the Server checks but excluding the SPN as we are not on a domain

    Invoke-DbcCheck -Check Server -ExcludeCheck SPN

There is a configuration setting to exclude checks as well. (Be careful this will exclude them even if you specifically specify a check using Invoke-DbcCheck but we do give you a warning!)

So now I can run

    Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value SPN
    Invoke-DbcCheck -Check Server

and all of the server checks except the SPN check will run against the local machine and the default instance that I have set in the config

Creating an environment config and exporting it to use any time we like
-----------------------------------------------------------------------

So lets make this a lot more useful. Lets create a configuration for our production environment and save it to disk (or even source control it!) so that we can use it again and again. We can also then pass it to other members of our team or even embed it in an automated process or our CI/CD system

Lets build up a configuration for a number of tests for my “production” environment. I will not explain them all here but let you read through the code and the comments to see what has been set. You will see that some of them are due to me running the test on a single machine with one drive.
```
# The computername we will be testing
Set-DbcConfig -Name app.computername -Value localhost                                                                                                                                                                                                          
# The Instances we want to test
Set-DbcConfig -Name app.sqlinstance -Value 'localhost' ,'localhost\PROD1','localhost\PROD2', 'localhost\PROD3'                                                                                                                                            
# The database owner we expect
Set-DbcConfig -Name policy.validdbowner.name -Value 'dbachecksdemo\dbachecks'  
# the database owner we do NOT expect
Set-DbcConfig -Name policy.invaliddbowner.name -Value 'sa'      
# Should backups be compressed by default?
Set-DbcConfig -Name policy.backup.defaultbackupcompreesion -Value $true     
# Do we allow DAC connections?
Set-DbcConfig -Name policy.dacallowed -Value $true    
# What recovery model should we have?
Set-DbcConfig -Name policy.recoverymodel.type -value FULL     
# What should our database growth type be?
Set-DbcConfig -Name policy.database.filegrowthtype -Value kb   
# What authentication scheme are we expecting?                                                                                                            
Set-DbcConfig -Name policy.connection.authscheme -Value 'NTLM'
# Which Agent Operator should be defined?
Set-DbcConfig -Name agent.dbaoperatorname -Value 'DBA Team'
# Which Agent Operator email should be defined?
Set-DbcConfig -Name agent.dbaoperatoremail -Value 'DBATeam@TheBeard.Local'
# Which failsafe operator shoudl be defined?
Set-DbcConfig -Name agent.failsafeoperator -Value 'DBA Team'
# Where is the whoisactive stored procedure?
Set-DbcConfig -Name policy.whoisactive.database -Value DBAAdmin 
# What is the maximum time since I took a Full backup?
Set-DbcConfig -Name policy.backup.fullmaxdays -Value 7
# What is the maximum time since I took a DIFF backup (in hours) ?
Set-DbcConfig -Name policy.backup.diffmaxhours -Value 26
# What is the maximum time since I took a log backup (in minutes)?
Set-DbcConfig -Name policy.backup.logmaxminutes -Value 30 
# What is my domain name?
Set-DbcConfig -Name domain.name -Value 'WORKGROUP'
# Where is my Ola database?
Set-DbcConfig -Name policy.ola.database -Value DBAAdmin
# Which database should not be checked for recovery model
Set-DbcConfig -Name policy.recoverymodel.excludedb -Value 'master','msdb','tempdb'
# What is my SQL Credential
Set-DbcConfig -Name app.sqlcredential -Value $null
# Should I skip the check for temp files on c?
Set-DbcConfig -Name skip.tempdbfilesonc -Value $true
# Should I skip the check for temp files count?
Set-DbcConfig -Name skip.tempdbfilecount -Value $true
# Which Checks should be excluded?
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, HADR, PseudoSimple,spn
# How many months before a build is unsupported do I want to fail the test?
Set-DbcConfig -Name policy.build.warningwindow -Value 6
Get-Dbcconfig | ogv
```
When I run this I get

![](assets/uploads/2018/02/08-configuration.png)

I can then export this to disk (to store in source control) using

    Export-DbcConfig -Path C:\Users\dbachecks\Desktop\production_config.json

and I have a configuration file

![](assets/uploads/2018/02/09-configuration-json.png)

which I can use any time to set the configuration for dbachecks using the Import-DbcConfig command (But this doesn’t work in VS Codes integrated terminal – which occasionally does odd things, this appears to be one of them)

    Import-DbcConfig -Path C:\Users\dbachecks\Desktop\production_config.json

![](assets/uploads/2018/02/10-import-configuration.png)

So I can import this configuration and run my checks with it any time I like. This means that I can create many different test configurations for my many different environment or estate configurations.

Yes, I know “good/best practice” says we should use the same configuration for all of our instances but we know that isn’t true. We have instances that were set up 15 years ago that are still in production. We have instances from the companies our organisation has bought over the years that were set up by system administrators. We have instances that were set up by shadow IT and now we have to support but cant change.

As well as those though, we also have different environments. Our development or test environment will have different requirements to our production environments.

In this hypothetical situation the four instances for four different applications have 4 development containers which are connected to using SQL Authentication. We will need a different configuration.

SQL Authentication
------------------

We can set up SQL Authentication for connecting to our SQL Instances using the app.sqlcredential configuration. this is going to hold a PSCredential object for SQL Authenticated connection to your instance. If this is set the checks will always try to use it. Yes this means that the same username and password is being used for each connection. No there is currently no way to choose which instances use it and which don’t. This may be a limitation but as you will see further down you can still do this with different configurations

To set the  SQL Authentication run

    Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential)

This will give a prompt for you to enter the credential

![](assets/uploads/2018/02/11-prompt-for-credenial.png)

Development Environment Configuration
-------------------------------------

So now we know how to set a SQL Authentication configuration we can create our development environment configuration like so. As you can see below the values are different for the checks and more checks have been skipped. I wont explain it all, if it doesn’t make sense ask a question in the comments or in the dbachecks in SQL Server Community Slack

```
#region Dev Config
# The Instances we want to test
Set-DbcConfig -Name app.sqlinstance -Value 'localhost,1401' ,'localhost,1402','localhost,1403', 'localhost,1404' 
# What is my SQL Credential
Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential)
# The database owner we expect
Set-DbcConfig -Name policy.validdbowner.name -Value 'sa'   
# What authentication scheme are we expecting?  
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
# the database owner we do NOT expect
Set-DbcConfig -Name policy.invaliddbowner.name -Value 'dbachecksdemo\dbachecks'
# Should backups be compressed by default?
Set-DbcConfig -Name policy.backup.defaultbackupcompreesion -Value $false
# What should our database growth type be?
Set-DbcConfig -Name policy.database.filegrowthtype -Value kb
# What should our database growth value be higher than (Mb)?
Set-DbcConfig -Name policy.database.filegrowthvalue -Value 64
# Do we allow DAC connections?
Set-DbcConfig -Name policy.dacallowed -Value $false 
# What is the maximum latency (ms)?
Set-DbcConfig -Name policy.network.latencymaxms -Value 100
# What recovery model should we have?
Set-DbcConfig -Name policy.recoverymodel.type -value Simple
# Where is the whoisactive stored procedure?
Set-DbcConfig -Name policy.whoisactive.database -Value DBAAdmin 
# What is my domain name?
Set-DbcConfig -Name domain.name -Value 'WORKGROUP'
# Which database should not be checked for recovery model
Set-DbcConfig -Name policy.recoverymodel.excludedb -Value 'master','msdb','tempdb'
# Should I skip the check for temp files on c?
Set-DbcConfig -Name skip.tempdbfilesonc -Value $true
# Should I skip the check for temp files count?
Set-DbcConfig -Name skip.tempdbfilecount -Value $true
# How many months before a build is unsupported do I want to fail the test?
Set-DbcConfig -Name policy.build.warningwindow -Value 6
# Which Checks should be excluded?
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, HADR, SaReNamed, PseudoSimple,spn, DiskSpace, DatabaseCollation,Agent,Backup,UnusedIndex,LogfileCount,FileGroupBalanced,LogfileSize,MaintenanceSolution,ServerNameMatch

Export-DbcConfig -Path C:\Users\dbachecks\Desktop\development_config.json
```

Using The Different Configurations
----------------------------------

Now I have two configurations, one for my Production Environment and one for my development environment. I can run my checks whenever I like (perhaps you will automate this in some way)

*   Import the production configuration
*   Run my tests with that configuration and create a json file for my Power Bi labelled production
*   Import the development configuration (and enter the SQL authentication credential)
*   Run my tests with that configuration and create a json file for my Power Bi labelled development
*   Start Power Bi to show those results

```
# Import the production config
Import-DbcConfig C:\Users\dbachecks\Desktop\production_config.json
# Run the tests with the production config and create/update the production json
Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment Production
# Import the development config
Import-DbcConfig C:\Users\dbachecks\Desktop\development_config.json
# Run the tests with the production config and create/update the development json
Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment Development
# Open the PowerBi
Start-DbcPowerBi
```
I have published the Power Bi so that you can see what it would like and have a click around (maybe you can see improvements you would like to contribute)

now we can see how each environment is performing according to our settings for each environment  

Combining Configurations Into One Result Set
--------------------------------------------

As you saw above, by using the Environment parameter of Update-DbcPowerBiDataSource you can add different environments to one report. But if I wanted to have a report for my application APP1 showing both production and development environments but they have different configurations how can I do this?

Here’s how.

*   Create a configuration for the production environment (I have used the production configuration one from above but only localhost for the instance)
*   Export it using to  C:\Users\dbachecks\Desktop\APP1-Prod_config.json
*   Create a configuration for the development environment (I have used the development configuration one from above but only localhost,1401 for the instance)
*   Export it using to  C:\Users\dbachecks\Desktop\APP1-Dev_config.json

Then run
```
# Import the production config
Import-DbcConfig C:\Users\dbachecks\Desktop\APP1-Prod_config.json
# Run the tests with the production config and create/update the production json
Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment APP1
# Import the development config
Import-DbcConfig C:\Users\dbachecks\Desktop\APP1-Dev_config.json
# Run the tests with the production config and create/update the development json
Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment APP1 -Append
Start-DbcPowerBi
```
Notice that this time there is an Append on the last Invoke-DbcCheck this creates a single json file for the PowerBi and the results look like this. Now we have the results for our application and both the production environment localhost and the development container localhost,1401  

It’s Open Source – We Want Your Ideas, Issues, New Code
-------------------------------------------------------

dbachecks is open-source [available on GitHub for anyone to contribute](https://github.com/potatoqualitee/dbachecks)

We would love you to contribute. Please open issues for new tests, enhancements, bugs. Please fork the repository and add code to improve the module. please give feedback to make this module even more useful

You can also come in the [SQL Server Community Slack](https://sqlps.io/slack) and join the dbachecks channel and get advice, make comments or just join in the conversation

Thank You
---------

I want to say thank you to all of the people who have enabled dbachecks to get this far. These wonderful people have used their own time to ensure that you have a useful tool available to you for free

Chrissy Lemaire [@cl](https://twitter.com/cl)

Fred Weinmann [@FredWeinmann](https://twitter.com/FredWeinmann)

Cláudio Silva [@ClaudioESSilva](https://github.com/ClaudioESSilva)

Stuart Moore [@napalmgram](https://github.com/napalmgram)

Shawn Melton [@wsmelton](https://twitter.com/wsmelton)

Garry Bargsley [@gbargsley](https://twitter.com/gbargsley)

Stephen Bennett [@staggerlee011](https://twitter.com/staggerlee011)

Sander Stad [@SQLStad](https://twitter.com/sqlstad)

Jess Pomfret [@jpomfret](https://twitter.com/jpomfret)

Jason Squires [@js0505](https://twitter.com/js0505)

Shane O’Neill [@SOZDBA](https://twitter.com/SOZDBA)

and all of the other people who have contributed in the dbachecks Slack channel











