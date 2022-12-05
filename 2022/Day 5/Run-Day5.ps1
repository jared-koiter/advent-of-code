function Parse-Input {
    [CmdletBinding()]
    param (
        $CrateDetails
    )

    $crateRows = @()
    $i = 0
    # read rows until we find the one describing the columns
    while ($CrateDetails[$i] -match '\[') {
        $crateRows += $CrateDetails[$i]
        $i++
    }

    # parse the column description row
    $columnDescription = $CrateDetails[$i].Replace(' ', '')
    $columnCount = [int]($columnDescription.Substring($columnDescription.Length-1))
    $i += 2

    # read the action rows
    $actions = @()
    while ($i -lt $CrateDetails.Count) {
        
    } 

}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $crates, $actions = Parse-Input -CrateDetails $PuzzleInput
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
