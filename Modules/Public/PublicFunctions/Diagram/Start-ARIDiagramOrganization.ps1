<#
.Synopsis
Organization Module for Draw.io Diagram

.DESCRIPTION
This module is used for the Organization topology in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDiagramOrganization.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-ARIDiagramOrganization {
    Param($ResourceContainers,$DiagramCache,$LogFile)

    Write-Output ('DrawIOOrgsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Function')
    Function Add-Icon {    
        Param($Style,$x,$y,$w,$h,$p)
        
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('style', $Style)
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $p)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
        }

    Function Add-Connection {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
            $Script:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Script:XmlWriter.WriteAttributeString('edge', "1")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $Parent)
            $Script:XmlWriter.WriteAttributeString('source', $Source)
            $Script:XmlWriter.WriteAttributeString('target', $Target)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('relative', "1")
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
        
        }

    Function Add-Container0 {
        Param($x,$y,$w,$h,$title)
            $Script:ContID0 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', $Script:ContID0)
            $Script:XmlWriter.WriteAttributeString('value', "$title")
            $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;fontColor=#333333;strokeColor=#666666;swimlaneFillColor=#F5F5F5;rounded=1;")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', "1")
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
    }

    Function Add-Container1 {
        Param($x,$y,$w,$h,$title)
            $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', $Script:ContID)
            $Script:XmlWriter.WriteAttributeString('value', "$title")
            $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;swimlaneFillColor=#D5E8D4;rounded=1;")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', "1")
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
    }

    Function Add-Container2 {
        Param($x,$y,$w,$h,$title,$p)
            $Script:ContID2 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', $Script:ContID2)
            $Script:XmlWriter.WriteAttributeString('value', "$title")
            $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;swimlaneFillColor=#DAE8FC;rounded=1;")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $p)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
    }

    Function Add-Container3 {
        Param($x,$y,$w,$h,$title,$p)
            $Script:ContID3 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', $Script:ContID3)
            $Script:XmlWriter.WriteAttributeString('value', "$title")
            $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;swimlaneFillColor=#FFE6CC;rounded=1;")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $p)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
    }

    Function Add-Container4 {
        Param($x,$y,$w,$h,$title,$p)
            $Script:ContID4 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', $Script:ContID4)
            $Script:XmlWriter.WriteAttributeString('value', "$title")
            $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;swimlaneFillColor=#FFE6CC;rounded=1;")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $p)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('x', $x)
                $Script:XmlWriter.WriteAttributeString('y', $y)
                $Script:XmlWriter.WriteAttributeString('width', $w)
                $Script:XmlWriter.WriteAttributeString('height', $h)
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
    }

    Function Set-Stencil {
        $Script:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
        $Script:IconMgmtGroup = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Management_Groups.svg;" #width="44" height="71"
        $Script:Ret = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        $Script:Ret1 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#b0e3e6;strokeColor=#0e8088;"
        $Script:Ret2 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#b1ddf0;strokeColor=#10739e;"
        $Script:Ret3 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#fad7ac;strokeColor=#b46504;"
        $Script:Ret4 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#e1d5e7;strokeColor=#9673a6;"

    }

    Function Start-OrgDiagram {

            $OrgObjs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions'} 

            $Script:1stLevel = @()
            $Lvl2 = @()
            $Lvl3 = @()
            $Lvl4 = @()
            foreach($org in $OrgObjs)
                {
                    if($org.properties.managementgroupancestorschain.count -eq 2)
                        {                            
                            $Script:1stLevel += $org.properties.managementgroupancestorschain.displayname[0]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 3)
                        {
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[0]
                            $Script:1stLevel += $org.properties.managementgroupancestorschain.displayname[1]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 4)
                        {
                            $Lvl3 += $org.properties.managementgroupancestorschain.name[0]
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[1]
                            $Script:1stLevel += $org.properties.managementgroupancestorschain.displayname[2]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 5)
                        {
                            $Lvl4 += $org.properties.managementgroupancestorschain.name[0]
                            $Lvl3 += $org.properties.managementgroupancestorschain.name[1]
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[2]
                            $Script:1stLevel += $org.properties.managementgroupancestorschain.displayname[3]
                        }
                }

            $Script:1stLevel = $Script:1stLevel | Select-Object -Unique
            $Lvl2 = $Lvl2 | Select-Object -Unique
            $Lvl3 = $Lvl3 | Select-Object -Unique
            $Lvl4 = $Lvl4 | Select-Object -Unique

            $Script:XLeft = 0
            $Script:XTop = 100
            $XXLeft = 100

            $Script:XTop = $Script:XTop + 200

            $RoundSubs00 = @() 
            foreach($Sub in $OrgObjs)
                    {
                        if($Sub.properties.managementgroupancestorschain[0].displayname -eq 'tenant root group')
                            {
                                $RoundSubs00 += $Sub
                            }
                    }
            
            $MgmtHeight0 = (($RoundSubs00.id.count * 70) + 80)

            Add-Container0 '0' '0' '200' $MgmtHeight0 'tenant root group'

            $Script:XmlWriter.WriteStartElement('object')            
            $Script:XmlWriter.WriteAttributeString('label', '')
            $Script:XmlWriter.WriteAttributeString('ManagementGroup', 'tenant root group')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                if($RoundSubs00)
                    {
                        Add-Icon $Script:IconMgmtGroup '-30' ($MgmtHeight0-15) '50' '50' $Script:ContID0
                    }
                else
                    {
                        Add-Icon $Script:IconMgmtGroup '75' '27' '50' '50' $Script:ContID0
                    }

            $Script:XmlWriter.WriteEndElement()

            $LocalTop = 50
            $LocalLeft = 25

            foreach($Sub in $RoundSubs00)
            {
                $RGs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', $sub.name)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($Script:CelNum++)))

                    Add-Icon $Ret1 $LocalLeft $LocalTop '150' '70' $Script:ContID0

                $Script:XmlWriter.WriteEndElement()

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', '')

                $RGNum = 1
                foreach($RG in $RGs)
                    {
                        $Attr = ('ResourceGroup_'+[string]$RGNum)
                        $Script:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                        $RGNum++
                    }
                
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                    Add-Icon $Script:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Script:ContID0

                $Script:XmlWriter.WriteEndElement()

                $LocalTop = $LocalTop + 90

            }




            foreach($1stlvl in $Script:1stLevel)
                {
                $RoundSubs0 = @() 
                
                foreach($Sub in $OrgObjs)
                    {
                        if($Sub.properties.managementgroupancestorschain.displayname[0] -eq $1stlvl)
                            {
                                $RoundSubs0 += $Sub
                            }
                    }

                $MgmtHeight = (($RoundSubs0.id.count * 70) + 80)

                Add-Container1 $XLeft $XTop '200' $MgmtHeight $1stlvl $Script:ContID0       
                
                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', '')
                $Script:XmlWriter.WriteAttributeString('ManagementGroup', [string]$1stlvl)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                if($RoundSubs0)
                    {
                        Add-Icon $Script:IconMgmtGroup '-30' ($MgmtHeight-15) '50' '50' $Script:ContID
                    }
                else
                    {
                        Add-Icon $Script:IconMgmtGroup '75' '27' '50' '50' $Script:ContID
                    }
    
                $Script:XmlWriter.WriteEndElement()

                Add-Connection $Script:ContID0 $Script:ContID

                $LocalTop = 50
                $LocalLeft = 25

                foreach($Sub in $RoundSubs0)
                    {
                        $RGs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', $sub.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($Script:CelNum++)))

                            Add-Icon $Ret1 $LocalLeft $LocalTop '150' '70' $Script:ContID

                        $Script:XmlWriter.WriteEndElement()

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', '')

                        $RGNum = 1
                        foreach($RG in $RGs)
                            {
                                $Attr = ('ResourceGroup_'+[string]$RGNum)
                                $Script:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                $RGNum++
                            }
                        
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                            Add-Icon $Script:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Script:ContID

                        $Script:XmlWriter.WriteEndElement()

                        $LocalTop = $LocalTop + 90

                    }
                
                ######################################## 2ND LEVEL ##############################################
                
                $2ndLevel = @()
                foreach($sub2nd in $OrgObjs)
                {                 
                    if($sub2nd.properties.managementgroupancestorschain.displayname[1] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[0]
                        }
                    if($sub2nd.properties.managementgroupancestorschain.displayname[2] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[1]
                        }
                    if($sub2nd.properties.managementgroupancestorschain.displayname[3] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[2]
                        }
                }
                $2ndLevel = $2ndLevel | Select-Object -Unique
                
                $XXLeft = 0
                if($2ndLevel.count  % 2 -eq 1 )
                    {
                        $Align = $true
                        $loops = -[Math]::ceiling($2ndLevel.count /2 - 1)
                    }
                else
                    {
                        $Align = $false
                        $loops = [Math]::ceiling($2ndLevel.count / 2)
                        
                    }
                if($2ndLevel.count -eq 1)
                    {
                        $loops = 1
                    }
                $TempSon = 0


                foreach($2nd in $2ndLevel)
                    {
                        $RoundSubs = @() 
                        $Temp3rd = @()
                        $Temp4rd = @()
                        $Temp5th = @()                                        

                        foreach($Sub in $OrgObjs)
                            {
                                if($Sub.properties.managementgroupancestorschain.name[0] -eq $2nd)
                                    {
                                        $RoundSubs += $Sub
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[1] -eq $2nd)
                                    {
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[0]
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[2] -eq $2nd)
                                    {
                                        $Temp4rd += $Sub.properties.managementgroupancestorschain.name[0]
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[1]
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[3] -eq $2nd)
                                    {
                                        $Temp5th += $Sub.properties.managementgroupancestorschain.name[0]
                                        $Temp4rd += $Sub.properties.managementgroupancestorschain.name[1]
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[2]
                                    }
                            }

                        $Temp3rd = $Temp3rd | Select-Object -Unique
                        $Temp4rd = $Temp4rd | Select-Object -Unique
                        $Temp5th = $Temp5th | Select-Object -Unique

                        if($XXLeft -eq 0 -and $Align -eq $true)
                            {
                            }
                        elseif($XXLeft -eq 0 -and $Align -eq $false)
                            {
                                $XXLeft = -150 + -((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($Align -eq $false -and $loops -eq 0)
                            {
                                $XXLeft = 150 + ((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($loops -gt 0 -and $XXLeft -eq 0)
                            {
                                $XXLeft = $XXLeft + ($2ndLevel.count*300)/2 + ((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($XXLeft -le 0 -and $loops -lt 0)
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150))}
                                $XXLeft = $XXLeft + -$XXTemp
                                $loops++
                            }
                        elseif($XXLeft -gt 0 -and $loops -ge 0)
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150))}
                                $XXLeft = $XXLeft + $XXTemp
                                $loops++
                            }
                        else
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*300)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*300))}
                                $XXLeft = $XXLeft + $XXTemp
                                $loops++
                            }

                        $MgmtHeight1 = if((($RoundSubs.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs.id.count * 90) + 50)}
                        
                        $XXTop = $MgmtHeight + 200

                        Add-Container2 $XXLeft $XXTop '200' $MgmtHeight1 $2nd $Script:ContID

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', '')
                        $Script:XmlWriter.WriteAttributeString('ManagementGroup', [string]$2nd)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                        if($RoundSubs)
                            {
                                Add-Icon $Script:IconMgmtGroup '-30' ($MgmtHeight1-15) '50' '50' $Script:ContID2
                            }
                        else
                            {
                                Add-Icon $Script:IconMgmtGroup '75' '27' '50' '50' $Script:ContID2
                            }

                        $Script:XmlWriter.WriteEndElement()

                        Add-Connection $Script:ContID $Script:ContID2

                        $TempSon = (($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count))

                        if($XXLeft -eq 0 -and $loops -lt 0)
                            {
                                $XXLeft = -1
                            }
                        elseif($XXLeft -lt 0 -and $loops -ge 0)
                            {
                                $XXLeft = 1
                            }

                        $LocalTop = 50
                        $LocalLeft = 25

                        foreach($Sub in $RoundSubs)
                            {                                
                                $RGs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                $Script:XmlWriter.WriteStartElement('object')
                                $Script:XmlWriter.WriteAttributeString('label', $sub.name)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($Script:CelNum++)))

                                    Add-Icon $Ret2 $LocalLeft $LocalTop '150' '70' $Script:ContID2

                                $Script:XmlWriter.WriteEndElement()

                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')

                                $RGNum = 1
                                foreach($RG in $RGs)
                                    {
                                        $Attr = ('ResourceGroup_'+[string]$RGNum)
                                        $Script:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                        $RGNum++
                                    }
                                
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                                    Add-Icon $Script:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Script:ContID2

                                $Script:XmlWriter.WriteEndElement()

                                $LocalTop = $LocalTop + 90
                            }


                        ######################################## 3RD LEVEL ##############################################

                        $3rdLevel = @()
                        foreach($sub3rd in $OrgObjs)
                            {                 
                                if($sub3rd.properties.managementgroupancestorschain.name[1] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[0]
                                    }
                                if($sub3rd.properties.managementgroupancestorschain.name[2] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[1]
                                    }
                                if($sub3rd.properties.managementgroupancestorschain.name[3] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[2]
                                    }
                            }
                            $3rdLevel = $3rdLevel | Select-Object -Unique

                            $XXXLeft = 0
                            if($3rdLevel.count  % 2 -eq 1 )
                                {
                                    $Align3 = $true
                                    $loops3 = -[Math]::ceiling($3rdLevel.count / 2 - 1)
                                }
                            else
                                {
                                    $Align3 = $false
                                    $loops3 = [Math]::ceiling($3rdLevel.count / 2) - 1
                                    
                                }
                            if($3rdLevel.count -eq 1)
                                {
                                    $loops3 = 1
                                }


                        foreach($3rd in $3rdLevel)
                            {   
                                $RoundSubs3 = @() 
                                $Temp4rd3 = @()
                                $Temp5th3 = @()
                        
                                foreach($Sub in $OrgObjs)
                                    {
                                        if($Sub.properties.managementgroupancestorschain.name[0] -eq $3rd)
                                            {
                                                $RoundSubs3 += $Sub
                                            }
                                        if($Sub.properties.managementgroupancestorschain.name[1] -eq $3rd)
                                            {
                                                $Temp4rd3 += $Sub.properties.managementgroupancestorschain.name[0]
                                            }
                                        if($Sub.properties.managementgroupancestorschain.name[2] -eq $3rd)
                                            {
                                                $Temp5th3 += $Sub.properties.managementgroupancestorschain.name[0]
                                                $Temp4rd3 += $Sub.properties.managementgroupancestorschain.name[1]
                                            }
                                    }

                                $Temp4rd3 = $Temp4rd3 | Select-Object -Unique
                                $Temp5th3 = $Temp5th3 | Select-Object -Unique
                            

                                if($XXXLeft -eq 0 -and $Align3 -eq $true)
                                    {
                                    }
                                elseif($XXXLeft -eq 0 -and $Align3 -eq $false)
                                    {
                                        $XXXLeft = -150 + -((((($Temp4rd3.count)+($Temp5th3.count)))*150)/2)
                                        $loops3++
                                    }
                                elseif($Align3 -eq $false -and $loops3 -eq 0)
                                    {
                                        $XXXLeft = 150 + ((((($Temp4rd3.count)+($Temp5th3.count)))*150)/2)
                                        $loops3++
                                    }
                                elseif($loops3 -gt 0 -and $XXXLeft -eq 0)
                                    {
                                        $XXXLeft = $XXXLeft + ($3rdLevel.count*300)/2 + ((((($Temp4rd3.count)+($Temp5th3.count)))*300)/2)
                                        $loops3++
                                    }
                                elseif($XXXLeft -eq 0 -and $loops3 -lt 0)
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + -$XXXTemp
                                        $loops3++
                                    }
                                elseif($XXXLeft -lt 0 -and $loops3 -lt 0)
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + -$XXXTemp
                                        $loops3++
                                    }
                                elseif($XXXLeft -eq 1 -and $loops3 -gt 0)
                                    {
                                        $XXXLeft = 150 + ((((($Temp4rd3.count)+($Temp5th3.count)))*150))
                                        $loops3++
                                    }
                                else
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + $XXXTemp
                                        $loops3++
                                    }

                                
                                $MgmtHeight2 = if((($RoundSubs3.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs3.id.count * 90) + 50)}

                                $XXXTop = $MgmtHeight1 + 200

                                Add-Container3 $XXXLeft $XXXTop '200' $MgmtHeight2 $3rd $Script:ContID2

                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
                                $Script:XmlWriter.WriteAttributeString('ManagementGroup', [string]$3rd)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                                if($RoundSubs3)
                                    {
                                        Add-Icon $Script:IconMgmtGroup '-30' ($MgmtHeight2-15) '50' '50' $Script:ContID3
                                    }
                                else
                                    {
                                        Add-Icon $Script:IconMgmtGroup '75' '27' '50' '50' $Script:ContID3
                                    }

                                $Script:XmlWriter.WriteEndElement()

                                Add-Connection $Script:ContID2 $Script:ContID3

                                if($XXXLeft -eq 0 -and $loops3 -lt 0)
                                    {
                                        $XXXLeft = -1
                                    }
                                elseif($XXXLeft -lt 0 -and $loops3 -ge 0)
                                    {
                                        $XXXLeft = 1
                                    }

                                $LocalTop = 50
                                $LocalLeft = 25

                                foreach($Sub in $RoundSubs3)
                                    {                                

                                        $RGs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                        $Script:XmlWriter.WriteStartElement('object')
                                        $Script:XmlWriter.WriteAttributeString('label', $sub.name)
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($Script:CelNum++)))

                                            Add-Icon $Ret3 $LocalLeft $LocalTop '150' '70' $Script:ContID3

                                        $Script:XmlWriter.WriteEndElement()

                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', '')

                                        $RGNum = 1
                                        foreach($RG in $RGs)
                                            {
                                                $Attr = ('ResourceGroup_'+[string]$RGNum)
                                                $Script:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                                $RGNum++
                                            }
                                        
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                                            Add-Icon $Script:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Script:ContID3

                                        $Script:XmlWriter.WriteEndElement()

                                        $LocalTop = $LocalTop + 90
                                    }


                                    ######################################## 4TH LEVEL ##############################################

                                    $4thLevel = @()
                                    foreach($sub4th in $OrgObjs)
                                        {                 
                                            if($sub4th.properties.managementgroupancestorschain.name[1] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[0]
                                                }
                                            if($sub4th.properties.managementgroupancestorschain.name[2] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[1]
                                                }
                                            if($sub4th.properties.managementgroupancestorschain.name[3] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[2]
                                                }
                                        }
                                        $4thLevel = $4thLevel | Select-Object -Unique

                                        $XXXXLeft = 0
                                        if($4thLevel.count  % 2 -eq 1 )
                                            {
                                                $Align4 = $true
                                                $loops4 = -[Math]::ceiling($sub4th.count / 2 - 1)
                                            }
                                        else
                                            {
                                                $Align4 = $false
                                                $loops4 = [Math]::ceiling($sub4th.count / 2) - 1
                                                
                                            }
                                        if($4thLevel.count -eq 1)
                                            {
                                                $loops4 = 1
                                            }


                                    foreach($4th in $4thLevel)
                                        {                              
                                            $RoundSubs4 = @() 
                                            $Temp5th4 = @()
                                    
                                            foreach($Sub in $OrgObjs)
                                                {
                                                    if($Sub.properties.managementgroupancestorschain.name[0] -eq $4th)
                                                        {
                                                            $RoundSubs4 += $Sub
                                                        }
                                                    if($Sub.properties.managementgroupancestorschain.name[1] -eq $4th)
                                                        {
                                                            $Temp5th4 += $Sub.properties.managementgroupancestorschain.name[0]
                                                        }
                                                    if($Sub.properties.managementgroupancestorschain.name[2] -eq $4th)
                                                        {
                                                            $Temp5th4 += $Sub.properties.managementgroupancestorschain.name[0]
                                                        }
                                                }

                                            $Temp5th4 = $Temp5th4 | Select-Object -Unique

                                            if($XXXXLeft -eq 0 -and $Align4 -eq $true)
                                                {
                                                }
                                            elseif($XXXXLeft -eq 0 -and $Align4 -eq $false)
                                                {
                                                    $XXXXLeft = -150 + -((((($Temp4rd4.count)+($Temp5th4.count)))*150)/2)
                                                    $loops4++
                                                }
                                            elseif($Align4 -eq $false -and $loops4 -eq 0)
                                                {
                                                    $XXXXLeft = 150 + ((((($Temp4rd4.count)+($Temp5th4.count)))*150)/2)
                                                    $loops4++
                                                }
                                            elseif($loops4 -gt 0 -and $XXXXLeft -eq 0)
                                                {
                                                    $XXXXLeft = $XXXXLeft + ($4thLevel.count*300)/2 + ((((($Temp5th4.count)))*300)/2)
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -eq 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + -$XXXXTemp
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -lt 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + -$XXXXTemp
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -eq 1 -and $loops4 -gt 0)
                                                {
                                                    $XXXXLeft = 150 + ((((($Temp5th4.count)))*150))
                                                    $loops4++
                                                }
                                            else
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + $XXXXTemp
                                                    $loops4++
                                                }
                
                                            
                                            $MgmtHeight3 = if((($RoundSubs4.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs4.id.count * 90) + 50)}

                                            $XXXXTop = $MgmtHeight2 + 200

                                            Add-Container4 $XXXXLeft $XXXXTop '200' $MgmtHeight3 $4th $Script:ContID3

                                            $Script:XmlWriter.WriteStartElement('object')            
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('ManagementGroup', [string]$4th)
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                                            if($RoundSubs4)
                                                {
                                                    Add-Icon $Script:IconMgmtGroup '-30' ($MgmtHeight3-15) '50' '50' $Script:ContID4
                                                }
                                            else
                                                {
                                                    Add-Icon $Script:IconMgmtGroup '75' '27' '50' '50' $Script:ContID4
                                                }

                                            $Script:XmlWriter.WriteEndElement()

                                            Add-Connection $Script:ContID3 $Script:ContID4

                                            if($XXXXLeft -eq 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXLeft = -1
                                                }
                                            elseif($XXXXLeft -lt 0 -and $loops4 -ge 0)
                                                {
                                                    $XXXXLeft = 1
                                                }

                                            $LocalTop = 50
                                            $LocalLeft = 25

                                            foreach($Sub in $RoundSubs4)
                                                {                                

                                                    $RGs = $ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                                    $Script:XmlWriter.WriteStartElement('object')
                                                    $Script:XmlWriter.WriteAttributeString('label', $sub.name)
                                                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($Script:CelNum++)))

                                                        Add-Icon $Ret4 $LocalLeft $LocalTop '150' '70' $Script:ContID4

                                                    $Script:XmlWriter.WriteEndElement()

                                                    $Script:XmlWriter.WriteStartElement('object')            
                                                    $Script:XmlWriter.WriteAttributeString('label', '')

                                                    $RGNum = 1
                                                    foreach($RG in $RGs)
                                                        {
                                                            $Attr = ('ResourceGroup_'+[string]$RGNum)
                                                            $Script:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                                            $RGNum++
                                                        }

                                                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        

                                                        Add-Icon $Script:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Script:ContID4

                                                    $Script:XmlWriter.WriteEndElement()

                                                    $LocalTop = $LocalTop + 90
                                                }

                                        }

                            }

                    }

            }

    }

    Set-Stencil

    $OrgFile = Join-Path $DiagramCache 'Organization.xml'

    $Script:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    $Script:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    $Script:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

    $Script:IDNum = 0
    $Script:CelNum = 0

    Write-Output ('DrawIOOrgsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Creating XML File: ' + $OrgFile)

    $Script:XmlWriter = New-Object System.XMl.XmlTextWriter($OrgFile,$Null)

    $Script:XmlWriter.Formatting = 'Indented'
    $Script:XmlWriter.Indentation = 2

    $Script:XmlWriter.WriteStartDocument()

        $Script:XmlWriter.WriteStartElement('mxfile')
        $Script:XmlWriter.WriteAttributeString('host', 'Electron')
        $Script:XmlWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $Script:XmlWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $Script:XmlWriter.WriteAttributeString('etag', $etag)
        $Script:XmlWriter.WriteAttributeString('version', '15.4.0')
        $Script:XmlWriter.WriteAttributeString('type', 'device')

            $Script:XmlWriter.WriteStartElement('diagram')
            $Script:XmlWriter.WriteAttributeString('id', $DiagID)
            $Script:XmlWriter.WriteAttributeString('name', 'Organization')

                $Script:XmlWriter.WriteStartElement('mxGraphModel')
                $Script:XmlWriter.WriteAttributeString('dx', "1326")
                $Script:XmlWriter.WriteAttributeString('dy', "798")
                $Script:XmlWriter.WriteAttributeString('grid', "1")
                $Script:XmlWriter.WriteAttributeString('gridSize', "10")
                $Script:XmlWriter.WriteAttributeString('guides', "1")
                $Script:XmlWriter.WriteAttributeString('tooltips', "1")
                $Script:XmlWriter.WriteAttributeString('connect', "1")
                $Script:XmlWriter.WriteAttributeString('arrows', "1")
                $Script:XmlWriter.WriteAttributeString('fold', "1")
                $Script:XmlWriter.WriteAttributeString('page', "1")
                $Script:XmlWriter.WriteAttributeString('pageScale', "1")
                $Script:XmlWriter.WriteAttributeString('pageWidth', "850")
                $Script:XmlWriter.WriteAttributeString('pageHeight', "1100")
                $Script:XmlWriter.WriteAttributeString('math', "0")
                $Script:XmlWriter.WriteAttributeString('shadow', "0")

                    $Script:XmlWriter.WriteStartElement('root')

                        $Script:XmlWriter.WriteStartElement('mxCell')
                        $Script:XmlWriter.WriteAttributeString('id', "0")
                        $Script:XmlWriter.WriteEndElement()

                        $Script:XmlWriter.WriteStartElement('mxCell')
                        $Script:XmlWriter.WriteAttributeString('id', "1")
                        $Script:XmlWriter.WriteAttributeString('parent', "0")
                        $Script:XmlWriter.WriteEndElement()


                            Start-OrgDiagram


                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()

            $Script:XmlWriter.WriteEndElement()
        
        $Script:XmlWriter.WriteEndElement()

    $Script:XmlWriter.WriteEndDocument()
    $Script:XmlWriter.Flush()
    $Script:XmlWriter.Close()

    Write-Output ('DrawIOOrgsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - End of Function')

}