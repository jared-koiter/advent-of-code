function Get-FishCount {
    [CmdletBinding()]
    param (
        $InitialFishCounts,
        $NumberOfDays
    )

    [int[]]$fishCounts = $InitialFishCounts -split ','
    $maxFishDays = 9
    $fishBuckets = ,0 * $maxFishDays
    $fishCounts | ForEach-Object { $fishBuckets[$_]++ }

    for ($day = 0; $day -lt $NumberOfDays; $day++) {
        $newFish = $fishBuckets[0]
        for ($fishBucketId = 1; $fishBucketId -lt $maxFishDays; $fishBucketId++) {
            $fishBuckets[$fishBucketId - 1] = $fishBuckets[$fishBucketId]
        }
        $fishBuckets[6] += $newFish
        $fishBuckets[8] = $newFish
    }

    return ($fishBuckets | Measure-Object -Sum).Sum
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
