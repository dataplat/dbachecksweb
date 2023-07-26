---
title: "dbachecks – Which Configuration Item For Which Check ?"
date: "2018-05-15" 
categories:
  - dbachecks
  - Blog

tags:
  - dbachecks
  - GitHub 


image: assets/uploads/2018/05/03-New-dbccheck.png

---
I love showing [dbachecks](http://dbachecks.io) to people. It’s really cool seeing how people will use it and listening to their experiences. I was showing it to a production DBA a month or so ago and he said

How Do I Know Which Checks There Are?
-------------------------------------

OK you just need to run

`Get-DbcCheck`

and it will show you

[![01 - get-dbcchecks.png](assets/uploads/2018/05/01-get-dbcchecks.png)](assets/uploads/2018/05/01-get-dbcchecks.png)

It will show you the group, the type (does it need a computer name or an instance name), The description, the unique tag for running just that check and all the tags that will run that check

OK he said, you talked about configurations

How Do I Know Which Configurations There Are?
---------------------------------------------

So to do that you just need to run

`Get-DbcConfig`

and it will show you

[![02 - dbcconfig.png](assets/uploads/2018/05/02-dbcconfig.png)](assets/uploads/2018/05/02-dbcconfig.png)

You can see the name, the current value and the description

Ah thats cool he said so

How Do I Know Which Configuration Is For Which Check?
-----------------------------------------------------

Well, you just…. , you know…… AHHHHHHH

Ping – light bulb moment!

It’s always really useful to give something you have built to people who have never seen it before and then listen to what they say. Their new eyes and different experiences or expectations will give you lots of insight

None of the amazing contributors to dbachecks had thought of this scenario so I decided to fix this. First I asked for an [issue to be raised in GitHub](https://github.com/sqlcollaborative/dbachecks/issues) because an issue can be an improvement or a suggestion not just a bug.

Then I fixed it so that it would do what was required. Thank you Nick for this feedback and for helping to improve dbachecks

I improved `Get-DbcCheck` so that now it shows the configuration item related to each check

It is easier to see (and sort or search) if you use Out-GridView

    Get-DbcCheck | Out-GridView

[![03 - New dbccheck.png](assets/uploads/2018/05/03-New-dbccheck.png)](assets/uploads/2018/05/03-New-dbccheck.png)

So now you can see which configuration can be set for each check!

Happy Validating!





