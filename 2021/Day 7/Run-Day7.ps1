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
    $measurement = $numbers | Measure-Object -Maximum -Minimum

    $minimumCost = [int]::MaxValue
    foreach ($position in ($measurement.Minimum..$measurement.Maximum)) {
        $fuelCost = Get-SimpleFuelCost -StartingPositions $numbers -Target $position
        if ($fuelCost -lt $minimumCost) {
            Write-Warning "$position has a fuelCost of $fuelCost"
            $minimumCost = $fuelCost
        }
    }

    return $minimumCost    
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    [int[]]$numbers = $PuzzleInput -split ','
    #$average = [Math]::Round(($numbers | Measure-Object -Average).Average, 0)
    #return Get-ComplexFuelCost -StartingPositions $numbers -Target $average

    $measurement = $numbers | Measure-Object -Maximum -Minimum

    $minimumCost = [int]::MaxValue
    foreach ($position in ($measurement.Minimum..$measurement.Maximum)) {
        $fuelCost = Get-ComplexFuelCost -StartingPositions $numbers -Target $position
        if ($fuelCost -lt $minimumCost) {
            Write-Warning "$position has a fuelCost of $fuelCost"
            $minimumCost = $fuelCost
        }
    }

    return $minimumCost  
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
