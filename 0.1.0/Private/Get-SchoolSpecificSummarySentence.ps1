<#
  .Synopsis
  Prints a random sentence summarizing a school's result at the tournament.
#>
function Get-SchoolSpecificSummarySentence{
    param(
        $schoolName
    )
        $summaryArray = @(
        "$schoolName had a good showing at the tournament."
    )
    return $summaryArray[(Get-Random -Minimum 0 -Maximum ($summaryArray.Length))]
}
