function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    Param
    (      
        [Parameter(Mandatory = $true)]
        [string]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Properties,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Result,

        [Parameter()]
        [Boolean]
        $SupressReboot,

        [Parameter()]
        [DateTime]
        $EffectiveDate,

        [Parameter()]
        [uint32]
        $Duration
    )

    $functionName = "Get-TargetResource"

    $PropertiesHashTable = @{}
    foreach($prop in $Properties)
    {
        $PropertiesHashTable.Add($prop.Key, $prop.Value)
    }

    $validation = Assert-Property -ResourceName $ResourceName -Properties $PropertiesHashTable -Method $functionName

    if($validation.error)
    {
        throw $validation.errorMessage
    }
        
    Import-Module $validation.resourcePath -Function $functionName -Prefix $ResourceName
    $splatProperties = $validation.properties
            
    $get = &"$($validation.resourceType)\Get-${ResourceName}TargetResource" @splatProperties

    $CimGetResults = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

    foreach($row in $get.Keys.GetEnumerator())
    {
        $value = $get.$row
        $CimGetResults += New-CimInstance -ClientOnly -Namespace "root/Microsoft/Windows/DesiredStateConfiguration" -ClassName "MSFT_KeyValuePair" -Property @{
                                                                                                                                                                    Key = "$row"
                                                                                                                                                                    Value = "$value"
                                                                                                                                                                }
    }

    $returnValue = @{
        InstanceName = $InstanceName
        ResourceName = $ResourceName
        Properties = $Properties
        Result = $CimGetResults
        SupressReboot = $SupressReboot
        EffectiveDate = $EffectiveDate
        Duration = $Duration
    }
    
    return $returnValue
}

function Test-TargetResource
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Properties,

        [Parameter()]
        [Boolean]
        $SupressReboot,

        [Parameter()]
        [DateTime]
        $EffectiveDate,

        [Parameter()]
        [uint32]
        $Duration
    )

    $functionName = "Test-TargetResource"

    $PropertiesHashTable = @{}
    foreach($prop in $Properties)
    {
        $PropertiesHashTable.Add($prop.Key, $prop.Value)
    }

    $validation = Assert-Property -ResourceName $ResourceName -Properties $PropertiesHashTable -Method $functionName

    if($validation.error)
    {
        throw $validation.errorMessage
    }
        
    Import-Module $validation.resourcePath -Function $functionName -Prefix $ResourceName
    $splatProperties = $validation.properties
            
    $result = &"$($validation.resourceType)\Test-${ResourceName}TargetResource" @splatProperties
    
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Properties,

        [Parameter()]
        [Boolean]
        $SupressReboot,

        [Parameter()]
        [DateTime]
        $EffectiveDate,

        [Parameter()]
        [uint32]
        $Duration
    )

    if(-not $(Test-MaintenanceWindow -EffectiveDate $EffectiveDate -Duration $Duration))
    {
        Write-Verbose "You are outside the maintenance window. Set will not continue."
        return
    }

    $functionName = "Set-TargetResource"

    $PropertiesHashTable = @{}
    foreach($prop in $Properties)
    {
        $PropertiesHashTable.Add($prop.Key, $prop.Value)
    }
    
    $validation = Assert-Property -ResourceName $ResourceName -Properties $PropertiesHashTable -Method $functionName
    
    if($validation.error)
    {
        throw $validation.errorMessage
    }
    
    Import-Module $validation.resourcePath -Function $functionName -Prefix $ResourceName
    
    $splatProperties = $validation.properties
    
    &"$($validation.resourceType)\Set-${ResourceName}TargetResource" @splatProperties -Verbose

    if($SupressReboot)
    {
        $global:DSCMachineStatus = 0
    }
}

function Test-MaintenanceWindow
{
    param(
        [Parameter()]
        [Nullable[DateTime]]
        $EffectiveDate,

        [Parameter()]
        [Nullable[int]]
        $Duration
    )

    $Now = Get-Date

    $start = Get-Date -Hour $EffectiveDate.Hour -Minute $EffectiveDate.Minute -Second 0 -Millisecond 0

    $End = $start.AddHours($Duration)
    
    if($Now -lt $EffectiveDate)
    {
        return $false
    }

    if($Now -ge $Start -and $Now -lt $End)
    {
        return $true
    }
    else
    {
        return $false
    }
}

function Test-Validation
{
    param(
        [Parameter(Mandatory = $true)]
        [object[]]
        $Validation,

        [Parameter()]
        [object]
        $value
    )

    $types = @(
        "ValidateNotNull",
        "ValidateNotNullOrEmpty",
        "ValidateLength",
        "ValidateCount",
        "ValidateRange",
        "ValidateSet",
        "ValidatePattern",
        "ValidateScript"
    )

    foreach($type in $types)
    {
        $criteria = ($Validation | Select-String "(?<=\[$type\(("")?(')?).*(?=("")?(')?\)\])").Matches.Value
        if($criteria)
        {
            switch ($type)
            {
                "ValidateNotNull"
                    {
                        if($null -eq $value)
                        {
                            return $false
                        }
                        break
                    }
                "ValidateNotNullOrEmpty"
                    {
                        if([string]::IsNullOrEmpty($value))
                        {
                            return $false
                        }
                        break
                    }
                "ValidateLength"
                    {
                        $length = $criteria -split ","
                        if($value.length -lt $length[0])
                        {
                            return $false
                        }
                        elseif($value.Length -gt $length[1])
                        {
                            return $false
                        }
                        break
                    }
                "ValidateCount"
                    {
                        
                        break
                    }
                "ValidateRange"
                    {
                        $length = $criteria -split ","
                        if([int]::Parse($value) -lt [int]::Parse($length[0]))
                        {
                            return $false
                        }
                        elseif([int]::Parse($value) -gt [int]::Parse($length[1]))
                        {
                            return $false
                        }
                        break
                    }
                "ValidateSet"
                    {
                        if(-not $criteria.Split(",").Trim("'"," ","""").ToLower().Contains($value.ToLower()))
                        {
                            return $false
                        }
                        break
                    }
                "ValidatePattern"
                    {
                        if($value -notmatch $criteria.Trim("'",""""))
                        {
                            return $false
                        }
                        break
                    }
                "ValidateScript"
                    {
                        $scriptblock = [ScriptBlock]::Create($criteria.Replace('{','').Replace('}','').Replace("`$_", "`$args[0]"))
                        $result = Invoke-Command -ScriptBlock $scriptblock -ArgumentList $value
                        if($result -eq $false)
                        {
                            return $false
                        }
                        break;
                    }
            }
        }
    }
    return $true
}

function Assert-Property
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [HashTable]
        $Properties,

        [Parameter(Mandatory = $true)]
        [string]
        $Method
    )

    $resource = Get-DscResource -Name $ResourceName -Syntax
    $resourcePath = $resource.Path
    $resourceParameters = $resource.Properties
    $propertiesToPass = @{}

    $errorMessage = "`n"
    $error = $false

    $mandatoryParameters = $resourceParameters.Where({$_.IsMandatory -eq $true})
    foreach($param in $mandatoryParameters)
    {
        if(-not $Properties.ContainsKey($param.Name))
        {
            $errorMessage += "Resource $ResourceName is missing mandatory parameter '$($param.Name)'`n"
            $error = $true
        }
    }


    $parser = [System.Management.Automation.Language.Parser]::ParseFile($resourcePath,[ref]$null,[ref]$null)
    $ast = $parser.EndBlock.Statements.Where({$_.Name -eq $Method}).Body.ParamBlock.Parameters
    $charReplace = '{0}|{1}' -f "'", '"'
    $select = @{ n = 'Name'; e = { $_.Name.VariablePath.UserPath } }, @{ n = 'ValidationString'; e = {$_.Extent.Text } }
 
    $params = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ParameterAst] }, $true) | Select-Object $select -Unique | sort-object -Property Name -Unique

    foreach($param in $params)
    {
        if($Properties.($param.Name))
        {
            $pass = Test-Validation -Validation $param.ValidationString -value $Properties.($param.Name)
            if(-not $pass){
                $errorMessage += "'$($param.Name)' does not meet validation requirement`n"
                $error = $true
            }
            $propertiesToPass.Add($param.Name,$Properties.($param.Name))
        }

    }

    $data = @{
        resourcePath = $resourcePath
        resourceType = $resource.ResourceType
        properties = $propertiesToPass
        error = $error
        errorMessage = $errorMessage
    }
    return $data
}


Export-ModuleMember -Function *-TargetResource
