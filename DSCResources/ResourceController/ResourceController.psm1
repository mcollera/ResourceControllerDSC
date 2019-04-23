# Suppress Global Vars PSSA Error because $global:DSCMachineStatus must be allowed
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param()

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
        [System.String]
        $Properties,

        [Parameter()]
        [Boolean]
        $SuppressReboot,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MaintenanceWindow,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceVersion,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Credentials
    )

    $functionName = "Get-TargetResource"

    $PropertiesHashTable = [scriptblock]::Create($Properties).Invoke()
    $PropertiesHashTable = ConvertTo-Hashtable -Hashtable $PropertiesHashTable -Credentials $Credentials

    $dscResource = (Get-DscResource -Name $ResourceName).Where( {$_.Version -eq $ResourceVersion})[0]

    try
    {
        Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName

        try
        {
            Test-ParameterValidation -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable
        }
        catch
        {
            throw $_.Exception.Message
        }

        Write-Verbose "Parameters passed in have validated succesfully."

        $splatProperties = Get-ValidParameter -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable

        Write-Verbose "Calling Get-TargetResource"

        $get = & "Get-${ResourceName}TargetResource" @splatProperties

        $CimGetResults = New-Object -TypeName 'System.Collections.ObjectModel.Collection`1[Microsoft.Management.Infrastructure.CimInstance]'

        foreach ($row in $get.Keys.GetEnumerator())
        {
            $value = $get.$row

            $CimProperties = @{
                Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
                ClassName = "MSFT_KeyValuePair"
                Property  = @{
                    Key   = "$row"
                    Value = "$value"
                }
            }
            $CimGetResults += New-CimInstance -ClientOnly @CimProperties
        }

        $returnValue = @{
            InstanceName      = $InstanceName
            ResourceName      = $ResourceName
            Properties        = $Properties
            Result            = $CimGetResults
            SuppressReboot    = $SuppressReboot
            MaintenanceWindow = $MaintenanceWindow
        }

        return $returnValue
    }
    finally
    {
        Remove-Module -Name $dscResource.ResourceType
    }
}

function Test-TargetResource
{
    [OutputType([Boolean])]
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
        [System.String]
        $Properties,

        [Parameter()]
        [Boolean]
        $SuppressReboot,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MaintenanceWindow,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceVersion,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Credentials
    )

    $functionName = "Test-TargetResource"

    $PropertiesHashTable = [scriptblock]::Create($Properties).Invoke()
    $PropertiesHashTable = ConvertTo-Hashtable -Hashtable $PropertiesHashTable -Credentials $Credentials

    $dscResource = (Get-DscResource -Name $ResourceName).Where( {$_.Version -eq $ResourceVersion})[0]

    try
    {
        Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName

        try
        {
            $null = Test-ParameterValidation -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable
        }
        catch
        {
            throw $_.Exception.Message
        }

        Write-Verbose "Parameters passed in have validated succesfully."

        $splatProperties = Get-ValidParameter -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable

        Write-Verbose "Calling Test-TargetResource"

        $result = &"Test-${ResourceName}TargetResource" @splatProperties

        return $result
    }
    finally
    {
        Remove-Module -Name $dscResource.ResourceType
    }
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
        [System.String]
        $Properties,

        [Parameter()]
        [Boolean]
        $SuppressReboot,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $MaintenanceWindow,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceVersion,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Credentials
    )

    $inMaintenanceWindow = $false
    foreach ($window in $MaintenanceWindow)
    {
        $maintenanceWindowProperties = @{}
        $params = @("Frequency",
            "StartTime",
            "EndTime",
            "DayOfWeek",
            "Week",
            "Day",
            "StartDate",
            "EndDate")

        foreach ($param in $params)
        {
            if ($window.$param)
            {
                $maintenanceWindowProperties.Add($param, $window.$param)
            }
        }

        if ($(Test-MaintenanceWindow @maintenanceWindowProperties))
        {
            $inMaintenanceWindow = $true
        }
    }

    if (-not $inMaintenanceWindow -and $MaintenanceWindow)
    {
        Write-Verbose "You are outside the maintenance window. No changes will be made."
        return
    }

    $functionName = "Set-TargetResource"    

    $PropertiesHashTable = [scriptblock]::Create($Properties).Invoke()
    $PropertiesHashTable = ConvertTo-Hashtable -Hashtable $PropertiesHashTable -Credentials $Credentials

    $dscResource = (Get-DscResource -Name $ResourceName).Where( {$_.Version -eq $ResourceVersion})[0]

    try
    {
        Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName

        try
        {
            Test-ParameterValidation -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable
        }
        catch
        {
            throw $_.Exception.Message
        }

        Write-Verbose "Parameters passed in have validated succesfully."

        $splatProperties = Get-ValidParameter -Name $functionName.Replace("-", "-$ResourceName") -Values $PropertiesHashTable

        Write-Verbose "Calling Set-TargetResource."

        &"Set-${ResourceName}TargetResource" @splatProperties -Verbose

        if ($SuppressReboot -and $global:DSCMachineStatus -ne 0)
        {
            $global:DSCMachineStatus = 0
        }
    }
    finally
    {
        Remove-Module -Name $dscResource.ResourceType
    }
}

function Test-MaintenanceWindow
{
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Frequency,

        [Parameter()]
        [Nullable[DateTime]]
        $StartTime,

        [Parameter()]
        [Nullable[DateTime]]
        $EndTime,

        [Parameter()]
        [string[]]
        $DayOfWeek,

        [Parameter()]
        [int[]]
        $Week,

        [Parameter()]
        [int[]]
        $Day,

        [Parameter()]
        [Nullable[DateTime]]
        $StartDate,

        [Parameter()]
        [Nullable[DateTime]]
        $EndDate
    )

    $now = Get-Date

    if ($StartDate)
    {
        if ($now.Date -lt $StartDate.Date)
        {
            return $false
        }
    }

    if ($EndDate)
    {
        if ($now.Date -gt $EndDate.Date)
        {
            return $false
        }
    }

    if ($StartTime)
    {
        if ($now.TimeOfDay -lt $StartTime.TimeOfDay)
        {
            return $false
        }
    }

    if ($EndTime)
    {
        if ($now.TimeOfDay -gt $EndTime.TimeOfDay)
        {
            return $false
        }
    }

    switch ($Frequency)
    {
        'Daily'
        {

            if ($DayOfWeek.Count -eq 0)
            {
                $DayOfWeek = @("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
            }

            if (-not ($DayOfWeek -Contains $now.DayOfWeek))
            {
                return $false
            }
        }
        'Weekly'
        {

            if ($DayOfWeek.Count -eq 0)
            {
                $DayOfWeek = @("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
            }

            if ($Week.Count -eq 0)
            {
                $Week = @("0", "1", "2", "3", "4")
            }

            if (-not ($DayOfWeek -Contains $now.DayOfWeek))
            {
                return $false
            }

            $dow = $now.DayOfWeek
            $WorkingDate = Get-Date -Year $now.Year -Month $now.Month -Day 1
            $weekCount = 0

            for ($i = 1; $i -le $now.Day; $i++)
            {
                if ($WorkingDate.DayOfWeek -eq $dow)
                {
                    $weekCount++
                }
                $WorkingDate = $WorkingDate.AddDays(1)
            }

            if (-not ($Week -contains $weekCount))
            {
                if ($Week -contains 0)
                {
                    $WorkingDate = Get-Date -Year $now.Year -Month $now.Month -Day $([DateTime]::DaysInMonth($now.Year, $now.Month))
                    while ($dow -ne $WorkingDate.DayOfWeek)
                    {
                        $WorkingDate = $WorkingDate.AddDays(-1)
                    }

                    if ($WorkingDate.Day -ne $now.Day)
                    {
                        return $false
                    }
                }
                else
                {
                    return $false
                }
            }
        }
        'Monthly'
        {

            if ($Day.Count -eq 0)
            {
                $Day = @("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31")
            }
            if (-not ($Day -contains $now.Day))
            {
                if ($Day -contains 0)
                {
                    $lastDayofMonth = $([DateTime]::DaysInMonth($now.Year, $now.Month))
                    if ($lastDayofMonth -ne $now.Day)
                    {
                        return $false
                    }
                }
                else
                {
                    return $false
                }
            }
        }
    }

    return $true
}

function Assert-Validation
{
    param(
        [Parameter(Mandatory = $true)]
        $element,

        [Parameter(Mandatory = $true)]
        [psobject]
        $ParameterMetadata
    )

    $BindingFlags = 'static', 'nonpublic', 'instance'
    $errorMessage = @()
    foreach ($attribute in $ParameterMetadata.Attributes)
    {
        try
        {
            $Method = $attribute.GetType().GetMethod('ValidateElement', $BindingFlags)
            if ($Method)
            {
                $Method.Invoke($attribute, @($element))
            }

        }
        catch
        {
            $errorMessage += "Error on parameter $($ParameterMetadata.Name): $($_.Exception.InnerException.Message)"
        }
    }
    if ($errorMessage.Count -gt 0)
    {
        throw $errorMessage -join "`n"
    }
}

function Test-ParameterValidation
{
    param(

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [Hashtable]
        $Values
    )

    $ignoreResourceParameters = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters
    $errorMessage = @()
    $command = Get-Command -Name $name
    $parameterNames = $command.Parameters
    foreach ($name in $parameterNames.Keys)
    {
        if ($ignoreResourceParameters -notcontains $name)
        {
            $metadata = $command.Parameters.$($name)
            if ($Values.$($name))
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
            elseif ($($metadata.Attributes | Where-Object {$_.TypeId.Name -eq "ParameterAttribute"}).Mandatory)
            {
                $errorMessage += "Parameter '$name' is mandatory."
            }
        }
    }
    if ($errorMessage.Count -gt 0)
    {
        throw $errorMessage -join "`n"
    }
}

function Get-ValidParameter
{
    param(

        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [Hashtable]
        $Values
    )

    $ignoreResourceParameters = [System.Management.Automation.Cmdlet]::CommonParameters + [System.Management.Automation.Cmdlet]::OptionalCommonParameters
    $command = Get-Command -Name $name
    $parameterNames = $command.Parameters
    $properties = @{}
    foreach ($name in $parameterNames.Keys)
    {
        if ($ignoreResourceParameters -notcontains $name)
        {
            if ($Values.ContainsKey($name))
            {
                $properties.Add($Name, $Values.$name)
            }
        }
    }
    return $properties
}

function ConvertTo-Hashtable
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param
    (
        [Parameter(Mandatory = $true)]
        $Hashtable,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]] 
        $Credentials
    )

    $tempHashtable = @{}
    foreach ($row in $Hashtable.Keys)
    {
        if ($Hashtable.$row -imatch "\[pscredential\]:(.*)")
        {
            $split = $Hashtable.$row -split ':', 2
            $credential = $Credentials | Where-Object -FilterScript { $_.Name -eq $split[1] } | Select-Object -First 1
            
            $password = ConvertTo-SecureString -String $credential.Credential.Password -AsPlainText -Force
            $credentialObject = [PsCredential]::new($credential.Credential.UserName, $password)

            $tempHashtable.Add($row, $credentialObject )
        }
        else
        {
            $tempHashtable.Add($row, $Hashtable.$row )
        }
    }
    return $tempHashtable
}

Export-ModuleMember -Function *-TargetResource
