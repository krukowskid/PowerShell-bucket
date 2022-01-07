function New-BicepParametersFileFromTemplate
{
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $TemplateFilePath,
        $Version = "1.0.0.0",
        $OutFilePath = "$($TemplateFilePath.Replace(".bicep",".parameters.json"))",
        $Schema = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
    ) 

    function Format-Json {
        param
        (
            [Parameter(Mandatory, ValueFromPipeline)]
            [String]
            $json
        ) 

        $indent = 0;
        $result = ($json -Split '\n' |
                % {
                if ($_ -match '[\}\]]') {
                    $indent--
                }
                $line = (' ' * $indent * 2) + $_.TrimStart().Replace(': ', ':')
                if ($_ -match '[\{\[]') {
                    $indent++
                }
                $line
            }) -Join "`n"
            
        $result.Replace('\u0027', "'").Replace('\u003c', "<").Replace('\u003e', ">").Replace('\u0026', "&")
    
    }

    $parameters = @{}
    Get-Content $TemplateFilePath `
        | ForEach-Object {
            $_ = $_ -split '\s+'

            if ($_[0] -eq "param")
            {
                $parameters.Add(
                    $_[1],
                    [pscustomobject]@{
                        value=$_[2]
                    }
                )
            }
        }

    [pscustomobject]@{
            '$schema'="$schema";
            'contentVersion'="$version"
            "parameters" = $parameters
        } | ConvertTo-Json -Depth 3 `
                | Format-Json `
                    | Out-File  -Encoding utf8 `
                                -FilePath "$OutFilePath" `
                                -Force
}
