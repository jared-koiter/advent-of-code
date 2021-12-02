function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $horizontal = 0
    $depth = 0
    $parserRegex = '^(forward|down|up)\s(\d+)$'

    foreach ($step in $PuzzleInput) {
        $change, $units = [regex]::Match($step, $parserRegex).Captures.Groups[1,2].Value
        switch ($change) {
            'forward' { $horizontal += $units }
            'down'    { $depth += $units }
            'up'      { $depth -= $units }
            default   { throw "unable to parse step $step" } 
        }
    }

    return ($horizontal * $depth)
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $horizontal = 0
    $depth = 0
    $aim = 0
    $parserRegex = '^(forward|down|up)\s(\d+)$'

    foreach ($step in $PuzzleInput) {
        $change, $units = [regex]::Match($step, $parserRegex).Captures.Groups[1,2].Value
        switch ($change) {
            'forward' { $horizontal += $units; $depth += ($aim * $units) }
            'down'    { $aim += $units }
            'up'      { $aim -= $units }
            default   { throw "unable to parse step $step" } 
        }
    }

    return ($horizontal * $depth)
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
