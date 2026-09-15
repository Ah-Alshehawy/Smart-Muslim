# Script to build and prepare Firebase Hosting files

Write-Host "Cleaning up public_html directory..."
if (Test-Path "public_html") {
    Remove-Item -Recurse -Force "public_html"
}
New-Item -ItemType Directory -Force -Path "public_html" | Out-Null

Write-Host "Copying landing page..."
Copy-Item -Path "website\*" -Destination "public_html" -Recurse

Write-Host "Building Flutter Web (Lite Version)..."
flutter build web --base-href "/lite/"

Write-Host "Copying Flutter Web to public_html/lite..."
New-Item -ItemType Directory -Force -Path "public_html\lite" | Out-Null
Copy-Item -Path "build\web\*" -Destination "public_html\lite" -Recurse

Write-Host "Done! You can now run 'firebase deploy --only hosting' to publish the site."
