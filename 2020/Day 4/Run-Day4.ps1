function Parse-PassportData {
    [CmdletBinding()]
    param (
        [string[]] $RawData
    )

    $passportData = @{}
    foreach ($field in $RawData) {
        $fieldName, $value = $field -split ':'
        $passportData.$fieldName = $value
    }

    return $passportData
}

function Validate-Passport {
    [CmdletBinding()]
    param (
        [string[]] $RawData
    )

    $requiredFields = @(
        'byr'
        'iyr'
        'eyr'
        'hgt'
        'hcl'
        'ecl'
        'pid'
    )

    $passportData = Parse-PassportData -RawData $RawData

    $valid = $true
    foreach ($requiredField in $requiredFields) {
        if (-not ($passportData.$requiredField)) {
            $valid = $false
        }
    }

    return $valid
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $validCount = 0
    $data = @()

    foreach ($line in $PuzzleInput) {
        if ($line) {
            $data += ($line -split ' ')
        }
        else {
            $validCount += Validate-Passport -RawData $data
            $data = @()
        }
    }

    # validate any remaining data in case there was some left over at the end
    if ($data) {
        $validCount += Validate-Passport -RawData $data
    }

    return $validCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    #TODO
}

[string[]]$puzzleInput = Get-Content .\input.txt

$puzzle1Timer = [System.Diagnostics.Stopwatch]::StartNew()
$output = Run-Puzzle1 -PuzzleInput $puzzleInput
$puzzle1Timer.Stop()

Write-Host "Puzzle 1 Answer: $output"
Write-Host "Time: $($puzzle1Timer.ElapsedMilliseconds) ms"

$puzzle2Timer = [System.Diagnostics.Stopwatch]::StartNew()
$output = Run-Puzzle2 -PuzzleInput $puzzleInput
$puzzle2Timer.Stop()

Write-Host "Puzzle 2 Answer: $output"
Write-Host "Time: $($puzzle2Timer.ElapsedMilliseconds) ms"
