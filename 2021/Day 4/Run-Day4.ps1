function Get-BoardData {
    [CmdletBinding()]
    param (
        [string[]] $BoardInput,
        [int] $BoardDimension
    )

    $boards = @()

    $boardLines = @()
    foreach ($i in (0..($BoardInput.Count-1))) {
        $line = $BoardInput[$i]
        if ($line) {
            $boardLines += $line
        }
        if (-not $line -or ($i -eq ($BoardInput.Count-1))) {
            if ($boardLines.Count -ne $BoardDimension) {
                throw "incomplete board data, can't parse"
            }

            $board = @()
            foreach ($boardLine in $boardLines) {
                $board += ,(($boardLine -split ' ') | Where-Object { $_ })
            }

            $boards += ,$board
            $boardLines = @()
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

    for ($rowNum = 0; $rowNum -lt $Board.Count; $rowNum++) {
        for ($colNum = 0; $colNum -lt $Board.Count; $colNum++) {
            Write-Host "$($Board[$rowNum][$colNum]) " -NoNewline
        }
        Write-Host
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

    for ($rowNum = 0; $rowNum -lt $NumberBoard.Count; $rowNum++) {
        # deep copy to avoid overwriting *all* rows in the board at the same time
        $row = $MarkedBoard[$rowNum] | ForEach-Object { $_ }
        for ($colNum = 0; $colNum -lt $row.Count; $colNum++) {
            if ($NumberBoard[$rowNum][$colNum] -eq $Draw) {
                $row[$colNum] = $Mark
            }
        }
        $MarkedBoard[$rowNum] = $row
    }

    return $MarkedBoard
}

function Check-BoardForBingo {
    [CmdletBinding()]
    param (
        $MarkedBoard
    )

    $winner = $false
    $count = $MarkedBoard.Count

    # check for row wins
    for ($row = 0; $row -lt $count; $row++) {
        if (($MarkedBoard[$row] | Measure-Object -Sum).Sum -eq $count) {
            $winner = $true
            break
        }
    }

    if ($winner) {
        return $winner
    }

    # check for column wins
    for ($col = 0; $col -lt $count; $col++) {
        $sum = 0
        for ($row = 0; $row -lt $count; $row++) {
            $sum += $MarkedBoard[$row][$col]
        }

        if ($sum -eq $count) {
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
    for ($rowNum = 0; $rowNum -lt $MarkedBoard.Count; $rowNum++) {
        for ($colNum = 0; $colNum -lt $MarkedBoard.Count; $colNum++) {
            if (-not ($MarkedBoard[$rowNum][$colNum])) {
                $sum += $NumberBoard[$rowNum][$colNum]
            }
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
    $markedBoards = ,(,(,0 * $boardDimension) * $boardDimension) * $boards.Count

    # draw the initial 5 without checking for bingos
    for ($drawNum = 0; $drawNum -le 4; $drawNum++) {
        $draw = $draws[$drawNum]

        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
        }
    }

    for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
        if (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum]) {
            return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $markedBoards[$boardNum] -Draw $draw
        }
    }

    for ($drawNum = 5; $drawNum -lt $draws.Count; $drawNum++) {
        $draw = $draws[$drawNum]
        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
            if (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum]) {
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
    $markedBoards = ,(,(,0 * $boardDimension) * $boardDimension) * $boards.Count

    # play through the entire set to determine the final board states
    for ($drawNum = 0; $drawNum -lt $draws.Count; $drawNum++) {
        $draw = $draws[$drawNum]
        for ($boardNum = 0; $boardNum -lt $boards.Count; $boardNum++) {
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 1
        }
    }

    # verify that there isn't already a puzzle that didn't win
    for ($boardNum = ($boards.Count - 1); $boardNum -ge 0; $boardNum--) {
        if (-not (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum])) {
            return Get-BoardScore -NumberBoard $boards[$boardNum] -MarkedBoard $markedBoards[$boardNum] -Draw $draw
        }
    }

    # play backwards to determine which puzzle won last
    for ($drawNum = ($draws.Count - 1); $drawNum -ge 0; $drawNum--) {
        $draw = $draws[$drawNum]
        for ($boardNum = ($boards.Count - 1); $boardNum -ge 0; $boardNum--) {
            $afterMarkedBoard = ($markedBoards[$boardNum] | ForEach-Object { , $_ })
            $markedBoards[$boardNum] = Set-DrawMarks -NumberBoard $boards[$boardNum] -MarkedBoard ($markedBoards[$boardNum] | ForEach-Object { , $_ }) -Draw $draw -Mark 0
            if (-not (Check-BoardForBingo -MarkedBoard $markedBoards[$boardNum])) {
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
