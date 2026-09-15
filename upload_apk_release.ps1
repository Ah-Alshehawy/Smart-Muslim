# Smart Muslim - Automatic APK Release & Deployment Script
# This script uploads your latest Flutter APK to GitHub Releases with zero link-breakage!
# The website download link permanently points to:
# https://github.com/Ah-Alshehawy/Smart-Muslim/releases/latest/download/smart-muslim.apk

param (
    [string]$Tag = "",
    [switch]$BuildFirst = $false
)

$ErrorActionPreference = "Stop"

$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghPath)) {
    $ghPath = "gh"
}

# 1. Optionally build the release APK
if ($BuildFirst) {
    Write-Host "🔨 Building release APK with Flutter..." -ForegroundColor Cyan
    flutter build apk --release
}

$apkSource = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkSource)) {
    Write-Error "Could not find APK at $apkSource. Please run with -BuildFirst or build the APK first."
    exit 1
}

# 2. Extract version from pubspec.yaml if tag not provided
if (-not $Tag) {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    if ($pubspec -match 'version:\s*([^\s+]+)') {
        $cleanVer = $matches[1]
        $Tag = "v$cleanVer"
    } else {
        $Tag = "v" + (Get-Date -Format "yyyy.MM.dd-HHmm")
    }
}

Write-Host "📦 Preparing Release $Tag..." -ForegroundColor Green

# 3. Create a clean named copy of the APK
$tempApk = "smart-muslim.apk"
Copy-Item $apkSource -Destination $tempApk -Force

try {
    Write-Host "🚀 Uploading $tempApk to GitHub Release $Tag..." -ForegroundColor Cyan
    & $ghPath release create $Tag $tempApk --title "Smart Muslim $Tag" --notes "Official Android Release (APK) for Smart Muslim (المسلم الذكي)"
    Write-Host "✅ Release created and APK uploaded successfully!" -ForegroundColor Green
} catch {
    Write-Warning "Release may already exist. Attempting to upload/overwrite asset in existing release..."
    & $ghPath release upload $Tag $tempApk --clobber
} finally {
    if (Test-Path $tempApk) {
        Remove-Item $tempApk -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "`n🎉 Permanent download URL is active and updated:" -ForegroundColor Yellow
Write-Host "https://github.com/Ah-Alshehawy/Smart-Muslim/releases/latest/download/smart-muslim.apk" -ForegroundColor White
