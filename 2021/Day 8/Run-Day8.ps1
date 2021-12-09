function Get-SignalConfiguration {
    [CmdletBinding()]
    param (
        $SignalInputs
    )

    $signalPatterns = @{
        '2' = @()
        '3' = @()
        '4' = @()
        '5' = @()
        '6' = @()
        '7' = @()
    }
    foreach ($input in $SignalInputs) {
        $length = $input.Length
        $sortedInput = ($input.ToCharArray() | Sort-Object) -join ''
        $signalPatterns.$length += $sortedInput
    }

    # set the unique values right away
    $signalConfiguration = @{
        '1' = $signalPatterns.'2'[0]
        '4' = $signalPatterns.'4'[0]
        '7' = $signalPatterns.'3'[0]
        '8' = $signalPatterns.'7'[0]
    }

    # logic for determining each of the remaining numbers
    # 3: must be the length 5 that contains both of 1's segments
    $oneSegments = $signalConfiguration.'1'.ToCharArray()
    foreach ($option in $signalPatterns.'5') {
        $optionSegments = $option.ToCharArray()
        if ($optionSegments -contains $oneSegments[0] -and $optionSegments -contains $oneSegments[1]) {
            $signalConfiguration.'3' = $option
            $signalPatterns.'5' = $signalPatterns.'5' | Where-Object { $_ -ne $option}
            break
        }
    }

    # 6: must be the length 6 that when subtracted from 8 leaves behind something in 1
    $eightSegments = $signalConfiguration.'8'.ToCharArray()
    $oneSegments = $signalConfiguration.'1'.ToCharArray()
    foreach ($option in $signalPatterns.'6') {
        $optionSegments = $option.ToCharArray()
        foreach ($leftoverSegment in ($eightSegments | Where-Object { $optionSegments -notcontains $_ })) {
            if ($oneSegments -contains $leftoverSegment) {
                $signalConfiguration.'6' = $option
                $signalPatterns.'6' = $signalPatterns.'6' | Where-Object { $_ -ne $option}
                break
            }
        }
    }

    # 0: must be the leftover length 6 that when subtracted from 8 leaves behind something in 4  
    $eightSegments = $signalConfiguration.'8'.ToCharArray()
    $fourSegments = $signalConfiguration.'4'.ToCharArray()
    foreach ($option in $signalPatterns.'6') {
        $optionSegments = $option.ToCharArray()
        foreach ($leftoverSegment in ($eightSegments | Where-Object { $optionSegments -notcontains $_ })) {
            if ($fourSegments -contains $leftoverSegment) {
                $signalConfiguration.'0' = $option
                $signalPatterns.'6' = $signalPatterns.'6' | Where-Object { $_ -ne $option}
                break
            }
        }
    }

    # 9: must be the length 6 left over after determining 0 and 6
    $signalConfiguration.'9' = $signalPatterns.'6'
    
    # 5: must be the length 5 that when subtracted from 6 leaves behind something not in 1
    $sixSegments = $signalConfiguration.'6'.ToCharArray()
    $oneSegments = $signalConfiguration.'1'.ToCharArray()
    foreach ($option in $signalPatterns.'5') {
        $optionSegments = $option.ToCharArray()
        $containsAOneSegment = $false
        foreach ($leftoverSegment in ($sixSegments | Where-Object { $optionSegments -notcontains $_ })) {
            if ($oneSegments -contains $leftoverSegment) {
                $containsAOneSegment = $true
                break
            }
        }

        if (-not $containsAOneSegment) {
            $signalConfiguration.'5' = $option
            $signalPatterns.'5' = $signalPatterns.'5' | Where-Object { $_ -ne $option}
            break
        }
    }

    # 2: must be the length 5 left over after determining 3 and 5
    $signalConfiguration.'2' = $signalPatterns.'5'

    # swap keys and values so we can get the number based on the seven segment input later
    $swapped = @{}
    foreach ($key in $signalConfiguration.Keys) {
        $swapped.($signalConfiguration.$key) = $key
    }

    return $swapped
}

function Parse-SevenSegmentDisplay {
    [CmdletBinding()]
    param (
        $OutputValues,
        $SignalConfiguration
    )

    $number = ''
    foreach ($outputValue in $OutputValues) {
        $outputValue = ($outputValue.ToCharArray() | Sort-Object) -join ''
        $number += $SignalConfiguration.$outputValue
    }

    return [int]$number
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $simpleDigitCount = 0
    $uniqueSegmentNumbers = @(2, 4, 3, 7)
    foreach ($line in $PuzzleInput) {
        $signalInputs, $outputValues = $line.Split('|')
        foreach ($outputValue in ($outputValues.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))) {
            $simpleDigitCount += ($uniqueSegmentNumbers -contains $outputValue.Length)
        }
    }

    return $simpleDigitCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $sum = 0
    foreach ($line in $PuzzleInput) {
        $signalInputs, $outputValues = $line.Split('|')
        $signalInputs = $signalInputs.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        $outputValues = $outputValues.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        $signalConfiguration = Get-SignalConfiguration -SignalInputs $signalInputs
        $sum += Parse-SevenSegmentDisplay -OutputValues $outputValues -SignalConfiguration $signalConfiguration
    }

    return $sum
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
