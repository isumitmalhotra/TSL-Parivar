param(
    [string]$Root = "D:\Zyphex Projects",
    [string]$OutFile = "D:\Zyphex Projects\CODEBASE_SITEMAP_TREE.txt"
)

$ErrorActionPreference = "Stop"

Set-Location $Root

$sections = @()
$sections += "TSL Codebase Quick Tree"
$sections += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$sections += "Root: $Root"
$sections += ""

$sections += "[lib]"
$sections += (Get-ChildItem -Recurse -File -Path "$Root\lib" | ForEach-Object {
    $_.FullName.Replace("$Root\", "")
})
$sections += ""

$sections += "[test]"
$sections += (Get-ChildItem -Recurse -File -Path "$Root\test" | ForEach-Object {
    $_.FullName.Replace("$Root\", "")
})
$sections += ""

$sections += "[docs]"
$sections += (Get-ChildItem -Recurse -File -Filter *.md -Path $Root | ForEach-Object {
    $_.FullName.Replace("$Root\", "")
})
$sections += ""

$sections += "[firebase-config]"
$firebaseFiles = @(
    "firebase.json",
    "firestore.rules",
    "firestore.indexes.json",
    "storage.rules",
    ".firebaserc"
)
$sections += ($firebaseFiles | Where-Object { Test-Path (Join-Path $Root $_) })

$sections -join [Environment]::NewLine | Set-Content -Path $OutFile -Encoding UTF8
Write-Host "Wrote sitemap tree to $OutFile"

