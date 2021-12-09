function Get-SimpleFuelCost {
    [CmdletBinding()]
    param (
        $StartingPositions,
        $Target
    )

    $totalFuelCost = 0
    foreach ($position in $StartingPositions) {
        $totalFuelCost += [Math]::Abs($position - $Target)
    }
    return $totalFuelCost
}

function Get-ComplexFuelCost {
    [CmdletBinding()]
    param (
        $StartingPositions,
        $Target
    )

    $totalFuelCost = 0
    foreach ($position in $StartingPositions) {
        $difference = [Math]::Abs($position - $Target)
        for ($i = 1; $i -le $difference; $i++) {
            $totalFuelCost += $i
        }
    }
    return $totalFuelCost
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    [int[]]$numbers = $PuzzleInput -split ','

    # check only median value and surrounding values
    $medianPosition = (($numbers | Sort-Object)[ [int](($numbers.count -1) / 2)])
    return ((
        (Get-SimpleFuelCost -StartingPositions $numbers -Target $medianPosition),
        (Get-SimpleFuelCost -StartingPositions $numbers -Target ($medianPosition + 1)),
        (Get-SimpleFuelCost -StartingPositions $numbers -Target ($medianPosition - 1))
    ) | Measure-Object -Minimum).Minimum
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    [int[]]$numbers = $PuzzleInput -split ','

    # check only average value and surrounding values
    $averagePosition = [Math]::Round(($numbers | Measure-Object -Average).Average, 0)
    return ((
        (Get-ComplexFuelCost -StartingPositions $numbers -Target $averagePosition),
        (Get-ComplexFuelCost -StartingPositions $numbers -Target ($averagePosition + 1)),
        (Get-ComplexFuelCost -StartingPositions $numbers -Target ($averagePosition - 1))
    ) | Measure-Object -Minimum).Minimum
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
