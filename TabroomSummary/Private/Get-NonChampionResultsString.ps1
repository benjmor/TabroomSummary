<#
  .Synopsis
  Returns a sentence summarizing the result for a given team.
#>
function Get-NonChampionResultsString{
    param(
        [string]$honorType,
        [string]$divName,
        [bool]$isTeam,
        [string]$TeamName,
        [string]$TeamCode
    )
    $resultsStringArray = @(
        "The $honorType in the $divName division was $(if ($isTeam){"the team of "})$resultReportTeamName ($resultReportTeamCode).",
        "$(if ($isTeam){"The team of "})$resultReportTeamName ($resultReportTeamCode) was the $honorType in $divName."
    )
    return $resultsStringArray[(Get-Random -Minimum 0 -Maximum ($resultsStringArray.Length))]
}
