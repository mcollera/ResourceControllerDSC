[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param()

function New-CIMProperty
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Key,

        [parameter(Mandatory = $true)]
        [string]
        $Value
    )
    $CimProperties = @{
        Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
        ClassName = "MSFT_KeyValuePair"
        Property = @{
                        Key = "$Key"
                        Value = "$Value"
                    }
    }
    return New-CimInstance -ClientOnly @CimProperties
}

function New-CIMCredential
{
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Name,

        [parameter(Mandatory = $true)]
        [string]
        $UserName
    )
    $cimCredential = @{
        Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
        ClassName = "MSFT_Credential"
        Property = @{
                        UserName = "$UserName"
                        Password = "Password"
                    }
    }
    $pscredential = New-CimInstance -ClientOnly @cimCredential

    $CimProperties = @{
        Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
        ClassName = "Credential"
        Property = @{
                        Name = "$Name"
                        Credential = $pscredential
                    }
    }
    return New-CimInstance -ClientOnly @CimProperties
}

function New-CIMWindow
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
        $DaysofWeek,

        [Parameter()]
        [int[]]
        $Week,

        [Parameter()]
        [int[]]
        $Days,

        [Parameter()]
        [Nullable[DateTime]]
        $StartDate,

        [Parameter()]
        [Nullable[DateTime]]
        $EndDate
    )
    $maintenanceWindowProperties = @{}

    foreach($param in $PSBoundParameters.Keys)
    {
        $maintenanceWindowProperties.Add($param, $PSBoundParameters.$param)
    }
    $CimProperties = @{
        Namespace = 'root/Microsoft/Windows/DesiredStateConfiguration'
        ClassName = "MaintenanceWindow"
        Property = $maintenanceWindowProperties
    }

    return New-CimInstance -ClientOnly @CimProperties
}
