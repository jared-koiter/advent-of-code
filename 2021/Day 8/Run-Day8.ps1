function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $simpleDigitCount = 0
    $uniqueSegmentNumbers = @(2, 4, 3, 7)
    foreach ($line in $PuzzleInput) {
        $signalPatterns, $outputValues = $line.Split('|')
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
