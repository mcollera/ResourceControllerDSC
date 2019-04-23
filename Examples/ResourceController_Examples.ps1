ResourceController 'newtest'
{
    InstanceName = 'newtest'
    ResourceName = 'Registry'
    ResourceVersion = '1.1'
    Credentials = @(
        Credential {
            Name = 'Cred1'
            Credential = $cred
        }
        Credential {
            Name = 'Cred2'
            Credential = $cred2
        }
    )
    Properties = {
        @{
            Ensure    = 'Present'
            Key       = 'HKLM:\System\Test'
            ValueName = 'Test'
            ValueType = 'String'
            ValueData = '[PSCredential]:Cred1'
        }
    }
}
