# making the redirect pages.

$redirectFiles = Get-ChildItem .\archive -File

foreach ($redirect in $redirectFiles) {
    $redirectContent = Get-Content $redirect.FullName -Raw

    $pattern = 'redirect_to:\s*-\s*(https?://\S+)'
    $url = $redirectContent | Select-String -Pattern $pattern | ForEach-Object { $_.Matches.Groups[1].Value }

    $pattern = 'permalink:\s*(\S+)'
    $permalink = $redirectContent | Select-String -Pattern $pattern | ForEach-Object { $_.Matches.Groups[1].Value }

    $filecontent = @"
---
title: {1}
type: "redirect"
redirect: {0}
---
"@ -f $url, ($permalink -replace '/', '')

    $FilePath = "$($permalink -replace '/', '').md"
    if (!(Test-Path $FilePath)) {
        New-Item -Path content -Name $FilePath -ItemType File
    }
    $filecontent | Out-File -FilePath "./content/$FilePath" -Encoding utf8
}


