$templatePath = Join-Path $PSScriptRoot "index.template.html"
$jsonPath = Join-Path $PSScriptRoot "words_180.json"
$indexPath = Join-Path $PSScriptRoot "index.html"

$template = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
$json = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8)

# Replace placeholder with pure C# string replace (no regex, no variable expansion)
$result = $template.Replace("__WORDS_JSON__", $json)

[System.IO.File]::WriteAllText($indexPath, $result, [System.Text.Encoding]::UTF8)
Write-Host "Replaced and generated index.html successfully! File size: $($result.Length)"
