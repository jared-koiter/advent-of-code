function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $cycle = 0
    $cycleCheck = @(20, 60, 100, 140, 180, 220)
    $signalStrength = 0
    $x = 1
    
    foreach ($instruction in $PuzzleInput) {
        $cycle++

        if ($cycleCheck -contains $cycle) {
            $signalStrength += ($x * $cycle)
        }

        if ($instruction -ne 'noop') {
            $null, [int]$value = $instruction -split ' '

            # advance one cycle and recheck
            $cycle++
            if ($cycleCheck -contains $cycle) {
                $signalStrength += ($x * $cycle)
            }

            # update x after the two cycles have been completed and checked
            $x += $value
        }
    }

    return $signalStrength
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $cycle = 0
    $screenEdgeIndex = 40
    $spriteMiddleIndex = 2
    $crt = "`n"
    
    foreach ($instruction in $PuzzleInput) {
        $cycle++

        # check if sprite overlaps with current cycle
        if ([Math]::Abs($spriteMiddleIndex - $cycle) -le 1) {
            $crt += '#'
        }
        else {
            $crt += '.'
        }

        # add newlines one the edge of the screen is reached and printed
        # also update the sprite location to be on the next line
        if (($cycle % $screenEdgeIndex) -eq 0) {
            $crt += "`n"
            $spriteMiddleIndex += $screenEdgeIndex
        }

        if ($instruction -ne 'noop') {
            $null, [int]$value = $instruction -split ' '

            # advance one cycle and recheck
            $cycle++
            if ([Math]::Abs($spriteMiddleIndex - $cycle) -le 1) {
                $crt += '#'
            }
            else {
                $crt += '.'
            }

            $spriteMiddleIndex += $value
            if (($cycle % $screenEdgeIndex) -eq 0) {
                $crt += "`n"
                $spriteMiddleIndex += $screenEdgeIndex
            }
        }
    }

    return $crt
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
