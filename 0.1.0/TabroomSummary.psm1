Set-StrictMode -Version Latest

#Define global module variables:
New-Variable -Name ModuleRoot -Value $PSScriptRoot -Option ReadOnly
New-Variable -Name binPath    -Value (Join-Path -Path $PSScriptRoot -ChildPath 'bin') -Option ReadOnly
New-Variable -Name etcPath    -Value (Join-Path -Path $PSScriptRoot -ChildPath 'etc') -Option ReadOnly
New-Variable -Name libPath    -Value (Join-Path -Path $PSScriptRoot -ChildPath 'lib') -Option ReadOnly

# Import global dependency files:
# $Putty = Join-Path -Path $binPath -ChildPath 'putty.exe'

# Get public and private function definition files:
$Classes = @(Get-ChildItem -Path $ModuleRoot\Classes  -Include *.ps1 -Recurse -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path $ModuleRoot\Public   -Include *.ps1 -Recurse -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $ModuleRoot\Private  -Include *.ps1 -Recurse -ErrorAction SilentlyContinue)

# Dot source the files:
foreach ($Import in @($Classes + $Public + $Private)) {
    try {
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.BaseName): $_"
    }
}
Export-ModuleMember -Function $Public.BaseName
