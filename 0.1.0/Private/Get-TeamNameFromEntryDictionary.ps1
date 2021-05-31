<#
  .Synopsis
  Returns the team name from the given team object or team name.
  .Notes
  If $team is an object with an entry property on it, use that entry value to get the team name.
  Otherwise, assume that the value of $team is an entry ID and use that to get the team name.
  .Example
  Get-TeamNameFromEntryDictionary -entryDictionary $tournamentEntries -team $myTeam
#>
function Get-TeamNameFromEntryDictionary{
    param(
        [PsCustomObject]$team,
        [PSCustomObject]$entryDictionary
    )
    if ($team.entry){
        return (Get-PropertyByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team.entry -outputColumn name)
    } else {
        return (Get-PropertyByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team -outputColumn name)
    }
}
