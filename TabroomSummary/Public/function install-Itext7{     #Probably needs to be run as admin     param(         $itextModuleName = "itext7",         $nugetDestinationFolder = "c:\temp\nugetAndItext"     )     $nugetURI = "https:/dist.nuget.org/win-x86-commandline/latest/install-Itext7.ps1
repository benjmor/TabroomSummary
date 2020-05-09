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
    $AddTypeArray = @(`
        "$basePath\common.logging.core\*\lib\net40\Common.Logging.Core.dll",`
        "$basePath\common.logging\*\lib\net40\Common.Logging.dll",`
        "$basePath\itext7\*\lib\net40\itext.io.dll",`
        "$basePath\portable.bouncycastle\*\lib\net40\BouncyCastle.Crypto.dll",
        "$basePath\itext7\*\lib\net40\itext.kernel.dll",
        "$basePath\itext7\*\lib\net40\itext.layout.dll"
    )
    foreach ($myDll in $AddTypeArray){
        Add-Type -Path $myDll
    }
}
