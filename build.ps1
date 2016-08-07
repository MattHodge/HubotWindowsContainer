#Requires -RunAsAdministrator
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Task = 'default',

    [Parameter(Mandatory=$true)]
    [string]$Version
)

if (!(Get-PackageProvider -Name Nuget -ErrorAction SilentlyContinue))
{
    Install-PackageProvider -Name NuGet -Force -Confirm:$true
}

$modulesToInstall = @(
    'Pester',
    'psake'
)

ForEach ($module in $modulesToInstall)
{
    if (!(Get-Module -Name $module -ListAvailable))
    {
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# Invoke PSake
Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -parameters @{'build_version' = $Version} -Verbose:$VerbosePreference
