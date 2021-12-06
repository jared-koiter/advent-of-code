function Get-FishCount {
    [CmdletBinding()]
    param (
        $InitialFishCounts,
        $NumberOfDays
    )

    [int[]]$fishCounters = $InitialFishCounts -split ','
    
    for ($day = 0; $day -lt $NumberOfDays; $day++) {
        $newFish = 0
        for ($fishId = 0; $fishId -lt $fishCounters.Count; $fishId++) {
            if ($fishCounters[$fishId] -eq 0) {
                $fishCounters[$fishId] = 6
                $newFish++
            }
            else {
                $fishCounters[$fishId]--
            }
        }
        $fishCounters += ,8 * $newFish
    }

    return $fishCounters.Count
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )
    
    return Get-FishCount -InitialFishCounts $PuzzleInput -NumberOfDays 80
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    return Get-FishCount -InitialFishCounts $PuzzleInput -NumberOfDays 256
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
