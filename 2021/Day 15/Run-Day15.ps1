function Get-CaveMap {
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

function Get-ShortestPathCostOld {
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
        Distance = 0
        Previous = ''
    }

    while ($nodes.Keys -gt 0) {
        $shortestDistance = (($nodes.Keys | ForEach-Object { $nodes.$_.Distance }) | Measure-Object -Minimum).Minimum
        $shortestDistanceNode = $nodes.Keys | Where-Object { $nodes.$_.Distance -eq $shortestDistance } | Select-Object -First 1

        #Write-Host "Checking $shortestDistanceNode" -ForegroundColor DarkCyan

        if ($shortestDistanceNode -eq $endCoord) {
            break
        }

        [int]$x, [int]$y = $shortestDistanceNode -split ','
        if ($y -ne $maxCol) {
            $rightNeighbour = "$x,$($y+1)"
            $rightNeighbourDistance = $map[$x][$y+1]
            $rightTotalDistance = ($rightNeighbourDistance + $shortestDistance)

            if ($nodes.$rightNeighbour) {
                if ($rightTotalDistance -lt $nodes.$rightNeighbour.Distance) {
                    $nodes.$rightNeighbour.Distance = $rightTotalDistance
                    $nodes.$rightNeighbour.Previous = $shortestDistanceNode
                }                
            }
            else {
                $nodes.$rightNeighbour = @{
                    Distance = $rightTotalDistance
                    Previous = $shortestDistanceNode
                }
            }
        }

        if ($x -ne $maxRow) {
            $botNeighbour = "$($x+1),$y"
            $botNeighbourDistance = $map[$x+1][$y]
            $botTotalDistance = ($botNeighbourDistance + $shortestDistance)

            if ($nodes.$botNeighbour) {
                if ($botTotalDistance -lt $nodes.$botNeighbour.Distance) {
                    $nodes.$botNeighbour.Distance = $botTotalDistance
                    $nodes.$botNeighbour.Previous = $shortestDistanceNode
                }                
            }
            else {
                $nodes.$botNeighbour = @{
                    Distance = $botTotalDistance
                    Previous = $shortestDistanceNode
                }
            }
        }

        $nodes.Remove($shortestDistanceNode)
    }

    return $nodes.$endCoord.Distance
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
        #$adjacents += "$($Row - 1),$Col"
    }

    if ($Col -lt $MaxCol) {
        $adjacents += "$Row,$($Col + 1)"
    }

    if ($Col -gt 0) {
        #$adjacents += "$Row,$($Col - 1)"
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

    $averageDistanceValue = 1
    return [Math]::Floor((($TargetRow - $CurrentRow) + ($TargetCol - $CurrentCol)) * $averageDistanceValue)
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
        FValue = (Get-DistanceToTargetEstimate -CurrentRow 0 -CurrentCol 0 -TargetRow $maxRow -TargetCol $maxCol)
        Distance = 0
        Previous = ''
    }

    while ($nodes.Count -gt 0) {
        $fValue = [int]::MaxValue
        foreach ($key in $nodes.Keys) {
            if ($nodes.$key.FValue -lt $fValue) {
                $fValue = $nodes.$key.FValue
                $node = $key
            }
        }

        if ($node -eq $endCoord) {
            break
        }

        [int]$row, [int]$col = $node -split ','
        $neighbours = Get-AdjacentCoords -Row $row -Col $col -MaxRow $maxRow -MaxCol $maxCol
        foreach ($neighbour in $neighbours) {
            if ($neighbour -eq $nodes.$node.Previous) {
                continue
            }
            [int]$nRow, [int]$nCol = $neighbour -split ','
            $neighbourDistance = ($map[$nRow][$nCol] + $nodes.$node.Distance)
            $neighbourFValue = $neighbourDistance + (Get-DistanceToTargetEstimate -CurrentRow $row -CurrentCol $col -TargetRow $nRow -TargetCol $nCol)

            if ($nodes.$neighbour) {
                if ($neighbourFValue -lt $nodes.$neighbour.FValue) {
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
                }
            }
        }

        $nodes.Remove($node)
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