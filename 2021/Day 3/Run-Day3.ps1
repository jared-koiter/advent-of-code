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

    $half = [math]::Round($Rows.Count / 2)
    return (($counter | ForEach-Object { [int]($_ -gt $half) }) -join '')
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $gammaRate = [convert]::ToInt64((Get-MostCommonBits -Rows $PuzzleInput), 2)
    $mask = [convert]::ToInt64('1' * $counter.Count, 2)
    $epsilonRate = $gammaRate -bxor $mask

    return ($gammaRate * $epsilonRate)
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
