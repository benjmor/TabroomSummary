<#
  .Synopsis
  Return a sentence with a generic headline for a school's success at a debate tournament.
#>
function Get-Headline{
    param(
        $schoolName
    )
        $headlineArray = @(
        "$schoolName High School wins big at local debate tournament!",
        "Debaters from $schoolName compete at debate tournament!",
        "$schoolName impresses at local debate competition"
    )
    return $headlineArray[(Get-Random -Minimum 0 -Maximum ($headlineArray.Length))]
}
