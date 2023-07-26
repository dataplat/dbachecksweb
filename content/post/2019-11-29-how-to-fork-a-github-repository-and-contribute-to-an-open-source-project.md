---
title: "How to fork a GitHub repository and contribute to an open source project"
date: "2019-11-29" 
categories:
  - Blog
  - Source Control
  - Jupyter Notebooks
  - Azure Data Studio
  - dbatools
  - dbachecks

tags:
  - adsnotebook
  - dbachecks
  - dbatools
  - GitHub 
  - PowerShell
  - Open Source


image: assets/uploads/2019/11/CreatePR.png

---
I enjoy maintaining open source GitHub repositories such as [dbachecks](https://github.com/sqlcollaborative/dbachecks) and [ADSNotebook](https://github.com/sqlcollaborative/ADSNotebook). I absolutely love it when people add more functionality to them.

To collaborate with a repository in GitHub you need to follow these steps

![](https://blog.robsewell.com/assets/uploads/2019/11/GitHub.png)

*   Fork the repository into your own GitHub
*   Clone the repository to your local machine
*   Create a new branch for your changes
*   Make some changes and commit them with useful messages
*   Push the changes to your repository
*   Create a Pull Request from your repository back to the original one

You will need to have `git.exe` available which you can download and install from [https://git-scm.com/downloads](https://git-scm.com/downloads) if required

Fork the repository into your own GitHub
----------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/ForkRepo.png)

A fork is a copy of the original repository. This allows you to make changes without affecting the original project. It does not get updated when the original project gets updated (We will talk about that in the next post) This enables you to code a new feature or a bug fix, test it locally and make sure it is working.

Let’s take dbachecks as our example. Start by going to the project in GiHub. In this case the URL is [https://github.com/sqlcollaborative/dbachecks](https://github.com/sqlcollaborative/dbachecks) You will see a Fork button at the top right of the page

![](https://blog.robsewell.com/assets/uploads/2019/11/image-41.png?fit=630%2C74&ssl=1)

When you click the button the repository is copied into your own GitHub account

![](https://blog.robsewell.com/assets/uploads/2019/11/image-42.png?resize=630%2C304&ssl=1)

The page will open at [https://github.com/YOURGITHUBUSERNAME/NameOfRepository](https://github.com/SQLDBAWithABeard/dbachecks) in this case [https://github.com/SQLDBAWithABeard/dbachecks](https://github.com/SQLDBAWithABeard/dbachecks) You will be able to see that it is a fork of the original repository at the top of the page

![](https://blog.robsewell.com/assets/uploads/2019/11/image-43.png?resize=474%2C119&ssl=1)

Clone the repository to your local machine
------------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/CloneRepo-2.png?resize=630%2C218&ssl=1)

Forking the repository has created a _remote_ repository stored on the GitHub servers. Now that the repository has been forked you need to clone it to your local machine to create a _local_ repository so that you can start coding your amazing fix. When you have finished you can then sync it back to your _remote_ repository ready for a Pull Request back to the original repository.

In your browser, at your _remote_ repository that you just created ([https://github.com/YOURGITHUBUSERNAME/NameOfRepository](https://github.com/SQLDBAWithABeard/dbachecks) if you have closed the page) click on `Clone or Download` and then the icon to the right to copy the url

![](https://blog.robsewell.com/assets/uploads/2019/11/image-46.png?fit=630%2C316&ssl=1)

You can clone your repository in [VS Code](https://code.visualstudio.com/) or [Azure Data Studio](https://aka.ms/azuredatastudio) by clicking F1 or CTRL + SHIFT + P in Windows or Linux and ⇧⌘P or F1 on a Mac

![](https://blog.robsewell.com/assets/uploads/2019/11/image-44.png?fit=630%2C206&ssl=1)

then start typing clone until you see `Git:Clone` and press enter or click

![](https://blog.robsewell.com/assets/uploads/2019/11/image-45.png?fit=630%2C100&ssl=1)

Paste in the URL that you just copied and click enter. A dialog will open asking you to select a folder. This is the parent directory where your _local_ repository will be created. The clone will create a directory for your repository so you do not need to. I suggest that you use a folder called GitHub or something similar to place all of the repositories that you are going to clone and create.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-47.png?fit=630%2C345&ssl=1)

When it has finished it will ask you if you wish to open the repository

![](https://blog.robsewell.com/assets/uploads/2019/11/image-49.png?fit=630%2C215&ssl=1)

if you click `Open` it will close anything that you have already got opened and open the folder. If you click `Add to Workspace` it will add the folder to the workspace and leave everything you already had open as it was and surprisingly clicking `Open in New Window` will open the folder in a new instance of Visual Studio Code or Azure Data Studio!

![](https://blog.robsewell.com/assets/uploads/2019/11/image-51.png?fit=630%2C997&ssl=1)

and you will also be able to see the local repository files on your computer

![](https://blog.robsewell.com/assets/uploads/2019/11/image-50.png?resize=442%2C244&ssl=1)

You can clone the repository at the command line if you wish by navigating to your local GitHub directory and running `git clone TheURLYouCopied`

![](https://blog.robsewell.com/assets/uploads/2019/11/image-48.png?fit=630%2C165&ssl=1)

Now your _local_ repository has been created, it’s time to do your magic coding.

Create a new branch for your changes
------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/NewBranch.png?resize=630%2C218&ssl=1)

It is a good idea to create a branch for your `amazing new feature` This enables you to work on coding for that feature in isolation. It has the added advantage that if you mess it right royally up, you can just delete that branch and start again with a new one!

To create a branch in VS Code or Azure Data Studio you can click on the branch name at the bottom left.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-52.png?resize=630%2C284&ssl=1)

Or open the Command Palette and type Branch until you see `Git: Create Branch`

![](https://blog.robsewell.com/assets/uploads/2019/11/image-53.png?fit=630%2C282&ssl=1)

You will be prompted for a branch name

![](https://blog.robsewell.com/assets/uploads/2019/11/image-54.png?fit=630%2C96&ssl=1)

I like to choose a name that relates to the code that I am writing like `configurable_engine` or `removeerroringexample` You can see the name of the branch in the bottom left so that you always know which branch you are working on.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-55.png?fit=630%2C312&ssl=1)

The icon shows that the branch is only _local_ and hasn’t been pushed (published) to the _remote_ repository yet

Make some changes and commit them with useful messages
------------------------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/awesomenewfeature.png?resize=630%2C246&ssl=1)

Now you can start writing your code for your awesome new feature, bug fix or maybe just documentation improvement. Keep your commits small and give them useful commit messages that explain _why_ you have made the change as the diff tooling will be able to show _what_ change you have made

Write your code or change the documentation, save the file and in Visual Studio Code or Azure Data Studio you will see that the source control icon has a number on it

![](https://blog.robsewell.com/assets/uploads/2019/11/image-56.png?fit=630%2C143&ssl=1)

Clicking on the icon will show the files that have changes ready

![](https://blog.robsewell.com/assets/uploads/2019/11/image-57.png?fit=630%2C290&ssl=1)

You can write your commit message in the box and click CTRL + ENTER to commit your changes with a message

![](https://blog.robsewell.com/assets/uploads/2019/11/image-58.png?fit=630%2C296&ssl=1)

If you want to do this at the command line, you can use `git status` to see which files have changes

![](https://blog.robsewell.com/assets/uploads/2019/11/image-59.png?fit=630%2C195&ssl=1)

You will need to `git add .`or `git add .\pathtofile` to stage your changes ready for committing and then `git commit -m 'Commit Message'` to commit them

![](https://blog.robsewell.com/assets/uploads/2019/11/image-60.png?fit=630%2C128&ssl=1)

Notice that I did exactly what I just said not to do! A better commit message would have been _So that people can find the guide to forking and creating a PR_

Push the changes to your repository
-----------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/publishbranch.png?resize=630%2C219&ssl=1)

You only have the changes that you have made in your _local_ repository on your computer. Now you need to push those changes to GitHub your _remote_ repository. You can click on the publish icon

![](https://blog.robsewell.com/assets/uploads/2019/11/image-55.png?resize=630%2C312&ssl=1)

You will get a pop-up asking you if you wish to stage your changes. I click `Yes` and never `Always` so that I can use this prompt as a sanity check that I am doing the right thing

![](https://blog.robsewell.com/assets/uploads/2019/11/image-75.png?fit=630%2C150&ssl=1)

At the command line you can push the branch, if you do that, you will have to tell git where the branch needs to go. If you just type `git push` it will helpfully tell you

![](https://blog.robsewell.com/assets/uploads/2019/11/image-61.png?fit=630%2C121&ssl=1)

    fatal: The current branch AwesomeNewFeature has no upstream branch.
    To push the current branch and set the remote as upstream, use
    
        git push --set-upstream origin AwesomeNewFeature

So you will need to use that command

![](https://blog.robsewell.com/assets/uploads/2019/11/image-62.png?fit=630%2C282&ssl=1)

You can see in the bottom left that the icon has changed

![](https://blog.robsewell.com/assets/uploads/2019/11/image-63.png?fit=630%2C186&ssl=1)

and if you read the output of the `git push` command you will see what the next step is also.

Create a Pull Request from your repository back to the original one
-------------------------------------------------------------------

![](https://blog.robsewell.com/assets/uploads/2019/11/CreatePR.png?resize=630%2C238&ssl=1)

You can CTRL click the link in the `git push` output if you have pushed from the command line or if you visit either you repository or the original repository in your browser you will see that there is a `Compare and Pull Request` button

![](https://blog.robsewell.com/assets/uploads/2019/11/image-64.png?fit=630%2C334&ssl=1)

You click that and let GitHub do its magic

![](https://blog.robsewell.com/assets/uploads/2019/11/image-65.png?fit=630%2C459&ssl=1)

and it will create a Pull Request for you ready for you to fill in the required information, ask for reviewers and other options. Once you have done that you can click `Create pull request` and wait for the project maintainer to review it and (hopefully) accept it into their project

You can find the Pull Request that I created here [https://github.com/sqlcollaborative/dbachecks/pull/720](https://github.com/sqlcollaborative/dbachecks/pull/720) and see how the rest of this blog post was created.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-66.png?fit=630%2C489&ssl=1)

If you make more changes to the code in the same branch in your _local_ repository and push them, they will automatically be added to this Pull Request whilst it is open. You can do this if the maintainer or reviewer asks for changes.

Shane has asked for a change

![](https://blog.robsewell.com/assets/uploads/2019/11/image-67.png?resize=630%2C110&ssl=1)

So I can go to my _local_ repository in Azure Data Studio and make the requested change and save the file. If I look in the source control in Azure Data Studio I can again see there is a change waiting to be committed and if I click on the name of the file I can open the diff tool to see what the change was

![](https://blog.robsewell.com/assets/uploads/2019/11/image-68.png?fit=630%2C128&ssl=1)

Once I am happy with my change I can commit it again in the same way as before either in the editor or at the command line. The icon at the bottom will change to show that I have one commit in my _local_ repository waiting to be pushed

![](https://blog.robsewell.com/assets/uploads/2019/11/image-69.png?fit=630%2C160&ssl=1)

To do the same thing at the command line I can type `git status` and see the same thing.

![](https://blog.robsewell.com/assets/uploads/2019/11/image-70.png?fit=630%2C138&ssl=1)

I can then push my change to my remote repository either in the GUI or by using `git push`

![](https://blog.robsewell.com/assets/uploads/2019/11/image-72.png?fit=630%2C213&ssl=1)

and it will automatically be added to the Pull Request as you can see

![](https://blog.robsewell.com/assets/uploads/2019/11/image-73.png?fit=630%2C480&ssl=1)

Now that the required changes for the review have been made, the review has been approved by Shane and the pull request is now ready to be merged. (You can also see that dbachecks runs some checks against the code when a Pull Request is made)

![](https://blog.robsewell.com/assets/uploads/2019/11/image-74.png?resize=630%2C359&ssl=1)

Many, many thanks to Shane [b](https://twitter.com/sozdba) | [t](https://nocolumnname.blog/) who helped with the writing of this post even whilst on a “no tech” holiday.

Go Ahead – Contribute to an Open Source Project
-----------------------------------------------

Hopefully you can now see how easy it is to create a fork of a GitHub repository, clone it to your own machine and contribute. There are many open source projects that you can contribute to.

You can use this process to contribute to the Microsoft Docs for example by clicking on the edit button on any page.

You can contribute other open source projects like

*   **[PowerShell](https://github.com/PowerShell/PowerShell)** by Microsoft
*   **[tigertoolbox](https://github.com/microsoft/tigertoolbox)** by Microsoft Tiger Team
*   [dbatools](https://github.com/sqlcollaborative/dbatools)
*   [dbachecks](https://github.com/sqlcollaborative/dbachecks)
*   [ADSNotebook](https://github.com/sqlcollaborative/ADSNotebook)
*   [PSDatabaseClone](https://github.com/sqlcollaborative/PSDatabaseClone)
*   **[OpenQueryStore](https://github.com/OpenQueryStore/OpenQueryStore)** by William Durkin and Enrico van de Laar
*   **[sqlwatch](https://github.com/marcingminski/sqlwatch)** by Marcin Gminski
*   [SQLCop](https://github.com/red-gate/SQLCop) by Redgate
*   **[sp_whoisactive](https://github.com/amachanic/sp_whoisactive)** by Adam Machanic
*   **[sql-server-maintenance-solution](https://github.com/olahallengren/sql-server-maintenance-solution)** by Ola Hallengren
*   **[SQL-Server-First-Responder-Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit)** by Brent Ozar Unlimited
*   **[Pester](https://github.com/pester/Pester)**
*   **[ReportingServicesTools](https://github.com/microsoft/ReportingServicesTools)**

or go and find the the ones that you use and can help with.
