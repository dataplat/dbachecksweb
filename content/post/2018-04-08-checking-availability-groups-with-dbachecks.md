---
title: "Checking Availability Groups with dbachecks"
date: "2018-04-08" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - dbatools
  - PowerShell


image: assets/uploads/2018/04/VSTS-results.png

---
It’s been 45 days since we released dbachecks

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Announcing dbachecks – Configurable PowerShell Validation For Your SQL Instances <a href="https://t.co/2dmUdKtgTQ">https://t.co/2dmUdKtgTQ</a> <a href="https://t.co/N8W01KaKo9">pic.twitter.com/N8W01KaKo9</a></p>&mdash; Rob Sewell - He/Him (@sqldbawithbeard) <a href="https://twitter.com/sqldbawithbeard/status/966643862176493568?ref_src=twsrc%5Etfw">February 22, 2018</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Since then there have been 25 releases to the PowerShell Gallery!! Today release 1.1.119 was released 🙂 There have been over 2000 downloads of the module already.

In the beginning we had 80 checks and 108 configuration items, today we have 84 checks and 125 configuration items!

If you have already installed dbachecks it is important to make sure that you update regularly. You can do this by running

Update-Module dbachecks

If you want to try dbachecks, you can install it from the [PowerShell Gallery](https://www.powershellgallery.com/packages/dbachecks) by running

Install-Module dbachecks # -Scope CurrentUser # if not running as admin

You can read more about installation and read a number of blog posts about using different parts of dbachecks at this link [https://dbatools.io/installing-dbachecks/](https://dbatools.io/installing-dbachecks/)

HADR Tests
----------

Today we updated the HADR tests to add the capability to test multiple availability groups and fix a couple of bugs

Once you have installed dbachecks you will need to set some configuration so that you can perform the tests. You can see all of the configuration items and their values using

Get-DbcConfig | Out-GridView

[![get-config.png](assets/uploads/2018/04/get-config.png)](assets/uploads/2018/04/get-config.png)

You can set the values with the Set-DbcConfig command. It has intellisense to make things easier 🙂 To set the values for the HADR tests

Set-DbcConfig -Name app.cluster -Value sql1
Set-DbcConfig -Name app.computername -Value sql0,sql1
Set-DbcConfig -Name app.sqlinstance -Value sql0,sql1
Set-DbcConfig -Name domain.name -Value TheBeard.Local
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true

*   app.cluster requires one of the nodes of the cluster.
*   app.computername requires the windows computer names of the machines to run operating system checks against
*   app.sqlinstance requires the instance names of the SQL instances that you want to run SQL checks against (These are default instances but it will accept SERVER\\INSTANCE)
*   domain.name requires the domain name the machines are part of
*   skip.hadr.listener.pingcheck is a boolean value which defines whether to skip the listener ping check or not. As this is in Azure I am skipping the check by setting the value to $true
*   policy.hadr.tcpport is set to default to 1433 but you can also set this configuration if your SQL is using a different port

NOTE – You can find all the configuration items that can skip tests by running

Get-DbcConfig -Name skip*

[![skips.png](assets/uploads/2018/04/skips.png)](assets/uploads/2018/04/skips.png)

Now we have set the configuration (For the HADR checks – There are many more configurations for other checks that you can set) you can run the checks with

Invoke-DbcCheck -Check HADR

[![check results.png](assets/uploads/2018/04/check-results.png)](assets/uploads/2018/04/check-results.png)

This runs the following checks

*   Each node on the cluster should be up
*   Each resource on the cluster should be online
*   Each SQL instance should be enabled for Always On
*   Connection check for the listener and each node
    *   Should be pingable (unless skip.hadr.listener.pingcheck is set to true)
    *   Should be able to run SQL commands
    *   Should be the correct domain name
    *   Should be using the correct tcpport
*   Each replica should not be in unknown state
*   Each synchronous replica should be synchronised
*   Each asynchronous replica should be synchonising
*   Each database should be synchronised (or synchronising) on each replica
*   Each database should be failover ready on each replica
*   Each database should be joined to the availability group on each replica
*   Each database should not be suspended on each replica
*   Each node should have the AlwaysOn_Health extended event
*   Each node should have the AlwaysOn_Health extended event running
*   Each node should have the AlwaysOn_Health extended event set to auto start

(Apologies folk over the pond, I use the Queens English 😉 )

This is good for us to be able to run this check at the command line but we can do more.

We can export the results and display them with PowerBi. Note we need to add -PassThru so that the results go through the pipeline and that I used -Show Fails so that only the titles of the Describe and Context blocks and any failing tests are displayed to the screen

Invoke-DbcCheck -Check HADR -Show Fails -PassThru | Update-DbcPowerBiDataSource -Environment HADR-Test
Start-DbcPowerBi

[![results.png](assets/uploads/2018/04/results.png)](assets/uploads/2018/04/results.png)

This will create a file at C:\\Windows\\Temp\\dbachecks and open the PowerBi report. You will need to refresh the data in the report and then you will see

[![dbachecks.png](assets/uploads/2018/04/dbachecks.png)](assets/uploads/2018/04/dbachecks.png)

Excellent, everything passed 🙂

Saving Configuration for reuse
------------------------------

We can save our configuration using Export-DbcConfig which will export the configuration to a json file

Export-DbcConfig -Path Git:\\PesterTests\\MyHADRTestsForProd.json

so that we can run this particular set of tests with this comfiguration by importing the configuration using Import-DbcConfig

Import-DbcConfig -Path -Path Git:\\PesterTests\\MyHADRTestsForProd.json
Invoke-DbcCheck -Check HADR

In this way you can set up different check configurations for different use cases. This also enables you to make use of the checks in your CI/CD process. For example, I have a GitHub repository for creating a domain, a cluster and a SQL 2017 availability group using VSTS. I have saved a dbachecks configuration to my repository and as part of my build I can import that configuration, run the checks and output them to XML for consumption by the publish test results task of VSTS

After copying the configuration to the machine, I run

Import-Dbcconfig -Path C:\\Windows\\Temp\\FirstBuild.json
Invoke-DbcCheck-AllChecks -OutputFile PesterTestResultsdbachecks.xml -OutputFormat NUnitXml

in my build step and then use the publish test results task and VSTS does the rest 🙂

[![VSTS results.png](assets/uploads/2018/04/VSTS-results.png)](assets/uploads/2018/04/VSTS-results.png)








