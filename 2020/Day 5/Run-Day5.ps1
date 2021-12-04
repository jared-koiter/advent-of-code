function Get-RowColumnNumber {
    [CmdletBinding()]
    param (
        [int] $MinValue,
        [int] $MaxValue,
        [string[]] $Code
    )

    foreach ($entry in $Code) {
        $mid = ($MaxValue + $MinValue + 1) / 2
        if ($entry -eq 'F' -or $entry -eq 'L') {
            $MaxValue = $mid - 1
        }
        else {
            $MinValue = $mid
        }
    }

    if ($MinValue -ne $MaxValue) {
        throw "unable to determine row or column number"
    }

    return $MinValue
}

function Get-SeatId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $SeatCode
    )

    process {
        $rowNumber = Get-RowColumnNumber -Code $SeatCode[0..6] -MinValue 0 -MaxValue 127
        $colNumber = Get-RowColumnNumber -Code $SeatCode[7..9] -MinValue 0 -MaxValue 7
        return ($rowNumber * 8 + $colNumber)
    }
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    return (($PuzzleInput | Get-SeatId) | Measure -Maximum).Maximum
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $seatIds = ($PuzzleInput | Get-SeatId) | Sort-Object

    $minSeatId = $seatIds[0]
    for ($i = 1; $i -lt ($seatIds.Count - 1); $i++) {
        $expectedSeatId = $minSeatId + $i
        if ($seatIds[$i] -ne $expectedSeatId) {
            break
        }
    }

    if (-not $expectedSeatId) {
        throw "no missing seats found"
    }

    return $expectedSeatId
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
