<#
  .Synopsis
  Uses tournament data to return a string summarizing the results for a given competition category.
#>
function Get-ResultsSentence{
    [CmdletBinding()]
    param(
        #Name of the category to get information on (eg. LD)
        [PsCustomObject]$divisionCategory,

        #use this parameter to supply Tabroom data.
        [Parameter(Mandatory=$true, ParameterSetName = "TabroomData")]
        [PsCustomObject]$entryDictionary,

        [ValidateSet("*Prelim*","*Final Place*")]
        #  Whether you want results from Prelims (ie. seeds) or Final places.
        [string]$resultType,

        #   The rank that you want data on -- eg. specify 1 for first place.
        [string]$rank
    )
    $divName = $divisionCategory.name
    $divisionResults = $division.result_sets
    $resultReport = $divisionResults | Where-Object label -Like "$resultType" #TODO: Error handling if there's more than one match
    if (-Not $resultReport){
        Write-Warning "No results found for $resultType in the $($divisionCategory.type) division $($divisionCategory.name). Skipping."
        return $null
    }
    $teamWithSpecifiedRank = ($resultReport.results | Where-Object rank -eq $rank)
    try {
      $resultReportTeam = $teamWithSpecifiedRank[0]
    } catch {
      write-warning "Could not find a matching result for $resultType and Rank $rank."
      return $null
    }
    $resultReportTeamName = Get-TeamNameFromEntryDictionary -team $resultReportTeam -entryDictionary $entryDictionary
    $resultReportTeamCode = Get-TeamCodeFromEntryDictionary -team $resultReportTeam -entryDictionary $entryDictionary
    try {
        $resultString = Get-ResultSentence -resultType $resultType -divName $divName -resultReportTeamName $resultReportTeamName -resultReportTeamCode $resultReportTeamCode
        return $resultString
    } catch {
        write-warning "Could not generate results string for team name $resultReportTeamName and team code $resultReportTeamCode."
        return $null
    }
}
