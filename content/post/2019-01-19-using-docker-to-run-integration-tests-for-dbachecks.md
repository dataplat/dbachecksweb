---
title: "Using Docker to run Integration Tests for dbachecks"
date: "2019-01-19" 
categories:
  - dbachecks
  - Blog
  - PowerShell
  - dbatools

tags:
  - containers
  - dbachecks
  - dbatools
  - docker
  - GitHub 
  - pester
  - PowerShell
  - test

---
My wonderful friend [André Kamman](https://twitter.com/AndreKamman) wrote a fantastic blog post this week [SQL Server Container Instances via Cloudshell](https://andrekamman.com/sql-server-container-instances-via-cloudshell/) about how he uses containers in Azure to test code against different versions of SQL Server.

It reminded me that I do something very similar to test [dbachecks](http://dbachecks.io) code changes. I thought this might make a good blog post. I will talk through how I do this locally as I merge a PR from another great friend [Cláudio Silva](https://github.com/ClaudioESSilva) who has added [agent job history checks.](https://github.com/sqlcollaborative/dbachecks/pull/582)

GitHub PR VS Code Extension
---------------------------

I use the [GitHub Pull Requests extension for VS Code](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github) to work with pull requests for [dbachecks](https://github.com/sqlcollaborative/dbachecks/pulls). This enables me to see all of the information about the Pull Request, merge it, review it, comment on it all from VS Code

![](https://blog.robsewell.com/assets/uploads/2019/01/GitHub-Pull-Request-VsCode-Extension.png)

I can also see which files have been changed and which changes have been made

![](https://blog.robsewell.com/assets/uploads/2019/01/viewing-a-change.png)

Once I am ready to test the pull request I perform a checkout using the extension

![](https://blog.robsewell.com/assets/uploads/2019/01/checkout-pull-request-checkout.png)

This will update all of the files in my local repository with all of the changes in this pull request

<VIDEO src="https://blog.robsewell.com/wp-content/uploads/2019/01/pull-request-checkout.mp4" controls></VIDEO>

You can see at the bottom left that the branch changes from development to the name of the PR.[](https://blog.robsewell.com/version-update-code-signing-and-publishing-to-the-powershell-gallery-with-vsts/)

Running The Unit Tests
----------------------

The first thing that I do is to run the Unit Tests for the module. These will test that the code is following all of the guidelines that we require and that the tests are formatted in the correct way for the Power Bi to parse. I have blogged about this [here](https://blog.robsewell.com/using-the-ast-in-pester-for-dbachecks/) and [here](https://blog.robsewell.com/using-the-powershell-ast-to-find-a-foreach-method/) and we use this Pester in our CI process in Azure DevOps which I described [here.](https://blog.robsewell.com/version-update-code-signing-and-publishing-to-the-powershell-gallery-with-vsts/)

I navigate to the root of the dbachecks repository on my local machine and run

     $testresults = Invoke-Pester .\tests -ExcludeTag Integration -Show Fails -PassThru 

and after about a minute

![](https://blog.robsewell.com/assets/uploads/2019/01/pester-tests.png)

Thank you Cláudio, the code has passed the tests 😉

Running Some Integration Tests
------------------------------

The difference between Unit tests and Integration tests in a nutshell is that the Unit tests are testing that the code is doing what is expected without any other external influences whilst the Integration tests are checking that the code is doing what is expected when running on an actual environment. In this scenario we know that the code is doing what is expected but we want to check what it does when it runs against a SQL Server and even when it runs against multiple SQL Servers of different versions.

Multiple Versions of SQL Server
-------------------------------

As I have described [before](https://blog.robsewell.com/creating-sql-server-containers-for-versions-2012-2017/) my friend and former colleague Andrew Pruski [b](http://dbafromthecold.com) | [t](http://twitter.com/dbafromthecold) has many resources for running SQL in containers. This means that I can quickly and easily create fresh uncontaminated instances of SQL 2012, 2014, 2016 and 2017 really quickly.

![](https://blog.robsewell.com/assets/uploads/2019/01/creating-contatiners.png)

I can create 4 instances of different versions of SQL in (a tad over) 1 minute. How about you?

Imagine how long it would take to run the installers for 4 versions of SQL and the pain you would have trying to uninstall them and make sure everything is ‘clean’. Even images that have been sysprep’d won’t be done in 1 minute.

Docker Compose Up ?
-------------------

So what is this magic command that has enabled me to do this? docker compose uses a YAML file to define multi-container applications. This means that with a file called docker-compose.yml like [this](https://gist.github.com/SQLDBAWithABeard/b589d499484af4ebfb7d637cb6b4efa3)

    version: '3.7'
    
    services:
        sql2012:
            image: dbafromthecold/sqlserver2012dev:sp4
            ports:  
              - "15589:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2014:
            image: dbafromthecold/sqlserver2014dev:sp2
            ports:  
              - "15588:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2016:
            image: dbafromthecold/sqlserver2016dev:sp2
            ports:  
              - "15587:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"
        sql2017:
            image: microsoft/    mssql-server-windows-developer:2017-latest
            ports:  
              - "15586:1433"
            environment:
              SA_PASSWORD: "Password0!"
              ACCEPT_EULA: "Y"

and in that directory just run

    docker-compose up -d

and 4 SQL containers are available to you. You can interact with them via SSMS if you wish with localhost comma PORTNUMBER. The port numbers in the above file are 15586, 15587,15588 and 15589

![](https://blog.robsewell.com/assets/uploads/2019/01/containers.png?resize=630%2C188&ssl=1)](https://blog.robsewell.com/assets/uploads/2019/01/containers.png?ssl=1)

Now it must be noted, as I [describe here](https://blog.robsewell.com/creating-sql-server-containers-for-versions-2012-2017/) that first I pulled the images to my laptop. The first time you run docker compose will take significantly longer if you haven’t pulled the images already (pulling the images will take quite a while depending on your broadband speed)

Credential
----------

The next thing is to save a credential to make it easier to automate.~~I use the method described by my PowerShell friend Jaap Brasser [here](https://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/).~~

EDIT (September or is it March? 2020) - Nowadays I use the Secret Management Module

I run this code


     $CredentialPath = 'C:\MSSQL\BACKUP\KEEP\sacred.xml'
     Get-Credential | Export-Clixml -Path $CredentialPath

and then I can create a credential object using

    $cred = Import-Clixml $CredentialPath 

Check The Connections
---------------------

I ensure a clean session by removing the dbatools and dbachecks modules and then import the local version of dbachecks and set some variables

    $dbacheckslocalpath = 'GIT:\dbachecks\'
    Remove-Module dbatools, dbachecks -ErrorAction SilentlyContinue
    Import-Module $dbacheckslocalpath\dbachecks.psd1
    $cred = Import-Clixml $CredentialPath 
    $containers = 'localhost,15589', 'localhost,15588', 'localhost,    15587', 'localhost,15586'

Now I can start to run my Integration tests. First reset the dbachecks configuration and set some configuration values

    # run the checks against these instances
    $null = Set-DbcConfig -Name app.sqlinstance $containers
    # We are using SQL authentication
    $null = Set-DbcConfig -Name policy.connection.authscheme     -Value SQL
    # sometimes its a bit slower than the default value
    $null = Set-DbcConfig -Name policy.network.latencymaxms -Value     100 # because the containers run a bit slow!

Then I will run the dbachecks connectivity checks and save the results to a variable without showing any output

    $ConnectivityTests = Invoke-DbcCheck -SqlCredential $cred -Check Connectivity -Show None -PassThru

I can then use Pester to check that dbachecks has worked as expected by testing if the failedcount property returned is 0.

    Describe "Testing the checks are running as expected" -Tag     Integration {
        Context "Connectivity Checks" {
            It "All Tests should pass" {
                $ConnectivityTests.FailedCount | Should -Be 0     -Because "We expect all of the checks to run and     pass with default settings"
            }
        }
    }

![](https://blog.robsewell.com/assets/uploads/2019/01/check-connectivity.png)

What is the Unit Test for this PR?
----------------------------------

Next I think about what we need to be testing for the this PR. The Unit tests will help us.

![](https://blog.robsewell.com/assets/uploads/2019/01/what-are-the-unit-tests.png)

Choose some Integration Tests
-----------------------------

This check is checking the Agent job history settings and the unit tests are

*   It “Passes Check Correctly with Maximum History Rows disabled (-1)”
*   It “Fails Check Correctly with Maximum History Rows disabled (-1) but configured value is 1000”  
    
*   It “Passes Check Correctly with Maximum History Rows being 10000”  
    
*   It “Fails Check Correctly with Maximum History Rows being less than 10000”  
    
*   It “Passes Check Correctly with Maximum History Rows per job being 100”  
    
*   It “Fails Check Correctly with Maximum History Rows per job being less than 100”

So we will check the same things on real actual SQL Servers. First though we need to start the SQL Server Agent as it is not started by default. We can do this as follows

    docker exec -ti integration_sql2012_1 powershell start-service     SQLSERVERAGENT
    docker exec -ti integration_sql2014_1 powershell start-service     SQLSERVERAGENT
    docker exec -ti integration_sql2016_1 powershell start-service     SQLSERVERAGENT
    docker exec -ti integration_sql2017_1 powershell start-service     SQLSERVERAGENT

Unfortunately, the agent service wont start in the SQL 2014 container so I cant run agent integration tests for that container but it’s better than no integration tests.

![](https://blog.robsewell.com/assets/uploads/2019/01/agent-wont-start.png)

This is What We Will Test
-------------------------

So we want to test if the check will pass with default settings. In general, dbachecks will pass for default instance, agent or database settings values by default.

We also want the check to fail if the configured value for dbachecks is set to default but the value has been set on the instance.

We want the check to pass if the configured value for the dbachecks configuration is set and the instance (agent, database) setting matches it.

If You Are Doing Something More Than Once ……
--------------------------------------------

Let’s automate that. We are going to be repeatedly running those three tests for each setting that we are running integration tests for. I have created 3 functions for this again checking that FailedCount or Passed Count is 0 depending on the test.

    function Invoke-DefaultCheck {
        It "All Checks should pass with default for $Check" {
            $Tests = get-variable "$($Check)default"  -ValueOnly
            $Tests.FailedCount | Should -Be 0 -Because "We expect     all of the checks to run and pass with default setting     (Yes we may set some values before but you get my     drift)"
        }
    }
    function Invoke-ConfigCheck {
        It "All Checks should fail when config changed for $Check"     {
            $Tests = get-variable "$($Check)configchanged"      -ValueOnly
            $Tests.PassedCount | Should -Be 0 -Because "We expect     all of the checks to run and fail when we have changed     the config values"
        }
    }
    function Invoke-ValueCheck {
        It "All Checks should pass when setting changed for     $Check" {
            $Tests = get-variable "$($Check) value changed"    -ValueOnly
            $Tests.FailedCount | Should -Be 0 -Because "We expect     all of the checks to run and pass when we have changed     the settings to match the config values"
        }
    }

Now I can use those functions inside a loop in my Integration Pester Test

    $TestingTheChecks = @('errorlogscount','jobhistory')
        Foreach ($Check in $TestingTheChecks) {
            Context "$Check Checks" {
                Invoke-DefaultCheck
                Invoke-ConfigCheck
                Invoke-ValueCheck
            }
        }
Write Some Integration Tests
----------------------------

So for this new test I have added a value to the TestingTheChecks array then I can test my checks. The default check I can check like this

    # run the checks against these instances (SQL2014 agent wont     start :-( ))
    $null = Set-DbcConfig -Name app.sqlinstance $containers.Where    {$_ -ne 'localhost,15588'}
    # by default all tests should pass on default instance settings
    $jobhistorydefault = Invoke-DbcCheck -SqlCredential $cred     -Check JobHistory -Show None  -PassThru
Now I need to change the configurations so that they do not match the defaults and run the checks again

    #Change the configuration to test that the checks fail
    $null = Set-DbcConfig -Name agent.history.    maximumjobhistoryrows -value 1000
    $null = Set-DbcConfig -Name agent.history.maximumhistoryrows     -value 10000
    $jobhistoryconfigchanged = Invoke-DbcCheck -SqlCredential     $cred -Check JobHistory -Show None  -PassThru

Next we have to change the instance settings so that they match the dbachecks configuration and run the checks and test that they all pass.

We will (of course) use [dbatools](http://dbatools.io) for this. First we need to find the command that we need

    Find-DbaCommand jobserver

![](https://blog.robsewell.com/assets/uploads/2019/01/find-dbacommand.png)

and then work out how to use it

    Get-Help Set-DbaAgentServer -Detailed

![](https://blog.robsewell.com/assets/uploads/2019/01/set-the-values.png)

There is an example that does exactly what we want 🙂 So we can run this.

    $setDbaAgentServerSplat = @{
        MaximumJobHistoryRows = 1000
        MaximumHistoryRows = 10000
        SqlInstance = $containers.Where{$_ -ne 'localhost,15588'}
        SqlCredential = $cred
    }
    Set-DbaAgentServer @setDbaAgentServerSplat
    $jobhistoryvaluechanged = Invoke-DbcCheck -SqlCredential $cred     -Check JobHistory -Show None  -PassThru

Run the Integration Tests
-------------------------

And then we will check that all of the checks are passing and failing as expected

    Invoke-Pester .\DockerTests.ps1
![](https://blog.robsewell.com/assets/uploads/2019/01/testing-the-checks.png)

Integration Test For Error Log Counts
-------------------------------------

There is another integration test there for the error logs count. This works in the same way. Here is the code

    #region error Log Count - PR 583
    # default test
    $errorlogscountdefault = Invoke-DbcCheck -SqlCredential $cred     -Check ErrorLogCount -Show None  -PassThru
    # set a value and then it will fail
    $null = Set-DbcConfig -Name policy.errorlog.logcount -Value 10
    $errorlogscountconfigchanged = Invoke-DbcCheck -SqlCredential     $cred -Check ErrorLogCount -Show None  -PassThru
    
    # set the value and then it will pass
    $null = Set-DbaErrorLogConfig -SqlInstance $containers     -SqlCredential $cred -LogCount 10
    $errorlogscountvaluechanged = Invoke-DbcCheck -SqlCredential     $cred -Check ErrorLogCount -Show None  -PassThru
    #endregion

Merge the Changes
-----------------

So with all the tests passing I can merge the PR into the development branch and Azure DevOps will start a build. Ultimately, I would like to add the integration to the build as well following [André](https://twitter.com/AndreKamman)‘s blog post but for now I used the GitHub Pull Request extension to merge the pull request into development which started a [build](https://sqlcollaborative.visualstudio.com/dbachecks/_build/results?buildId=365&view=results) and then merged that into master which signed the code and deployed it to the PowerShell gallery as you can see [here](https://sqlcollaborative.visualstudio.com/dbachecks/_releaseProgress?_a=release-environment-logs&releaseId=81&environmentId=81) and the result is

[https://www.powershellgallery.com/packages/dbachecks/1.1.164](https://www.powershellgallery.com/packages/dbachecks/1.1.164)

![](https://blog.robsewell.com/assets/uploads/2019/01/powershell-gallery.png)
