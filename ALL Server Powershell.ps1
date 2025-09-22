$Subscriptions = Get-AzSubscription | select Name, Id
$AccessToken = Get-AzAccessToken
$Headers = @{"Authorization" = "$($AccessToken.Type) "+ "$($AccessToken.Token)"}
foreach ($sub in $Subscriptions)
    {
        Set-AzContext -Subscription $sub.Name
        $AzVMs = Get-AzVM | select Name, ResourceGroupName
        Write-Host "Deleting Defender configuration for $($sub.Name) Azure VMs..."
        foreach ($vm in $AzVMs)
            {
                $uri = "https://management.azure.com/subscriptions/$($sub.Id)/resourceGroups/$($vm.ResourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($vm.Name)/providers/Microsoft.Security/pricings/virtualMachines?api-version=2024-01-01"
                Write-Host $uri
                $Response = Invoke-RestMethod -Uri $uri -Method Delete -Headers $Headers
                Write-Output $Response.StatusCode
            }
        $AzARCMAchines = Get-AzConnectedMachine | select Name, ResourceGroupName
        Write-Host "Deleting Defender configuration for $($sub.Name) Azure ARC servers..."
        foreach ($ARCMachine in $AzARCMAchines)
            {
                $uri = "https://management.azure.com/subscriptions/$($sub.Id)/resourceGroups/$($ARCMachine.ResourceGroupName)/providers/Microsoft.HybridCompute/machines/$($ARCMachine.Name)/providers/Microsoft.Security/pricings/virtualMachines?api-version=2024-01-01"
                Write-Host $uri
                $Response = Invoke-RestMethod -Uri $uri -Method Delete -Headers $Headers
                Write-Output $Response.StatusCode
            }
    }