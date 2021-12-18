function Get-BinaryString {
    [CmdletBinding()]
    param (
        $HexCharacter
    )

    $binString = switch ($HexCharacter) {
        '0' { '0000' }
        '1' { '0001' }
        '2' { '0010' }
        '3' { '0011' }
        '4' { '0100' }
        '5' { '0101' }
        '6' { '0110' }
        '7' { '0111' }
        '8' { '1000' }
        '9' { '1001' }
        'A' { '1010' }
        'B' { '1011' }
        'C' { '1100' }
        'D' { '1101' }
        'E' { '1110' }
        'F' { '1111' }
        default { throw "unrecognized hex character $HexCharacter" }
    }

    return $binString
}

function Get-PacketNumber {
   [CmdletBinding()]
    param (
        $Bits
    )

    $numberString = ""
    $pointer = 0
    while ($true) {
        $group = $Bits[$pointer..($pointer + 4)]
        $numberString += ($group[1..4] -join '')
        $pointer += 5

        if ($group[0] -eq '0') {
            break
        }
    }
    $number = [Convert]::ToInt64($numberString, 2)
    $remainingBits = $Bits[$pointer..($Bits.Count - 1)]

    return $number, $remainingBits
}

function Process-Packet {
    [CmdletBinding()]
    param (
        $Bits
    )

    $versionCode = [Convert]::ToInt32(($Bits[0..2] -join ''), 2)
    $typeId = [Convert]::ToInt32(($Bits[3..5] -join ''), 2)

    $packet = @{
        Version = $versionCode
        Type = $typeId
    }

    # process type id of 4 as a numerical value
    if ($typeId -eq 4) {
        $packet.Number, $remainingBits = Get-PacketNumber -Bits $Bits[6..($Bits.Count - 1)]
    }
    else {
        $packet.Children = @()
        $typeLengthId = $Bits[6]
        if ($typeLengthId -eq '0') {
            $length = [Convert]::ToInt32(($Bits[7..21] -join ''), 2)

            $remainingBits = $Bits[22..($Bits.Count - 1)]
            $totalLength = 0
            while ($totalLength -lt $length) {
                $subPacket, $remainingBits = Process-Packet -Bits $remainingBits
                $packet.Children += $subPacket
                $totalLength += $subPacket.Length
            }
        }
        else {
            $length = [Convert]::ToInt32(($Bits[7..17] -join ''), 2)
            $remainingBits = $Bits[18..($Bits.Count - 1)]

            for ($i = 0; $i -lt $length; $i++) {
                $subPacket, $remainingBits = Process-Packet -Bits $remainingBits
                $packet.Children += $subPacket
            }
        }
    }

    $packet.Length = $Bits.Count - $remainingBits.Count

    return $packet, $remainingBits
}

function Get-VersionSum {
    [CmdletBinding()]
    param (
        $Packet
    )

    $versionSum = $Packet.Version
    if ($Packet.Children) {
        $Packet.Children | ForEach-Object { $versionSum += Get-VersionSum -Packet $_ } 
    }

    return $versionSum
}

function Get-ExpressionResult {
    [CmdletBinding()]
    param (
        $Packet
    )

    $type = $Packet.Type
    if ($type -eq 4) {
        return $Packet.Number
    }
    else {
        $numbers = $Packet.Children | ForEach-Object { Get-ExpressionResult -Packet $_ }
        switch ($type) {
            0 {
                $sum = 0
                $numbers | ForEach-Object { $sum += $_ } 
                return $sum
            }
            1 {
                $product = 1
                $numbers | ForEach-Object { $product *= $_ } 
                return $product
            }
            2 {
                return ($numbers | Measure-Object -Minimum).Minimum
            }
            3 {
                return ($numbers | Measure-Object -Maximum).Maximum
            }
            5 {
                return [int]($numbers[0] -gt $numbers[1])
            }
            6 {
                return [int]($numbers[0] -lt $numbers[1])
            }
            7 {
                return [int]($numbers[0] -eq $numbers[1])
            }
            default { throw "Unrecognized type $type" }
        }
    }
}


function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $transmission = $PuzzleInput.ToCharArray()
    $bits = $transmission | ForEach-Object { (Get-BinaryString $_).ToCharArray() }
    $packet, $null = Process-Packet -Bits $bits

    return Get-VersionSum -Packet $packet
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $transmission = $PuzzleInput.ToCharArray()
    $bits = $transmission | ForEach-Object { (Get-BinaryString $_).ToCharArray() }
    $packet, $null = Process-Packet -Bits $bits

    return Get-ExpressionResult -Packet $packet
}

$puzzleInput = Get-Content .\input.txt

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
