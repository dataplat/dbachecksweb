---
title: "Version Update, Code Signing and publishing to the PowerShell Gallery with VSTS"
date: "2018-05-01" 
categories:
  - Blog

tags:
  - dbachecks
  - dbatools
  - GitHub 
  - pester
  - PowerShell
  - psconfeu


image: assets/uploads/2018/05/32-Dashboard.png

---
At the fabulous [PowerShell Conference EU](http://psconf.eu) I presented about Continuous Delivery to the PowerShell Gallery with VSTS and explained how we use VSTS to enable CD for [dbachecks](http://dbachecks.io). We even released a new version during the session 🙂 

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Next on <a href="https://twitter.com/sqldbawithbeard?ref_src=twsrc%5Etfw">@sqldbawithbeard</a> presenting &quot;Continuous delivery for modules to the PowerShell gallery&quot; <a href="https://twitter.com/hashtag/PSConfEU?src=hash&amp;ref_src=twsrc%5Etfw">#PSConfEU</a> <a href="https://t.co/AubbhdewQv">pic.twitter.com/AubbhdewQv</a></p>&mdash; Fabian Bader (@fabian_bader) <a href="https://twitter.com/fabian_bader/status/986871659750678530?ref_src=twsrc%5Etfw">April 19, 2018</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

So how do we achieve this?

We have a few steps

*   Create a project and link to our GitHub
*   Run unit uests with Pester to make sure that our code is doing what we expect.
*   Update our module version and commit the change to GitHub
*   Sign our code with a code signing certificate
*   Publish to the PowerShell Gallery

Create Project and link to GitHub
---------------------------------

First you need to create a VSTS project by going to [https://www.visualstudio.com/](https://www.visualstudio.com/) This is free for up to 5 users with 1 concurrent CI/CD queue limited to a maximum of 60 minutes run time which should be more than enough for your PowerShell module.

[![01 - sign up.png](assets/uploads/2018/05/01-sign-up-1.png)](assets/uploads/2018/05/01-sign-up-1.png)

Click on Get Started for free under Visual Studio Team Services and fill in the required information. Then on the front page click new project

[![02 - New Project.png](assets/uploads/2018/05/02-New-Project.png)](assets/uploads/2018/05/02-New-Project.png)

Fill in the details and click create

[![03 - create project.png](assets/uploads/2018/05/03-create-project.png)](assets/uploads/2018/05/03-create-project.png)

Click on builds and then new definition

[![04- builds.png](assets/uploads/2018/05/04-builds.png)](assets/uploads/2018/05/04-builds.png)

next you need to link your project to your GitHub (or other source control providers) repository

[![05 - github auth.png](assets/uploads/2018/05/05-github-auth.png)](assets/uploads/2018/05/05-github-auth.png)

You can either authorise with OAuth or you can [provide a PAT token following the instructions here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). Once that is complete choose your repo. Save the PAT as you will need it later in the process!

[![06 - choose repo.png](assets/uploads/2018/05/06-choose-repo.png)](assets/uploads/2018/05/06-choose-repo.png)

and choose the branch that you want this build definition to run against.

[![07 branch.png](assets/uploads/2018/05/07-branch.png)](assets/uploads/2018/05/07-branch.png)

I chose to run the Unit Tests when a PR was merged into the development branch. I will then create another build definition for the master branch to sign the code and update module version. This enables us to push several PRs into the development branch and create a single release for the gallery.

Then I start with an empty process

[![08 - empty process.png](assets/uploads/2018/05/08-empty-process.png)](assets/uploads/2018/05/08-empty-process.png)

and give it a suitable name

[![09 - name it.png](assets/uploads/2018/05/09-name-it.png)](assets/uploads/2018/05/09-name-it.png)

i chose the hosted queue but you can download an agent to your build server if you need to do more or your integration tests require access to other resources not available on the hosted agent.

Run Unit Tests with Pester
--------------------------

We have a number of Unit tests in our [tests folder in dbachecks](https://github.com/sqlcollaborative/dbachecks/tree/development/tests) so we want to run them to ensure that everything is as it should be and the new code will not break existing functionality (and for dbachecks the [format of the PowerBi](/using-the-ast-in-pester-for-dbachecks/))

You can use the [Pester Test Runner Build Task](https://marketplace.visualstudio.com/items?itemName=richardfennellBM.BM-VSTS-PesterRunner-Task) from the folk at [Black Marble](http://blackmarble.com/) by clicking on the + sign next to Phase 1 and searching for Pester

[![10 - Pester task runner.png](assets/uploads/2018/05/10-Pester-task-runner.png)](assets/uploads/2018/05/10-Pester-task-runner.png)

You will need to click Get It Free to install it and then click add to add the task to your build definition. You can pretty much leave it as default if you wish and Pester will run all of the *.Tests.ps1 files that it finds in the directory where it downloads the GitHub repo which is referred to using the variable $(Build.SourcesDirectory). It will then output the results to a json file called Test-Pester.XML ready for publishing.

However, as dbachecks has a number of dependent modules, this task was not suitable. I spoke with Chris Gardner  [b](https://chrislgardner.github.io/) | [t](https://twitter.com/HalbaradKenafin)  from Black Marble at the PowerShell Conference and he says that this can be resolved so look out for the update. Chris is a great guy and always willing to help, you can often find him in the [PowerShell Slack channel](http://slack.poshcode.org/) answering questions and helping people

But as you can use PowerShell in VSTS tasks, this is not a problem although you need to write your PowerShell using try catch to make sure that your task fails when your PowerShell errors. This is the code I use to install the modules

$ErrorActionPreference = 'Stop'

\# Set location to module home path in artifacts directory
try {
    Set-Location $(Build.SourcesDirectory)
    Get-ChildItem
}
catch {
    Write-Error "Failed to set location"

}

\# Get the Module versions
Install-Module Configuration -Scope CurrentUser -Force
$Modules = Get-ManifestValue -Path .\\dbachecks.psd1 -PropertyName RequiredModules

$PesterVersion = $Modules.Where{$_.Get\_Item('ModuleName') -eq 'Pester'}\[0\].Get\_Item('ModuleVersion')
$PSFrameworkVersion = $Modules.Where{$_.Get\_Item('ModuleName') -eq 'PSFramework'}\[0\].Get\_Item('ModuleVersion')
$dbatoolsVersion = $Modules.Where{$_.Get\_Item('ModuleName') -eq 'dbatools'}\[0\].Get\_Item('ModuleVersion')

\# Install Pester
try {
    Write-Output "Installing Pester"
    Install-Module Pester  -RequiredVersion $PesterVersion  -Scope CurrentUser -Force -SkipPublisherCheck
    Write-Output "Installed Pester"

}
catch {
    Write-Error "Failed to Install Pester $($_)"
}
\# Install dbatools
try {
    Write-Output "Installing PSFramework"
    Install-Module PSFramework  -RequiredVersion $PsFrameworkVersion  -Scope CurrentUser -Force 
    Write-Output "Installed PSFramework"

}
catch {
    Write-Error "Failed to Install PSFramework $($_)"
}
\# Install dbachecks
try {
    Write-Output "Installing dbatools"
    Install-Module dbatools  -RequiredVersion $dbatoolsVersion  -Scope CurrentUser -Force 
    Write-Output "Installed dbatools"

}
catch {
    Write-Error "Failed to Install dbatools $($_)"
}

\# Add current folder to PSModulePath
try {
    Write-Output "Adding local folder to PSModulePath"
    $ENV:PSModulePath = $ENV:PSModulePath + ";$pwd"
    Write-Output "Added local folder to PSModulePath"    
    $ENV:PSModulePath.Split(';')
}
catch {
    Write-Error "Failed to add $pwd to PSModulePAth - $_"
}

I use the [Configuration module](https://github.com/PoshCode/Configuration) from [Joel Bennett](https://twitter.com/jaykul) to get the required module versions for the required modules and then add the path to $ENV:PSModulePath so that the modules will be imported. I think this is because the modules did not import correctly without it.

Once I have the modules I can then run Pester as follows

try {
    Write-Output "Installing dbachecks"
    Import-Module .\\dbachecks.psd1
    Write-Output "Installed dbachecks"

}
catch {
    Write-Error "Failed to Install dbachecks $($_)"
}
$TestResults = Invoke-Pester .\\tests -ExcludeTag Integration,IntegrationTests  -Show None -OutputFile $(Build.SourcesDirectory)\\Test-Pester.XML -OutputFormat NUnitXml -PassThru

if ($TestResults.failedCount -ne 0) {
    Write-Error "Pester returned errors"
}

As you can see I import the dbachecks module from the local folder, run Invoke-Pester and output the results to an XML file and check that there are no failing tests.

Whether you use the task or PowerShell the next step is to Publish the test results so that they are displayed in the build results in VSTS.

Click on the + sign next to Phase 1 and search for Publish

[![12 - publish test results.png](assets/uploads/2018/05/12-publish-test-results.png)](assets/uploads/2018/05/12-publish-test-results.png)

Choose the Publish Test Results task and leave everything as default unless you have renamed the xml file. This means that on the summary page you will see some test results

[![13 - Test on sumary page.png](assets/uploads/2018/05/13-Test-on-sumary-page.png)](assets/uploads/2018/05/13-Test-on-sumary-page.png)

and on the tests tab you can see more detailed information and drill down into the tests

[![14 - detailed test report.png](assets/uploads/2018/05/14-detailed-test-report.png)](assets/uploads/2018/05/14-detailed-test-report.png)

Trigger
-------

The next step is to trigger a build when a commit is pushed to the development branch. Click on Triggers and tick enable continuous integration

[![15 Trigger.png](assets/uploads/2018/05/15-Trigger.png)](assets/uploads/2018/05/15-Trigger.png)

Saving the Build Definition
---------------------------

I would normally save the build definition regularly and ensure that there is a good message in the comment. I always tell clients that this is like a commit message for your build process so that you can see the history of the changes for the build definition.

You can see the history on the edit tab of the build definition

[![16 - build history.png](assets/uploads/2018/05/16-build-history.png)](assets/uploads/2018/05/16-build-history.png)

If you want to compare or revert the build definition this can be done using the hamburger menu as shown below.

[![17 - build history compare revert.png](assets/uploads/2018/05/17-build-history-compare-revert.png)](assets/uploads/2018/05/17-build-history-compare-revert.png)

Update the Module Version
-------------------------

Now we need to create a build definition for the master branch to update the module version and sign the code ready for publishing to the PowerShell Gallery when we commit or merge to master

Create a new build definition as above but this time choose the master branch

[![18 - master build.png](assets/uploads/2018/05/18-master-build.png)](assets/uploads/2018/05/18-master-build.png)

Again choose an empty process and name it sensibly, click the + sign next to Phase 1 and search for PowerShell

[![19 - PowerShell task.png](assets/uploads/2018/05/19-PowerShell-task.png)](assets/uploads/2018/05/19-PowerShell-task.png)

I change the version to 2 and use this code. Note that the commit message has \*\*\*NO_CI\*\*\* in it. Putting this in a commit message tells VSTS not to trigger a build for this commit.

$manifest = Import-PowerShellDataFile .\\dbachecks.psd1 
\[version\]$version = $Manifest.ModuleVersion
Write-Output "Old Version - $Version"
\# Add one to the build of the version number
\[version\]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
Write-Output "New Version - $NewVersion"
\# Update the manifest file
try {
    Write-Output "Updating the Module Version to $NewVersion"
    $path = "$pwd\\dbachecks.psd1"
    (Get-Content .\\dbachecks.psd1) -replace $version, $NewVersion | Set-Content .\\dbachecks.psd1 -Encoding string
    Write-Output "Updated the Module Version to $NewVersion"
}
catch {
    Write-Error "Failed to update the Module Version - $_"
}

try {
    Write-Output "Updating GitHub"
git config user.email "mrrobsewell@outlook.com"
git config user.name "SQLDBAWithABeard"
git add .\\dbachecks.psd1
git commit -m "Updated Version Number to $NewVersion \*\*\*NO_CI\*\*\*"

git push https://$(RobsGitHubPAT)@github.com/sqlcollaborative/dbachecks.git HEAD:master
Write-Output "Updated GitHub "

}
catch {
    $_ | Fl -Force
    Write-Output "Failed to update GitHub"
}

I use Get-Content Set-Content as I had errors with the Update-ModuleManifest but Adam Murray [g](https://github.com/muzzar78) | [t](https://twitter.com/muzzar78) uses this code to update the version using the BuildID from VSTS

$newVersion = New-Object version -ArgumentList 1, 0, 0, $env:BUILD_BUILDID
$Public  = @(Get-ChildItem -Path $ModulePath\\Public\\*.ps1)
$Functions = $public.basename
Update-ModuleManifest -Path $ModulePath\\$ModuleName.psd1 -ModuleVersion $newVersion -FunctionsToExport $Functions

You can commit your change by adding your PAT token as a variable under the variables tab. Don’t forget to tick the padlock to make it a secret so it is not displayed in the logs

[![20 - variables.png](assets/uploads/2018/05/20-variables.png)](assets/uploads/2018/05/20-variables.png)

Sign the code with a certificate
--------------------------------

The SQL Collaborative uses a code signing certificate from [DigiCert](https://digicert.com/) who allow MVPs to use one for free to sign their code for open source projects, Thank You. We had to upload the certificate to the secure files store in the VSTS library. Click on library, secure files and the blue +Secure File button

[![21 - secure file store.png](assets/uploads/2018/05/21-secure-file-store.png)](assets/uploads/2018/05/21-secure-file-store.png)

You also need to add the password as a variable under the variables tab as above. Again don’t forget to tick the padlock to make it a secret so it is not displayed in the logs

Then you need to add a task to download the secure file. Click on the + sign next to Phase 1 and search for secure

[![22 download secure file.png](assets/uploads/2018/05/22-download-secure-file.png)](assets/uploads/2018/05/22-download-secure-file.png)

choose the file from the drop down

[![23 - download secure file.png](assets/uploads/2018/05/23-download-secure-file.png)](assets/uploads/2018/05/23-download-secure-file.png)

Next we need to import the certificate and sign the code. I use a PowerShell task for this with the following code

$ErrorActionPreference = 'Stop'
\# read in the certificate from a pre-existing PFX file
\# I have checked this with @IISResetMe and this does not go in the store only memory
$cert = \[System.Security.Cryptography.X509Certificates.X509Certificate2\]::new("$(Agent.WorkFolder)\\_temp\\dbatools-code-signing-cert.pfx","$(CertPassword)")

try {
    Write-Output "Signing Files"
    # find all scripts in your module...
Get-ChildItem  -Filter *.ps1 -Include *.ps1 -Recurse -ErrorAction SilentlyContinue |
\# ...that do not have a signature yet...
Where-Object {
  ($_ | Get-AuthenticodeSignature).Status -eq 'NotSigned'
  } |
\# and apply one
\# (note that we added -WhatIf so no signing occurs. Remove this only if you
\# really want to add digital signatures!)
Set-AuthenticodeSignature -Certificate $cert
Write-Output "Signed Files"
}
catch {
    $_ | Format-List -Force
    Write-Error "Failed to sign scripts"
}

which will import the certificate into memory and sign all of the scripts in the module folder.

Publish your artifact
---------------------

The last step of the master branch build publishes the artifact (your signed module) to VSTS ready for the release task. Again, click the + sign next to Phase one and choose the Publish Artifact task not the deprecated copy and publish artifact task and give the artifact a useful name

[![24 - publish artifact.png](assets/uploads/2018/05/24-publish-artifact.png)](assets/uploads/2018/05/24-publish-artifact.png)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Don’t forget to set the trigger for the master build as well following the same steps as the development build above

Publish to the PowerShell Gallery
---------------------------------

Next we create a release to trigger when there is an artifact ready and publish to the PowerShell Gallery.

Click the Releases tab and New Definition

[![25 - Reelase creation](assets/uploads/2018/05/25-Reelase-creation.png)](assets/uploads/2018/05/25-Reelase-creation.png)

Choose an empty process and name the release definition appropriately

[![26 Release name empty process.png](assets/uploads/2018/05/26-Release-name-empty-process.png)](assets/uploads/2018/05/26-Release-name-empty-process.png)

Now click on the artifact and choose the master build definition. If you have not run a build you will get an error like below but dont worry click add.

[![27 - add artifact.png](assets/uploads/2018/05/27-add-artifact.png)](assets/uploads/2018/05/27-add-artifact.png)

Click on the lightning bolt next to the artifact to open the continuous deployment trigger

[![28 - Choose lightning bolt](assets/uploads/2018/05/28-Choose-lightning-bolt.png)](assets/uploads/2018/05/28-Choose-lightning-bolt.png)

and turn on Continuous Deployment so that when an artifact has been created with an updated module version and signed code it is published to the gallery

[![28 - Continuous deployment trigger](assets/uploads/2018/05/28-Continuous-deployment-trigger.png)](assets/uploads/2018/05/28-Continuous-deployment-trigger.png)

Next, click on the environment and name it appropriately and then click on the + sign next to Agent Phase and choose a PowerShell step

[![29 - PowerShell Publish step](assets/uploads/2018/05/29-PowerShell-Publish-step.png)](assets/uploads/2018/05/29-PowerShell-Publish-step.png)

You may wonder why I dont choose the PowerShell Gallery Packager task. There are two reasons. First I need to install the required modules for dbachecks (dbatools, PSFramework, Pester) prior to publishing and second it appears that the API Key is stored in plain text

[![30 - PowerShell Gallery Publisher](assets/uploads/2018/05/30-PowerShell-Gallery-Publisher.png)](assets/uploads/2018/05/30-PowerShell-Gallery-Publisher.png)

I save my API key for the PowerShell Gallery as a variable again making sure to tick the padlock to make it a secret

[![31 - API Key variable.png](assets/uploads/2018/05/31-API-Key-variable.png)](assets/uploads/2018/05/31-API-Key-variable.png)

and then use the following code to install the required modules and publish the module to the gallery

Install-Module dbatools -Scope CurrentUser -Force
Install-Module Pester -Scope CurrentUser -SkipPublisherCheck -Force
Install-Module PSFramework -Scope CurrentUser -Force

Publish-Module -Path "$(System.DefaultWorkingDirectory)/Master - Version Update, Signing and Publish Artifact/dbachecks" -NuGetApiKey "$(GalleryApiKey)"

Thats it 🙂

Now we have a process that will automatically run our Pester tests when we commit or merge to the development branch and then update our module version number and sign our code and publish to the PowerShell Gallery when we commit or merge to the master branch

Added Extra – Dashboard
-----------------------

I like to create dashboards in VSTS to show the progress of the various definitions. You can do this under the dashboard tab. Click edit and choose or search for widgets and add them to the dashboard

[![32 - Dashboard.png](assets/uploads/2018/05/32-Dashboard.png)](assets/uploads/2018/05/32-Dashboard.png)

Added Extra – Badges
--------------------

You can also enable badges for displaying on your readme in GitHub (or VSTS). For the build defintions this is under the options tab.

[![33 - Build badges](assets/uploads/2018/05/33-Build-badges.png)](assets/uploads/2018/05/33-Build-badges.png)

for the release definitions, click the environment and then options and integrations

[![34 - Release Badge](assets/uploads/2018/05/34-Release-Badge.png)](assets/uploads/2018/05/34-Release-Badge.png)

You can then copy the URL and use it in your readme [like this on dbachecks](https://github.com/sqlcollaborative/dbachecks)

[![35 - dbachecks readme badges.png](assets/uploads/2018/05/35-dbachecks-readme-badges.png)](assets/uploads/2018/05/35-dbachecks-readme-badges.png)

The SQL Collaborative has joined the preview of enabling public access to VSTS projects as [detailed in this blog post](https://blogs.msdn.microsoft.com/devops/2018/04/27/vsts-public-projects-limited-preview/) So you can [see the dbachecks build and release without the need to log in](https://sqlcollaborative.visualstudio.com/dbachecks/dbachecks%20Team/_build) and soon [the dbatools process as well](https://sqlcollaborative.visualstudio.com/dbatools/_build)

I hope you found this useful and if you have any questions or comments please feel free to contact me

Happy Automating!





































