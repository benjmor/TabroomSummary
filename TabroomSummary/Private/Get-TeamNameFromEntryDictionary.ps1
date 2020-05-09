<#
    .Synopsis
    Wrapper function to get Team Name
#>
function Get-TeamNameFromEntryDictionary{
    param(
        [PsCustomObject]$team,
        [PSCustomObject]$entryDictionary
    )
    if ($team.entry){
        return (Get-ByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team.entry -outputColumn name)
    } else {
        return (Get-ByID -inputColumn "entry_id" -inputObject $entryDictionary -id $team -outputColumn name)
    }
}
