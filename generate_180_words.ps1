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

$additional42 = @(
    # 1. 曜日 (7語)
    [PSCustomObject]@{ en="Sunday"; kana="（サンデイ）"; ja="日曜日" },
    [PSCustomObject]@{ en="Monday"; kana="（マンデイ）"; ja="月曜日" },
    [PSCustomObject]@{ en="Tuesday"; kana="（チューズデイ）"; ja="火曜日" },
    [PSCustomObject]@{ en="Wednesday"; kana="（ウェンズデイ）"; ja="水曜日" },
    [PSCustomObject]@{ en="Thursday"; kana="（サーズデイ）"; ja="木曜日" },
    [PSCustomObject]@{ en="Friday"; kana="（フライデイ）"; ja="金曜日" },
    [PSCustomObject]@{ en="Saturday"; kana="（サタデイ）"; ja="土曜日" },

    # 2. 時・時を表す重要副詞 (5語)
    [PSCustomObject]@{ en="today"; kana="（トゥデイ）"; ja="今日" },
    [PSCustomObject]@{ en="tomorrow"; kana="（トゥモロー）"; ja="明日" },
    [PSCustomObject]@{ en="yesterday"; kana="（イエスタデイ）"; ja="昨日" },
    [PSCustomObject]@{ en="now"; kana="（ナウ）"; ja="今、現在" },
    [PSCustomObject]@{ en="then"; kana="（ゼン）"; ja="そのとき、それから" },

    # 3. 疑問詞 (3語)
    [PSCustomObject]@{ en="which"; kana="（ウィッチ）"; ja="どちら、どの" },
    [PSCustomObject]@{ en="whose"; kana="（フーズ）"; ja="だれの、だれのもの" },
    [PSCustomObject]@{ en="why"; kana="（ホワイ）"; ja="なぜ、どうして" },

    # 4. 指示代名詞 (3語)
    [PSCustomObject]@{ en="this"; kana="（ディス）"; ja="これ、この" },
    [PSCustomObject]@{ en="that"; kana="（ダット）"; ja="あれ、あの" },
    [PSCustomObject]@{ en="it"; kana="（イット）"; ja="それは、それを" },

    # 5. 身近な場所 (5語)
    [PSCustomObject]@{ en="park"; kana="（パーク）"; ja="公園" },
    [PSCustomObject]@{ en="station"; kana="（ステーション）"; ja="駅" },
    [PSCustomObject]@{ en="hospital"; kana="（ホスピタル）"; ja="病院" },
    [PSCustomObject]@{ en="library"; kana="（ライブラリ）"; ja="図書館" },
    [PSCustomObject]@{ en="store"; kana="（ストア）"; ja="店" },

    # 6. 身近な乗り物・物 (6語)
    [PSCustomObject]@{ en="bus"; kana="（バス）"; ja="バス" },
    [PSCustomObject]@{ en="train"; kana="（トレイン）"; ja="電車、列車" },
    [PSCustomObject]@{ en="car"; kana="（カー）"; ja="車、自動車" },
    [PSCustomObject]@{ en="bike"; kana="（バイク）"; ja="自転車" },
    [PSCustomObject]@{ en="computer"; kana="（コンピュータ）"; ja="コンピュータ" },
    [PSCustomObject]@{ en="picture"; kana="（ピクチャー）"; ja="写真、絵" },

    # 7. 食べ物・飲み物 (4語)
    [PSCustomObject]@{ en="apple"; kana="（アップル）"; ja="りんご" },
    [PSCustomObject]@{ en="orange"; kana="（オレンジ）"; ja="オレンジ、みかん" },
    [PSCustomObject]@{ en="milk"; kana="（ミルク）"; ja="牛乳、ミルク" },
    [PSCustomObject]@{ en="tea"; kana="（ティー）"; ja="お茶、紅茶" },

    # 8. 中1基本動詞 (9語)
    [PSCustomObject]@{ en="open"; kana="（オープン）"; ja="開ける、開く" },
    [PSCustomObject]@{ en="close"; kana="（クローズ）"; ja="閉める、閉じる" },
    [PSCustomObject]@{ en="stand"; kana="（スタンド）"; ja="立つ" },
    [PSCustomObject]@{ en="sit"; kana="（シット）"; ja="座る" },
    [PSCustomObject]@{ en="sing"; kana="（スィング）"; ja="歌う" },
    [PSCustomObject]@{ en="wash"; kana="（ウォッシュ）"; ja="洗う" },
    [PSCustomObject]@{ en="clean"; kana="（クリーン）"; ja="掃除する、きれいな" },
    [PSCustomObject]@{ en="start"; kana="（スタート）"; ja="始める、始まる" },
    [PSCustomObject]@{ en="stop"; kana="（ストップ）"; ja="止まる、止める" }
)

# 重複チェック
$existingSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($w in $expandedWords) {
    [void]$existingSet.Add($w.en)
}

$toAdd = @()
foreach ($item in $additional42) {
    if ($existingSet.Contains($item.en)) {
        Write-Warning "Duplicate detected in additional: $($item.en)"
    } else {
        [void]$existingSet.Add($item.en)
        $toAdd += $item
    }
}

Write-Host "Base expanded count: $($expandedWords.Count)"
Write-Host "Additional valid count: $($toAdd.Count)"
Write-Host "Total: $($expandedWords.Count + $toAdd.Count)"

$finalList = @()
$id = 1
foreach ($item in ($expandedWords + $toAdd)) {
    $finalList += [PSCustomObject]@{
        id = $id
        en = $item.en
        kana = $item.kana
        ja = $item.ja
        mistakes = 0
        history = @()
    }
    $id++
}

$outPath = Join-Path $PSScriptRoot "words_180.json"
$finalList | ConvertTo-Json -Depth 5 | Set-Content -Path $outPath -Encoding UTF8
Write-Host "Saved words_180.json successfully. Total: $($finalList.Count)"
