function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $mapDimension = 1000
    $map = New-Object 'int [,]' $mapDimension, $mapDimension
    $coordRegex = '^(\d+),(\d+) -> (\d+),(\d+)$'
    $dangerCount = 0

    foreach ($line in $PuzzleInput) {
        [int]$x1, [int]$y1, [int]$x2, [int]$y2 = [regex]::Match($line, $coordRegex).Captures.Groups[1..4].Value
        
        # ignore diagonals in puzzle 1
        if ($x1 -eq $x2 -or $y1 -eq $y2) {
            $xRange = $x1..$x2
            $yRange = $y1..$y2

            foreach ($x in $xRange) {
                foreach ($y in $yRange) {
                    $map[$x,$y] += 1
                    if ($map[$x,$y] -eq 2) {
                        $dangerCount++
                    }
                }
            }
        }
    }

    return $dangerCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $mapDimension = 1000
    $map = New-Object 'int [,]' $mapDimension, $mapDimension
    $coordRegex = '^(\d+),(\d+) -> (\d+),(\d+)$'
    $dangerCount = 0

    foreach ($line in $PuzzleInput) {
        [int]$x1, [int]$y1, [int]$x2, [int]$y2 = [regex]::Match($line, $coordRegex).Captures.Groups[1..4].Value

        $xDiff = [Math]::Abs($x1 - $x2)
        $yDiff = [Math]::Abs($y1 - $y2)

        if ($xDiff) {
            $xRange = $x1..$x2
        }
        else {
            $xRange = ,$x1 * ($yDiff + 1)
        }

        if ($yDiff) {
            $yRange = $y1..$y2
        }
        else {
            $yRange = ,$y1 * ($xDiff + 1)
        }

        for ($i = 0; $i -lt $xRange.Count; $i++) {
            $map[$xRange[$i],$yRange[$i]] += 1
            if ($map[$xRange[$i],$yRange[$i]] -eq 2) {
                $dangerCount++
            }
        }
    }

    return $dangerCount
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
