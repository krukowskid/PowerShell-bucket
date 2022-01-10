param (
    [Parameter(Mandatory = $true)]
    [string]$repositoryName,
    [Parameter(Mandatory = $true)]
    [string]$newBranchName,
    [Parameter(Mandatory = $true)]
    [string]$baseBranchName
)

# Get ID of the base branch
if($baseBranchName -like "refs/*"){
    $baseBranchName = $baseBranchName.Replace("refs/","")
}
if($baseBranchName -like "heads/*"){
    $baseBranchName = $baseBranchName.Replace("heads/","")
}

$headers = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }

$url = "$($env:System_TeamFoundationCollectionUri)$($env:System_TeamProject)/_apis/git/repositories/$repositoryName/refs?filter=heads/$baseBranchName&`$top=1&api-version=6.0"
$baseBranchId = (Invoke-RestMethod -Uri $url `
                                   -ContentType "application/json" `
                                   -headers $headers `
                                   -Method GET).value.objectId

# Create a new branch
$url = "$($env:System_TeamFoundationCollectionUri)$($env:System_TeamProject)/_apis/git/repositories/$repositoryName/refs?api-version=6.0"

$body = ConvertTo-Json @(
@{
    name = "refs/heads/$newBranchName"
    newObjectId = $baseBranchId
    oldObjectId = "0000000000000000000000000000000000000000"
})

Invoke-RestMethod -Uri $url `
                  -ContentType "application/json" `
                  -Body $body `
                  -headers $headers `
                  -Method POST
