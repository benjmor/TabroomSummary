<#
  .Synopsis
  Main routine to get the text of a summary of the tournament, given a tournament ID and school name.
  .Parameter tournamentID
  ID of the tournament on tabroom.com, visible in the URL bar. Examples: GBX2019 "12924", #RufusKing2019 "13685", #Blake2019 "14015"
  .Parameter mySchool
  Name of your school as entered on Tabroom.com. Functions will use a trailing wildcard -- "West" will match "West Des Moines" but not "Madison West"
  .Parameter tournamentJson
  JSON object if you want to provide your own JSON object for testing without downloading from tabroom.com.
#>
function Write-TournamentSummary{
    param(
        [string]$tournamentID, 
        [string]$mySchool,
        $tournamentJson
    )

    if (!($tournamentJson)){
        $baseURL = "http://www.tabroom.com/api/download_data.mhtml?tourn_id="
        $response = (Invoke-WebRequest $baseURL$tournamentID).Content
        $jsonObject = ConvertJSON-ToObject -jsonText $response
    } else {
        $jsonObject = $tournamentJson
    }

    #Create an object that contains the entry ID, name, and code so that lookups can be done.
    $globalEntryDictionary = Create-EntryDictionary($jsonObject)

    $jsonObject.city.ToUpper() + " -- " + (Get-TournamentDateString -jsonObject $jsonObject) + " " + "After several rounds of competitions, a few teams walked away ranked number one in their divisions."

    $resultsArray = Get-TopPerformerStringsForAllEvents -jsonObject $jsonObject -entryDictionary $globalEntryDictionary
    $resultsArray -join " "

    #region school specifics
    Get-SchoolSpecificSummarySentence -schoolName $mySchool
    #TODO: How many students/entries did the school send to the tournament?
    ##This will likely require the full API
    #Get the TOC bids.
    $schoolSpecificBidArray = Get-TOCBidListBySchool -specificSchoolName $mySchool -entryDictionary $globalEntryDictionary -jsonObject $jsonObject
    Get-TOCBidSummary -bidArray $schoolSpecificBidArray
    #Call out top performers
    $schoolSpecificTopPerformerArray = Get-SchoolSpecificTopPerformers -specificSchoolName $mySchool -entryDictionary $globalEntryDictionary -jsonObject $jsonObject
    Get-TopPerformerSummary -topPerformerArray ($schoolSpecificTopPerformerArray | Sort-Object -Descending -Property percentile) -schoolName $mySchool
    #TODO: Add Speaker awards
    #endregion
    <# TODO: Parse elim round results since not all tournaments publish Final Places.
    $pfBracket = ($pfResults | where label -eq 'Bracket').results
    $roundValues = @()
    $roundValues = foreach ($elim in $pfBracket){
        $roundValues += ($elim.round)
    }
    #>
    #Say something nice and vacuous.
    Get-ClicheSummary
    #Link out to the full Tabroom results.
    Get-LinkToFullResultsSentence -tournamentID $tournamentID
}
