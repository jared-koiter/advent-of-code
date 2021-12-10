$bracketEndingLookup = @{
    '(' = ')'
    '[' = ']'
    '{' = '}'
    '<' = '>'
}
$startingBrackets = $bracketEndingLookup.Keys

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $bracketScoreLookup = @{
        ')' = 3
        ']' = 57
        '}' = 1197
        '>' = 25137
    }

    $score = 0
    foreach ($line in $PuzzleInput) {
        [string[]]$chars = $line.ToCharArray()
        [System.Collections.Generic.List[string]] $chunkStack = @()
        foreach ($char in $chars) {
            if ($startingBrackets -contains $char) {
                $chunkStack.Add($bracketEndingLookup.$char)
            }
            else {
                $expectedClosingBracket = $chunkStack[$chunkStack.Count - 1]
                if ($char -ne $expectedClosingBracket) {
                    # corrupted chunk, add to total score
                    $score += $bracketScoreLookup.$char
                    break
                }
                $chunkStack.RemoveAt($chunkStack.Count - 1)
            }
        }
    }

    return $score
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $bracketScoreLookup = @{
        ')' = 1
        ']' = 2
        '}' = 3
        '>' = 4
    }

    $lineScores = @()
    foreach ($line in $PuzzleInput) {
        [string[]]$chars = $line.ToCharArray()
        [System.Collections.Generic.List[string]] $chunkStack = @()
        $corrupted = $false
        foreach ($char in $chars) {
            if ($startingBrackets -contains $char) {
                $chunkStack.Add($bracketEndingLookup.$char)
            }
            else {
                $expectedClosingBracket = $chunkStack[$chunkStack.Count - 1]
                if ($char -ne $expectedClosingBracket) {
                    # corrupted chunk, skip this line
                    $corrupted = $true
                    break
                }
                $chunkStack.RemoveAt($chunkStack.Count - 1)
            }
        }

        if ($corrupted) {
            continue
        }

        # remaining brackets in the stack are the endings we need to add
        $lineScore = 0
        while ($chunkStack.Count -gt 0) {
            $nextClosingBracket = $chunkStack[$chunkStack.Count - 1]
            $lineScore = ($lineScore * 5) + $bracketScoreLookup.$nextClosingBracket
            $chunkStack.RemoveAt($chunkStack.Count - 1)
        }
        $lineScores += $lineScore
    }

    return ($lineScores | Sort-Object)[[Math]::Floor($lineScores.Count / 2)]
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
