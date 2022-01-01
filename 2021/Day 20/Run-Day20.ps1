function Get-ImageData {
    [CmdletBinding()]
    param (
        [string[]] $ImageInput
    )

    $image = @()
    for ($i = 0; $i -lt $ImageInput.Count; $i++) {
        $image += ,$ImageInput[$i].ToCharArray()
    }

    return $image
}

function Print-Image {
    [CmdletBinding()]
    param (
        $Image
    )

    for ($rowNum = 0; $rowNum -lt $Image.Count; $rowNum++) {
        for ($colNum = 0; $colNum -lt $Image[0].Count; $colNum++) {
            Write-Host "$($Image[$rowNum][$colNum]) " -NoNewline
        }
        Write-Host
    }
}

# returns the input image surrounded with a 1-wide border of pixels
function Get-ExpandedImageGrid {
    [CmdletBinding()]
    param (
        $ImageInput,
        $InfinitePixel
    )

    $originalHeight = $ImageInput.Count
    $originalWidth = $ImageInput[0].Count
    $newHeight = $originalHeight + 4
    $newWidth = $originalWidth + 4

    $newImage = ,(,[char]$InfinitePixel * $newWidth) * $newHeight
    
    for ($row = 2; $row -lt ($newHeight - 2); $row++) {
        $imageRow = $newImage[$row] | ForEach-Object { $_ }
        for ($col = 2; $col -lt ($newWidth - 2); $col++) {
            $imageRow[$col] = $ImageInput[$row - 2][$col - 2]
        }
        $newImage[$row] = $imageRow
    }

    return $newImage
}

function Enhance-Image {
    [CmdletBinding()]
    param (
        $Image,
        $Algorithm,
        $InfinitePixel
    )

    $height = $Image.Count
    $width = $Image[0].Count
    $newImage = ,(,[char]'X' * $width) * $height

    # enhance image
    for ($row = 0; $row -lt $height; $row++) {
        $newImageRow = $newImage[$row] | ForEach-Object { $_ }
        for ($col = 0; $col -lt $width; $col++) {
            $pixelString = ""
            foreach ($i in ($row - 1)..($row + 1)) {
                foreach ($j in ($col - 1)..($col + 1)) {
                    if ($i -lt 0 -or $i -gt ($height - 1) -or $j -lt 0 -or $j -gt ($width - 1)) {
                        $pixel = $InfinitePixel
                    }
                    else {
                        $pixel = $image[$i][$j]
                    }

                    $pixelString += if ($pixel -eq '#') { '1' } else { '0' }
                }
            }
            $newPixel = $Algorithm[[Convert]::ToInt32($pixelString,2)]
            $newImageRow[$col] = $newPixel
        }
        $newImage[$row] = $newImageRow
    }

    # calculate new infinite pixel for region outside of our tracked image
    $InfinitePixel = if ($InfinitePixel -eq '#') { $Algorithm[-1] } else { $Algorithm[0] }
    return $newImage, $InfinitePixel
}

function Get-LitPixelCount {
    [CmdletBinding()]
    param (
        $Image,
        $InfinitePixel
    )

    if ($InfinitePixel -eq '#') {
        Write-Warning "Infinite image is lit"
        return [Int]::MaxValue
    }

    $count = 0
    for ($rowNum = 0; $rowNum -lt $Image.Count; $rowNum++) {
        for ($colNum = 0; $colNum -lt $Image[0].Count; $colNum++) {
            if ($Image[$rowNum][$colNum] -eq '#') {
                $count++
            }
        }
    }

    return $count
}

function Run-EnhancementRoutine {
    [CmdletBinding()]
    param (
        $Image,
        $Algorithm,
        $EnhancementCount
    )

    # start off assuming all space outside the image is dark pixels
    $infinitePixel = '.'

    for ($i = 0; $i -lt $EnhancementCount; $i++) {
        $expandedImage = Get-ExpandedImageGrid -ImageInput $Image -InfinitePixel $infinitePixel
        $Image, $infinitePixel = Enhance-Image -Image $expandedImage -Algorithm $Algorithm -InfinitePixel $infinitePixel
    }

    return $Image
}

function Run-Puzzle1 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $algorithm = $PuzzleInput[0].ToCharArray()
    $image = Get-ImageData -ImageInput $PuzzleInput[2..($PuzzleInput.Count - 1)]
    $image = Run-EnhancementRoutine -Image $image -Algorithm $algorithm -EnhancementCount 2
    return Get-LitPixelCount -Image $image -InfinitePixel $infinitePixel
}

function Run-Puzzle2 {
    [CmdletBinding()]
    param (
        $PuzzleInput
    )

    $algorithm = $PuzzleInput[0].ToCharArray()
    $image = Get-ImageData -ImageInput $PuzzleInput[2..($PuzzleInput.Count - 1)]
    $image = Run-EnhancementRoutine -Image $image -Algorithm $algorithm -EnhancementCount 50
    return Get-LitPixelCount -Image $image -InfinitePixel $infinitePixel
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
