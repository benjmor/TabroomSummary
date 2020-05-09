<#
  .Synopsis
  Returns a sentence with a link to where people can see the full results of the tournament.
#>
function Get-LinkToFullResultsSentence{
    param(
        $tournamentID
    )
    return "Full tournament results and awards are available electronically at https://www.tabroom.com/index/tourn/results/index.mhtml?tourn_id=$tournamentID."
}
