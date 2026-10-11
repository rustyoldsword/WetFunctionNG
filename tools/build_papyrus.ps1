# Compile papyrus\source\*.psc into papyrus\out\*.pex.
#
# papyrus\stubs stands in for SexLab P+ (its sources do not parse with the Bethesda compiler); stubs are
# never shipped. A failed compile leaves the previous .pex
# in place, so every output is checked to be newer than its source.
#
# Run: powershell -ExecutionPolicy Bypass -File tools\build_papyrus.ps1 -Game <Skyrim SE dir> -Mods <MO2 mods dir>

param(
    [string]$Game = $env:SKYRIM_GAME,   # Skyrim SE folder with 'Papyrus Compiler' and Data\Scripts\Source
    [string]$Mods = $env:MO2_MODS       # MO2 mods folder (for SkyUI\scripts\Source)
)

$ErrorActionPreference = 'Stop'
if (-not $Game -or -not $Mods) { throw 'Pass -Game and -Mods (or set SKYRIM_GAME and MO2_MODS).' }

$root     = Split-Path -Parent $PSScriptRoot
$mods     = $Mods
$game     = $Game
$compiler = Join-Path $game 'Papyrus Compiler\PapyrusCompiler.exe'
$src      = Join-Path $root 'papyrus\source'
$out      = Join-Path $root 'papyrus\out'

New-Item -ItemType Directory -Force $out | Out-Null

$imports = @(
    $src
    (Join-Path $root 'papyrus\stubs')
    (Join-Path $mods 'SkyUI\scripts\Source')
    (Join-Path $game 'Data\Scripts\Source')
    (Join-Path $game 'Data\Source\Scripts')
) -join ';'

$failed = @()
Push-Location $env:TEMP
try {
    foreach ($file in Get-ChildItem $src -Filter *.psc) {
        $output = & $compiler $file.FullName -f='TESV_Papyrus_Flags.flg' -i="$imports" -o="$out" 2>&1
        $pex = Join-Path $out ($file.BaseName + '.pex')
        if (-not (Test-Path $pex) -or (Get-Item $pex).LastWriteTime -lt $file.LastWriteTime) {
            $failed += $file.Name
            $output | Where-Object { $_ -match '\(\d+,\d+\)|error' } | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "ok  $($file.Name)"
        }
    }
} finally {
    Pop-Location
}

if ($failed.Count) {
    Write-Host "FAILED: $($failed -join ', ')"
    exit 1
}
