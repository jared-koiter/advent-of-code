function Run-PolymerSteps {
    [CmdletBinding()]
    param (
        $Template,
        $Rules,
        $RepetitionCount
    )

    # populate initial buckets
    $pairBuckets = @{}
    $letterBuckets = @{}
    for ($i = 0; $i -lt ($Template.Count - 1); $i++) {
        $letterBuckets.($Template[$i]) += 1

        $pair = "$($Template[$i])$($Template[$i+1])"
        if ($pairBuckets.$pair) {
            ($pairBuckets.$pair)++
        }
        else {
            $pairBuckets.$pair = 1
        }
    }
    $letterBuckets.($Template[$i]) += 1

    for ($i = 0; $i -lt $RepetitionCount; $i++) {
        $newPairBuckets = $pairBuckets.Clone()
        foreach ($pair in $pairBuckets.Keys) {
            $pairCount = $pairBuckets.$pair
            [char]$newEntry = $Rules.$pair
            $letterBuckets.$newEntry += $pairCount

            $splitPair = $pair.ToCharArray()
            $leftPair = "$($splitPair[0])$newEntry"
            $rightPair = "$newEntry$($splitPair[1])"

            if ($newPairBuckets.$pair -eq $pairCount) {
                $newPairBuckets.Remove($pair)
            }
            else {
                $newPairBuckets.$pair -= $pairCount
            }

            $newPairBuckets.$leftPair += $pairCount
            $newPairBuckets.$rightPair += $pairCount
        }
        $pairBuckets = $newPairBuckets
    }

    $counts = $letterBuckets.Values | Measure-Object -Maximum -Minimum
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

    $template = $PuzzleInput[0].ToCharArray()
    $rules = @{}
    $PuzzleInput[2..($PuzzleInput.Count - 1)] | ForEach-Object {
        $pair, $insert = $_ -split ' -> '
        $rules.$pair = $insert
    }

    return Run-PolymerSteps -Template $template -Rules $rules -RepetitionCount 40
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
