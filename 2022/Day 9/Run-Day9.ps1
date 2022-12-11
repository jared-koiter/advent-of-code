function Get-TailVisitedNodes {
    [CmdletBinding()]
    param (
        $Movements,
        $KnotCount
    )

    $tailVisited = @{}
    $ropeLocs = @()
    for ($i = 0; $i -lt $KnotCount; $i++) {
        $ropeLocs += [PSCustomObject]@{
            Index = $i
            X = 0
            Y = 0
        }
    }

    # add the initial starting location as a visited node
    $tailVisited.'0,0' = 1

    :movements foreach ($movement in $Movements) {
        $direction, $distance = $movement -split ' '

        # move head location
        switch ($direction) {
            'U' {
                $ropeLocs[0].Y += $distance
            }
            'D' {
                $ropeLocs[0].Y -= $distance
            }
            'L' {
                $ropeLocs[0].X -= $distance
            }
            'R' {
                $ropeLocs[0].X += $distance
            }
            default {
                throw "Could not parse direction $direction"
            }
        }

        # update subsequent knot locations (if necessary)
        for ($i = 1; $i -lt $KnotCount; $i++) {
            $coordDiff = @{
                X = ($ropeLocs[$i-1].X - $ropeLocs[$i].X)
                Y = ($ropeLocs[$i-1].Y - $ropeLocs[$i].Y)
            }
            $coordDiff.AbsX = [math]::Abs($coordDiff.X)
            $coordDiff.AbsY = [math]::Abs($coordDiff.Y)
            $coordDiff.DirX = if ($coordDiff.X -ne 0) { $coordDiff.X / $coordDiff.AbsX } else { 0 }
            $coordDiff.DirY = if ($coordDiff.Y -ne 0) { $coordDiff.Y / $coordDiff.AbsY } else { 0 }
            $coordDiff.StepCount = [Math]::Max($coordDiff.AbsX, $coordDiff.AbsY) - 1

            if ($coordDiff.StepCount -gt 0) {
                # run through the steps to get all of the intermediate coords visited by the knot
                for ($j = 1; $j -le $coordDiff.StepCount; $j++) {
                    $newX = $ropeLocs[$i].X + ($j * $coordDiff.DirX)
                    if ($coordDiff.DirX) {
                        $newX = if ($coordDiff.DirX -gt 0) { [Math]::Min($newX, $ropeLocs[$i-1].X) } else { [Math]::Max($newX, $ropeLocs[$i-1].X) }
                    }

                    $newY = $ropeLocs[$i].Y + ($j * $coordDiff.DirY)
                    if ($coordDiff.DirY) {
                        $newY = if ($coordDiff.DirY -gt 0) { [Math]::Min($newY, $ropeLocs[$i-1].Y) } else { [Math]::Max($newY, $ropeLocs[$i-1].Y) }
                    }

                    if ($i -eq ($KnotCount - 1)) {
                        $tailVisited."$newX,$newY" = 1
                    }
                }

                # update coords of this knot
                $ropeLocs[$i].X = $newX
                $ropeLocs[$i].Y = $newY
            }
            else {
                # if this node didn't move, then all subsequent nodes won't either, we can skip to the next movement
                continue movements
            }
        }
    }

    return $tailVisited
}

function Get-TailVisitedStepByStep {
    [CmdletBinding()]
    param (
        $Movements,
        $KnotCount
    )

    $tailVisited = @{}
    $ropeLocs = @()
    for ($i = 0; $i -lt $KnotCount; $i++) {
        $ropeLocs += [PSCustomObject]@{
            Index = $i
            X = 0
            Y = 0
        }
    }

    # add the initial starting location as a visited node
    $tailVisited.'0,0' = 1

    :movements foreach ($movement in $Movements) {
        $direction, $distance = $movement -split ' '

        :steps for ($k = 0; $k -lt $distance; $k++) {
            # move head location
            switch ($direction) {
                'U' {
                    $ropeLocs[0].Y += 1
                }
                'D' {
                    $ropeLocs[0].Y -= 1
                }
                'L' {
                    $ropeLocs[0].X -= 1
                }
                'R' {
                    $ropeLocs[0].X += 1
                }
                default {
                    throw "Could not parse direction $direction"
                }
            }

            # update subsequent knot locations (if necessary)
            for ($i = 1; $i -lt $KnotCount; $i++) {
                $coordDiff = @{
                    X = ($ropeLocs[$i-1].X - $ropeLocs[$i].X)
                    Y = ($ropeLocs[$i-1].Y - $ropeLocs[$i].Y)
                }
                $coordDiff.AbsX = [math]::Abs($coordDiff.X)
                $coordDiff.AbsY = [math]::Abs($coordDiff.Y)
                $coordDiff.DirX = if ($coordDiff.X -ne 0) { $coordDiff.X / $coordDiff.AbsX } else { 0 }
                $coordDiff.DirY = if ($coordDiff.Y -ne 0) { $coordDiff.Y / $coordDiff.AbsY } else { 0 }
                $coordDiff.StepCount = [Math]::Max($coordDiff.AbsX, $coordDiff.AbsY) - 1

                if ($coordDiff.StepCount -gt 0) {
                    # run through the steps to get all of the intermediate coords visited by the knot
                    for ($j = 1; $j -le $coordDiff.StepCount; $j++) {
                        $newX = $ropeLocs[$i].X + ($j * $coordDiff.DirX)
                        if ($coordDiff.DirX) {
                            $newX = if ($coordDiff.DirX -gt 0) { [Math]::Min($newX, $ropeLocs[$i-1].X) } else { [Math]::Max($newX, $ropeLocs[$i-1].X) }
                        }

                        $newY = $ropeLocs[$i].Y + ($j * $coordDiff.DirY)
                        if ($coordDiff.DirY) {
                            $newY = if ($coordDiff.DirY -gt 0) { [Math]::Min($newY, $ropeLocs[$i-1].Y) } else { [Math]::Max($newY, $ropeLocs[$i-1].Y) }
                        }

                        if ($i -eq ($KnotCount - 1)) {
                            $tailVisited."$newX,$newY" = 1
                        }
                    }

                    # update coords of this knot
                    $ropeLocs[$i].X = $newX
                    $ropeLocs[$i].Y = $newY
                }
                else {
                    # if this node didn't move, then all subsequent nodes won't either, we can skip to the next movement
                    continue steps
                }
            }
        }
    }

    return $tailVisited
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $tailVisited = Get-TailVisitedNodes -Movements $PuzzleInput -KnotCount 2
    return $tailVisited.Keys.Count
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    
    #$tailVisited = Get-TailVisitedNodes -Movements $PuzzleInput -KnotCount 10 # this gives 2565 - wrong answer
    $tailVisited = Get-TailVisitedStepByStep -Movements $PuzzleInput -KnotCount 10 # this gives 2607 - right answer
    return $tailVisited.Keys.Count
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
