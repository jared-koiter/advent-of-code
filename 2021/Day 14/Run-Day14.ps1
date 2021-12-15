function Run-PolymerSteps {
    [CmdletBinding()]
    param (
        $Template,
        $Rules,
        $RepetitionCount
    )

    for ($i = 0; $i -lt $RepetitionCount; $i++) {
        [System.Collections.ArrayList]$newPolymer = $Template | ForEach-Object { $_ }

        for ($j = ($template.Count - 2); $j -ge 0; $j--) {
            $pair = "$($template[$j])$($template[$j+1])"
            
            if ($Rules.$pair) {
                $newPolymer.Insert($j+1, $Rules.$pair)
            }
        }

        $Template = $newPolymer
    }

    $counts = $Template | Group-Object -NoElement | ForEach-Object { $_.Count } | Measure-Object -Maximum -Minimum
    return ($counts.Maximum - $counts.Minimum)
}

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

    return Run-PolymerSteps -Template $template -Rules $rules -RepetitionCount 10
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
