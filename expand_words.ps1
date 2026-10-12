# Build 180 words list for Junior High 1st grade
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseWordsJsonPath = Join-Path $PSScriptRoot "parsed_words.json"
$baseWords = Get-Content $baseWordsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

$expandedWords = @()

foreach ($item in $baseWords) {
    if ($item.en -eq "I / my / me / mine") {
        $expandedWords += [PSCustomObject]@{ en="I"; kana="（アイ）"; ja="私は、私が" }
        $expandedWords += [PSCustomObject]@{ en="my"; kana="（マイ）"; ja="私の" }
        $expandedWords += [PSCustomObject]@{ en="me"; kana="（ミー）"; ja="私を、私に" }
        $expandedWords += [PSCustomObject]@{ en="mine"; kana="（マイン）"; ja="私のもの" }
    }
    elseif ($item.en -eq "you / your / you / yours") {
        $expandedWords += [PSCustomObject]@{ en="you"; kana="（ユー）"; ja="あなたは、あなたを" }
        $expandedWords += [PSCustomObject]@{ en="your"; kana="（ユア）"; ja="あなたの" }
        $expandedWords += [PSCustomObject]@{ en="yours"; kana="（ユアーズ）"; ja="あなたのもの" }
    }
    elseif ($item.en -eq "he / his / him / his") {
        $expandedWords += [PSCustomObject]@{ en="he"; kana="（ヒー）"; ja="彼は、彼が" }
        $expandedWords += [PSCustomObject]@{ en="his"; kana="（ヒズ）"; ja="彼の、彼のもの" }
        $expandedWords += [PSCustomObject]@{ en="him"; kana="（ヒム）"; ja="彼を、彼に" }
    }
    elseif ($item.en -eq "she / her / her / hers") {
        $expandedWords += [PSCustomObject]@{ en="she"; kana="（シー）"; ja="彼女は、彼女が" }
        $expandedWords += [PSCustomObject]@{ en="her"; kana="（ハー）"; ja="彼女の、彼女を、彼女に" }
        $expandedWords += [PSCustomObject]@{ en="hers"; kana="（ハーズ）"; ja="彼女のもの" }
    }
    elseif ($item.en -eq "we / our / us / ours") {
        $expandedWords += [PSCustomObject]@{ en="we"; kana="（ウィー）"; ja="私たちは、私たちが" }
        $expandedWords += [PSCustomObject]@{ en="our"; kana="（アワー）"; ja="私たちの" }
        $expandedWords += [PSCustomObject]@{ en="us"; kana="（アス）"; ja="私たちを、私たちに" }
        $expandedWords += [PSCustomObject]@{ en="ours"; kana="（アワーズ）"; ja="私たちのもの" }
    }
    elseif ($item.en -eq "they / their / them / theirs") {
        $expandedWords += [PSCustomObject]@{ en="they"; kana="（ゼイ）"; ja="彼らは、それらは" }
        $expandedWords += [PSCustomObject]@{ en="their"; kana="（ゼア）"; ja="彼らの、それらの" }
        $expandedWords += [PSCustomObject]@{ en="them"; kana="（ゼム）"; ja="彼らを、それらを" }
        $expandedWords += [PSCustomObject]@{ en="theirs"; kana="（ゼアーズ）"; ja="彼らのもの、それらのもの" }
    }
    elseif ($item.en -eq "in / on / at") {
        $expandedWords += [PSCustomObject]@{ en="in"; kana="（イン）"; ja="〜の中に、〜で（場所・月など）" }
        $expandedWords += [PSCustomObject]@{ en="on"; kana="（オン）"; ja="〜の上に、〜に（曜日・日付など）" }
        $expandedWords += [PSCustomObject]@{ en="at"; kana="（アット）"; ja="〜で、〜に（特定の場所・時刻）" }
    }
    else {
        $expandedWords += [PSCustomObject]@{ en=$item.en; kana=$item.kana; ja=$item.ja }
    }
}

Write-Host "After expansion count:" $expandedWords.Count
