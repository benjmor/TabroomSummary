function Get-ClicheIntroSentence{
    [CmdletBinding()]
    param()
        $clicheIntroArray = @(
            "After several rounds of competitions, a few teams walked away ranked number one in their divisions.",
            "After a long tournament of debating, these were some of the notable results.",
            "Students competed for top honors in forensics (speech and debate) events."
    )
    return ($clicheIntroArray[(Get-Random -Minimum 0 -Maximum ($clicheIntroArray.Length))])
}