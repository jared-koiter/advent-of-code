function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $counter = New-Object int[] ($PuzzleInput[0].Length)
    foreach ($row in $PuzzleInput) {
        $counter = for ($i = 0; $i -lt $counter.Length; $i++) {
            $counter[$i] + [convert]::ToInt32($row[$i], 10)
        }
    }

    $half = [math]::Round($PuzzleInput.Count / 2)
    $gammaRate = [convert]::ToInt64((($counter | ForEach-Object { [int]($_ -gt $half) }) -join ''), 2)
    $mask = [convert]::ToInt64('1' * $counter.Count, 2)
    $epsilonRate = $gammaRate -bxor $mask

    return ($gammaRate * $epsilonRate)
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    #TODO
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
