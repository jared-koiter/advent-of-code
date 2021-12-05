function Get-BoardData {
    [CmdletBinding()]
    param (
        [string[]] $BoardInput,
        [int] $BoardDimension
    )

    $boards = @()
    $board = @()
    for ($i = 0; $i -le $BoardInput.Count; $i++) {
        $line = $BoardInput[$i]
        if ($line) {
            $board += ($line.Trim() -split '\s+')
        }
        else {
            $boards += ,$board
            $board = @()
        }
    }

    return $boards
}

# for debugging purposes
function Print-Board {
    [CmdletBinding()]
    param (
        $Board
    )

    $boardDimension = [Math]::Sqrt($Board.Count)

    for ($i = 0; $i -lt $Board.Count; $i++) {
        Write-Host "$($Board[$i]) " -NoNewline
        if (-not (($i+1) % $boardDimension)) { Write-Host }
    }
}

function Set-DrawMarks {
    [CmdletBinding()]
    param (
        $NumberBoard,
        $MarkedBoard,
        $Draw,
        $Mark
    )

    for ($i = 0; $i -lt $NumberBoard.Count; $i++) {
        if ($NumberBoard[$i] -eq $Draw) {
            $MarkedBoard[$i] = $Mark
        }
    }

    return $MarkedBoard
}

function Check-BoardForBingo {
    [CmdletBinding()]
    param (
        $MarkedBoard,
        $BoardDimension
    )

    $winner = $false

    # check for row wins
    for ($row = 0; $row -lt $BoardDimension; $row++) {
        $sum = 0
        $startIndex = $row * $BoardDimension
        for ($i = $startIndex; $i -lt ($startIndex + $BoardDimension); $i++) {
            $sum += $MarkedBoard[$i]
        }

        if ($sum -eq $BoardDimension) {
            $winner = $true
            break
        }
    }

    if ($winner) {
        return $winner
    }

    # check for column wins
    for ($col = 0; $col -lt $BoardDimension; $col++) {
        $sum = 0
        for ($i = $col; $i -lt $MarkedBoard.Count; $i += $BoardDimension) {
            $sum += $MarkedBoard[$i]
        }

        if ($sum -eq $BoardDimension) {
            $winner = $true
            break
        }
    }

    return $winner
}

function Get-BoardScore {
    [CmdletBinding()]
    param (
        $NumberBoard,
        $MarkedBoard,
        $Draw
    )

    $sum = 0
    for ($i = 0; $i -lt $NumberBoard.Count; $i++) {
        if (-not ($MarkedBoard[$i])) {
            $sum += $NumberBoard[$i]
        }
    }

    return ($sum * $Draw)
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $boardDimension = 5
    $draws = $PuzzleInput[0] -split ','

    # parse the rest of the file to get the various board states
    $boards = Get-BoardData -BoardInput ($PuzzleInput | Select-Object -Skip 2) -BoardDimension $boardDimension
    $markedBoards = ,(,0 * ($boardDimension * $boardDimension)) * $boards.Count

    # draw the initial 5 without checking for bingos
    for ($drawNum = 0; $drawNum -le 4; $drawNum++) {
        $draw = $draws[$drawNum]
        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
        }
    }

    for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
        if (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum] -BoardDimension $boardDimension) {
            return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $markedBoards[$boardNum] -Draw $draw
        }
    }

    for ($drawNum = 5; $drawNum -lt $draws.Count; $drawNum++) {
        $draw = $draws[$drawNum]
        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
            if (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum] -BoardDimension $boardDimension) {
                return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $markedBoards[$boardNum] -Draw $draw
            }
        }
    }
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $boardDimension = 5
    $draws = $PuzzleInput[0] -split ','

    # parse the rest of the file to get the various board states
    $boards = Get-BoardData -BoardInput ($PuzzleInput | Select-Object -Skip 2) -BoardDimension $boardDimension
    $markedBoards = ,(,0 * ($boardDimension * $boardDimension)) * $boards.Count

    # play through the entire set to determine the final board states
    for ($drawNum = 0; $drawNum -lt $draws.Count; $drawNum++) {
        $draw = $draws[$drawNum]
        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
        }
    }

    # verify that there isn't already a puzzle that didn't win
    for ($boardNum = ($boards.Count - 1); $boardNum -ge 0; $boardNum--) {
        if (-not (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum] -BoardDimension $boardDimension)) {
            return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $markedBoards[$boardNum] -Draw $draw
        }
    }

    # play backwards to determine which puzzle won last
    for ($drawNum = ($draws.Count - 1); $drawNum -ge 0; $drawNum--) {
        $draw = $draws[$drawNum]
        for ($boardNum = ($boards.Count - 1); $boardNum -ge 0; $boardNum--) {
            $afterMarkedBoard = ($markedBoards[$boardNum] | ForEach-Object { , $_ })
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 0
            if (-not (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum] -BoardDimension $boardDimension)) {
                return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $afterMarkedBoard -Draw $draw
            }
        }
    }
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
