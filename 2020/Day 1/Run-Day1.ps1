function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $target = 2020
    $sorted = $PuzzleInput | Sort-Object
    
    $botIndex = 0
    $topIndex = $sorted.Count - 1
    
    $sum = $sorted[$botIndex] + $sorted[$topIndex]
    while ($sum -ne $target) {
        if ($sum -gt $target) {
            $topIndex--
        }
        else {
            $botIndex++
        }

        if ($topIndex -le $botIndex) {
            throw "Unable to find pair with sum of $target"
        }

        $sum = $sorted[$botIndex] + $sorted[$topIndex]
    }

    return ($sorted[$botIndex] * $sorted[$topIndex])
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $target = 2020
    $sorted = $PuzzleInput | Sort-Object

    $botIndex = 0
    $topIndex = $sorted.Count - 1
    $midIndex = $topIndex - 1
    $subTarget = $target - $sorted[$topIndex]

    $sum = $sorted[$botIndex] + $sorted[$midIndex]     
    while ($sum -ne $subTarget) {
        if ($sum -gt $subTarget) {
            $midIndex--
        }
        else {
            $botIndex++
        }

        if (($sorted[$botIndex] -ge $subTarget) -or ($midIndex -le $botIndex)) {
            $topIndex--
            $botIndex = 0
            $midIndex = $topIndex - 1
            $subTarget = $target - $sorted[$topIndex]
        }

        if ($midIndex -le $botIndex) {
            throw "Unable to find trio with sum of $target"
        }

        $sum = $sorted[$botIndex] + $sorted[$midIndex]
    }
    return ($sorted[$botIndex] * $sorted[$midIndex] * $sorted[$topIndex])
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
