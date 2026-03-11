# GitHub 저장소에 커밋 & 푸시 스크립트
# 사용법: PowerShell에서 .\git-push.ps1 "커밋 메시지"
# 예: .\git-push.ps1 "로또 추천 서비스 초기 버전"

$msg = if ($args[0]) { $args[0] } else { "Update lotto recommendation service" }
$repo = "c:\Users\SD2-22\Desktop\바이브코딩 260311"

Set-Location $repo

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git이 설치되어 있지 않거나 PATH에 없습니다. https://git-scm.com 에서 설치 후 다시 실행하세요." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path .git)) {
    git init
    git branch -M main
}
git add -A
git status
git commit -m $msg
$remote = git remote get-url origin 2>$null
if (-not $remote) {
    git remote add origin https://github.com/peter901128-bit/20260311.git
}
git push -u origin main

Write-Host "완료: $msg" -ForegroundColor Green
