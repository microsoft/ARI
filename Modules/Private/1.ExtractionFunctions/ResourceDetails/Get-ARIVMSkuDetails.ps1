function Get-ARIVMSkuDetails {
    Param ($Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }

    $vm = $Resources | Where-Object {$_.TYPE -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'}

    $VMskuData = Foreach($location in ($vm | Select-Object -ExpandProperty location -Unique))
        {
            $tmp = [PSCustomObject]@{
                Location    = $location
                SKUs        = Get-AzComputeResourceSku $location -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
            }
            $tmp
        }

    $VMSkuDetails = [PSCustomObject]@{
        'type'          = 'ARI/VM/SKU'
        'properties'    = $VMskuData
    }

    return $VMSkuDetails
}