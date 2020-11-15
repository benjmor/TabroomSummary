<#
    .Synopsis
    Returns a random phrase from a list of phrases synonymous with winning. First letter is capitalized unless specified otherwise.
#>
function Get-WinningSynonym{
  [CmdletBinding()]
  param(
    [switch]$lowercase
  )
    $winningSynonymArray = @(
        "Championing",
        "Trimphant in",
        "In first place in",
        "Taking home top honors in",
        "Placing first in",
        "Victorious in",
        "Besting all competition in",
        "Crowned champion in",
        "The tournament's winner in",
        "The tournament's champion in"
    )
    if (!($lowercase)){
      return $winningSynonymArray[(Get-Random -Minimum 0 -Maximum ($winningSynonymArray.Length))]
    }
    return ($winningSynonymArray[(Get-Random -Minimum 0 -Maximum ($winningSynonymArray.Length))]).ToLower()
}
