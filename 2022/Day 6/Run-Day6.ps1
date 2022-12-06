function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    for ($i = 0; $i -lt ($PuzzleInput.Length - 3); $i++) {
        $snippet = $PuzzleInput[$i..($i+3)]
        if (($snippet | Sort-Object | Get-Unique).Count -eq 4) {
            return ($i + 4)
        }
    }
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    for ($i = 0; $i -lt ($PuzzleInput.Length - 13); $i++) {
        $snippet = $PuzzleInput[$i..($i+13)]
        if (($snippet | Sort-Object | Get-Unique).Count -eq 14) {
            return ($i + 14)
        }
    }
}

[string]$puzzleInput = Get-Content .\input.txt

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
