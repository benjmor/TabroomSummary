<#
  .Synopsis
  Main routine to get the text of a summary of the tournament, given a tournament ID and school name.
  .Parameter tournamentID
  ID of the tournament on tabroom.com, visible in the URL bar. Examples: GBX2019 "12924", #RufusKing2019 "13685", #Blake2019 "14015"
  .Parameter mySchool
  Name of your school as entered on Tabroom.com. Functions will use a trailing wildcard -- "West" will match "West Des Moines" but not "Madison West"
  .Parameter tournamentJson
  JSON object if you want to provide your own JSON object for testing without downloading from tabroom.com.

  <# TODO: Parse elim round results since not all tournaments publish Final Places.
    $pfBracket = ($pfResults | where label -eq 'Bracket').results
    $roundValues = @()
    $roundValues = foreach ($elim in $pfBracket){
        $roundValues += ($elim.round)
    }
  #>

  #TODO - Add more flair.
  "went spotless with an undefeated record"
  "This was a massive tournament with over ### schools across the nation in attendance."

#>
function Write-TournamentSummary{
    [CmdletBinding()]
    param(
        [string]$tournamentID, 
        [string]$mySchool,
        $tournamentJson,
        [ref]$date,
        $maxStudentsToCallOut = 3,
        $locationOverride = "THE INTERNET" #Covid, bro
    )

    #If an object has already been downloaded and passed in, use that, otherwise download data from Tabroom.
    #This is only returning the data available to the public (no user authentication).
    if (!($tournamentJson)){
        $baseURL = "http://www.tabroom.com/api/download_data.mhtml?tourn_id="
        $response = (Invoke-WebRequest $baseURL$tournamentID).Content
        $jsonObject = Convert-TabroomJsonToObject -jsonText $response
    } else {
        $jsonObject = $tournamentJson
    }
    
    #Use tournament start date as the date for the summary
    $date = $jsonObject.start

    #Create an object that contains the entry ID, name, and code so that lookups can be done.
    #This will be necessary until there's a more robust API published.
    $globalEntryDictionary = New-EntryDictionary($jsonObject)
    $resultsStringArray = Get-TopPerformerStringsForAllEvents -jsonObject $jsonObject -entryDictionary $globalEntryDictionary

    #Especially with online tournaments, we need backup options for location.
    if ($jsonObject.city){
        $location = $jsonObject.city.ToUpper()
    } else {
        $location = $locationOverride.ToUpper()
    }

    #Start off the article with an all-caps location name, newspaper style.
    #On the same line, add a simple topic sentence explaining what tournament happened and when.
    #Then provide some generic commentary about it.
    $location + " -- " + (Get-TournamentDateString -jsonObject $jsonObject) + " " + $(Get-ClicheIntroSentence)

    #Write out the results for top finishers in each event.
    $resultsStringArray -join " " -replace "  "," " #Replace double-spaces because they're not good style.

    #school specific details
    if ($mySchool){
        #Generically state that the school of interest attended.
        Get-SchoolSpecificSummarySentence -schoolName $mySchool
        $schoolSpecificTopPerformerArray = Get-SchoolSpecificTopPerformers -specificSchoolName $mySchool -entryDictionary $globalEntryDictionary -jsonObject $jsonObject
        #TODO: How many students/entries did the school send to the tournament?
        "$mySchool sent $($schoolSpecificTopPerformerArray.count) entries to the tournament and every student competed admirably."
        ##This will likely require the full API
        #Get the TOC bids.
        $schoolSpecificBidArray = Get-TOCBidListBySchool -specificSchoolName $mySchool -entryDictionary $globalEntryDictionary -jsonObject $jsonObject
        Get-TOCBidSummary -bidArray $schoolSpecificBidArray
        #Call out top performers
        Get-TopPerformerSummary -topPerformerArray ($schoolSpecificTopPerformerArray | Sort-Object -Descending -Property { [int]$_.percentile }) -schoolName $mySchool -maxTopPerformers $maxStudentsToCallOut
    }

    #Say something nice and vacuous.
    Get-ClicheSummary
    #Link out to the full Tabroom results.
    Get-LinkToFullResultsSentence -tournamentID $tournamentID
}
