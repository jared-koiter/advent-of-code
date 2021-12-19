function Build-NumberTree {
    [CmdletBinding()]
    param (
        $NumberArray,
        $NodeId,
        $ParentId
    )

    $left = $NumberArray[0]
    $right = $NumberArray[1]

    $numberTree = @{
        $NodeId = @{
            Parent = $ParentId
        }
    }

    if ($left.GetType() -eq [Int32]) {
        $numberTree.$NodeId.Left = $left
    }
    else {
        $leftId = (New-Guid).ToString()
        $leftnumberTree = Build-NumberTree -NumberArray $left -ParentId $NodeId -NodeId $leftId
        $numberTree.$NodeId.Left = $leftId

        foreach ($key in $leftNumberTree.Keys) {
            $numberTree.$key = $leftNumberTree.$key
        }
    }

    if ($right.GetType() -eq [Int32]) {
        $numberTree.$NodeId.Right = $right
    }
    else {
        $rightId = (New-Guid).ToString()
        $rightnumberTree = Build-NumberTree -NumberArray $right -ParentId $NodeId -NodeId $rightId
        $numberTree.$NodeId.Right = $rightId

        foreach ($key in $rightNumberTree.Keys) {
            $numberTree.$key = $rightNumberTree.$key
        }
    }

    return $numberTree
}

function Get-TreeAsString {
    [CmdletBinding()]
    param (
        $NumberTree,
        $RootNodeId
    )

    if ($NumberTree.$RootNodeId.Left.GetType() -ne [Int32]) {
        $left = Get-TreeAsString -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Left
    }
    else {
        $left = $NumberTree.$RootNodeId.Left
    }

    if ($NumberTree.$RootNodeId.Right.GetType() -ne [Int32]) {
        $right = Get-TreeAsString -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Right
    }
    else {
        $right = $NumberTree.$RootNodeId.Right
    }

    return "[$left,$right]"
}

function Get-NodeDepth {
    [CmdletBinding()]
    param (
        $NumberTree,
        $NodeId
    )

    $depth = 0
    while ($NumberTree.$NodeId.Parent) {
        $depth++
        $NodeId = $NumberTree.$NodeId.Parent
    }

    return $depth
}

function Reduce-TreeByExploding {
    [CmdletBinding()]
    param (
        $NumberTree,
        $RootNodeId
    )

    $didReduce = $false
    $depth = Get-NodeDepth -NumberTree $NumberTree -NodeId $RootNodeId
    if ($depth -eq 4) {
        $leftValue = $NumberTree.$RootNodeId.Left
        $rightValue = $NumberTree.$RootNodeId.Right
        $parentNode = $NumberTree.$RootNodeId.Parent

        # add left value to the next node to the left, if one exists
        $leftCurrentNode = $RootNodeId
        $leftParentNode = $parentNode
        while ($leftParentNode) {
            if ($NumberTree.$leftParentNode.Left -ne $leftCurrentNode) {
                if ($NumberTree.$leftParentNode.Left.GetType() -eq [Int32]) {
                    $NumberTree.$leftParentNode.Left += $leftValue
                    break
                }
                else {
                    $nextLeftNode = $NumberTree.$leftParentNode.Left
                    while ($NumberTree.$nextLeftNode.Right.GetType() -ne [Int32]) {
                        $nextLeftNode = $NumberTree.$nextLeftNode.Right
                    }
                    $NumberTree.$nextLeftNode.Right += $leftValue
                    break
                }
            }
            else {
                $leftCurrentNode = $leftParentNode
                $leftParentNode = $NumberTree.$leftCurrentNode.Parent
            }
        }

        # add right value to the next node to the right
        $rightCurrentNode = $RootNodeId
        $rightParentNode = $parentNode
        while ($rightParentNode) {
            if ($NumberTree.$rightParentNode.Right -ne $rightCurrentNode) {
                if ($NumberTree.$rightParentNode.Right.GetType() -eq [Int32]) {
                    $NumberTree.$rightParentNode.Right += $rightValue
                    break
                }
                else {
                    $nextRightNode = $NumberTree.$rightParentNode.Right
                    while ($NumberTree.$nextRightNode.Left.GetType() -ne [Int32]) {
                        $nextRightNode = $NumberTree.$nextRightNode.Left
                    }
                    $NumberTree.$nextRightNode.Left += $rightValue
                    break
                }
            }
            else {
                $rightCurrentNode = $rightParentNode
                $rightParentNode = $NumberTree.$rightCurrentNode.Parent
            }
        }

        # remove the exploded node and replace it with a 0
        $NumberTree.Remove($RootNodeId)
        if ($NumberTree.$parentNode.Left -eq $RootNodeId) {
            $NumberTree.$parentNode.Left = 0
        }
        else {
            $NumberTree.$parentNode.Right = 0
        }

        $didReduce = $true
    }

    # if we didn't reduce at our current node, recursively try reducing at child nodes, left to right
    if ((-not $didReduce) -and ($NumberTree.$RootNodeId.Left.GetType() -ne [Int32])) {
        $NumberTree, $didReduce = Reduce-TreeByExploding -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Left
    }

    if ((-not $didReduce) -and ($NumberTree.$RootNodeId.Right.GetType() -ne [Int32])) {
        $NumberTree, $didReduce = Reduce-TreeByExploding -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Right
    }

    return $NumberTree, $didReduce
}

function Reduce-TreeBySplitting {
    [CmdletBinding()]
    param (
        $NumberTree,
        $RootNodeId
    )

    $didReduce = $false
    if ($NumberTree.$RootNodeId.Left.GetType() -eq [Int32]) {
        if ($NumberTree.$RootNodeId.Left -gt 9) {
            [Int32]$newLeftValue = [Math]::Floor($NumberTree.$RootNodeId.Left / 2)
            [Int32]$newRightValue = $NumberTree.$RootNodeId.Left - $newLeftValue

            $newNodeId = (New-Guid).ToString()
            $newNode = @{
                Parent = $RootNodeId
                Left = $newLeftValue
                Right = $newRightValue
            }
            $NumberTree.$newNodeId = $newNode
            $NumberTree.$RootNodeId.Left = $newNodeId

            $didReduce = $true
        }
    }
    else {
        $NumberTree, $didReduce = Reduce-TreeBySplitting -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Left
    }

    if ($didReduce) {
        return $NumberTree, $didReduce
    }

    if ($NumberTree.$RootNodeId.Right.GetType() -eq [Int32]) {
        if ($NumberTree.$RootNodeId.Right -gt 9) {
            [Int32]$newLeftValue = [Math]::Floor($NumberTree.$RootNodeId.Right / 2)
            [Int32]$newRightValue = $NumberTree.$RootNodeId.Right - $newLeftValue

            $newNodeId = (New-Guid).ToString()
            $newNode = @{
                Parent = $RootNodeId
                Left = $newLeftValue
                Right = $newRightValue
            }
            $NumberTree.$newNodeId = $newNode
            $NumberTree.$RootNodeId.Right = $newNodeId

            $didReduce = $true
        }
    }
    else {
        $NumberTree, $didReduce = Reduce-TreeBySplitting -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Right
    }

    return $NumberTree, $didReduce
}

function Get-TreeMagnitude {
    [CmdletBinding()]
    param (
        $NumberTree,
        $RootNodeId
    )

    if ($NumberTree.$RootNodeId.Left.GetType() -ne [Int32]) {
        $left = Get-TreeMagnitude -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Left
    }
    else {
        $left = $NumberTree.$RootNodeId.Left
    }

    if ($NumberTree.$RootNodeId.Right.GetType() -ne [Int32]) {
        $right = Get-TreeMagnitude -NumberTree $NumberTree -RootNodeId $NumberTree.$RootNodeId.Right
    }
    else {
        $right = $NumberTree.$RootNodeId.Right
    }

    return [Int32]((3 * $left) + (2 * $right))
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $leftRootId = (New-Guid).ToString()
    $leftTree = Build-NumberTree -NumberArray ($PuzzleInput[0] | ConvertFrom-Json) -NodeId $leftRootId
    for ($i = 1; $i -lt $PuzzleInput.Count; $i++) {
        $rightRootId = (New-Guid).ToString()
        $rightTree = Build-NumberTree -NumberArray ($PuzzleInput[$i] | ConvertFrom-Json) -NodeId $rightRootId

        #Write-Host "   $(Get-TreeAsString -NumberTree $leftTree -RootNodeId $leftRootId)" -ForegroundColor DarkCyan
        #Write-Host "+  $(Get-TreeAsString -NumberTree $rightTree -RootNodeId $rightRootId)" -ForegroundColor DarkMagenta

        $sumRootId = (New-Guid).ToString()
        $sumTree = @{
            $sumRootId = @{
                Parent = $null
                Left = $leftRootId
                Right = $rightRootId
            }
        }
        $leftTree.$leftRootId.Parent = $sumRootId
        $rightTree.$rightRootId.Parent = $sumRootId

        $sumTree = $sumTree + $leftTree + $rightTree
        do {
            $sumTree, $didReduce = Reduce-TreeByExploding -NumberTree $sumTree -RootNodeId $sumRootId
            if (-not $didReduce) {
                $sumTree, $didReduce = Reduce-TreeBySplitting -NumberTree $sumTree -RootNodeId $sumRootId
            }
        }
        while ($didReduce)

        Write-Host "=  $(Get-TreeAsString -NumberTree $sumTree -RootNodeId $sumRootId)" -ForegroundColor Green
        Write-Host ""
        $leftRootId = $sumRootId
        $leftTree = $sumTree
    }

    return (Get-TreeMagnitude -NumberTree $leftTree -RootNodeId $leftRootId)
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
