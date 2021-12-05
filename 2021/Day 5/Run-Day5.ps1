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
        $x1, $y1, $x2, $y2 = [regex]::Match($line, $coordRegex).Captures.Groups[1..4].Value
        
        # ignore diagonals in puzzle 1
        if ($x1 -eq $x2) {
            foreach ($y in ($y1..$y2)) {
                $map[$x1,$y] += 1
                if ($map[$x1,$y] -eq 2) {
                    $dangerCount++
                }
            }
        }
        elseif ($y1 -eq $y2) {
            foreach ($x in ($x1..$x2)) {
                $map[$x,$y1] += 1
                if ($map[$x,$y1] -eq 2) {
                    $dangerCount++
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

    # TODO
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
