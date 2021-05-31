<#
    .Synopsis
        Looks up a value in an array and returns the specified property associated with that value
    .Example
        Get-PropertyByID -inputColumn "student_id" -id "649111" -inputObject $studentObject #Returns the student name.
#>
function Get-PropertyByID{
    param(
        [string]$inputColumn,
        [string]$outputColumn="name",
        [string]$id,
        $inputObject
    )
    return (($inputObject | where $inputColumn -eq $id).$outputColumn)
}
