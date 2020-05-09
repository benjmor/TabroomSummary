<#
  .Synopsis
  Returns the team code from the given team object or team name.
  .Notes
  If $team is an object with an entry property on it, use that entry value to get the team code.
  Otherwise, assume that the value of $team is an entry ID and use that to get the team code.
  .Example
  Get-TeamCodeFromEntryDictionary -entryDictionary $tournamentEntries -team $myTeam
#>
function Get-TeamCodeFromEntryDictionary{
    param(
        [PsCustomObject]$team,
        [PSCustomObject]$entryDictionary
    )
    if ($team.entry){
        return (Get-ByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team.entry -outputColumn code)
    } else {
        return (Get-ByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team -outputColumn code)
    }
}
