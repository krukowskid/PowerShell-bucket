param(
    [Parameter(Mandatory=$true)]
    [string]$sourceBranch,
    [Parameter(Mandatory = $true)]
    [string]$targetBranchName,
    [Parameter(Mandatory=$true)]
    [string]$repositoryName
)

if($sourceBranch -like "refs/*"){
    $sourceBranch = $sourceBranch.Replace("refs/","")
}
if($sourceBranch -like "heads/*"){
    $sourceBranch = $sourceBranch.Replace("heads/","")
}

if($targetBranch -like "refs/*"){
    $targetBranch = $targetBranch.Replace("refs/","")
}
if($targetBranch -like "heads/*"){
    $targetBranch = $targetBranch.Replace("heads/","")
}

$body =  @{
	sourceRefName= "$sourceBranch"
	targetRefName = "$targetBranch"
	title = "Auto PR from pipeline: $env:RELEASE_RELEASENAME"
}

$head = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"  }
$json = ConvertTo-Json $body
$url = "$($env:System_TeamFoundationCollectionUri)$($env:System_TeamProject)/_apis/git/repositories/$repositoryName/pullrequests?api-version=6.0"
Invoke-RestMethod -Uri $url `
                    -Method Post `
                    -Headers $head `
                    -Body $json `
                    -ContentType application/json
