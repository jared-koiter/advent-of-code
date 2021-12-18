function Get-TargetArea {
    [CmdletBinding()]
    param (
        $CoordString
    ) 

    $coordRegex = 'target area: x=([-\d]+)..([-\d]+), y=([-\d]+)..([-\d]+)'
    [int]$minX, [int]$maxX, [int]$minY, [int]$maxY = [regex]::Match($CoordString, $coordRegex).Captures.Groups[1..4].Value
    return $minX, $maxX, $minY, $maxY
}

function Run-Step {
    [CmdletBinding()]
    param (
        $X,
        $Y,
        $XVelocity,
        $YVelocity
    )

    $X += $XVelocity
    $Y += $YVelocity
    if ($XVelocity -gt 0) {
        $XVelocity--
    }
    elseif ($XVelocity -lt 0) {
        $XVelocity++
    }
    else {
        $XVelocity = 0
    }
    
    $YVelocity--

    return $X, $Y, $XVelocity, $YVelocity
}

function Test-Trajectory {
    [CmdletBinding()]
    param (
        $XVelocity,
        $YVelocity,
        $XRange,
        $YRange
    )

    $maxX = $XRange[($XRange.Count - 1)]
    $minY = $YRange[0]
    $x, $y = 0, 0
    $maxYHeight = 0

    $targetHit = $false
    while ($x -le $maxX -and $y -ge $minY) {
        $params = @{
            X = $x
            Y = $y
            XVelocity = $XVelocity
            YVelocity = $YVelocity
        }
        $x, $y, $XVelocity, $YVelocity = Run-Step @params
        $maxYHeight = [Math]::Max($y, $maxYHeight)

        if ($x -in $XRange -and $y -in $YRange) {
            $targetHit = $true
            break
        }

        # stop processing if x isn't changing anymore and we're not in the target x range
        if ($XVelocity -eq 0 -and $x -notin $XRange) {
            break
        }
    }

    return $targetHit, $x, $y, $maxYHeight
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $minX, $maxX, $minY, $maxY = Get-TargetArea -CoordString $PuzzleInput
    $xRange = $minX..$maxX
    $yRange = $minY..$maxY

    # calculate reasonable ranges for initial velocities that could end up in the target zone
    $minXVelocity = 0
    while ($minX -ge 0) {
        $minXVelocity++
        $minX -= $minXVelocity
    }

    $maxXVelocity = 0
    while ($maxX -ge 0) {
        $maxXVelocity++
        $maxX -= $maxXVelocity
    }

    # TODO make this better
    $minYVelocity = 0
    $maxYVelocity = 1000

    $overallMaxHeight = 0
    foreach ($xVelocity in ($minXVelocity..$maxXVelocity)) {
        foreach ($yVelocity in ($minYVelocity..$maxYVelocity)) {
            $trajectoryParams = @{
                XVelocity = $xVelocity
                YVelocity = $yVelocity
                XRange = $xRange
                YRange = $yRange
            }
            $targetHit, $x, $y, $maxHeight = Test-Trajectory @trajectoryParams

            if ($targetHit) {
                $overallMaxHeight = [Math]::Max($overallMaxHeight, $maxHeight)
            }
        }
    }

    return $overallMaxHeight
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $minX, $maxX, $minY, $maxY = Get-TargetArea -CoordString $PuzzleInput
}

$puzzleInput = Get-Content .\input.txt

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
