$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot '../checkout/source'
if (!(Test-Path $source)) { $source = Join-Path $env:GITHUB_WORKSPACE 'checkout/source' }
$out = Join-Path $env:GITHUB_WORKSPACE 'release'
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($entry in @(@('MiapaxERP.Desktop','Masaustu'),@('MiapaxERP.MobileServer','Sunucu'))) {
    dotnet publish "$source/$($entry[0])/$($entry[0]).csproj" -c Release -r win-x64 --self-contained true --disable-build-servers -m:1 -p:NuGetAudit=false -o "$out/$($entry[1])"
    if ($LASTEXITCODE -ne 0) { throw 'Publish failed' }
}
Copy-Item "$source/MobilKurulum/*" "$out/" -Recurse -Force
Copy-Item "$source/DEVELOPMENT_STATUS.md" "$out/OKU-ONCE.md"
Compress-Archive -Path "$out/Masaustu","$out/Sunucu","$out/*.ps1","$out/*.cmd","$out/*.ornek","$out/OKU-ONCE.md" -DestinationPath "$out/MiaPaxERP-v2.8.2-Windows-x64.zip"
$assets = @("$out/MiaPaxERP-v2.8.2-Windows-x64.zip", "$env:GITHUB_WORKSPACE/checkout/source/MiaPaxERP-source.zip")
$lines = foreach ($file in $assets) { $hash = Get-FileHash -LiteralPath $file -Algorithm SHA256; "$($hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($file))" }
$lines | Set-Content "$out/SHA256SUMS.txt" -Encoding utf8
if ($env:GITHUB_EVENT_NAME -ne 'push' -or $env:GITHUB_REF -ne 'refs/heads/main') { Write-Host 'Packages built and checksummed; release waits for main.'; exit 0 }
$headers = @{Authorization="Bearer $env:GH_TOKEN";Accept='application/vnd.github+json';'X-GitHub-Api-Version'='2022-11-28'}
$body = @{tag_name='v2.8.2';target_commitish=$env:GITHUB_SHA;name='MiaPaxERP 2.8.2 — HTTPS ve ERP bütünlüğü';draft=$true;prerelease=$false;body='Windows x64 masaüstü ve ana HTTPS sunucusu. SQL/TLS ve işlem bütünlüğü testlerinden sonra üretildi. Otomatik güncelleme manifesti değiştirilmez; kurmadan önce veritabanı yedeği alın. Mobil APK yenilenmedi. E-belge sağlayıcı hesabı ve alan adı müşteri sunucusunda yapılandırılmalıdır. Ayrıntılar kaynak paketindeki DEVELOPMENT_STATUS.md dosyasındadır.'} | ConvertTo-Json
$api = "https://api.github.com/repos/$env:GITHUB_REPOSITORY/releases"
$release = Invoke-RestMethod -Method Post -Uri $api -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
foreach ($file in ($assets + "$out/SHA256SUMS.txt")) {
    $name = [Uri]::EscapeDataString([IO.Path]::GetFileName($file))
    $upload = ($release.upload_url -replace '\{.*$','') + '?name=' + $name
    Invoke-RestMethod -Method Post -Uri $upload -Headers $headers -ContentType 'application/octet-stream' -InFile $file | Out-Null
}
Invoke-RestMethod -Method Patch -Uri "$api/$($release.id)" -Headers $headers -ContentType 'application/json' -Body '{"draft":false}' | Out-Null
Write-Host "Published $($release.html_url)"
