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