function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $validCount = 0
    $parserRegex = '^(\d+)-(\d+)\s([a-z]?):\s([a-z]+)$'

    foreach ($entry in $PuzzleInput) {
        $min, $max, $letter, $password = [regex]::Match($entry, $parserRegex).Captures.Groups[1..4].Value
        $validCount += ((($password.ToCharArray() -eq "$letter").Count) -In ($min..$max))
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
