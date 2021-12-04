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

function Validate-PassportSimple {
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
            break
        }
    }

    return $valid
}

function Validate-PassportComplex {
    [CmdletBinding()]
    param (
        [string[]] $RawData
    )

    $requiredFields = @(
        @{
            FieldName = 'byr'
            ValidationType = 'range'
            Range = 1920..2002
        }
        @{
            FieldName = 'iyr'
            ValidationType = 'range'
            Range = 2010..2020
        }
        @{
            FieldName = 'eyr'
            ValidationType = 'range'
            Range = 2020..2030
        }
        @{
            FieldName = 'hgt'
            ValidationType = 'multirange'
            Ranges = @{
                cm = 150..193
                in = 59..76
            }
        }
        @{
            FieldName = 'hcl'
            ValidationType = 'regex'
            Regex = '^#[a-f0-9]{6}$'
        }
        @{
            FieldName = 'ecl'
            ValidationType = 'regex'
            Regex = '^(?:amb|blu|brn|gry|grn|hzl|oth)$'
        }
        @{
            FieldName = 'pid'
            ValidationType = 'regex'
            Regex = '^[0-9]{9}$'
        }
    )

    $passportData = Parse-PassportData -RawData $RawData

    $valid = $true
    foreach ($requiredField in $requiredFields) {
        $fieldValue = $passportData.($requiredField.FieldName)
        if (-not $fieldValue) {
            $valid = $false
            break
        }
        else {
            $valid = switch ($requiredField.ValidationType) {
                'range' {
                    $requiredField.Range -contains $fieldValue
                }
                'multirange' {
                    $value, $unit = [regex]::Match($fieldValue, '^(\d+)(.+)$').Captures.Groups[1,2].Value;
                    $requiredFields.Ranges.$unit -contains $value
                }
                'regex' {
                    $fieldValue -match $requiredField.Regex
                }
            }

            if (-not $valid) {
                break
            }
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
            $validCount += Validate-PassportSimple -RawData $data
            $data = @()
        }
    }

    # validate any remaining data in case there was some left over at the end
    if ($data) {
        $validCount += Validate-PassportSimple -RawData $data
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
