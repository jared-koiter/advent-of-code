function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $template = $PuzzleInput[0].ToCharArray()
    $rules = @{}    
    $PuzzleInput[2..($PuzzleInput.Count - 1)] | ForEach-Object {
        $pair, $insert = $_ -split ' -> '
        $rules.$pair = $insert
    }

    $repetitionCount = 10    
    for ($i = 0; $i -lt $repetitionCount; $i++) {
        [System.Collections.ArrayList]$newPolymer = $template | ForEach-Object { $_ }

        for ($j = ($template.Count - 2); $j -ge 0; $j--) {
            $pair = "$($template[$j])$($template[$j+1])"
            
            if ($rules.$pair) {
                $newPolymer.Insert($j+1, $rules.$pair)
            }
        }

        $template = $newPolymer
    }

    $counts = $template | Group-Object -NoElement | ForEach-Object { $_.Count } | Measure-Object -Maximum -Minimum

    return ($counts.Maximum - $counts.Minimum)
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
