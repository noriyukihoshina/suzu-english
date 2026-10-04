# Set console and script to read UTF8
$data1Path = Join-Path $PSScriptRoot "raw_data1.txt"
$data2Path = Join-Path $PSScriptRoot "raw_data2.txt"

# UTF-8 kana dictionary built via base64 or unicode escapes or external json
$kanaJson = @"
{
    "watch": "\u30a6\u30a9\u30c3\u30c1",
    "I / my / me / mine": "\u30a2\u30a4 / \u30de\u30a4 / \u30df\u30fc / \u30de\u30a4\u30f3",
    "you / your / you / yours": "\u30e6\u30fc / \u30e6\u30a2 / \u30e6\u30fc / \u30e6\u30a2\u30fc\u30ba",
    "he / his / him / his": "\u30d2\u30fc / \u30d2\u30ba / \u30d2\u30e0 / \u30d2\u30ba",
    "she / her / her / hers": "\u30b7\u30fc / \u30cf\u30fc / \u30cf\u30fc / \u30cf\u30fc\u30ba",
    "we / our / us / ours": "\u30a6\u30a3\u30fc / \u30a2\u30ef\u30fc / \u30a2\u30b9 / \u30a2\u30ef\u30fc\u30ba",
    "they / their / them / theirs": "\u30bc\u30a4 / \u30bc\u30a2 / \u30bc\u30e0 / \u30bc\u30a2\u30fc\u30ba",
    "what": "\u30db\u30ef\u30c3\u30c8",
    "who": "\u30d5\u30fc",
    "where": "\u30a6\u30a7\u30a2",
    "when": "\u30a6\u30a7\u30f3",
    "how": "\u30cf\u30a6",
    "can": "\u30ad\u30e3\u30f3",
    "very": "\u30d9\u30ea\u30fc",
    "always": "\u30aa\u30fc\u30eb\u30a6\u30a7\u30a4\u30ba",
    "usually": "\u30e6\u30fc\u30b8\u30e5\u30a2\u30ea\u30fc",
    "often": "\u30aa\u30d5\u30c8\u30a1\u30f3",
    "and": "\u30a2\u30f3\u30c9",
    "but": "\u30d0\u30c3\u30c8",
    "in / on / at": "\u30a2\u30f3 / \u30aa\u30f3 / \u30a2\u30c3\u30c8",
    "with": "\u30a6\u30a3\u30ba",
    "for": "\u30d5\u30a9\u30fc"
}
"@
$kanaMap = $kanaJson | ConvertFrom-Json

$dict = [System.Collections.Specialized.OrderedDictionary]::new()

# Read UTF8 files
$lines1 = [System.IO.File]::ReadAllLines($data1Path, [System.Text.Encoding]::UTF8)
foreach ($line in $lines1) {
    $line = $line.Trim()
    if (-not $line) { continue }
    $cols = $line.Split("`t")
    if ($cols.Length -ge 2) {
        $en = $cols[0].Trim()
        $ja = $cols[1].Trim()
        $key = $en.ToLower()
        $kanaVal = ""
        if ($kanaMap.PSObject.Properties[$en]) {
            $kanaVal = $kanaMap.$en
        }
        $kana = ""
        if ($kanaVal) {
            $kana = [char]0xFF08 + $kanaVal + [char]0xFF09
        }
        $dict[$key] = [PSCustomObject]@{
            en = $en
            kana = $kana
            ja = $ja
        }
    }
}

$lines2 = [System.IO.File]::ReadAllLines($data2Path, [System.Text.Encoding]::UTF8)
foreach ($line in $lines2) {
    $line = $line.Trim()
    if (-not $line) { continue }
    $cols = $line.Split("`t")
    if ($cols.Length -ge 3) {
        $en = $cols[0].Trim()
        $kana = [char]0xFF08 + $cols[1].Trim() + [char]0xFF09
        $jaRaw = $cols[2].Trim()
        $ja = $jaRaw
        if ($jaRaw -match "I have") {
            $ja = [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xe6,0x8c,0x81,0xe3,0x81,0xa3,0xe3,0x81,0xa6,0xe3,0x81,0x84,0xe3,0x82,0x8b,0xe3,0x80,0x81,0xe9,0xa3,0xbc,0xe3,0x81,0xa3,0xe3,0x81,0xa6,0xe3,0x81,0x84,0xe3,0x82,0x8b))
        }
        $key = $en.ToLower()
        if ($dict.Contains($key)) {
            $existing = $dict[$key]
            if (-not $existing.kana) {
                $existing.kana = $kana
            }
            if ($ja.Length -gt $existing.ja.Length) {
                $existing.ja = $ja
            }
        } else {
            $dict[$key] = [PSCustomObject]@{
                en = $en
                kana = $kana
                ja = $ja
            }
        }
    }
}

$resultList = @()
$id = 1
foreach ($key in $dict.Keys) {
    $item = $dict[$key]
    $resultList += [PSCustomObject]@{
        id = $id
        en = $item.en
        kana = $item.kana
        ja = $item.ja
        mistakes = 0
        history = @()
    }
    $id++
}

$outPath = Join-Path $PSScriptRoot "parsed_words.json"
$jsonStr = $resultList | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($outPath, $jsonStr, [System.Text.Encoding]::UTF8)

Write-Host "Extracted $($resultList.Count) unique words."
