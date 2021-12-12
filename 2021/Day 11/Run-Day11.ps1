function Get-EnergyMap {
    [CmdletBinding()]
    param (
        $Input
    )

    $map = @()
    foreach ($line in $PuzzleInput) {
        $map += ,($line.ToCharArray() | ForEach-Object { [int]::Parse($_) }) 
    }

    return $map
}

function Get-AdjacentCoords {
    [CmdletBinding()]
    param (
        $Row,
        $Col,
        $MaxRow,
        $MaxCol
    )

    $availableAdjacents = @{
        'topleft'  = @(($Row - 1), ($Col - 1))
        'top'      = @(($Row - 1), $Col)
        'topright' = @(($Row - 1), ($Col + 1))
        'left'     = @($Row, ($Col - 1))
        'right'    = @($Row, ($Col + 1))
        'botleft'  = @(($Row + 1), ($Col - 1))
        'bot'      = @(($Row + 1), $Col)
        'botright' = @(($Row + 1), ($Col + 1))
    }

    if ($Row -eq $MaxRow) {
        $availableAdjacents.Remove('botleft')
        $availableAdjacents.Remove('bot')
        $availableAdjacents.Remove('botright')
    }

    if ($Row -eq 0) {
        $availableAdjacents.Remove('topleft')
        $availableAdjacents.Remove('top')
        $availableAdjacents.Remove('topright')
    }

    if ($Col -eq $MaxCol) {
        $availableAdjacents.Remove('topright')
        $availableAdjacents.Remove('right')
        $availableAdjacents.Remove('botright')
    }

    if ($Col -eq 0) {
        $availableAdjacents.Remove('topleft')
        $availableAdjacents.Remove('left')
        $availableAdjacents.Remove('botleft')
    }

    $adjacents = @()
    foreach ($direction in $availableAdjacents.Keys) {
        $adjacents += ,$availableAdjacents.$direction
    }

    return $adjacents
}

# for debugging
function Print-Map {
    [CmdletBinding()]
    param (
        $Map
    )

    for ($rowNum = 0; $rowNum -lt $Map.Count; $rowNum++) {
        for ($colNum = 0; $colNum -lt $Map.Count; $colNum++) {
            if ($Map[$rowNum][$colNum] -eq 9) {
                Write-Host "$($Map[$rowNum][$colNum]) " -NoNewline -ForegroundColor Red
            }
            elseif ($map[$rowNum][$colNum] -eq 0) {
                Write-Host "$($Map[$rowNum][$colNum]) " -NoNewline -ForegroundColor Green
            }
            else {
                Write-Host "$($Map[$rowNum][$colNum]) " -NoNewline
            }
        }
        Write-Host
    }
    Write-Host "----------"
}


function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-EnergyMap -Input $PuzzleInput
    $maxRow = $map.Count - 1
    $maxCol = $map[0].Count - 1
    $maxEnergy = 9
    $flashCount = 0
    $stepsToRun = 100

    for ($step = 0; $step -lt $stepsToRun; $step++) {
        # increase energy levels by 1
        [System.Collections.Generic.List[string]] $toFlash = @()
        for ($row = 0; $row -le $maxRow; $row++) {
            for ($col = 0; $col -le $maxCol; $col++) {
                $map[$row][$col]++
                if ($map[$row][$col] -gt $maxEnergy) {
                    $coordString = "$row,$col"
                    if ($toFlash -notcontains $coordString) {
                        $toFlash.Add($coordString)
                    }
                }
            }
        }

        # run through flash sequence and zero out energy levels
        [System.Collections.Generic.List[string]] $flashed = @()
        while ($toFlash.Count) {
            [int]$row, [int]$col = $toFlash[0].Split(',')
            $adjacentCoords = Get-AdjacentCoords -Row $row -Col $col -MaxRow $MaxRow -MaxCol $MaxCol
            foreach ($adjacentCoord in $adjacentCoords) {
                $coordString = "$($adjacentCoord[0]),$($adjacentCoord[1])"

                if ($flashed -notcontains $coordString) {
                    # increase energy level if it is not already set to flash
                    if ($toFlash -notcontains $coordString) {
                        $map[$adjacentCoord[0]][$adjacentCoord[1]]++

                        # trigger flash if the threshold has been reached
                        if ($map[$adjacentCoord[0]][$adjacentCoord[1]] -gt $maxEnergy) {
                            $toFlash.Add($coordString)
                        }
                    }
                }
            }
        
            # zero out energy level for this coordinate and add it to the ignore list for the rest of the step
            $map[$row][$col] = 0
            $flashCount++
            $flashed += $toFlash[0]
            $toFlash.RemoveAt(0)
        }
    }

    return $flashCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-EnergyMap -Input $PuzzleInput
    $maxRow = $map.Count - 1
    $maxCol = $map[0].Count - 1
    $maxEnergy = 9
    $octopusCount = ($map.Count) * ($map[0].Count)

    $step = 0
    do {
        $step++
        $flashCount = 0

        # increase energy levels by 1
        [System.Collections.Generic.List[string]] $toFlash = @()
        for ($row = 0; $row -le $maxRow; $row++) {
            for ($col = 0; $col -le $maxCol; $col++) {
                $map[$row][$col]++
                if ($map[$row][$col] -gt $maxEnergy) {
                    $coordString = "$row,$col"
                    if ($toFlash -notcontains $coordString) {
                        $toFlash.Add($coordString)
                    }
                }
            }
        }

        # run through flash sequence and zero out energy levels
        [System.Collections.Generic.List[string]] $flashed = @()
        while ($toFlash.Count) {
            [int]$row, [int]$col = $toFlash[0].Split(',')
            $adjacentCoords = Get-AdjacentCoords -Row $row -Col $col -MaxRow $MaxRow -MaxCol $MaxCol
            foreach ($adjacentCoord in $adjacentCoords) {
                $coordString = "$($adjacentCoord[0]),$($adjacentCoord[1])"

                if ($flashed -notcontains $coordString) {
                    # increase energy level if it is not already set to flash
                    if ($toFlash -notcontains $coordString) {
                        $map[$adjacentCoord[0]][$adjacentCoord[1]]++

                        # trigger flash if the threshold has been reached
                        if ($map[$adjacentCoord[0]][$adjacentCoord[1]] -gt $maxEnergy) {
                            $toFlash.Add($coordString)
                        }
                    }
                }
            }
        
            # zero out energy level for this coordinate and add it to the ignore list for the rest of the step
            $map[$row][$col] = 0
            $flashCount++
            $flashed += $toFlash[0]
            $toFlash.RemoveAt(0)
        }
    }
    while ($flashCount -ne $octopusCount)

    return $step
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
