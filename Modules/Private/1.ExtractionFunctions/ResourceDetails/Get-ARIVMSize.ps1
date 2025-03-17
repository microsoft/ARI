function Get-ARIVMSize {
    Param ($Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }
    $vm = $Resources | Where-Object {$_.TYPE -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'}

    $vmsizemap = @{}

        Foreach($location in ($vm | Select-Object -ExpandProperty location -Unique))
            {
                foreach ($vmsize in ( Get-AzVMSize -Location $location -InformationAction SilentlyContinue -ProgressAction SilentlyContinue))
                    {
                        $vmsizemap[$vmsize.name] = @{
                            CPU = $vmSize.numberOfCores
                            RAM = [math]::Round($vmSize.memoryInMB / 1024, 0) 
                        }
                    }
            }

    $VMSizes = @{
        'type' = 'ARI/VM/Size';
        'Sizes' = $vmsizemap;
    }

    return $VMSizes

}