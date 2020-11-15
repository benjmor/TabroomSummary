<#
  .Synopsis
  Returns the champion (Final Place rank 1) and top seeds of all events at the tournament.
#>
function Get-TopPerformerStringsForAllEvents{
    [CmdletBinding()]
    param(
        $jsonObject,
        $entryDictionary
    )
    [string[]]$resultsArray = @()
    foreach ($division in $jsonObject.categories.events){
        $divisionResult = Get-ResultsSentence -divisionCategory $division -resultType '*Final Place*' -rank 1 -entryDictionary $globalEntryDictionary
        if (-Not ($divisionResult)){
            continue
        }
        $resultsArray += $divisionResult
        if (($division.type -notmatch "congress|senate|house") -and ($division.type -match 'debate')){ #Top seed is more of a debate thing than a speech/Congress thing.
            $divisionResult = Get-ResultsSentence -divisionCategory $division -resultType '*Prelim*' -rank 1 -entryDictionary $globalEntryDictionary
            $resultsArray += $divisionResult
        }
    }
    return $resultsArray
}
