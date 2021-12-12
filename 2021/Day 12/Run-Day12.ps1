function Get-CaveConnections {
    [CmdletBinding()]
    param (
        $Connections
    )
    
    $caves = @{}

    foreach ($connection in $Connections) {
        $start, $end = $connection -split '-'

        if ($caves.$start) {
            $caves.$start.Connections += $end
        }
        else {
            $caves.$start = @{
                IsLarge = ($start -cmatch '^[A-Z]*$')
                Connections = @(
                    $end
                )
            }
        }

        if ($caves.$end) {
            $caves.$end.Connections += $start
        }
        else {
            $caves.$end = @{
                IsLarge = ($end -cmatch '^[A-Z]*$')
                Connections = @(
                    $start
                )
            }
        }
    }

    return $caves
}

function Get-PathsFromNode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Caves,
        [Parameter(Mandatory = $true)]
        $Node,
        [Parameter(Mandatory = $false)]
        [array]$VisitedSmallCaves = @()
    )

    if ($Node -eq 'end') {
        return @('end')
    }

    $VisitedSmallCaves += $Node

    $paths = @()
    foreach ($connection in $Caves.$Node.Connections) {
        # don't check visited small caves
        if ($Visited -ccontains $connection -and (-not $Caves.$connection.IsLarge)) {
            continue
        }

        [array]$possiblePaths = @(Get-PathsFromNode -Caves $Caves -Node $connection -VisitedSmallCaves ($Visited | ForEach-Object { $_ }))

        # append the current node to child paths to return all possible combinations
        foreach ($possiblePath in $possiblePaths) {
            $paths += ,@(@($Node) + $possiblePath)
        }
    }

    return $paths
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $caves = Get-CaveConnections -Connections $PuzzleInput
    $paths = Get-PathsFromNode -Caves $caves -Node 'start'

    return $paths.Count
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
