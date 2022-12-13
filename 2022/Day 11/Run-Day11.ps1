function Parse-Input {
    [CmdletBinding()]
    param (
        $MonkeyInput
    )

    $monkeys = @()
    $commonDivisor = 1

    # assume each block is the same number of lines (6 + 1 whitespace = 7)
    for ($i = 0; $i -lt $MonkeyInput.Count; $i += 7) {
        # first line is Monkey ID, which we can ignore as it will match the array index
        $newMonkey = [PSCustomObject]@{
            Items = @()
            Operation = @{}
            Test = @{}
            InspectCount = 0
        }

        # parse starting items (starts at 18th character)
        $newMonkey.Items = [int[]]($MonkeyInput[$i+1].Substring(18) -split ', ')

        # parse operation (starts at 19th character)
        $operationText = $MonkeyInput[$i+2].Substring(19)
        $newMonkey.Operation.FirstValue, $newMonkey.Operation.Operator, $newMonkey.Operation.SecondValue = $operationText -split ' '

        # parse test (assuming all to be "divisible by" tests, so start at the 21st character)
        $newMonkey.Test.DivisibleBy = [int]$MonkeyInput[$i+3].Substring(21)
        $newMonkey.Test.TrueCase    = [int]($MonkeyInput[$i+4] -split ' ' | Select-Object -Last 1)
        $newMonkey.Test.FalseCase   = [int]($MonkeyInput[$i+5] -split ' ' | Select-Object -Last 1)

        $monkeys += $newMonkey

        # update common divisor
        $commonDivisor *= $newMonkey.Test.DivisibleBy
    }

    return $monkeys, $commonDivisor
}

# currently only handles * and + operations
function Get-OperationResult {
    [CmdletBinding()]
    param (
        $Operation,
        $OldValue
    )

    $firstValue  = if ($Operation.FirstValue -eq 'old') { $OldValue } else { [int]$Operation.FirstValue }
    $secondValue = if ($Operation.SecondValue -eq 'old') { $OldValue } else { [int]$Operation.SecondValue }

    if ($Operation.Operator -eq '+') {
        return ($firstValue + $secondValue)
    }
    elseif ($Operation.Operator -eq '*') {
        return ($firstValue * $secondValue)
    }
    else {
        throw "Unknown operator $($Operation.Operator)"
    }
}

# Monkeys is passed as a reference so changes within this function should propogate back to the caller
function Play-Round {
    [CmdletBinding()]
    param (
        $Monkeys,
        $WorryReduction,
        $CommonDivisor
    )

    # since all monkeys use division by primes, we can use Chinese Remainder Theorem to keep levels manageable
    # NOTE: I do not understand the basis for this math very well, solution is a result of having to read up 
    # on other solutions and then on some math theory before I was able to build it here :)

    foreach ($monkey in $Monkeys) {
        $monkey.InspectCount += $monkey.Items.Count
        foreach ($item in $monkey.Items) {
            $item = (Get-OperationResult -Operation $monkey.Operation -OldValue $item)
            $item = [Math]::Floor($item / $WorryReduction)
            $item = $item % $commonDivisor # use the remainder of the shared divisor to keep numbers down

            if ($item % $monkey.Test.DivisibleBy -eq 0) {
                $Monkeys[$monkey.Test.TrueCase].Items += $item
            }
            else {
                $Monkeys[$monkey.Test.FalseCase].Items += $item
            }
        }
        $monkey.Items = @()
    }
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $monkeys, $commonDivisor = Parse-Input -MonkeyInput $PuzzleInput
    $roundCount = 20
    $worryReduction = 3

    for ($i = 0; $i -lt $roundCount; $i++) {
        Play-Round -Monkeys $monkeys -WorryReduction $worryReduction -CommonDivisor $commonDivisor
    }

    $firstMost, $secondMost = $monkeys.InspectCount | Sort-Object -Descending | Select-Object -First 2
    return ($firstMost * $secondMost)
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $monkeys, $commonDivisor = Parse-Input -MonkeyInput $PuzzleInput
    $roundCount = 10000
    $worryReduction = 1

    for ($i = 0; $i -lt $roundCount; $i++) {
        Play-Round -Monkeys $monkeys -WorryReduction $worryReduction -CommonDivisor $commonDivisor
    }

    $firstMost, $secondMost = $monkeys.InspectCount | Sort-Object -Descending | Select-Object -First 2
    return ($firstMost * $secondMost)
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
