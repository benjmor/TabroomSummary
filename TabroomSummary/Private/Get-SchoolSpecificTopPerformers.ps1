<#
  .Synopsis
  Currently returns all performers from a school, including their name, code, division, and rank (including percentile finish).
      #TODO: Add Speaker awards -- currently blocked by not knowing the individual student ID
#>
function Get-SchoolSpecificTopPerformers{
    [CmdletBinding()]
    param(
        $specificSchoolName,
        $entryDictionary,
        $jsonObject
    )
    $schoolSpecificEntries = Get-DebateEntriesBySchoolName -schoolName $specificSchoolName -entryDictionary $globalEntryDictionary
    $topPerformerObjectArray = @()
    foreach ($division in $jsonObject.categories.events){
        Write-Verbose "Finding school entries in $($division.type) division $($division.name)..."
        foreach ($typeOfResult in "Final Places"){ #Add Speaker Awards if we can ever get the individual student ID into the entry dictionary.
            $awardResults = $division.result_sets | where {$_.label -match $typeOfResult}
            if (-Not ($awardResults)){
                Write-Warning "No $typeOfResult entries found in $($division.type) division $($division.name) for $specificSchoolName. Continuing."
                Continue
            }
            foreach ($performance in $awardResults.results){
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
    }
    return $topPerformerObjectArray
}
