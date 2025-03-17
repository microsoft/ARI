function Set-ARIDiagramFile {
    Param ($XMLFiles, $DDFile, $LogFile)
    try 
    {
        ('DrawIOFileJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Merging XML Files ') | Out-File -FilePath $LogFile -Append 
        foreach($File in $XMLFiles)
        {
            $oldxml = New-Object XML
            $oldxml.Load($File)

            $newxml = New-Object XML
            $newxml.Load($DDFile)

            $oldxml.DocumentElement.InsertAfter($oldxml.ImportNode($newxml.SelectSingleNode('mxfile'), $true), $afternode)

            $oldxml.Save($DDFile)

            Remove-Item -Path $File
        }
    }
    catch
    {
        ('DrawIOFileJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $LogFile -Append 
    }
}