function Get-LetterPriority {
    [CmdletBinding()]
    param (
        $Letter
    )

    # unicode numbers:
    # 97-122 = a-z
    # 65-90 = A-Z

    $letterCode = [int]$Letter
    if ($letterCode -gt 90) {
        return ($letterCode - 96) # lowercase
    }
    else {
        return ($letterCode - 38) # uppercase
    }
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $prioritySum = 0
    foreach ($rucksack in $PuzzleInput) {
        $compartmentSize = $rucksack.Length / 2
        $firstCompartment = $rucksack.Substring(0, $compartmentSize).ToCharArray() | Sort-Object -CaseSensitive | Get-Unique
        $secondCompartment = $rucksack.Substring($rucksack.Length - $compartmentSize, $compartmentSize).ToCharArray() | Sort-Object -CaseSensitive | Get-Unique

        :outer for ($i = 0; $i -lt $firstCompartment.Length; $i++) {
            for ($j = 0; $j -lt $secondCompartment.Length; $j++) {
                if ($firstCompartment[$i] -ceq $secondCompartment[$j]) {
                    $prioritySum += Get-LetterPriority -Letter $firstCompartment[$i]
                    break outer
                }
            }
        }
    }

    return $prioritySum
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $prioritySum = 0
    for ($r = 0; $r -lt $PuzzleInput.Length; $r += 3) {
        $combinedRucksacks = ($PuzzleInput[$r].ToCharArray() | Sort-Object -CaseSensitive | Get-Unique) +
        ($PuzzleInput[$r + 1].ToCharArray() | Sort-Object -CaseSensitive | Get-Unique) +
        ($PuzzleInput[$r + 2].ToCharArray() | Sort-Object -CaseSensitive | Get-Unique)

        $prioritySum += Get-LetterPriority -Letter ([char]($combinedRucksacks | Group-Object -NoElement | Where-Object { $_.Count -eq 3 }).Name)
    }

    return $prioritySum
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
