function Get-HeightMap {
    [CmdletBinding()]
    param (
        $MapInput
    )

    $map = @()
    foreach ($line in $MapInput) {
        $map += ,[int[]]($line -split '\B')
    }

    return $map
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-HeightMap -MapInput $PuzzleInput

    $rowMax = $map.Count
    $colMax = $map[0].Count

    $visibleCount = 0
    for ($row = 0; $row -lt $rowMax; $row++) {
        for ($col = 0; $col -lt $colMax; $col++) {
            # edges are always visible
            if ($row -eq 0 -or $row -eq ($rowMax-1) -or $col -eq 0 -or $col -eq ($colMax-1)) {
                $visibleCount++
                continue
            }

            $currHeight = $map[$row][$col]
            $blockedSides = 0

            # check for blocks above
            $rowPointer = $row - 1
            while ($rowPointer -ge 0) {
                if ($map[$rowPointer][$col] -ge $currHeight) {
                    $blockedSides++
                    break
                }
                $rowPointer--
            }

            # check for blocks below
            $rowPointer = $row + 1
            while ($rowPointer -lt $rowMax) {
                if ($map[$rowPointer][$col] -ge $currHeight) {
                    $blockedSides++
                    break
                }
                $rowPointer++
            }

            # check for blocks left
            $colPointer = $col - 1
            while ($colPointer -ge 0) {
                if ($map[$row][$colPointer] -ge $currHeight) {
                    $blockedSides++
                    break
                }
                $colPointer--
            }

            # check for blocks right
            $colPointer = $col + 1
            while ($colPointer -lt $colMax) {
                if ($map[$row][$colPointer] -ge $currHeight) {
                    $blockedSides++
                    break
                }
                $colPointer++
            }

            if ($blockedSides -ne 4) {
                $visibleCount++
            }
        }
    }

    return $visibleCount
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $map = Get-HeightMap -MapInput $PuzzleInput

    $rowMax = $map.Count
    $colMax = $map[0].Count

    $maxScore = 0
    for ($row = 0; $row -lt $rowMax; $row++) {
        for ($col = 0; $col -lt $colMax; $col++) {
            # edges always have a score of 0 (due to no trees in at least one direction)
            if ($row -eq 0 -or $row -eq ($rowMax-1) -or $col -eq 0 -or $col -eq ($colMax-1)) {
                continue
            }

            $currHeight = $map[$row][$col]
            $visibleTreeCount = @{
                Above = 0
                Below = 0
                Left  = 0
                Right = 0
            }

            # check for blocks above
            $rowPointer = $row - 1
            while ($rowPointer -ge 0) {
                $visibleTreeCount.Above++
                if ($map[$rowPointer][$col] -ge $currHeight) {
                    break
                }
                $rowPointer--
            }

            # check for blocks below
            $rowPointer = $row + 1
            while ($rowPointer -lt $rowMax) {
                $visibleTreeCount.Below++
                if ($map[$rowPointer][$col] -ge $currHeight) {
                    break
                }
                $rowPointer++
            }

            # check for blocks left
            $colPointer = $col - 1
            while ($colPointer -ge 0) {
                $visibleTreeCount.Left++
                if ($map[$row][$colPointer] -ge $currHeight) {
                    break
                }
                $colPointer--
            }

            # check for blocks right
            $colPointer = $col + 1
            while ($colPointer -lt $colMax) {
                $visibleTreeCount.Right++
                if ($map[$row][$colPointer] -ge $currHeight) {
                    break
                }
                $colPointer++
            }

            $currScore = ($visibleTreeCount.Above * $visibleTreeCount.Below * $visibleTreeCount.Left * $visibleTreeCount.Right)
            if ($currScore -gt $maxScore) {
                $maxScore = $currScore
            }
        }
    }

    return $maxScore
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
