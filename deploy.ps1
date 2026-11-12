# Script to deploy the portfolio site to https://Mahmoud-Karem.github.io

$ErrorActionPreference = "Continue"

Write-Host "==> Checking GitHub CLI authentication..." -ForegroundColor Cyan
gh auth status
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: You are not logged in to GitHub CLI. Please run 'gh auth login' first." -ForegroundColor Red
    exit 1
}

$repoName = "Mahmoud-Karem.github.io"
Write-Host "==> Checking if repo $repoName exists on your GitHub..." -ForegroundColor Cyan

# Check if repo exists without triggering NativeCommandError
$repoExists = $false
try {
    $existing = gh repo view "Mahmoud-Karem/$repoName" --json name -q ".name" 2>$null
    if ($existing -eq $repoName) {
        $repoExists = $true
    }
} catch {
    $repoExists = $false
}

if (-not $repoExists) {
    Write-Host "==> Creating public repo $repoName..." -ForegroundColor Yellow
    gh repo create "Mahmoud-Karem/$repoName" --public --description "Personal Engineering & Embedded Software Portfolio - Mahmoud Karem Zamel"
} else {
    Write-Host "==> Repo $repoName already exists. Proceeding to push updates..." -ForegroundColor Green
}

Write-Host "==> Initializing git and pushing portfolio files..." -ForegroundColor Cyan
if (-not (Test-Path ".git")) {
    git init
}

git add .
git commit -m "Deploy Mahmoud Karem portfolio website" --allow-empty
git branch -M main
git remote remove origin 2>$null
git remote add origin "https://github.com/Mahmoud-Karem/$repoName.git"
git push -u origin main --force

Write-Host "==> Enabling GitHub Pages on branch main..." -ForegroundColor Green
gh api --method POST -H "Accept: application/vnd.github+json" "/repos/Mahmoud-Karem/$repoName/pages" -f "source[branch]=main" -f "source[path]=/" 2>$null

Write-Host ""
Write-Host "==> SUCCESS! Your portfolio is deployed and will be live in 1-2 minutes at:" -ForegroundColor Green
Write-Host "    https://mahmoud-karem.github.io" -ForegroundColor Yellow
Write-Host ""
