<#
  .Synopsis
  Currently returns all performers from a school, including their name, code, division, and rank (including percentile finish).
  #TODO: Actually make this return the top performers, or at least order it by percentile/rank.
#>
function Get-SchoolSpecificTopPerformers{
    param(
        $specificSchoolName,
        $entryDictionary,
        $jsonObject
    )
    $schoolSpecificEntries = Get-DebateEntriesBySchoolName -schoolName $specificSchoolName -entryDictionary $globalEntryDictionary
    $topPerformerObjectArray = @()
    foreach ($division in $jsonObject.categories.events){
        $FinalPlaces = $division.result_sets | where {$_.label -like "*Final Places*"}
            foreach ($performance in $FinalPlaces.results){
                if ($schoolSpecificEntries.entry_id -contains $performance.entry){
                    $perfTeamCode = Get-TeamCodeFromEntryDictionary -entryDictionary $globalEntryDictionary -team $performance
                    $perfTeamName = Get-TeamNameFromEntryDictionary -entryDictionary $globalEntryDictionary -team $performance
                    $performanceObject = [PsCustomObject]@{
                        TeamName = $perfTeamName;
                        TeamCode = $perfTeamCode;
                        percentile = $performance.percentile;
                        rank = $performance.rank;
                        Division = $division.name;
                    }
                    $topPerformerObjectArray += $performanceObject
                }
            }
    }
    return $topPerformerObjectArray
}
