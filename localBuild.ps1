#!/usr/bin/env pwsh
$version = "0.0.9"
New-Item -ItemType Directory -Force -Path ./packages

Push-Location ./src/RyanDAnthony.CodeStandards
   ((Get-Content -path ./RyanDAnthony.CodeStandards.props  -Raw) -replace "<PackageVersion>#.#.#</PackageVersion>","<PackageVersion>$($version)</PackageVersion>") | Set-Content -Path ./RyanDAnthony.CodeStandards.props
   Write-Host "Packing"
   nuget pack ./RyanDAnthony.CodeStandards.nuspec -BasePath . -OutputDirectory ../../packages -Version $version
   Write-Host "Done Packing"
   ((Get-Content -path ./RyanDAnthony.CodeStandards.props  -Raw) -replace "<PackageVersion>$($version)</PackageVersion>","<PackageVersion>#.#.#</PackageVersion>") | Set-Content -Path ./RyanDAnthony.CodeStandards.props
Pop-Location

Write-Host "Checking for Local Nuget Source."
$sourceUrl = "~/nuget/"
$nugetExists =!(dotnet nuget list source | Where-Object { $_ -like "*$sourceUrl"})
if (-not $nugetExists)
{
   Write-Host "Local Nuget Source doesn't exist. Creating."
   dotnet nuget add source $sourceUrl
}

if (!(Test-Path $sourceUrl))
{
   Write-Host "Creating $sourceUrl."
   New-Item -itemType Directory -Path $sourceUrl
   Write-Host "Created $sourceUrl."
}
else
{
   Write-Host "$sourceUrl already exists"
}

Write-Host "Copying package into nuget source."
Copy-Item ./packages/RyanDAnthony.CodeStandards.$version.nupkg ~/nuget/ -Force