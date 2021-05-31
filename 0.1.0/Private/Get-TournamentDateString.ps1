<#
    .Synopsis
    Create a sentence describing the dates on which the tournament ran.
#>
function Get-TournamentDateString{
    param(
        $jsonObject
    )
    $dayOfWeekStart = $jsonObject.start | Get-Date -Format dddd
    $dayOfWeekEnd = $jsonObject.end | Get-Date -Format dddd
    if ($dayOfWeekStart -eq $dayOfWeekEnd){
        $tournamentDaysOfWeekString = "on $dayOfWeekStart"
    } else {
        $tournamentDaysOfWeekString = "from $dayOfWeekStart through $dayOfWeekEnd"
    }
    return "The $($jsonObject.name) debate tournament was held $tournamentDaysOfWeekString."
}
