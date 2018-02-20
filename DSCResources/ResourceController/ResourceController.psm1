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

    $dscResource = Get-DscResource -Name $ResourceName

    Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName
    
    try
    {
        Test-ParameterValidation -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
    }
    catch
    {
        throw $_.Exception.Message
    }

    $splatProperties = Get-ValidParameters -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
            
    $get = & "Get-${ResourceName}TargetResource" @splatProperties

    $CimGetResults = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

    foreach($row in $get.Keys.GetEnumerator())
    {
        $value = $get.$row

        $CimProperties = @{
            Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
            ClassName = "MSFT_KeyValuePair"
            Property = @{
                            Key = "$row"
                            Value = "$value"
                        }
        }
        $CimGetResults += New-CimInstance -ClientOnly @CimProperties
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

    $dscResource = Get-DscResource -Name $ResourceName

    Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName
    
    try
    {
        Test-ParameterValidation -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
    }
    catch
    {
        throw $_.Exception.Message
    }

    $splatProperties = Get-ValidParameters -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
            
    $result = &"Test-${ResourceName}TargetResource" @splatProperties
    
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
    
    $dscResource = Get-DscResource -Name $ResourceName

    Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName
    
    try
    {
        Test-ParameterValidation -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
    }
    catch
    {
        throw $_.Exception.Message
    }
    
    $splatProperties = Get-ValidParameters -Name $functionName.Replace("-","-$ResourceName") -Values $PropertiesHashTable
    
    &"Set-${ResourceName}TargetResource" @splatProperties -Verbose

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

    $start = Get-Date -Year $EffectiveDate.Year -Day $EffectiveDate.Day -Month $EffectiveDate.Month -Hour $EffectiveDate.Hour -Minute $EffectiveDate.Minute -Second 0 -Millisecond 0

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

function Assert-Validation
{
    param(
        [parameter(Mandatory = $true)]
        $element,

        [parameter(Mandatory = $true)]
        [psobject]
        $ParameterMetadata
    )

    $BindingFlags = 'static','nonpublic','instance'
    $errorMessage = @()
    foreach($attribute in $ParameterMetadata.Attributes)
    {
        try
        {  
            $Method = $attribute.GetType().GetMethod('ValidateElement',$BindingFlags)
            if($Method)
            {
                $Method.Invoke($attribute,@($element))
            }

        }
        catch
        {
            $errorMessage += "Error on parameter $($ParameterMetadata.Name): $($_.Exception.InnerException.Message)"
        }
    }
    if($errorMessage.Count -gt 0)
    {
        throw $errorMessage -join "`n"
    }
}

function Test-ParameterValidation
{
    param(

        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [Hashtable]
        $Values
    )

    $ignoreResourceParameters = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters
    $errorMessage = @()
    $command = Get-Command -Name $name
    $parameterNames = $command.Parameters
    foreach($name in $parameterNames.Keys)
    {
        if($ignoreResourceParameters -notcontains $name)
        {
            $metadata = $command.Parameters.$($name)
            if($Values.$($name))
            {
                try
                {
                    Assert-Validation -element $Values.$($name) -ParameterMetadata $metadata
                }
                catch
                {
                    $errorMessage += $_.Exception.Message
                }
            }
            elseif($($metadata.Attributes | Where-Object {$_.TypeId.Name -eq "ParameterAttribute"}).Mandatory)
            {
                $errorMessage += "Parameter '$name' is mandatory."
            }
        }
    }
    if($errorMessage.Count -gt 0)
    {
        throw $errorMessage -join "`n"
    }
}

function Get-ValidParameters
{
    param(

        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [Hashtable]
        $Values
    )

    $ignoreResourceParameters = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters
    $command = Get-Command -Name $name
    $parameterNames = $command.Parameters
    $properties = @{}
    foreach($name in $parameterNames.Keys)
    {
        if($ignoreResourceParameters -notcontains $name)
        {
            if($Values.ContainsKey($name))
            {
                $properties.Add($Name, $Values.$name)
            }
        }
    }
    return $properties
}

Export-ModuleMember -Function *-TargetResource
