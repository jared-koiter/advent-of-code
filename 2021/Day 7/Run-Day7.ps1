function Get-RuleSet {
    [CmdletBinding()]
    param (
        $RuleList
    )

    $ruleSet = @{}
    foreach ($rule in $RuleList) {
        $parentBagColour, $containsRules = $rule -split ' bags contain '
        foreach ($containsRule in ($containsRules -split ', ')) {
            $count, $mod, $colour, $null = $containsRule -split ' '
            $bagColour = "$mod $colour"

            if ($count -ne 'no') {
                # add children
                $childEntry = @{
                    Colour = $bagColour
                    Count = [int]$count
                }

                if ($ruleSet.$parentBagColour) {
                    $ruleSet.$parentBagColour.Children += $childEntry
                }
                else {
                    $ruleSet.$parentBagColour = @{
                        Children = @(
                            $childEntry
                        )
                        Parents = @()
                    }
                }

                # add parents
                if ($ruleSet.$bagColour) {
                    $ruleSet.$bagColour.Parents += $parentBagColour
                }
                else {
                    $ruleSet.$bagColour = @{
                        Children = @()
                        Parents = @(
                            $parentBagColour
                        )
                    }
                }
            }
        }
    }

    return $ruleSet
}

function Get-Parents {
    [CmdletBinding()]
    param (
        $RuleSet,
        $TargetBagColours
    )

    $parents = @()
    foreach ($colour in $TargetBagColours) {
        $parents += $RuleSet.$colour.Parents
    }    
    return $parents
}

function Get-ChildBagCount {
    [CmdletBinding()]
    param (
        $RuleSet,
        $TargetBagColour
    )

    $bagCount = 0
    foreach ($child in $RuleSet.$TargetBagColour.Children) {
        $bagCount += ($child.Count + ($child.Count * (Get-ChildBagCount -RuleSet $RuleSet -TargetBagColour $child.Colour)))
    }

    return $bagCount
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $ruleSet = Get-RuleSet -RuleList $PuzzleInput
    $targetBagColour = 'shiny gold'

    $possibleParents = Get-Parents -RuleSet $ruleSet -TargetBagColours $targetBagColour
    $moreParents = Get-Parents -RuleSet $ruleSet -TargetBagColours $possibleParents
    while ($moreParents) {
        $possibleParents += $moreParents
        $moreParents = Get-Parents -RuleSet $ruleSet -TargetBagColours $moreParents
    }

    return ($possibleParents | Sort-Object | Get-Unique).Count
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $ruleSet = Get-RuleSet -RuleList $PuzzleInput
    $targetBagColour = 'shiny gold'

    $childBagCount = Get-ChildBagCount -RuleSet $ruleSet -TargetBagColour $targetBagColour
    return $childBagCount
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
