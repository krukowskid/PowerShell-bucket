param(
    [Parameter(Mandatory=$true)]
    [string]$sourceBranch,
    [Parameter(Mandatory=$true)]
    [string]$repositoryName
)
$body =  @{
    isLocked = "true"
    newRefInfo = "GitRefUpdate"
}

if($sourceBranch -like "refs/*"){
    $sourceBranch = $sourceBranch.Replace("refs/","")
}

$head = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"  }
$json = ConvertTo-Json $body
$url = "$($env:System_TeamFoundationCollectionUri)$($env:System_TeamProject)/_apis/git/repositories/$repositoryName/refs?filter=$sourceBranch&api-version=6.0"
Invoke-RestMethod -Uri $url `
                  -Method PATCH `
                  -Headers $head `
                  -Body $json `
                  -ContentType application/json
