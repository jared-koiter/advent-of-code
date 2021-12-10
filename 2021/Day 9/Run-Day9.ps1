function Get-HeightMap {
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

    $adjacents = @()

    # assumes that the starting row/col are already valid indexes
    if ($Row -lt $MaxRow) {
        $adjacents += ,@(($Row + 1), $Col)
    }

    if ($Row -gt 0) {
        $adjacents += ,@(($Row - 1), $Col)
    }

    if ($Col -lt $MaxCol) {
        $adjacents += ,@($Row, ($Col + 1))
    }

    if ($Col -gt 0) {
        $adjacents += ,@($Row, ($Col - 1))
    }

    return $adjacents
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-HeightMap -Input $PuzzleInput
    $maxRow = $map.Count - 1
    $maxCol = $map[0].Count - 1

    $sum = 0
    for ($row = 0; $row -le $maxRow; $row++) {
        for ($col = 0; $col -le $maxCol; $col++) {
            $height = $map[$row][$col]
            $adjacentCoords = Get-AdjacentCoords -Row $row -Col $col -MaxRow $maxRow -MaxCol $maxCol

            $lowest = $true
            foreach ($adjacentCoord in $adjacentCoords) {
                if ($height -ge $map[$adjacentCoord[0]][$adjacentCoord[1]]) {
                    $lowest = $false
                    break
                }
            }

            if ($lowest) {
                $sum += ($height + 1)
            }
        }
    }

    return $sum
}

function Get-BasinSize {
    [CmdletBinding()]
    param (
        $Map,
        $StartingRow,
        $StartingCol,
        $MaxRow,
        $MaxCol
    )

    $maxHeight = 9
    $basinCoords = @()
    [System.Collections.Generic.List[string]] $uncheckedCoords = @()
    $uncheckedCoords.Add("$StartingRow,$StartingCol")

    # check all adjacent coordinates of the starting ones, adding them to the list to be checked if they aren't a 9
    # repeat until there are no more adjacent coordinates to check
    while ($uncheckedCoords.Count -gt 0) {
        [int]$row, [int]$col = $uncheckedCoords[0].Split(',')
        $adjacentCoords = Get-AdjacentCoords -Row $row -Col $col -MaxRow $MaxRow -MaxCol $MaxCol
        foreach ($adjacentCoord in $adjacentCoords) {
            $coordString = "$($adjacentCoord[0]),$($adjacentCoord[1])"
            if (
                ($basinCoords -notcontains $coordString) -and
                ($uncheckedCoords -notcontains $coordString) -and
                ($Map[$adjacentCoord[0]][$adjacentCoord[1]] -ne $maxHeight)
            ) {
                $uncheckedCoords.Add($coordString)
            }
        }

        # now that we've checked it, add it to the list of basin coords
        $basinCoords += $uncheckedCoords[0]
        $uncheckedCoords.RemoveAt(0)
    }

    return $basinCoords.Count
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-HeightMap -Input $PuzzleInput
    $maxRow = $map.Count - 1
    $maxCol = $map[0].Count - 1

    $basinSizes = @()
    for ($row = 0; $row -le $maxRow; $row++) {
        for ($col = 0; $col -le $maxCol; $col++) {
            $height = $map[$row][$col]
            $adjacentCoords = Get-AdjacentCoords -Row $row -Col $col -MaxRow $maxRow -MaxCol $maxCol

            $lowest = $true
            foreach ($adjacentCoord in $adjacentCoords) {
                if ($height -ge $map[$adjacentCoord[0]][$adjacentCoord[1]]) {
                    $lowest = $false
                    break
                }
            }

            # this is the start of a basin, search from here
            if ($lowest) {
                $basinSizes += Get-BasinSize -Map $map -StartingRow $row -StartingCol $col -MaxRow $maxRow -MaxCol $maxCol
            }
        }
    }

    $basinSizes = $basinSizes | Sort-Object -Descending | Select -First 3
    return ($basinSizes[0] * $basinSizes[1] * $basinSizes[2])
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
