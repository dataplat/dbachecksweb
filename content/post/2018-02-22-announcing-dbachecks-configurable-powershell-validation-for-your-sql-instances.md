---
title: "Announcing dbachecks – Configurable PowerShell Validation For Your SQL Instances"
date: "2018-02-22" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - dbatools
  - pester
  - PowerShell


image: assets/uploads/2018/02/09-PowerBi.png

---
For the last couple of months members of the [dbatools](http://dbatools.io) team have been working on a new PowerShell module called [dbachecks](http://dbachecks.io). This open source PowerShell module will enable you to validate your SQL Instances. Today it is released for you all to start to use 🙂

Validate Your SQL Instances?
----------------------------

What do I mean by validate your SQL Instances? You want to know if your SQL Instances are (still) set up in the way that you want them to be or that you have not missed any configurations when setting them up. With dbachecks you can use any or all of the 80 checks to ensure one or many SQL Instances are as you want them to be. Using Pester, dbachecks will validate your SQL Instance(s) against default settings or ones that you configure yourself.

Installation
------------

Installation is via the PowerShell Gallery. You will need to open PowerShell on a machine connected to the internet and run

Install-Module dbachecks

If you are not running your process as admin or you only want (or are able) to install for your own user account you will need to

Install-Module -Scope CurrentUser

This will also install the PSFramework module used for configuration (and other things beneath the hood) and the latest version (4.2.0 – released on Sunday!) of Pester

Once you have installed the module you can see the commands available by running

Get-Command -Module dbachecks

To be able to use these (and any PowerShell) commands, your first step should always be Get-Help

Get-Help Send-DbcMailMessage

[![](assets/uploads/2018/02/01a-get-help.png)](assets/uploads/2018/02/01a-get-help.png)

80 Checks
---------

At the time of release, dbachecks has 80 checks. You can see all of the checks by running

Get-DbcCheck

(Note this has nothing to do with DBCC CheckDb!) Here is the output of

Get-DbcCheck | Select Group, UniqueTag

so you can see the current checks

 **Group** | **UniqueTag** 
---|---
 **Agent** | AgentServiceAccount 
 **Agent** | DbaOperator 
 **Agent** | FailsafeOperator 
 **Agent** | DatabaseMailProfile 
 **Agent** | FailedJob 
 **Database** | DatabaseCollation 
 **Database** | SuspectPage 
 **Database** | TestLastBackup 
 **Database** | TestLastBackupVerifyOnly 
 **Database** | ValidDatabaseOwner 
 **Database** | InvalidDatabaseOwner 
 **Database** | LastGoodCheckDb 
 **Database** | IdentityUsage 
 **Database** | RecoveryModel 
 **Database** | DuplicateIndex 
 **Database** | UnusedIndex 
 **Database** | DisabledIndex 
 **Database** | DatabaseGrowthEvent 
 **Database** | PageVerify 
 **Database** | AutoClose 
 **Database** | AutoShrink 
 **Database** | LastFullBackup 
 **Database** | LastDiffBackup 
 **Database** | LastLogBackup 
 **Database** | VirtualLogFile 
 **Database** | LogfileCount 
 **Database** | LogfileSize 
 **Database** | FileGroupBalanced 
 **Database** | AutoCreateStatistics 
 **Database** | AutoUpdateStatistics 
 **Database** | AutoUpdateStatisticsAsynchronously 
 **Database** | DatafileAutoGrowthType 
 **Database** | Trustworthy 
 **Database** | OrphanedUser 
 **Database** | PseudoSimple 
 **Database** | AdHocWorkloads 
 **Domain** | DomainName 
 **Domain** | OrganizationalUnit 
 **HADR** | ClusterHealth 
 **HADR** | ClusterServerHealth 
 **HADR** 
 **HADR** | System.Object[] 
 **Instance** | SqlEngineServiceAccount 
 **Instance** | SqlBrowserServiceAccount 
 **Instance** | TempDbConfiguration 
 **Instance** | AdHocWorkload 
 **Instance** | BackupPathAccess 
 **Instance** | DAC 
 **Instance** | NetworkLatency 
 **Instance** | LinkedServerConnection 
 **Instance** | MaxMemory 
 **Instance** | OrphanedFile 
 **Instance** | ServerNameMatch 
 **Instance** | MemoryDump 
 **Instance** | SupportedBuild 
 **Instance** | SaRenamed 
 **Instance** | DefaultBackupCompression 
 **Instance** | XESessionStopped 
 **Instance** | XESessionRunning 
 **Instance** | XESessionRunningAllowed 
 **Instance** | OLEAutomation 
 **Instance** | WhoIsActiveInstalled 
 **LogShipping** | LogShippingPrimary 
 **LogShipping** | LogShippingSecondary 
 **Server** | PowerPlan 
 **Server** | InstanceConnection 
 **Server** | SPN 
 **Server** | DiskCapacity 
 **Server** | PingComputer 
 **MaintenancePlan** | SystemFull 
 **MaintenancePlan** | UserFull 
 **MaintenancePlan** | UserDiff 
 **MaintenancePlan** | UserLog 
 **MaintenancePlan** | CommandLog 
 **MaintenancePlan** | SystemIntegrityCheck 
 **MaintenancePlan** | UserIntegrityCheck 
 **MaintenancePlan** | UserIndexOptimize 
 **MaintenancePlan** | OutputFileCleanup 
 **MaintenancePlan** | DeleteBackupHistory 
 **MaintenancePlan** | PurgeJobHistory 

108 Configurations
------------------

One of the things I have been talking about in my presentation “Green is Good Red is Bad” is configuring Pester checks so that you do not have to keep writing new tests for the same thing but with different values.

For example, a different user for a database owner. The code to write the test for the database owner is the same but the value might be different for different applications, environments, clients, teams, domains etc. I gave a couple of different methods for achieving this.

With dbachecks we have made this much simpler enabling you to set configuration items at run-time or for your session and enabling you to export and import them so you can create different configs for different use cases

There are 108 configuration items at present. You can see the current configuration by running

Get-DbcConfig

which will show you the name of the config, the value it is currently set and the description

[![](assets/uploads/2018/02/01-configs.png)](assets/uploads/2018/02/01-configs.png)

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

Running A Check
---------------

You can quickly run a single check by calling Invoke-DbcCheck.

Invoke-DbcCheck -SqlInstance localhost -Check FailedJob

[![](assets/uploads/2018/02/02-failed-jobs.png)](assets/uploads/2018/02/02-failed-jobs.png)

Excellent, my agent jobs have not failed 🙂

Invoke-DbcCheck -SqlInstance localhost -Check LastGoodCheckDb

[![](assets/uploads/2018/02/03-dbcc-check.png)](assets/uploads/2018/02/03-dbcc-check.png)

Thats good, all of my databases have had a successful DBCC CHECKDB within the last 7 days.

Setting a Configuration
-----------------------

To save me from having to specify the instance I want to run my tests against I can set the app.sqlinstance config to the instances I want to check.

Set-DbcConfig -Name app.sqlinstance -Value localhost, 'localhost\\PROD1'

[![](assets/uploads/2018/02/04-setting-instances-config.png)](assets/uploads/2018/02/04-setting-instances-config.png)

Then whenever I call Invoke-DbcCheck it will run against those instances for the SQL checks

So now if I run

Invoke-DbcCheck -Check LastDiffBackup

I can see that I dont have a diff backup for the databases on both instances. Better stop writing this and deal with that !!

[![](assets/uploads/2018/02/05-last-backup.png)](assets/uploads/2018/02/05-last-backup.png)

The configurations are stored in the registry but you can export them and then import them for re-use easily. I have written another blog post about that.

The Show Parameter
------------------

Getting the results of the tests on the screen is cool but if you are running a lot of tests against a lot of instances then you might find that you have 3 failed tests out of 15000! This will mean a lot of scrolling through green text looking for the red text and you may find that your PowerShell buffer doesnt hold all of your test results leaving you very frustrated.

dbachecks supports the Pester Show parameter enabling you to filter the output of the results to the screen. The available values are Summary, None, Fails, Inconclusive, Passed, Pending and Skipped

[![](assets/uploads/2018/02/06-show.png)](assets/uploads/2018/02/06-show.png)

in my opinion by far the most useful one is Fails as this will show you only the failed tests with the context to enable you to see which tests have failed

Invoke-DbcCheck -Check Agent -Show Fails

If we check all of the checks tagged as Agent we can easily see that most passed but The Job That Fails (surprisingly) failed. All of the other tests that were run for the agent service, operators, failsafe operator, database mail and all other agent jobs all passed in the example below

[![](assets/uploads/2018/02/07-Jobs-that-filed.png)](assets/uploads/2018/02/07-Jobs-that-filed.png)

Test Results are for other People as well
-----------------------------------------

It is all very well and good being able to run tests and get the results on our screen. It will be very useful for people to be able to validate a new SQL instance for example or run a morning check or the first step of an incident response. But test results are also useful for other people so we need to be able to share them

We have created a Power Bi Dashboard that comes with the dbachecks module to enable easy sharing of the test results. You can also send the results via email using Send-DbcMailMessage. we have an [open issue for putting them into a database](https://github.com/potatoqualitee/dbachecks/issues/270) that we would love you to help resolve.

To get the results into PowerBi you can run

Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment Production

This will run all of the dbachecks using your configuration for your Production environment, output only the failed tests to the screen and save the results in your windows\\temp\\dbachecks folder with a suffix of Production

If you then used a different configuration for your development environment and ran

Invoke-DbcCheck -AllChecks -Show Fails -PassThru |Update-DbcPowerBiDataSource -Environment Development

it will run all of the dbachecks using your configuration for your Development environment, output only the failed tests to the screen and save the results in your windows\\temp\\dbachecks folder with a suffix of Development and you would end up with two files in the folder

[![](assets/uploads/2018/02/08-test-results.png)](assets/uploads/2018/02/08-test-results.png)

You can then simply run

Start-DbcPowerBi

and as long as you have the (free) Powerbi Desktop then you will see this. You will need to refresh the data to get your test results

[![](assets/uploads/2018/02/09-PowerBi.png)](assets/uploads/2018/02/09-PowerBi.png)

Of course it is Powerbi so you can publish this report. Here it is so that you can click around and see what it looks like

It’s Open Source – We Want Your Ideas, Issues, New Code
-------------------------------------------------------

dbachecks is open-source [available on GitHub for anyone to contribute](https://github.com/potatoqualitee/dbachecks)

We would love you to contribute. Please open issues for new tests, enhancements, bugs. Please fork the repository and add code to improve the module. please give feedback to make this module even more useful

You can also come in the [SQL Server Community Slack](https://sqlps.io/slack) and join the dbachecks channel and get advice, make comments or just join in the conversation

Further Reading
---------------

There are many more introduction blog posts covering different areas at

*   [dbachecks.io/install](https://dbachecks.io/install)

Thank You
---------

I want to say thank you to all of the people who have enabled dbachecks to get this far. These wonderful people have used their own time to ensure that you have a useful tool available to you for free

Chrissy Lemaire [@cl](https://twitter.com/cl)

Fred Weinmann [@FredWeinmann](https://twitter.com/FredWeinmann)

Cláudio Silva [@ClaudioESSilva](https://twitter.com/ClaudioESSilva)

Stuart Moore [@napalmgram](https://twitter.com/napalmgram)

Shawn Melton [@wsmelton](https://twitter.com/wsmelton)

Garry Bargsley [@gbargsley](https://twitter.com/gbargsley)

Stephen Bennett [@staggerlee011](https://twitter.com/staggerlee011)

Sander Stad [@SQLStad](https://twitter.com/sqlstad)

Jess Pomfret [@jpomfret](https://twitter.com/jpomfret)

Jason Squires [@js0505](https://twitter.com/js0505)

Shane O’Neill [@SOZDBA](https://twitter.com/SOZDBA)

Tony Wilhelm [@TonyWSQL](https://twitter.com/TonyWSQL)

and all of the other people who have contributed in the dbachecks Slack channel











