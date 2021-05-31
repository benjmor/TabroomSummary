<#
  .Synopsis
    Returns sentences describing the best entries from a school. The top performer array is expected to be organized in descending order by percentile/rank.
    #TODO: Return the number of entries in each division.    
#>
function Get-TopPerformerSummary{
    [CmdletBinding()]
    param(
        $topPerformerArray,
        $schoolName,
        $maxTopPerformers = 3 #Only include details for the best 3 entries from a school.
    )
    if ($topPerformerArray.length -gt 1){
        "These were the top performing entries from $schoolName`:"
    } else {
        return
    }
    $resultsToReturn = (@($maxTopPerformers, $topPerformerArray.length) | Measure-Object).Minimum #If you only have two entries, don't return three entries...
    foreach ($topPerformer in $topPerformerArray[0..($resultsToReturn-1)]){
        "$($topPerformer.TeamCode) `($($topPerformer.TeamName)`) placed in the top $($topPerformer.rank) in $($topPerformer.Division)."
    }
}
