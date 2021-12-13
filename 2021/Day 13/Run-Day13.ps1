function Get-DotPlot {
    [CmdletBinding()]
    param (
        $Dots
    )
    
    $maxX = ($Dots.x | Measure-Object -Maximum).Maximum
    $maxY = ($Dots.y | Measure-Object -Maximum).Maximum

    $plot = ,(,'.' * ($maxX+1)) * ($maxY+1)

    foreach ($dot in $dots) {
        $row = $plot[$dot.y] | ForEach-Object { $_ }
        $row[$dot.x] = '#'
        $plot[$dot.y] = $row
    }

    $plotString = "`n"
    for ($y = 0; $y -le $maxY; $y++) {
        for ($x = 0; $x -le $maxX; $x++) {
            $plotString += "$($plot[$y][$x]) "
        }
        $plotString += "`n"
    }

    return $plotString
}


function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $dots = @()
    $instructions = @()
    foreach ($line in $PuzzleInput) {
        if ($line) {
            if ($line -like 'fold along*') {
                $null, $null, $instruction = $line -split ' '
                $instructions += $instruction
            }
            else {
                $x, $y = $line -split ','
                $dots += @{
                    x = [int]$x
                    y = [int]$y
                }
            }
        }
    }

    foreach ($instruction in $instructions) {
        $foldDir, $coord = $instruction -split '='
        $newDots = @()

        if ($foldDir -eq 'x') {
            $sameDir = 'y'
        }
        else {
            $sameDir = 'x'
        }

        foreach ($dot in $dots) {
            if ($dot.$foldDir -gt $coord) {
                $newDots += @{
                    $foldDir = ($coord - [Math]::Abs($dot.$foldDir - $coord))
                    $sameDir = $dot.$sameDir
                }
            }
            else {
                $newDots += $dot
            }
        }

        $dots = $newDots
        break # part one only uses the first instruction
    }

    return ($dots | ForEach-Object { "$($_.x),$($_.y)" } | Select-Object -Unique).Count
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $dots = @()
    $instructions = @()
    foreach ($line in $PuzzleInput) {
        if ($line) {
            if ($line -like 'fold along*') {
                $null, $null, $instruction = $line -split ' '
                $instructions += $instruction
            }
            else {
                $x, $y = $line -split ','
                $dots += @{
                    x = [int]$x
                    y = [int]$y
                }
            }
        }
    }

    foreach ($instruction in $instructions) {
        $foldDir, $coord = $instruction -split '='
        $newDots = @()

        if ($foldDir -eq 'x') {
            $sameDir = 'y'
        }
        else {
            $sameDir = 'x'
        }

        foreach ($dot in $dots) {
            if ($dot.$foldDir -gt $coord) {
                $newDots += @{
                    $foldDir = ($coord - [Math]::Abs($dot.$foldDir - $coord))
                    $sameDir = $dot.$sameDir
                }
            }
            else {
                $newDots += $dot
            }
        }

        $dots = $newDots
    }

    return (Get-DotPlot -Dots $dots)
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
