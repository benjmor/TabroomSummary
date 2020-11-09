<#
  .Synopsis
  Uses tournament data to return a string summarizing the results for a given competition category.
  .Parameter divisionCategory
  Name of the category to get information on (eg. LD)
  .Parameter jotObject
  If using data from Joy of Tournaments, use this parameter to supply JOT data.
  .Parameter entryDictionary
  If using data from Tabroom, use this parameter to supply Tabroom data.
  .Parameter resultType
  Whether you want results from Prelims (ie. seeds) or Final places.
  .Parameter rank
  The rank that you want data on -- eg. specify 1 for first place.
#>
function Get-ResultsString{
    param(
        [PsCustomObject]$divisionCategory,
        [Parameter(Mandatory=$true, ParameterSetName = "JOTData")]
        [PsCustomObject]$jotObject,
        [Parameter(Mandatory=$true, ParameterSetName = "TabroomData")]
        [PsCustomObject]$entryDictionary,
        [ValidateSet("*Prelim*","*Final Place*")]
        [string]$resultType,
        [string]$rank
    )
    $divName = $divisionCategory.name
    $divisionResults = $division.result_sets
    $resultReport = $divisionResults | where label -Like "$resultType" #TODO: Error handling if there's more than one match
    $teamWithSpecifiedRank = ($resultReport.results | where rank -eq $rank)
    try {
      $resultReportTeam = $teamWithSpecifiedRank[0]
    } catch {
      write-error "Could not find a matching result for $resultType and Rank $rank."
      return
    }
    if ($jotObject){
        $resultReportTeamName = Get-TeamName -team $resultReportTeam -jotObject $jotObject
        $resultReportTeamDebaters = Get-TeamDebaters -team $resultReportTeam -jotObject $jotObject
    } else {
        $resultReportTeamName = Get-TeamNameFromEntryDictionary -team $resultReportTeam -entryDictionary $entryDictionary
        $resultReportTeamCode = Get-TeamCodeFromEntryDictionary -team $resultReportTeam -entryDictionary $entryDictionary
    }
    try {
        $resultString = Get-ResultSentence -resultType $resultType -divName $divName -resultReportTeamName $resultReportTeamName -resultReportTeamCode $resultReportTeamCode
        return $resultString
    } catch {
        write-error "Could not generate results string for team name $resultReportTeamName and team code $resultReportTeamCode."
    }
}
