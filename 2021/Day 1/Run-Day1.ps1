function Run-Puzzle1 {
    [CmdletBinding()]    
    param (
        $PuzzleInput
    )

    $out = 0
    for ($i = 1; $i -lt ($PuzzleInput.Count); $i++) {
        $out += ($PuzzleInput[$i] -gt $PuzzleInput[$i-1])
    }
    return $out
}

function Run-Puzzle2 {
    [CmdletBinding()]    
    param (
        $PuzzleInput
    )

    $out = 0
    for ($i = 3; $i -lt ($PuzzleInput.Count); $i++) {
        $out += ($PuzzleInput[$i] -gt $PuzzleInput[$i-3])
    }
    return $out
}

[int[]]$puzzleInput = Get-Content .\input.txt

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
