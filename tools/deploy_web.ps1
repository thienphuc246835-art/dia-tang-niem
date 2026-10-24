# Builds the web app and publishes it to the gh-pages branch (GitHub Pages).
# Run from anywhere: powershell -ExecutionPolicy Bypass -File tools\deploy_web.ps1
# Builds through the ASCII junction C:\src\dtn (Flutter tools break on the
# accented project path, CLAUDE.md section 8).
$ErrorActionPreference = 'Stop'
$env:Path = "C:\src\flutter\bin;$env:Path"
$project = 'C:\src\dtn'
$out = Join-Path $project 'build\web_pages'
$remote = git -C $project remote get-url origin
$repoName = [IO.Path]::GetFileNameWithoutExtension($remote)

Push-Location $project
try {
    flutter test
    if ($LASTEXITCODE) { throw 'Tests failed' }
    flutter build web --release --no-tree-shake-icons --base-href "/$repoName/" -o $out
    if ($LASTEXITCODE) { throw 'Build failed' }
} finally { Pop-Location }

New-Item -ItemType File -Force (Join-Path $out '.nojekyll') | Out-Null
Push-Location $out
try {
    if (Test-Path .git) { Remove-Item -Recurse -Force .git }
    git init -q -b gh-pages
    git add -A
    git -c user.name="$(git -C $project config user.name)" -c user.email="$(git -C $project config user.email)" `
        commit -q -m "deploy: web build $(git -C $project rev-parse --short HEAD)"
    git push -f $remote gh-pages
    if ($LASTEXITCODE) { throw 'Push failed' }
} finally { Pop-Location }
