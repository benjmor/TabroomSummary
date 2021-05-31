<#
    .Synopsis
    Create an entryDictionary that will convert student entries to names and codes.
    .Parameter jsonObject
    JSON object of tabroom data for a tournament. At minimum, this needs access to see the ballot results of all divisions.
    .Notes
    Currently scrapes the ballot results to generate the dictionary. This takes a while.
    Hopefully this won't be necessary in the future if the Tabroom API publishes entries.
    #TODO: foreach loop over everything
#>
function New-EntryDictionary{
    [CmdletBinding()]
    param(
        [PSCustomObject]$jsonObject
    )
    $entryDictionary = @()
    foreach ($division in $jsonObject.categories.events){
        if ($division.PSobject.Properties.name -notcontains "rounds"){
            Write-Warning "No rounds found for $($division.name)."
            continue
        }
        foreach ($round in $division.rounds){
            if ($round.PSobject.Properties.name -notcontains "sections"){
                Write-Warning "No sections found for round with ID $($round.id)."
                continue
            }
            foreach ($section in $round.sections){
                if ($section.PSobject.Properties.name -notcontains "ballots"){
                    Write-Warning "No ballots found for section with ID $($section.id)."
                    continue
                }
                $ballots = $division.rounds.sections.ballots
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
        }
    }
    return $entryDictionary
}
