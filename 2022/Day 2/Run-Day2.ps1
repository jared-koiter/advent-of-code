$scoreRef = @{
    A = 1 # Rock
    B = 2 # Paper
    C = 3 # Scissors
    X = 1 # Rock
    Y = 2 # Paper
    Z = 3 # Scissors
}

$winRef = @{
    1 = 3
    2 = 1
    3 = 2
}

# returns the following relative to Input1
#   -1 if input1 loses to input2
#   0 if they tie
#   1 if input1 wins to input2
function Get-RoundWinner {
    [CmdletBinding()]
    param (
        $Input1,
        $Input2
    )

    if ($Input1 -eq $Input2) {
        return 0
    }
    elseif ($winRef.$Input1 -eq $Input2) {
        return 1
    }
    else {
        return -1
    }
}

function Get-Puzzle1RoundScore {
    [CmdletBinding()]
    param (
        $YourInput,
        $OpponentInput
    )

    switch (Get-RoundWinner -Input1 $YourInput -Input2 $OpponentInput) {
        -1 { return $YourInput }
        0  { return $YourInput + 3 }
        1  { return $YourInput + 6 }
    }
}

function Get-Puzzle2RoundScore {
    [CmdletBinding()]
    param (
        $YourGoal,
        $OpponentInput
    )

    switch ($YourGoal) {
        'X' { # lose
            return $winRef.($OpponentInput)
        }
        'Y' { # tie
            return 3 + $OpponentInput
        }
        'Z' { # win
            return 6 + ($winRef.GetEnumerator() | Where-Object { $_.Value -eq $OpponentInput }).Name
        }
    }
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $totalScore = 0
    foreach ($round in $PuzzleInput) {
        [string]$opponentInput, [string]$yourInput = $round[0,2]
        $totalScore += Get-Puzzle1RoundScore -YourInput $scoreRef.$yourInput -OpponentInput $scoreRef.$opponentInput
    }

    return $totalScore
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $totalScore = 0
    foreach ($round in $PuzzleInput) {
        [string]$opponentInput, [string]$yourGoal = $round[0,2]
        $totalScore += Get-Puzzle2RoundScore -YourGoal $yourGoal -OpponentInput $scoreRef.$opponentInput
    }

    return $totalScore
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
