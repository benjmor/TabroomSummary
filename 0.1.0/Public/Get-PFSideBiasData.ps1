function Get-PFSideBiasData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [int]$tournamentID
    )
    $myJsonObj = Convert-OfficialJsonToUsefulJson -tournamentID $tournamentID | ConvertFrom-Json
    enum Side {
        pro = 1
        con = 2
    }
    $wins = @{}
    $wins[1] = @{}
    $wins[2] = @{}
    $wins[1][[side]1] = 0
    $wins[1][[side]2] = 0
    $wins[2][[side]1] = 0
    $wins[2][[side]2] = 0

    foreach ($round in (($myJsonObj | Where-Object { $_.name -match "PF|Public Forum" } ).rounds)){
        if ($round.label -eq "Zero"){
            continue;
        }
        foreach ($ballot in $round.sections.ballots){
            if ($ballot.bye -or $ballot.forfeit -or ($ballot.winloss -eq "B")){
                continue
            }
            try {
                $ballotResultAbbrv = $ballot.winloss
                $winBool = if ($ballotResultAbbrv -eq "W") { 1 } else { 0 }
            } catch {
                continue
            }
            $side = $ballot.side
            #The converted tabroom JSON uses Aff/Neg
            if ($side -match "1|aff"){
                $side = 1
            } elseif ($side -match "2|neg") {
                $side = 2
            } else {
                Write-Verbose "Side was set as $side, which isn't understood as a pro/con position"
            }
            $speakerOrder = $ballot.speakerorder
            try {
                $wins[$speakerOrder][([side]$side)] += $winBool
            } catch {
                Write-Warning "Could not process data for $ballot"
            }
        }
    }
    #Rough data (since numbers aren't quite adding up)
    $totalWins = $wins[1][[side]1] + $wins[1][[side]2] + $wins[2][[side]1] + $wins[2][[side]2]
    if ($totalWins -lt 1) {
        Write-Error "No wins! Can't divide by zero. Exiting." -ErrorAction Stop
    }
    $proWins = $wins[1][[side]1] + $wins[2][[side]1]
    $proWinPercentage = $proWins / $totalWins
    "Pro win percentage = $(100 * $proWinPercentage)%"

    #first spks
    $firstSpeakWins = $wins[1][[side]1] + $wins[1][[side]2]
    $firstSpeakingWinPercentage = $firstSpeakWins / $totalWins
    "first speak win percentage = $(100 * $firstSpeakingWinPercentage)%"

    #drilling down...
    $firstProWinPercentage = $wins[1][[side]1] / ($wins[1][[side]1] + $wins[2][[side]2])
    "first speak PRO win percentage = $(100 * $firstProWinPercentage)%"

    $firstConWinPercentage = $wins[1][[side]2] / ($wins[1][[side]2] + $wins[2][[side]1])
    "first speak CON win percentage = $(100 * $firstConWinPercentage)%"
}