function Convert-OfficialJsonToUsefulJson {
    [CmdletBinding()]
    param (
        $tournamentID = 19483,
        $outPath = "$env:USERPROFILE\desktop\tournament_${tournamentID}_output.json",
        $jsonPath,
        $patternMatch
    )
    if ($jsonPath) {
        $content = Get-Content C:\users\redbe\Desktop\debateJsonTest.txt
    } else {
        $baseURL = "http://www.tabroom.com/api/download_data.mhtml?tourn_id="
        $content = (Invoke-WebRequest $baseURL$tournamentID).Content
    }
    $inputTest = Convert-TabroomJsonToObject -jsonText $content
    $entryIndex = @{}
    $objToReturn = @()
    foreach ($category in $inputTest.categories){
        if ($category.abbr -notmatch "PF"){
            continue
        }    
        #Sometimes the JSON has events, sometimes it doesn't. Figure out handling.
        $tempEvents = if ($category.PsObject.Properties.Name -contains 'result_sets'){ $category } elseif ($category.PsObject.Properties.Name -contains 'events') { $category.events }
        #Parse the rounds to get just the useful data
        foreach ($event in $tempEvents){
            $eventHash = @{
                name = $event.name
                type = $event.type
            }
            [PsCustomObject[]]$roundArray = @()
            foreach ($round in $event.rounds){
                $roundHash = @{
                    name = $round.name
                }
                [PsCustomObject[]]$sectionArray = @()
                foreach ($section in $round.sections){
                    $sectionHash = @{
                        sectionName = "ROUND $($round.name), SECTION $($section.letter)"
                    }
                    [PsCustomObject[]]$ballotHashArray = @()
                    foreach ($ballot in $section.ballots){
                        #Index the entry ID to a name/code so that it can be referenced in the results index
                        $entryIndex[$ballot.entry] = @{
                            code = $ballot.entry_code
                            name = $ballot.entry_name
                        }
                        #Add basic identifying information
                        $ballotHash = @{
                            entry_id = $ballot.entry
                            entry_code = $ballot.entry_code
                            entry_name = $ballot.entry_name
                        }
                        if ($section.PsObject.properties.name -notcontains 'bye'){
                            Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name judge -Value "$($ballot.judge_first) $($ballot.judge_last)"
                        }
                        #Debate only
                        if ($event.type -match "debate"){
                            if ($section.PsObject.properties.name -contains 'bye') {
                                $winloss = "B"
                            } elseif ($ballot.PSObject.Properties.name -contains 'scores' -and ($ballot.scores | where-object { $_.tag -like "winloss" })) {
                                $winloss = if (($ballot.scores | where-object { $_.tag -like "winloss" }).value) { "W" } else { "L" }
                                $side = if ($ballot.side -eq 1) { "AFF" } elseif ($ballot.side -eq 2) { "NEG" }
                                Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name Side -Value $side
                                if ($ballot.PsObject.Properties.name -contains 'speakerorder'){
                                    Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name SpeakerOrder -Value $ballot.speakerorder
                                }
                            }
                            Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name Winloss -Value $winloss
                        }
                        #Speech and debate, sometimes
                        if ($ballot.PsObject.Properties.name -contains 'scores'){
                            $rawPointData = ($ballot.scores | where-object { $_.tag -like "point" })
                            if ($rawPointData){
                                $points = ($rawPointData).value
                                for ($i = 0 ; $i -lt $points.count ; $i++) {
                                    Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name "Points for Speaker $($i+1)" -Value $points[$i]
                                }
                            }
                            $rawRankData = ($ballot.scores | where-object { $_.tag -like "rank" })
                            if ($rawRankData){
                                $ranks = ($rawRankData).value
                                for ($j = 0 ; $j -lt $ranks.count ; $j++) {
                                    Add-Member -InputObject $ballotHash -MemberType NoteProperty -Name "Ranks for Speaker $($j+1)" -Value $ranks[$j]
                                }
                            }
                        }
                        $ballotHashArray += $ballotHash
                    }
                    $sectionHash["ballots"] = $ballotHashArray
                    $sectionArray += $sectionHash
                }
                $roundHash["sections"] = ($sectionArray | Sort-Object -Property sectionName)
                $roundArray += $roundHash
            }
            $eventHash["rounds"] = $roundArray
            #Now do the results parsing
            #This will only return data if there are published results.
            [PsCustomObject[]]$resultSetArray = @()
            foreach ($resultSet in $event.result_sets){
                $resultSetHash = @{
                    label = $resultSet.label
                }
                [PsCustomObject[]]$resultArray = @()
                foreach ($result in ($resultSet.results | Sort-Object -Property rank)){
                    try {
                        $individualResult = [PsCustomObject]@{
                            rank = $result.rank
                            percentile = $result.percentile
                            entry_id = $result.entry
                            code = $entryIndex[$result.entry].code
                            name = $entryIndex[$result.entry].name
                            place = $result.place
                        }
                        $resultArray += $individualResult
                    } catch {
                        Write-Verbose "Could not process this entry. $($result.values)"
                    }
                }
                $resultSetHash["results"] = ($resultArray | Sort-Object -Property entry_id -Unique | Sort-Object -Property rank) #Competitors reaching elimination rounds get a 'prelim' and 'elim' duplicate entry in the official JSON
            }
            $resultSetArray += $resultSetHash
            $eventHash["result_sets"] = $resultSetHash
            $objToReturn += $eventHash
        } 
    }
    $usefulJson = $objToReturn | ConvertTo-Json -Depth 99 
    $usefulJson | out-file -FilePath $outPath | out-null
    $usefulJson
}