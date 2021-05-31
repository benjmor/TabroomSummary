<#
    .Synopsis
        Takes a tabroom-formatted Json and returns a PowerShell object representing the tournament data.
    .Notes
        This is probably a good place to talk about the structure of a Tabroom JSON.
        
    .Example
        Convert-TabroomJsonToObject -tabroomJson "c:\temp\myJson.json"
#>
function Convert-TabroomJsonToObject{
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName="ImportByFilePath")]
        [string]$tabroomJsonPath,
        [Parameter(Mandatory=$true,
        ParameterSetName="ImportText")]
        [string]$jsonText
    )
    if ($tabroomJsonPath){
        $jsonText = Get-Content $tabroomJsonPath
    }
    #region Renames some fields that have duplicates in different case (eg. EHm and Ehm). This is a requirement so that PowerShell's case-insensitive ConvertFrom-Json works.
    $jsonTextReplaced = $jsonText.replace('"EHm"','"EHm_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"Ehms"','"Ehms_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"hmv"','"hmv_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"hmsv"','"hmsv_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"hms"','"hms_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"hm"','"hm_"')
    $jsonTextReplaced = $jsonTextReplaced.replace('"H"','"H_"')
    #endregion
    return ($jsonTextReplaced | ConvertFrom-Json)
}
