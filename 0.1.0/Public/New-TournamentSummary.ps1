<#
  .Synopsis
  Creates a PDF with a newspaper article summarizing a debate tournament.
  #TODO: Get some sort of API call to https://www.mascotdb.com/ that will return the school mascot.
  #TODO: Add a check to see if iText is installed.
#>
function New-TournamentSummary{
  param(
    #String name of your school so we can get some cool, school-specific sentences
    [Parameter(Mandatory=$True)]
    [string]$mySchool,
    #ID of the tournament pulled from Tabroom.com
    [Parameter(Mandatory=$True)]
    [string]$tournamentID,
    #Link to a photo png/jpeg to use in the article.
    [Parameter(ParameterSetName="PDF")]
    [ValidatePattern("\.png|\.jpg|.jpeg")]
    $tournamentPhoto,
    #Switch to create a PDF document containing the summary. Otherwise, a string will be returned.
    [switch]$createPdf
  )
  if ($createPdf){
      $itextInstalled = (Test-Path "$home\.nuget\packages\itext7")
      if (-Not $itextInstalled){
          if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
              Write-Error "Installing PDF creation functionality requires running as administrator. Exiting..." -ErrorAction Stop
          }
          $ModuleRoot = (Get-Module "TabroomSummary").ModuleBase
          . "$ModuleRoot\etc\install-Itext7.ps1"
          Install-Itext7
      }
  }

  $baseURL = "http://www.tabroom.com/api/download_data.mhtml?tourn_id="
  $response = (Invoke-WebRequest $baseURL$tournamentID).Content
  $tournamentJson = Convert-TabroomJsonToObject -jsonText $response

  try {
    $tournamentDate = Get-Date $tournamentJson.end
  } catch {
    Write-Warning "Could not determine tournament end date -- defaulting to Today."
    $tournamentDate = Get-Date #Default value is Today.
  }
  $tournamentResultSummary = Write-TournamentSummary -tournamentID $tournamentID -mySchool $mySchool -tournamentJson $tournamentJson -date ([ref]$tournamentDate) | Out-String

  if (-Not ($createPdf)){
    return $tournamentResultSummary
  }
  else {
      #region Create the PDF
      $pdfDocuFilename = "$PSScriptRoot\$mySchool-tournament-report.pdf"

      #Create document
      $pdfWriter = [iText.Kernel.Pdf.PdfWriter]::new($pdfDocuFilename)
      $pdf = [iText.Kernel.Pdf.PdfDocument]::new($pdfWriter)
      $doc = [iText.Layout.Document]::new($pdf)

      #Set up basic font
      # $standardFonts = [itext.io.font.constants.StandardFonts] #Removed font changing features for now.
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
      Write-Host "Created PDF Summary at $pdfDocuFilename."
    }
}
