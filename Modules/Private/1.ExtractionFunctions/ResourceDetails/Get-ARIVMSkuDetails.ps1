function Get-ARIVMSkuDetails {
    Param ($Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }

    $vm = $Resources | Where-Object {$_.TYPE -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'}

    $VMskuDetails = @{}
    Foreach($location in ($vm | Select-Object -ExpandProperty location -Unique))
        {
            $VMskuDetails[$location] = Get-AzComputeResourceSku $location -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
        }

    $VMSkuDetails = @{
        'type' = 'ARI/VM/SKU';
        'Sizes' = $VMskuDetails;
    }

    return $VMSkuDetails
}