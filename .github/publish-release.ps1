$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot '../checkout/source'
if (!(Test-Path $source)) { $source = Join-Path $env:GITHUB_WORKSPACE 'checkout/source' }
# Restore unchanged static files from the hash-verified previous release.
$legacy = Join-Path $env:RUNNER_TEMP 'MiapaxERP-2.8.1-static.zip'
Invoke-WebRequest -Uri 'https://github.com/MiaPaxERP/MiapaxERP-Updates/releases/download/v2.8.1/MiapaxERP-Ana-v2.8.1.zip' -OutFile $legacy
if ((Get-FileHash $legacy -Algorithm SHA256).Hash.ToLowerInvariant() -ne '1064692cf7ea2ade7a524fa4649307e81eaf4b2449ab60e60b2f943818c94345') { throw 'Static archive hash mismatch' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($legacy)
try {
    foreach ($entry in $archive.Entries) {
        $relative = $entry.FullName.Replace([char]92,[char]47)
        if ($relative -notmatch '^Assets/(SahaWeb/(districts\.geojson|provinces\.geojson|places\.json)|Dashboard/[^/]+\.mp4)$') { continue }
        $destination = Join-Path "$source/MiapaxERP.Desktop" $relative
        New-Item -ItemType Directory -Force ([IO.Path]::GetDirectoryName($destination)) | Out-Null
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$destination,$true)
    }
} finally { $archive.Dispose() }
foreach ($file in @('districts.geojson','provinces.geojson','places.json')) {
    if (!(Test-Path "$source/MiapaxERP.Desktop/Assets/SahaWeb/$file")) { throw "Missing required map: $file" }
}
$out = Join-Path $env:GITHUB_WORKSPACE 'release'
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($entry in @(@('MiapaxERP.Desktop','Masaustu'),@('MiapaxERP.MobileServer','Sunucu'))) {
    dotnet publish "$source/$($entry[0])/$($entry[0]).csproj" -c Release -r win-x64 --self-contained true --disable-build-servers -m:1 -p:NuGetAudit=false -o "$out/$($entry[1])"
    if ($LASTEXITCODE -ne 0) { throw 'Publish failed' }
}
Copy-Item "$source/MobilKurulum/*" "$out/" -Recurse -Force
Copy-Item "$source/DEVELOPMENT_STATUS.md" "$out/OKU-ONCE.md"
Compress-Archive -Path "$out/Masaustu","$out/Sunucu","$out/*.ps1","$out/*.cmd","$out/*.ornek","$out/OKU-ONCE.md" -DestinationPath "$out/MiaPaxERP-v2.8.4-Windows-x64.zip"
# Updater packages must have the desktop EXE at archive root, not inside Masaustu/.
$flat = "$out/MiaPaxERP-Masaustu-v2.8.4.zip"
foreach ($name in @('MiapaxERP.guncelleme.json','BoruERP.guncelleme.json','MiaSoft.guncelleme.json')) {
    $config = Join-Path "$out/Masaustu" $name
    if (Test-Path $config) { Remove-Item -LiteralPath $config }
}
Compress-Archive -Path "$out/Masaustu/*" -DestinationPath $flat
if ([Diagnostics.FileVersionInfo]::GetVersionInfo("$out/Masaustu/MiapaxERP.Desktop.exe").FileVersion -ne '2.8.4.0') { throw 'Desktop package file version does not match 2.8.4.0' }
$checkZip = [IO.Compression.ZipFile]::OpenRead($flat)
try { if ($null -eq $checkZip.GetEntry('MiapaxERP.Desktop.exe') -or $null -eq $checkZip.GetEntry('MiapaxERP.Updater.exe')) { throw 'Updater package root files missing' } } finally { $checkZip.Dispose() }
$freshSource = "$out/MiaPaxERP-Kaynak-v2.8.4.zip"
$sourceArchive = [IO.Compression.ZipFile]::Open($freshSource,[IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in (Get-ChildItem -LiteralPath $source -Force -Recurse -File)) {
        $relative = [IO.Path]::GetRelativePath($source,$file.FullName).Replace([char]92,[char]47)
        if ($relative -match '(^|/)(bin|obj|\.git|\.vs|node_modules|TestResults|build|Teslim222)/') { continue }
        if ($file.Extension -in @('.zip','.exe','.dll','.pdb','.dpapi','.pfx','.p12','.key','.jks','.mdf','.ldf','.bak','.db','.sqlite','.log') -or $file.Name -match 'private|signing-key|secrets') { continue }
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($sourceArchive,$file.FullName,$relative,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $sourceArchive.Dispose() }
$assets = @($flat, $freshSource, "$out/MiaPaxERP-v2.8.4-Windows-x64.zip")
$lines = foreach ($file in $assets) { $hash = Get-FileHash -LiteralPath $file -Algorithm SHA256; "$($hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($file))" }
$lines | Set-Content "$out/SHA256SUMS.txt" -Encoding utf8
if ($env:GITHUB_EVENT_NAME -ne 'push' -or $env:GITHUB_REF -ne 'refs/heads/main') { Write-Host 'Packages built and checksummed; release waits for main.'; exit 0 }
$headers = @{Authorization="Bearer $env:GH_TOKEN";Accept='application/vnd.github+json';'X-GitHub-Api-Version'='2022-11-28'}
$body = @{tag_name='v2.8.4';target_commitish=$env:GITHUB_SHA;name='MiaPaxERP 2.8.4 — HTTPS ve ERP bütünlüğü';draft=$true;prerelease=$false;body='Windows x64 masaüstü ve ana HTTPS sunucusu. SQL/TLS ve işlem bütünlüğü testlerinden sonra üretildi. Ana/Yan otomatik güncelleme bildirimleri paket yüklemesinden sonra mevcut yayıncı anahtarıyla imzalanır. Kurmadan önce veritabanı yedeği alın. Mobil APK yenilenmedi. E-belge sağlayıcı hesabı ve alan adı müşteri sunucusunda yapılandırılmalıdır. Ayrıntılar kaynak paketindeki DEVELOPMENT_STATUS.md dosyasındadır.'} | ConvertTo-Json
$api = "https://api.github.com/repos/$env:GITHUB_REPOSITORY/releases"
$release = Invoke-RestMethod -Method Post -Uri $api -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
foreach ($file in ($assets + "$out/SHA256SUMS.txt")) {
    $name = [Uri]::EscapeDataString([IO.Path]::GetFileName($file))
    $upload = ($release.upload_url -replace '\{.*$','') + '?name=' + $name
    Invoke-RestMethod -Method Post -Uri $upload -Headers $headers -ContentType 'application/octet-stream' -InFile $file | Out-Null
}
Invoke-RestMethod -Method Patch -Uri "$api/$($release.id)" -Headers $headers -ContentType 'application/json' -Body '{"draft":false}' | Out-Null
Write-Host "Published $($release.html_url)"
