<#
  .Synopsis
  If given an array of team objects, prints information describing the TOC and listing the teams in that array as bid recipients.
#>
function Get-TOCBidSummary{
    param(
        $bidArray
    )
    if ($bidArray){
        "At least one student qualified to the prestigious Tournament of Champions in Lexington, Kentucky. The Tournament of Champions is an exclusive invitational that requires reaching late elimination rounds at a minimum of two sanctioned national circuit tournaments."
    }
    foreach ($bidder in $bidArray){
        "$($bidder.TeamCode) `($($bidder.TeamName)`) received a bid in $($bidder.Division)."
    }
}
