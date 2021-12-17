function Get-CaveMap {
    [CmdletBinding()]
    param (
        $Input
    )

    $map = @()
    foreach ($line in $Input) {
        $map += ,($line.ToCharArray() | ForEach-Object { [int]::Parse($_) }) 
    }

    return $map
}

function Get-ExtendedCaveMap {
    [CmdletBinding()]
    param (
        $Input
    )

    $map = @()
    foreach ($line in $PuzzleInput) {
        $map += ,($line.ToCharArray() | ForEach-Object { [int]::Parse($_) }) 
    }

    $rowCount = $map.Count
    $colCount = $map[0].Count
    $tileRepetitionCount = 5
    $extendedMap = ,(,0 * ($colCount * $tileRepetitionCount)) * ($rowCount * $tileRepetitionCount)

    for ($tileRow = 0; $tileRow -lt 5; $tileRow++) {
        for ($tileCol = 0; $tileCol -lt 5; $tileCol++) {
            for ($mapRow = 0; $mapRow -lt $rowCount; $mapRow++) {
                $row = $extendedMap[($mapRow + ($tileRow * $rowCount))] | ForEach-Object { $_ }
                for ($mapCol = 0; $mapCol -lt $colCount; $mapCol++) {
                    $originalValue = $map[$mapRow][$mapCol]            
                    $newValue = $originalValue + $tileRow + $tileCol
                    $newValue = if ($newValue -gt 9) { $newValue % 10 + 1 } else { $newValue }
                    $row[($mapCol + ($tileCol * $colCount))] = $newValue
                }
                $extendedMap[($mapRow + ($tileRow * $rowCount))] = $row
            }
        }
    }

    return $extendedMap
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
        $adjacents += "$($Row + 1),$Col"
    }

    if ($Row -gt 0) {
        $adjacents += "$($Row - 1),$Col"
    }

    if ($Col -lt $MaxCol) {
        $adjacents += "$Row,$($Col + 1)"
    }

    if ($Col -gt 0) {
        $adjacents += "$Row,$($Col - 1)"
    }

    return $adjacents
}

function Get-DistanceToTargetEstimate {
    [CmdletBinding()]
    param (
        [int] $CurrentRow,
        [int] $CurrentCol,
        [int] $TargetRow,
        [int] $TargetCol
    )
    
    return (($TargetRow - $CurrentRow) + ($TargetCol - $CurrentCol))
}

function Get-ShortestPathCost {
    [CmdletBinding()]
    param (
        $Map
    )

    $maxRow = $Map.Count - 1
    $maxCol = $Map[0].Count - 1
    $startCoord = '0,0'
    $endCoord = "$maxRow,$maxCol"

    $nodes = @{}
    $nodes.$startCoord = @{
        FValue = [int](Get-DistanceToTargetEstimate -CurrentRow 0 -CurrentCol 0 -TargetRow $maxRow -TargetCol $maxCol)
        Distance = 0
        Previous = ''
        Visited = $true
    }

    [int]$lowestFValue = $nodes.$startCoord.FValue
    $queue = @{
        $lowestFValue = [System.Collections.ArrayList] @( $startCoord )
    }

    while ($nodes.Count -gt 0) {
        if (-not $queue.$lowestFValue) {
            $queue.Remove($lowestFValue)
            [int]$lowestFValue = ($queue.Keys | Where-Object { $queue.$_ } | Measure-Object -Minimum).Minimum
        }
        $node = ($queue.$lowestFValue)[0]
        ($queue.$lowestFValue).RemoveAt(0)

        if ($node -eq $endCoord) {
            break
        }

        [int]$row, [int]$col = $node -split ','
        $neighbours = Get-AdjacentCoords -Row $row -Col $col -MaxRow $maxRow -MaxCol $maxCol
        foreach ($neighbour in $neighbours) {
            if ($neighbour -eq $nodes.$node.Previous) {
                continue
            }

            if ($nodes.$neighbour.Visited) {
                continue
            }

            [int]$nRow, [int]$nCol = $neighbour -split ','
            [int]$neighbourDistance = ($map[$nRow][$nCol] + $nodes.$node.Distance)
            [int]$neighbourFValue = $neighbourDistance + (Get-DistanceToTargetEstimate -CurrentRow $nRow -CurrentCol $nCol -TargetRow $maxRow -TargetCol $maxCol)

            $addToQueue = $false
            if ($nodes.$neighbour) {
                $existingFValue = $nodes.$neighbour.FValue
                if ($neighbourFValue -lt $existingFValue) {
                    [System.Collections.ArrayList] $queue.$existingFValue = @($queue.$existingFValue | Where-Object { $_ -ne $neighbour })
                    $addToQueue = $true

                    $nodes.$neighbour.FValue   = $neighbourFValue
                    $nodes.$neighbour.Distance = $neighbourDistance
                    $nodes.$neighbour.Previous = $node
                }                
            }
            else {
                $nodes.$neighbour = @{
                    FValue   = $neighbourFValue
                    Distance = $neighbourDistance
                    Previous = $node
                    Visted   = $false
                }

                $addToQueue = $true
            }

            if ($addToQueue) {
                if ($queue.$neighbourFValue) {
                    $index = $queue.$neighbourFValue.Add($neighbour)
                }
                else {
                    $queue.$neighbourFValue = [System.Collections.ArrayList] @( $neighbour )
                }
            }
        }

        $nodes.$node.Visited = $true
    }

    return $nodes.$endCoord.Distance
}


function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-CaveMap -Input $PuzzleInput
    return Get-ShortestPathCost -Map $map
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-ExtendedCaveMap -Input $PuzzleInput
    return Get-ShortestPathCost -Map $map
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
