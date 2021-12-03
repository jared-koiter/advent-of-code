function Get-MostCommonBits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$Rows,
        [Parameter(Mandatory = $false)]
        $StartIndex = 0,
        [Parameter(Mandatory = $false)]
        $EndIndex
    )

    $rowLength = $Rows[0].Length
    if ($EndIndex -eq $null) {
        $EndIndex = $rowLength - 1
    }

    if ($EndIndex -ge $rowLength -or $EndIndex -lt $StartIndex) {
        throw "invalid index input"
    }

    $counter = New-Object int[] $rowLength
    foreach ($row in $Rows) {
        for ($i = $StartIndex; $i -le $EndIndex; $i++) {
            $counter[$i] += [convert]::ToInt32($row[$i], 10)
        }
    }

    return @{
        MostCommonBits = (($counter | ForEach-Object { [int]($_ -ge ($Rows.Count - $_)) }) -join '')
        OneBitCounts = $counter
    }
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $gammaRate = [convert]::ToInt64((Get-MostCommonBits -Rows $PuzzleInput).MostCommonBits, 2)
    $mask = [convert]::ToInt64('1' * $PuzzleInput[0].Length, 2)
    $epsilonRate = $gammaRate -bxor $mask

    return ($gammaRate * $epsilonRate)
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $oxyList = $PuzzleInput
    $co2List = $PuzzleInput
    foreach ($i in (0..($PuzzleInput[0].Length - 1))) {
        if ($oxyList.Count -gt 1) {
            $bitData = Get-MostCommonBits -Rows $oxyList -StartIndex $i -EndIndex $i
            $bitSelector = if ($bitData.OneBitCounts[$i] -eq ($oxyList.Count / 2)) { '1' } else { $bitData.MostCommonBits[$i] }
            $oxyList = $oxyList | Where-Object { $_[$i] -eq $bitSelector }
        }

        if ($co2List.Count -gt 1) {
            $bitData = Get-MostCommonBits -Rows $co2List -StartIndex $i -EndIndex $i
            $bitSelector = if ($bitData.OneBitCounts[$i] -eq ($co2List.Count / 2)) { '1' } else { $bitData.MostCommonBits[$i] }
            $co2List = $co2List | Where-Object { $_[$i] -ne $bitSelector }
        }

        if ($oxyList.Count -eq 1 -and $co2List.Count -eq 1) {
            $oxyValue = [convert]::ToInt64($oxyList, 2)
            $co2Value = [convert]::ToInt64($co2List, 2)
            break
        }

        if (($oxyList.Count -eq 0) -or ($co2List.Count -eq 0)) {
            throw "eliminated all entries without finding value"
        }
    }

    if ((-not $oxyValue) -or (-not $co2Value)) {
        throw "didn't find a unique value"
    }

    return ($oxyValue * $co2Value)
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
