function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )
    
    $sum = 0
    $groupInput = @()
    for ($i = 0; $i -le $PuzzleInput.Count; $i++) {
        $line = $PuzzleInput[$i]
        if ($line) {
            $groupInput += $line.ToCharArray()
        }
        else {
            $sum += ($groupInput | Sort-Object | Get-Unique).Count
            $groupInput = @()
        }
    }

    return $sum
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $sum = 0
    $groupInput = @()
    for ($i = 0; $i -le $PuzzleInput.Count; $i++) {
        $line = $PuzzleInput[$i]
        if ($line) {
            $groupInput += ,$line.ToCharArray()
        }
        else {
            $sameAnswers = $groupInput[0]
            for ($j = 1; $j -lt $groupInput.Count; $j++) {
                $sameAnswers = $sameAnswers | Where-Object { $groupInput[$j] -contains $_ }
                if (-not $sameAnswers) {
                    break
                }
            }
            $sum += $sameAnswers.Count
            $groupInput = @()
        }
    }

    return $sum
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
