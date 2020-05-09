<#
  .Synopsis
  Returns sentences describing the best entries from a school. The top performer array is expected to be organized in descending order by percentile/rank.
  #TODO: verify the array is sorted in a way that guarantees top performers are in descending order by percentile/rank.
#>
function Get-TopPerformerSummary{
    param(
        $topPerformerArray,
        $schoolName,
        $maxTopPerformers = 3 #Only include details for the best 3 entries from a school.
    )
    if ($topPerformerArray){
        "These were the top performing entries from $schoolName`:"
    } else {
        return
    }
    foreach ($topPerformer in $topPerformerArray[0..($maxTopPerformers-1)]){
        "$($topPerformer.TeamCode) `($($topPerformer.TeamName)`) placed in the top $($topPerformer.rank) in $($topPerformer.Division)."
    }
}
