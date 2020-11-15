<#
    .Synopsis
    Function to generate an English-language sentence that describe a particular tournament result.
    .Parameter resultType
    Final Places, Prelim Seeds, Bracket, etc
    .Parameter divName
    name of the division -- Policy Debate, Congress, Dramatic Interpretation, etc.
    .Parameter resultReportTeamName
    Individual or team name -- "Andy ZZTestname", "Worlds School USA Blue", "Jones and Smith", etc.
    .Parameter resultReportTeamCode
    Team code -- "Test Academy ZZ", "DU Duolastname & Partner"
#>
function Get-ResultSentence{
    [CmdletBinding()]
    param(
        [string]$resultType,
        [string]$divName,
        [string]$resultReportTeamName,
        [string]$resultReportTeamCode
    )
    if (($resultReportTeamName -match ' and ') -or ($resultReportTeamName -match '&')){
        $isTeam = $true
    } else {
        $isTeam = $false
    }
    $honorType = if ($resultType -eq "*Prelim*") {"top seed"} elseif ($resultType -eq "*Final Place*") {"champion"}

    #Champions only
    if ($honorType -eq "champion"){
        return "$(Get-WinningSynonym) the $divName division was $(if ($isTeam){"the team of "})$resultReportTeamName ($resultReportTeamCode)."
    } else {
        return Get-NonChampionResultsString -honorType $honorType -divName $divName -isTeam $([bool]$isTeam) -TeamName $resultReportTeamName -TeamCode $resultReportTeamCode
    }
}
