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
