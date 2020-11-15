<#
    .Synopsis
    Create an entryDictionary that will convert student entries to names and codes.
    .Parameter jsonObject
    JSON object of tabroom data for a tournament. At minimum, this needs access to see the ballot results of all divisions.
    .Notes
    Currently scrapes the ballot results to generate the dictionary. This takes a while.
    Hopefully this won't be necessary in the future if the Tabroom API publishes entries.
#>
function New-EntryDictionary{
    [CmdletBinding()]
    param(
        [PSCustomObject]$jsonObject
    )
    $entryDictionary = @()
    foreach ($division in $jsonObject.categories){
        $ballots = $division.events.rounds.sections.ballots
        foreach ($ballot in $ballots){
            if (-Not ($entryDictionary) -or $entryDictionary.entry_id -notcontains $ballot.entry){
                $studentEntry = [PsCustomObject]@{
                    entry_id = $ballot.entry
                    name = $ballot.entry_name
                    code = $ballot.entry_code
                }
                $entryDictionary += $studentEntry
            }
        }
    }
    return $entryDictionary
}
