<#
    .Synopsis
    Given a school name, returns an array of team names/codes from that school that received a TOC bid.
#>
function Get-TOCBidListBySchool{
    [CmdletBinding()]
        param(
        $specificSchoolName,
        $entryDictionary,
        $jsonObject
    )
    $schoolSpecificEntries = Get-DebateEntriesBySchoolName -schoolName $specificSchoolName -entryDictionary $globalEntryDictionary
    $bidObjectArray = @()
    foreach ($division in $jsonObject.categories.events){
        $TOCBids = $division.result_sets | where {$_.label -like "TOC Qualifying Bids"}
        if (-Not ($TOCBids)){
            return $null
        }
        foreach ($bidResult in $TOCBids.results){
            if ($schoolSpecificEntries.entry_id -contains $bidResult.entry){
                $biddingTeamCode = Get-TeamCodeFromEntryDictionary -entryDictionary $globalEntryDictionary -team $bidResult
                $biddingTeamName = Get-TeamNameFromEntryDictionary -entryDictionary $globalEntryDictionary -team $bidResult
                $bidObject = [PsCustomObject]@{
                    TeamCode = $biddingTeamCode;
                    TeamName = $biddingTeamName;
                    Division = $division.name     
                }
                $bidObjectArray += $bidObject
            }
        }
    }
    return $bidObjectArray
}
