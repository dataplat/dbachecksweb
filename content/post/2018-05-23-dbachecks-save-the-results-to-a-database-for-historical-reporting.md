---
title: "dbachecks – Save the results to a database for historical reporting"
date: "2018-05-23" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - PowerShell
  - POwer Bi


image: assets/uploads/2018/05/08-filter-by-instance-and-insance.png

---
I gave a presentation at [SQL Day](https://sqlday.pl/en/) in Poland last week on [dbachecks](http://dbachecks.io) and one of the questions I got asked was will you write a command to put the results of the checks into a database for historical reporting.

The answer is no and here is the reasoning. The capability is already there. Most good PowerShell commands will only return an object and the beauty of an object is that you can do anything you like with it. Your only limit is your imagination 🙂 I have written about this before [here. ](/taking-dbatools-test-dbalastbackup-a-little-further/)The other reason is that it would be very difficult to write something that was easily configurable for the different requirements that people will require. But here is one way of doing it.

Create a configuration and save it
----------------------------------

Let’s define a configuration and call it production. This is something that I do all of the time so that I can easily run a set of checks with the configuration that I want.

```
# The computername we will be testing
Set-DbcConfig -Name app.computername -Value $sql0,$SQl1
# The Instances we want to test
Set-DbcConfig -Name app.sqlinstance -Value $sql0,$SQl1
# The database owner we expect
Set-DbcConfig -Name policy.validdbowner.name -Value 'THEBEARD\\EnterpriseAdmin'
# the database owner we do NOT expect
Set-DbcConfig -Name policy.invaliddbowner.name -Value 'sa'
# Should backups be compressed by default?
Set-DbcConfig -Name policy.backup.defaultbackupcompression -Value $true
# Do we allow DAC connections?
Set-DbcConfig -Name policy.dacallowed -Value $true
# What recovery model should we have?
Set-DbcConfig -Name policy.recoverymodel.type -value FULL
# What should ourt database growth type be?
Set-DbcConfig -Name policy.database.filegrowthtype -Value kb
# What authentication scheme are we expecting?
Set-DbcConfig -Name policy.connection.authscheme -Value 'KERBEROS'
# Which Agent Operator should be defined?
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'
# Which Agent Operator email should be defined?
Set-DbcConfig -Name agent.dbaoperatoremail -Value 'TheDBATeam@TheBeard.Local'
# Which failsafe operator shoudl be defined?
Set-DbcConfig -Name agent.failsafeoperator -Value 'The DBA Team'
## Set the database mail profile name
Set-DbcConfig -Name agent.databasemailprofile -Value 'DbaTeam'
# Where is the whoisactive stored procedure?
Set-DbcConfig -Name policy.whoisactive.database -Value master
# What is the maximum time since I took a Full backup?
Set-DbcConfig -Name policy.backup.fullmaxdays -Value 7
# What is the maximum time since I took a DIFF backup (in hours) ?
Set-DbcConfig -Name policy.backup.diffmaxhours -Value 26
# What is the maximum time since I took a log backup (in minutes)?
Set-DbcConfig -Name policy.backup.logmaxminutes -Value 30
# What is my domain name?
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'
# Where is my Ola database?
Set-DbcConfig -Name policy.ola.database -Value master
# Which database should not be checked for recovery model
Set-DbcConfig -Name policy.recoverymodel.excludedb -Value 'master','msdb','tempdb'
# Should I skip the check for temp files on c?
Set-DbcConfig -Name skip.tempdbfilesonc -Value $true
# Should I skip the check for temp files count?
Set-DbcConfig -Name skip.tempdbfilecount -Value $true
# Which Checks should be excluded?
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, PseudoSimple,SPN, TestLastBackupVerifyOnly,IdentityUsage,SaRenamed
# How many months before a build is unsupported do I want to fail the test?
Set-DbcConfig -Name policy.build.warningwindow -Value 6
## I need to set the app.cluster configuration to one of the nodes for the HADR check
## and I need to set the domain.name value
Set-DbcConfig -Name app.cluster -Value $SQL0
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'
## I also skip the ping check for the listener as we are in Azure
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true
```
Now I can export that configuration to a json file and store on a file share or in source control using the code below. This makes it easy to embed the checks into an automation solution

`Export-DbcConfig -Path Git:\\Production.Json`

and then I can use it with

```
Import-DbcConfig -Path Git:\\Production.Json
Invoke-DbcCheck
```

[![01 - Invoke-DbcCheck](assets/uploads/2018/05/01-Invoke-DbcCheck.png)](assets/uploads/2018/05/01-Invoke-DbcCheck.png)

I would use one of the Show parameter values here if I was running it at the command line, probably fails to make reading the information easier

Add results to a database
-------------------------

This only gets us the test results on the screen, so if we want to save them to a database we have to use the PassThru parameter for Invoke-DbcCheck. I will run the checks again, save them to a variable

`$Testresults = Invoke-DbcCheck -PassThru -Show Fails`

Then I can use the [dbatools](http://dbatools.io) [Write-DbaDatatable](https://dbatools.io/functions/write-dbadatatable/) command to write the results to a table in a database. I need to do this twice, once for the summary and once for the test results
```
$Testresults | Write-DbaDataTable -SqlInstance $sql0 -Database tempdb -Table Prod_dbachecks_summary -AutoCreateTable
$Testresults.TestResult | Write-DbaDataTable -SqlInstance $sql0 -Database tempdb -Table Prod_dbachecks_detail -AutoCreateTable
```
and I get two tables one for the summary

[![02 - summary](assets/uploads/2018/05/02-summary.png)](assets/uploads/2018/05/02-summary.png)

and one for the details

[![03 - detail](assets/uploads/2018/05/03-detail.png)](assets/uploads/2018/05/03-detail.png)

This works absolutely fine and I could continue to add test results in this fashion but it has no date property so it is not so useful for reporting.

Create tables and triggers
--------------------------

This is one way of doing it. I am not sure it is the best way but it works! I always look forward to how people take ideas and move them forward so if you have a better/different solution please blog about it and reference it in the comments below

First I created a staging table for the summary results
```
CREATE TABLE [dbachecks].[Prod_dbachecks_summary_stage](
	[TagFilter] [nvarchar](max) NULL,
	[ExcludeTagFilter] [nvarchar](max) NULL,
	[TestNameFilter] [nvarchar](max) NULL,
	[TotalCount] [int] NULL,
	[PassedCount] [int] NULL,
	[FailedCount] [int] NULL,
	[SkippedCount] [int] NULL,
	[PendingCount] [int] NULL,
	[InconclusiveCount] [int] NULL,
	[Time] [bigint] NULL,
	[TestResult] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
```
and a destination table with a primary key and a date column which defaults to todays date
```
CREATE TABLE [dbachecks].[Prod_dbachecks_summary](
	[SummaryID] [int] IDENTITY(1,1) NOT NULL,
	[TestDate] [date] NOT NULL,
	[TagFilter] [nvarchar](max) NULL,
	[ExcludeTagFilter] [nvarchar](max) NULL,
	[TestNameFilter] [nvarchar](max) NULL,
	[TotalCount] [int] NULL,
	[PassedCount] [int] NULL,
	[FailedCount] [int] NULL,
	[SkippedCount] [int] NULL,
	[PendingCount] [int] NULL,
	[InconclusiveCount] [int] NULL,
	[Time] [bigint] NULL,
	[TestResult] [nvarchar](max) NULL,
 CONSTRAINT [PK_Prod_dbachecks_summary] PRIMARY KEY CLUSTERED 
(
	[SummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_summary] ADD  CONSTRAINT [DF_Prod_dbachecks_summary_TestDate]  DEFAULT (getdate()) FOR [TestDate]
GO
```
and added an INSERT trigger to the staging table
```
CREATE TRIGGER [dbachecks].[Load_Prod_Summary] 
   ON   [dbachecks].[Prod_dbachecks_summary_stage]
   AFTER INSERT
AS 
BEGIN
	\\ SET NOCOUNT ON added to prevent extra result sets from
	\\ interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbachecks].[Prod_dbachecks_summary] 
	([TagFilter], [ExcludeTagFilter], [TestNameFilter], [TotalCount], [PassedCount], [FailedCount], [SkippedCount], [PendingCount], [InconclusiveCount], [Time], [TestResult])
	SELECT [TagFilter], [ExcludeTagFilter], [TestNameFilter], [TotalCount], [PassedCount], [FailedCount], [SkippedCount], [PendingCount], [InconclusiveCount], [Time], [TestResult] FROM [dbachecks].[Prod_dbachecks_summary_stage]

END
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_summary_stage] ENABLE TRIGGER [Load_Prod_Summary]
GO
```
and for the details I do the same thing. A details table
```
CREATE TABLE [dbachecks].[Prod_dbachecks_detail](
	[DetailID] [int] IDENTITY(1,1) NOT NULL,
	[SummaryID] [int] NOT NULL,
	[ErrorRecord] [nvarchar](max) NULL,
	[ParameterizedSuiteName] [nvarchar](max) NULL,
	[Describe] [nvarchar](max) NULL,
	[Parameters] [nvarchar](max) NULL,
	[Passed] [bit] NULL,
	[Show] [nvarchar](max) NULL,
	[FailureMessage] [nvarchar](max) NULL,
	[Time] [bigint] NULL,
	[Name] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Context] [nvarchar](max) NULL,
	[StackTrace] [nvarchar](max) NULL,
 CONSTRAINT [PK_Prod_dbachecks_detail] PRIMARY KEY CLUSTERED 
(
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail]  WITH CHECK ADD  CONSTRAINT [FK_Prod_dbachecks_detail_Prod_dbachecks_summary] FOREIGN KEY([SummaryID])
REFERENCES [dbachecks].[Prod_dbachecks_summary] ([SummaryID])
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail] CHECK CONSTRAINT [FK_Prod_dbachecks_detail_Prod_dbachecks_summary]
GO
```
A stage table
```
CREATE TABLE [dbachecks].[Prod_dbachecks_detail_stage](
	[ErrorRecord] [nvarchar](max) NULL,
	[ParameterizedSuiteName] [nvarchar](max) NULL,
	[Describe] [nvarchar](max) NULL,
	[Parameters] [nvarchar](max) NULL,
	[Passed] [bit] NULL,
	[Show] [nvarchar](max) NULL,
	[FailureMessage] [nvarchar](max) NULL,
	[Time] [bigint] NULL,
	[Name] [nvarchar](max) NULL,
	[Result] [nvarchar](max) NULL,
	[Context] [nvarchar](max) NULL,
	[StackTrace] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
```
with a trigger
```
CREATE TRIGGER [dbachecks].[Load_Prod_Detail] 
   ON   [dbachecks].[Prod_dbachecks_detail_stage]
   AFTER INSERT
AS 
BEGIN
	\\ SET NOCOUNT ON added to prevent extra result sets from
	\\ interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [dbachecks].[Prod_dbachecks_detail] 
([SummaryID],[ErrorRecord], [ParameterizedSuiteName], [Describe], [Parameters], [Passed], [Show], [FailureMessage], [Time], [Name], [Result], [Context], [StackTrace])
	SELECT 
	(SELECT MAX(SummaryID) From [dbachecks].[Prod_dbachecks_summary]),[ErrorRecord], [ParameterizedSuiteName], [Describe], [Parameters], [Passed], [Show], [FailureMessage], [Time], [Name], [Result], [Context], [StackTrace]
	FROM [dbachecks].[Prod_dbachecks_detail_stage]

END
GO

ALTER TABLE [dbachecks].[Prod_dbachecks_detail_stage] ENABLE TRIGGER [Load_Prod_Detail]
GO
```

Then I can use `Write-DbaDatatable` with a couple of extra parameters, `FireTriggers` to run the trigger, `Truncate` and `Confirm:$false` to avoid any confirmation because I want this to run without any interaction and I can get the results into the database.
```
$Testresults | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_summary_stage -FireTriggers -Truncate -Confirm:$False
$Testresults.TestResult | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_detail_stage -FireTriggers -Truncate -Confirm:$False
```
[![detail with stage](assets/uploads/2018/05/detail-with-stage.png)](assets/uploads/2018/05/detail-with-stage.png)

Which means that I can now query some of this data and also create PowerBi reports for it.

To enable me to have results for the groups in dbachecks I have to do a little bit of extra manipulation. I can add all of the checks to the database using
```
Get-DbcCheck | Write-DbaDataTable -SqlInstance $sql0 -Database ValidationResults -Schema dbachecks -Table Checks -Truncate -Confirm:$False -AutoCreateTable
```
But because the Ola Hallengren Job names are configuration items I need to update the values for those checks which I can do as follows
```
$query = "
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.systemfull) + "' WHERE [Describe] = 'Ola - `$SysFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserFull) + "' WHERE [Describe] = 'Ola - `$UserFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserDiff) + "' WHERE [Describe] = 'Ola - `$UserDiffJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserLog) + "' WHERE [Describe] = 'Ola - `$UserLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.CommandLogCleanup) + "' WHERE [Describe] = 'Ola - `$CommandLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.SystemIntegrity) + "' WHERE [Describe] = 'Ola - `$SysIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIntegrity) + "' WHERE [Describe] = 'Ola - `$UserIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIndex) + "' WHERE [Describe] = 'Ola - `$UserIndexJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.OutputFileCleanup) + "' WHERE [Describe] = 'Ola - `$OutputFileJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.DeleteBackupHistory) + "' WHERE [Describe] = 'Ola - `$DeleteBackupJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.PurgeBackupHistory) + "' WHERE [Describe] = 'Ola - `$PurgeBackupJobName'
"
Invoke-DbaSqlQuery -SqlInstance $SQL0 -Database ValidationResults -Query $query
```
You can get a sample Power Bi report in [my Github which also has the code from this blog post](https://github.com/SQLDBAWithABeard/dbachecks-expanded)

Then you just need to open in PowerBi Desktop and

Click Edit Queries  
Click Data Source Settings  
Click Change Source  
Change the Instance and Database names

[![09 - PowerBi](assets/uploads/2018/05/09-PowerBi.png)](assets/uploads/2018/05/09-PowerBi.png)

Then have an interactive report like this. Feel free to click around and see how it works. Use the arrows at the bottom right to go full-screen. NOTE – it filters by “today” so if I haven’t run the check and the import then click on one of the groups under “Today’s Checks by Group”

This enables me to filter the results and see what has happened in the past so I can filter by one instance

[![05 - filter by instance](assets/uploads/2018/05/05-filter-by-instance.png)](assets/uploads/2018/05/05-filter-by-instance.png)

or I can filter by a group of tests

[![07 - filter by instance](assets/uploads/2018/05/07-filter-by-instance.png)](assets/uploads/2018/05/07-filter-by-instance.png)

or even by a group of tests for an instance

[![08 - filter by instance and insance](assets/uploads/2018/05/08-filter-by-instance-and-insance.png)](assets/uploads/2018/05/08-filter-by-instance-and-insance.png)

Hopefully, this will give you some ideas of what you can do with your dbachecks results. [You can find all of the code and the PowerBi in my GitHub](https://github.com/SQLDBAWithABeard/dbachecks-expanded)

Happy Validating!










