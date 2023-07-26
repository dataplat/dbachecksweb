---
title: "Checking Trace Flags with dbachecks, online docs and PSPowerHour"
date: "2018-09-29" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - dbatools
  - pester
  - PowerShell
  - pspowerhour

---
It’s been a few weeks since i have blogged as I have been busy with a lot of other things. One of which is preparing for [my SQL Pass Summit pre-con](https://www.pass.org/summit/2018/Sessions/Details.aspxsid=80306) which has lead to me improving the CI/CD for [dbachecks](http://dbachecks.io) by adding auto-creation of online documentation, which you can find at [https://dbachecks.readthedocs.io](https://dbachecks.readthedocs.io) or by running Get-Help with the -Online switch for any dbachecks command.

Get-Help Invoke-DbcCheck -Online

![01 - online help.png](https://blog.robsewell.com/assets/uploads/2018/09/01-online-help.png)

I will blog about how dbachecks uses [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/) to do this another time

PSPowerHour
-----------

The PowerShell community members [Michael T Lombardi](https://twitter.com/barbariankb) and [Warren Frame](http://twitter.com/psCookieMonster) have created [PSPowerHour](https://github.com/PSPowerHour/PSPowerHour). PSPowerHour is “like a virtual User Group, with a lightning-demo format, and room for non-PowerShell-specific content. Eight community members will give a demo each PowerHour.”

[Chrissy](http://twitter.com/cl) blogged about the first one [on the dbatools blog](https://dbatools.io/pspowerhour/)

You can watch the videos on the [Youtube channel](https://www.youtube.com/channel/UCtHKcGei3EjxBNYQCFZ3WNQ) and keep an eye out for more online [PSPowerHours via twitter](https://twitter.com/hashtag/PSPowerHoursrc=hash) or [the GitHub page](https://github.com/PSPowerHour/PSPowerHour).

While watching the first group of sessions [Andrew Wickham](https://twitter.com/awickham) demonstrated using dbatools with trace flags and I thought that needs to be added to dbachecks so I created [an issue.](https://github.com/sqlcollaborative/dbachecks/issues/529) Anyone can do this to file improvements as well as bugs for members of the team to code.

Trace Flags
-----------

The previous release of dbachecks brought 2 new checks for traceflags. One for traceflags expected to be running and one for traceflags not expected to be running.

You will need to have installed [dbachecks from the PowerShell Gallery](https://www.powershellgallery.com/packages/dbachecks) to do this. This can be done using

Install-Module -Name dbachecks

Once dbachecks is installed you can find the checks using

Get-DBcCheck

you can filter using the pattern parameter

Get-DBcCheck -Pattern traceflag

![02 - get0dbcconfig.png](https://blog.robsewell.com/assets/uploads/2018/09/02-get0dbcconfig.png)

This will show you

*   the UniqueTag which will enable you to run only that check if you wish
*   AllTags which shows which tags will include that check
*   Config will show you which configuration items can be set for this check

The trace flag checks require the app.sqlinstance configuration which is the list of SQL instances that the checks will run against. You can also specify the instances as a parameter for [Invoke-DbCheck](https://dbachecks.readthedocs.io/en/latest/functions/Invoke-DbcCheck/) as well.

The configuration for the expected traceflags is policy.traceflags.expected By default it is set to null. You can see what configuration it has using

Get-DBcConfig policy.traceflags.expected

![get-dbcconfig.png](https://blog.robsewell.com/assets/uploads/2018/09/get-dbcconfig.png)

So if you want to check that there are no trace flags running, then you can run

$instance = 'sql0'
Set-DbcConfig -Name app.sqlinstance -Value $instance
Invoke-DbcCheck -Check TraceFlagsExpected

![check 1.png](https://blog.robsewell.com/assets/uploads/2018/09/check-1.png)

Maybe this instance is required to have [trace flag 1117 enabled](https://blogs.msdn.microsoft.com/sql_pfe_blog/2017/07/18/trace-flag-1117-growth-and-contention/) so that [all files in a file group grow equally](https://www.brentozar.com/archive/2014/06/trace-flags-1117-1118-tempdb-configuration/), you can set the trace flag you expect to be running using

Set-DbcConfig -Name policy.traceflags.expected -Value 1117

![set config.png](https://blog.robsewell.com/assets/uploads/2018/09/set-config.png)

Now you when you run the check it fails

Invoke-DbcCheck -Check TraceFlagsExpecte

![not found.png](https://blog.robsewell.com/assets/uploads/2018/09/not-found.png)

and gives you the error message

>  \[-\] Expected Trace Flags 1117 exist on sql0 593ms  
> Expected 1117 to be found in collection @(), because We expect that Trace Flag 1117 will be set on sql0, but it was not found.

So we have a failing test. We need to fix that. We can use [dbatools](http://dbatools.io)

Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 1117

![set traceflag.png](https://blog.robsewell.com/assets/uploads/2018/09/set-traceflag.png)

This time when we run the check

`Invoke-DbcCheck -Check TraceFlagsExpected`

it passes

![passed test](https://blog.robsewell.com/assets/uploads/2018/09/passed-test.png)

If you just need to see what trace flags are enabled you can use

`Get-DbaTraceFlag -SqlInstance $instance`

![get trace flag.png](https://blog.robsewell.com/assets/uploads/2018/09/get-trace-flag.png)

Reset the configuration for the expected trace flag to an empty array and then set the configuration for traceflags we do not expect to be running to 1117
```
Set-DbcConfig -Name policy.traceflags.expected -Value @()
Set-DbcConfig -Name policy.traceflags.notexpected -Value 1117
```
![set config 2.png](https://blog.robsewell.com/assets/uploads/2018/09/set-config-2.png)

and then run the trace flags not expected to be running check with

`Invoke-DbcCheck -Check TraceFlagsNotExpected`

It will fail as 1117 is still running

![not expected fail.png](https://blog.robsewell.com/assets/uploads/2018/09/not-expected-fail.png)

and give the message

> \[-\] Expected Trace Flags 1117 to not exist on sql0 321ms  
> Expected 1117 to not be found in collection 1117, because We expect that Trace Flag 1117 will not be set on sql0, but it was found.

So to resolve this failing check we need to disable the trace flag and we can do that with dbatools using

`Disable-DbaTraceFlag -SqlInstance $instance -TraceFlag 1117`

![disable trace flag](https://blog.robsewell.com/assets/uploads/2018/09/disable-trace-flag-1.png)

and now when we run the check

`Invoke-DbcCheck -Check TraceFlagsNotExpected`

it passes

![passed bnot expected.png](https://blog.robsewell.com/assets/uploads/2018/09/passed-bnot-expected.png)

The checks also work with multiple traceflags so you can set multiple values for trace flags that are not expexted to be running

`Set-DbcConfig -Name policy.traceflags.notexpected -Value 1117, 1118`

and as we saw earlier, you can run both trace flag checks using

`Invoke-DbcCheck -Check TraceFlag`

![multi checks.png](https://blog.robsewell.com/assets/uploads/2018/09/multi-checks.png)

You can use this or any of the 95 available checks to validate that your SQL instances, singular or your whole estate are as you expect them to be.




