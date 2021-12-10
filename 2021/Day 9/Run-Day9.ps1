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
