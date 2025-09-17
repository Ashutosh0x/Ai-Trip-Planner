$ErrorActionPreference = "Stop"

# Read API key from environment variable first, then fallback to tool/.apikey file
$apiKey = $env:GOOGLE_TRANSLATE_API_KEY
if (-not $apiKey -or $apiKey.Trim().Length -eq 0) {
  $apikeyPath = Join-Path $PSScriptRoot ".apikey"
  if (Test-Path $apikeyPath) {
    $apiKey = Get-Content $apikeyPath -Raw
  }
}
if (-not $apiKey -or $apiKey.Trim().Length -eq 0) {
  Write-Error "GOOGLE_TRANSLATE_API_KEY not found. Set env var or create tool/.apikey"
  exit 1
}

# Paths
$projectRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $projectRoot "assets/translations/en.json"
$output = Join-Path $projectRoot "assets/translations"

# Target languages (comma-separated)
$languages = if ($env:TRANSLATE_LANGS) { $env:TRANSLATE_LANGS } else { "hi,es,fr,de,ar,zh,ja,ru,pt" }

Write-Host "Translating using tool/translate.dart..." -ForegroundColor Cyan
Write-Host "Source:    $source"
Write-Host "Output:    $output"
Write-Host "Languages: $languages"

# Run the translator (reads API key from env)
$env:GOOGLE_TRANSLATE_API_KEY = $apiKey
dart run tool/translate.dart --source=$source --output=$output --languages=$languages


