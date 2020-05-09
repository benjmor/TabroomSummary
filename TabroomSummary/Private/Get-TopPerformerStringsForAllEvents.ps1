<#
  .Synopsis
  Returns the champion (Final Place rank 1) and top seeds of all events at the tournament.
#>
function Get-TopPerformerStringsForAllEvents{
    param(
        $jsonObject,
        $entryDictionary
    )
    [string[]]$resultsArray = @()
    foreach ($division in $jsonObject.categories.events){
        $divisionResult = Get-Results -divisionCategory $division -resultType '*Final Place*' -rank 1 -entryDictionary $globalEntryDictionary
        $resultsArray += $divisionResult
        if (($division.pattern.name -like '*Debate*') -and ($division.type -notlike "*Congress*")){ #Top seed is more of a debate thing than a speech/Congress thing.
            $divisionResult = Get-Results -divisionCategory $division -resultType '*Prelim*' -rank 1 -entryDictionary $globalEntryDictionary
            $resultsArray += $divisionResult
        }
    }
    return $resultsArray
}
