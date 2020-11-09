<#
  .Synopsis
  Creates a PDF with a newspaper article summarizing a debate tournament.
  #TODO: Get some sort of API call to https://www.mascotdb.com/ that will return the school mascot.
  .Parameter tournamentPhoto
  Link to a local image file (eg. png, jpeg).
#>
function New-SummaryPDF{
  param(
    [string]$mySchool, 
    [string]$tournamentID,
    $tournamentPhoto,
    [switch]$installIText
  )
  <# region - if you want to down
  $baseURL = "http://www.tabroom.com/api/download_data.mhtml?tourn_id="
  $response = (Invoke-WebRequest $baseURL$tournamentID).Content
  $tournamentJson = ConvertJSON-ToObject -jsonText $response
  #>

  $tournamentDate = Get-Date #Default value
  $tournamentResultSummary = Write-TournamentSummary -tournamentID $tournamentID -mySchool $mySchool -tournamentJson $tournamentJson -date ([ref]$tournamentDate)
  $tournamentResultSummary = $tournamentResultSummary | Out-String

  if ($installIText){
      install-Itext7
  }
  #TODO: Add a check to see if iText is installed.

  $pdfDocuFilename = "$PSScriptRoot\$mySchool-tournament-report.pdf"

  #Create document
  $pdfWriter = [iText.Kernel.Pdf.PdfWriter]::new($pdfDocuFilename)
  $pdf = [iText.Kernel.Pdf.PdfDocument]::new($pdfWriter)
  $doc = [iText.Layout.Document]::new($pdf)

  #Set up basic font
  $standardFonts = [itext.io.font.constants.StandardFonts]
  $TNRBold = [itext.io.font.constants.StandardFonts]::TIMES_BOLD
  $myFont = [iText.Kernel.Font.PdfFontFactory]::CreateFont($TNRBold)

  #Create title text for article
  $myTitleText = [iText.Layout.Element.Text](Get-Headline -schoolName $mySchool)
  $myTitleText = $myTitleText.SetFont($myFont)
  $myTitleText = $myTitleText.SetFontSize(20)

  #Create paragraph block for the title
  $myTitleParagraph = [iText.Layout.Element.Paragraph]::new()
  $myTitleParagraph.Add($myTitleText) | Out-Null
  $myTitleParagraph.SetFont($myFont) | Out-Null

  #Create paragraph block for the date
  $myDateParagraph = [iText.Layout.Element.Paragraph]( Get-Date ($tournamentDate | Get-Date) -Format "MMMM dd, yyyy")

  #Create image from the provided image.
  if ($tournamentPhoto){
      $myImage = [iText.IO.Image.ImageDataFactory]::Create($tournamentPhoto)
      $layoutImage = [iText.Layout.Element.Image]::new($myImage)
      $layoutImage.SetAutoScaleWidth(500) | Out-Null #Necessary to keep from pagebreaking.
  }

  #Create text for the tournament results.
  $TNR = [itext.io.font.constants.StandardFonts]::TIMES_ROMAN
  $myTNRFont = [iText.Kernel.Font.PdfFontFactory]::CreateFont($TNR)
  $myParaGraphText = [iText.Layout.Element.Text]($tournamentResultSummary)
  $myParaGraphText.SetFont($myTNRFont) | Out-Null

  #Create paragraph for the tournament results.
  $myPara = [iText.Layout.Element.Paragraph]::new()
  $myPara.Add($myParagraphText) | Out-Null
  $myPara.SetTextAlignment("JUSTIFIED") | Out-Null

  #Add paragraphs to the document.
  $doc.Add($myTitleParagraph) | Out-Null
  $doc.Add($myDateParagraph) | Out-Null
  if ($tournamentPhoto){
    $doc.Add($layoutImage) | Out-Null
  }
  $doc.Add($myPara) | Out-Null
  $doc.Close() | Out-Null
}
