function Parse-Input {
    [CmdletBinding()]
    param (
        $CrateDetails
    )

    $i = 0
    # read rows until we find the one describing the columns
    while ($CrateDetails[$i] -match '\[') {
        $i++
    }

    # parse the column description row
    $columnDescription = $CrateDetails[$i].Replace(' ', '')
    $columnCount = [int]($columnDescription.Substring($columnDescription.Length-1))

    # initialize empty crate stacks
    $crateStacks = @($null) * $columnCount
    for ($j = 0; $j -lt $columnCount; $j++) {
        $crateStacks[$j] = New-Object System.Collections.Stack
    }

    # go back and parse the initial crate configuration
    for ($j = ($i-1); $j -ge 0; $j--) {
        for ($k = 0; $k -lt $columnCount; $k++) {
            $entry = [string]($CrateDetails[$j][(1 + ($k*4))]) -replace ' ', ''
            if ($entry) {
                $crateStacks[$k].Push($entry)
            }
        }
    }

    # move pointer to next section
    $i += 2

    # read the action rows
    $actions = @()
    $actionRegex = "move (\d+) from (\d+) to (\d+)"
    while ($i -lt $CrateDetails.Count) {
        $count, $source, $target = (([regex]::Match($CrateDetails[$i], $actionRegex)).Groups.Value)[1..3]
        $actions += @{
            Count  = [int]$count
            Source = [int]$source - 1
            Target = [int]$target - 1
        }
        $i++
    }

    return $crateStacks, $actions
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $crateStacks, $actions = Parse-Input -CrateDetails $PuzzleInput

    foreach ($action in $actions) {
        for ($i = 0; $i -lt $action.Count; $i++) {
            $crateStacks[$action.Target].Push($crateStacks[$action.Source].Pop())
        }
    }

    return ($crateStacks | ForEach-Object { $_.Pop() }) -join ''
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $crateStacks, $actions = Parse-Input -CrateDetails $PuzzleInput

    foreach ($action in $actions) {
        $tempStack = New-Object System.Collections.Stack

        for ($i = 0; $i -lt $action.Count; $i++) {
            $tempStack.Push($crateStacks[$action.Source].Pop())
        }

        for ($i = 0; $i -lt $action.Count; $i++) {
            $crateStacks[$action.Target].Push($tempStack.Pop())
        }
    }

    return ($crateStacks | ForEach-Object { $_.Pop() }) -join ''
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
