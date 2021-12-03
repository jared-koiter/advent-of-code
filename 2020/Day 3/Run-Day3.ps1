function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $x = 3
    $count = 0
    $sectionWidth = $PuzzleInput[0].Length
    foreach ($y in (1..($PuzzleInput.Count - 1))) {
        $count += ($PuzzleInput[$y].Substring($x,1) -eq '#')
        $x += 3
        $x = if ($x -ge $sectionWidth) { $x - $sectionWidth } else { $x }
    }

    return $count
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $slopeVariations = @(
        ,@(1, 1)
        ,@(3, 1)
        ,@(5, 1)
        ,@(7, 1)
        ,@(1, 2)
    )

    $result = 1
    foreach ($slopeVariation in $slopeVariations) {
        $xInc, $yInc = $slopeVariation
        $x = $xInc
        $count = 0
        $sectionWidth = $PuzzleInput[0].Length

        for ($y = $yInc; $y -lt $PuzzleInput.Count; $y += $yInc) {
            $count += ($PuzzleInput[$y].Substring($x,1) -eq '#')
            $x += $xInc
            $x = if ($x -ge $sectionWidth) { $x - $sectionWidth } else { $x }
        }

        $result *= $count
    }

    return $result
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
