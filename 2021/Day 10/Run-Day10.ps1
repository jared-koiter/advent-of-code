$bracketEndingLookup = @{
    '(' = ')'
    '[' = ']'
    '{' = '}'
    '<' = '>'
}
$startingBrackets = $bracketEndingLookup.Keys

$bracketScoreLookup = @{
    ')' = 3
    ']' = 57
    '}' = 1197
    '>' = 25137
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $score = 0
    foreach ($line in $PuzzleInput) {
        [string[]]$chars = $line.ToCharArray()
        [System.Collections.Generic.List[Char]] $chunkStack = @()
        foreach ($char in $chars) {
            if ($startingBrackets -contains $char) {
                $chunkStack.Add($bracketEndingLookup.$char)
            }
            else {
                $expectedClosingBracket = $chunkStack[$chunkStack.Count - 1]
                if ($char -ne $expectedClosingBracket) {
                    # corrupted chunk
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
