function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $index = 0
    $calorieTotals = @(0)
    foreach ($calorieCount in $PuzzleInput) {
        if ($calorieCount -ne "") {
            $calorieTotals[$index] += [int]$calorieCount
        }
        else {
            $index++
            $calorieTotals += 0
        }
    }

    $calorieTotals = $calorieTotals | Sort-Object -Descending
    return $calorieTotals[0]
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $index = 0
    $calorieTotals = @(0)
    foreach ($calorieCount in $PuzzleInput) {
        if ($calorieCount -ne "") {
            $calorieTotals[$index] += [int]$calorieCount
        }
        else {
            $index++
            $calorieTotals += 0
        }
    }

    $calorieTotals = $calorieTotals | Sort-Object -Descending
    return ($calorieTotals[0] + $calorieTotals[1] + $calorieTotals[2])
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
