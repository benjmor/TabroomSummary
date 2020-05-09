<#
  .Synopsis
  Do a lookup over the tournament entry roster to find codes that match a given school name.
  Returns a list of entry IDs
  This is yet another workaround for not knowing what the tabroom API for entries is.
#>
function Get-DebateEntriesBySchoolName{
    param(
        [string]$schoolName,
        $entryDictionary
    )
    return $entryDictionary | where {$_.code -like "$schoolName*"} | Select-Object entry_id
}
