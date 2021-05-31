<#
  .Synopsis
  Installs iText7 using Nuget.
  .Notes
  Probably needs to be run as administrator.
  I have not tested the system requirements or dependencies for this software, but it is necessary to using the iText API for PDF manipulation.
#>
function install-Itext7{
    param(
        $itextModuleName = "itext7",
        $nugetDestinationFolder = "c:\temp\nugetAndItext"
    )
    $nugetURI = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    New-Item -Path $nugetDestinationFolder -ItemType Directory -ErrorAction Ignore
    $nugetExeLocation = "$nugetDestinationFolder\nuget.exe"
    Invoke-RestMethod -Method Get -Uri $nugetURI -OutFile $nugetExeLocation
    &$nugetExeLocation install $itextModuleName
    
    #addTypes
    $basePath = "$home\.nuget\packages"
    #Get all versions of iText available
    $commonLoggingCoreVersions = (Get-ChildItem "$basePath\common.logging.core\").FullName
    $commonLoggingVersions = (Get-ChildItem "$basePath\common.logging\").FullName
    $itextVersions = (Get-ChildItem "$basePath\itext7\").FullName
    $bouncyCastleVersions = (Get-ChildItem "$basePath\portable.bouncycastle\").FullName

    Add-Type -Path "$commonLoggingCoreVersions\lib\net40\Common.Logging.Core.dll"
    Add-Type -Path "$commonLoggingVersions\lib\net40\Common.Logging.dll"
    Add-Type -Path "$itextVersions\lib\net45\itext.io.dll"
    Add-Type -Path "$itextVersions\lib\net45\itext.kernel.dll"
    Add-Type -Path "$itextVersions\lib\net45\itext.layout.dll"
    Add-Type -Path "$bouncyCastleVersions\lib\net40\BouncyCastle.Crypto.dll"
}
