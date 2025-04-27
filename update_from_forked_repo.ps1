# 原仓库的 URL，请替换为实际的原仓库地址
$UpstreamUrl = "https://github.com/microsoft/playwright.git"
# 主分支名称，根据实际情况修改
$MainBranch = "master"

# 检查是否已添加原仓库作为远程仓库
$RemoteExists = git remote | Where-Object { $_ -eq "upstream" }
if (-not $RemoteExists) {
    git remote add upstream $UpstreamUrl
    Write-Host "The original repository has been added as a remote repository."
    git remote -v
}

# 从原仓库拉取最新代码
Write-Host "Fetching the latest code from the original repository..."
git fetch upstream

# 切换到本地主分支
Write-Host "Switching to the local main branch..."
git checkout $MainBranch
# 合并原仓库的更新到本地主分支，可能需要不断重试
Write-Host "Merging the updates from the original repository into the local main branch..."
$MergeSucceeded = $false
while (-not $MergeSucceeded) {
    try {
        git merge upstream/$MainBranch
        $MergeSucceeded = $true
    } catch {
        if ($_.Exception.Message -like "*conflict*") {
            Write-Host "Merge conflicts detected. Please resolve the conflicts manually and press Enter to continue retrying the merge..."
            Read-Host
        } else {
            Write-Error "An error occurred during the merge: $($_.Exception.Message)"
            exit 1
        }
    }
}

# 推送更新到你自己的 GitHub 仓库
Write-Host "Pushing the updates to your own GitHub repository..."
git push origin $MainBranch

Write-Host "The repository has been updated successfully."  