<#
    .Synopsis
    This script will convert a Tabroom JSON to just the essentials of what is needed to actually get useful results from it.
#>
function Convert-TabroomJsonToObjectResultsOnly{
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName="ImportByFilePath")]
        [string]$tabroomJsonPath,
        [Parameter(Mandatory=$true,
        ParameterSetName="ImportText")]
        [string]$jsonText
    )
    if ($jsonText){
        $obj = Convert-TabroomJsonToObject -JsonText $jsonText
    } else {
        $obj = Convert-TabroomJsonToObject -TabroomJsonPath $tabroomJsonPath
    }
    $obj
}