function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $overlapCount = 0
    foreach ($row in $PuzzleInput) {
        $range1, $range2 = $row -split ','
        [int]$min1, [int]$max1 = $range1 -split '-'
        [int]$min2, [int]$max2 = $range2 -split '-'

        if (($min1 -le $min2 -and $max1 -ge $max2) -or ($min2 -le $min1 -and $max2 -ge $max1)) {
            $overlapCount++
        }
    }

    return $overlapCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $notOverlap = 0
    foreach ($row in $PuzzleInput) {
        $range1, $range2 = $row -split ','
        [int]$min1, [int]$max1 = $range1 -split '-'
        [int]$min2, [int]$max2 = $range2 -split '-'

        if (($max1 -lt $min2) -or ($min1 -gt $max2)) {
            $notOverlap++
        }
    }

    return ($PuzzleInput.Count - $notOverlap)
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
