<#
    .Synopsis
    Returns a random sentence that expresses a general, positive sentiment about speech and debate.
    #TODO: Add more of these.
#>
function Get-ClicheSummary{
    $clicheSummaryArray = @(
        "Everybody involved had a great time and learned a lot of valuable public speaking skills."
    )
    return $clicheSummaryArray[(Get-Random -Minimum 0 -Maximum ($clicheSummaryArray.Length))]
}
