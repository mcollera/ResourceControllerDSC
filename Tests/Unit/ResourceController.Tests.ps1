#requires -Version 4.0 -Modules Pester
#requires -RunAsAdministrator

#region Setup for tests
$DSCResourceName = 'ResourceController'

Import-Module "$($PSScriptRoot)\..\..\DSCResources\$($DSCResourceName)\$($DSCResourceName).psm1" -Force
Import-Module "$($PSScriptRoot)\..\TestHelper.psm1" -Force

#endregion

Describe "$DSCResourceName\Get-TargetResource" {
    Context "Calling Get-TargetResource on xRegistry" {
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueName = 'Test2'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\test'; ValueData = 'Test String'; ValueType = 'String'}} -ModuleName $DSCResourceName -Verifiable
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'Test2'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SOFTWARE\test'),
                                            $(New-CimProperty -Key Ensure -Value 'Present'),
                                            $(New-CimProperty -Key ValueData -Value 'Test String'),
                                            $(New-CimProperty -Key ValueType -Value 'String')
                                            )
                        }

        $GetResult = & "$($DSCResourceName)\Get-TargetResource" @ContextParams

        It 'Should call Test-ParameterValidation once' {
            Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should call Get-ValidParameters once' {
            Assert-MockCalled -CommandName 'Get-ValidParameters' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should return Result' {
            $GetResult.Result | Should Not Be $null
        }
    }

}

Describe "$DSCResourceName\Test-TargetResource" {
    Context "Calling Test-TargetResource on xRegistry where Key does not exist" {
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'Test'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey')
                                            )
                        }

        $TestResult = & "$($DSCResourceName)\Test-TargetResource" @ContextParams

        It 'Should call Test-ParameterValidation once' {
            Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should call Get-ValidParameters once' {
            Assert-MockCalled -CommandName 'Get-ValidParameters' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should return False' {
            $TestResult | Should Be $false
        }
    }

        Context "Calling Test-TargetResource on xRegistry where Key does exist" {
        $ComputerName = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name ComputerName
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueType = 'String'; ValueData = $ComputerName.ComputerName; ValueName = 'ComputerName'; Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'}} -ModuleName $DSCResourceName -Verifiable
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'ComputerName'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'),
                                            $(New-CIMProperty -Key ValueData -Value $ComputerName.ComputerName),
                                            $(New-CIMProperty -Key ValueType -Value 'String')
                                            )
                        }

        $TestResult = & "$($DSCResourceName)\Test-TargetResource" @ContextParams

        It 'Should call Test-ParameterValidation once' {
            Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should call Get-ValidParameters once' {
            Assert-MockCalled -CommandName 'Get-ValidParameters' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should return true' {
            $TestResult | Should Be $true
        }
    }
}

Describe "$DSCResourceName\Set-TargetResource" {
    function Set-xRegistryTargetResource {}
    Context "Calling Set-TargetResource on xRegistry inside maintenace window" {
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
        Mock -CommandName Set-xRegistryTargetResource -MockWith {}
        Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'Test'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey')
                                            )
                        }

        $SetResult = & "$($DSCResourceName)\Set-TargetResource" @ContextParams

        It 'Should call Test-ParameterValidation once' {
            Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should call Get-ValidParameters once' {
            Assert-MockCalled -CommandName 'Get-ValidParameters' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }

        It 'Should call Set-xRegistryTargetResource once' {
            Assert-MockCalled -CommandName 'Set-xRegistryTargetResource' -Times 1 -Scope 'Context'
        }

        It 'Should call Test-MaintenanceWindow once' {
            Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }
    }

    Context "Calling Set-TargetResource on xRegistry outside maintenace window" {
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
        Mock -CommandName Set-xRegistryTargetResource -MockWith {}
        Mock -CommandName Test-MaintenanceWindow -MockWith {$false} -ModuleName $DSCResourceName
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'Test'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey')
                                            )
                        }

        $SetResult = & "$($DSCResourceName)\Set-TargetResource" @ContextParams

        It 'Should not call Test-ParameterValidation once' {
            Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 0 -Scope 'Context'
        }

        It 'Should not call Get-ValidParameters once' {
            Assert-MockCalled -CommandName 'Get-ValidParameters' -ModuleName $DSCResourceName -Times 0 -Scope 'Context'
        }

        It 'Should  not call Set-xRegistryTargetResource once' {
            Assert-MockCalled -CommandName 'Set-xRegistryTargetResource' -Times 0 -Scope 'Context'
        }

        It 'Should call Test-MaintenanceWindow once' {
            Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
        }
    }

    Context "Suppress Reboot equal True" {
        Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
        Mock -CommandName Get-ValidParameters -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
        Mock -CommandName Set-xRegistryTargetResource -MockWith {}
        Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName
        $ContextParams = @{
                            InstanceName = 'Test'
                            ResourceName = 'xRegistry'
                            SupressReboot = $true
                            Properties = @(
                                            $(New-CimProperty -Key ValueName -Value 'Test'),
                                            $(New-CimProperty -Key Key -Value 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey')
                                            )
                        }

        $global:DSCMachineStatus = 1
        $SetResult = & "$($DSCResourceName)\Set-TargetResource" @ContextParams

        It 'DSCMachineStatus should equal 0' {
            $global:DSCMachineStatus | should be 0
        }
    }
}

InModuleScope $DSCResourceName {
    Describe "Test-MaintenanceWindow" {
        Context "Calling Test-MaintenanceWindow outside of window" {

            $ContextParams = @{
                                EffectiveDate = (Get-Date).AddDays(-365)
                                Duration = 2
                            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window" {

            $ContextParams = @{
                                EffectiveDate = (Get-Date).AddHours(-1)
                                Duration = 3
                            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }
    }

    
    Describe "Get-ValidParameters" {
        $ResourceName = "xRegistry"
        $functionName = 'Test-TargetResource'
        $dscResource = Get-DscResource -Name $ResourceName
        Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName
        
        Context "Calling Get-ValidParameters with no extra parameters" {

            $ContextParams = @{
                                Name = 'Test-xRegistryTargetResource'
                                Values = @{
                                    Key = "TestRegistryKey"
                                    ValueName = ""
                                }
                            }

            $params = & "Get-ValidParameters" @ContextParams

            It 'Should return 2 params' {
                $params.count | should be 2
            }
        }

        Context "Calling Get-ValidParameters with extra parameters" {

            $ContextParams = @{
                                Name = 'Test-xRegistryTargetResource'
                                Values = @{
                                    Key = "TestRegistryKey"
                                    ValueName = ""
                                    Extra = ""
                                }
                            }

            $params = & "Get-ValidParameters" @ContextParams

            It 'Should return 2 params' {
                $params.Count | should be 2
            }
        }
    }

    Describe "Assert-Validation" {
        $Parameter = [System.Management.Automation.ParameterMetadata]::new("Name",'string')
        $Parameter.Attributes.Add([System.Management.Automation.ValidateLengthAttribute]::new(1,3))

        Context "Calling Assert-Validation with value not meeting parameter requirements" {
            $ContextParams = @{
                                element = 'Test'
                                ParameterMetadata = $Parameter
                            }

            It 'Should throw' {
                { Assert-Validation @ContextParams } | should throw
            }
        }

        Context "Calling Assert-Validation with value meeting parameter requirements" {

            $ContextParams = @{
                                element = 'Yes'
                                ParameterMetadata = $Parameter
                            }

            It 'Should not throw' {
                { Assert-Validation @ContextParams } | should not throw
            }
        }
    }

    Describe "Test-ParameterValidation" {
        $ResourceName = "xRegistry"
        $functionName = 'Test-TargetResource'
        $dscResource = Get-DscResource -Name $ResourceName
        Import-Module $dscResource.Path -Function $functionName -Prefix $ResourceName

        Context "Calling Test-ParameterValidation with value not meeting parameter requirements" {

            Mock -CommandName Assert-Validation -MockWith { throw "Error" }
            $ContextParams = @{
                                Name = 'Test-xRegistryTargetResource'
                                Values = @{
                                    Key = "TestRegistryKey"
                                }
                            }

            It 'Should throw' {
                { Test-ParameterValidation @ContextParams } | should throw
            }
        }

        Context "Calling Test-ParameterValidation with missing required parameter" {

            Mock -CommandName Assert-Validation -MockWith {}
            $ContextParams = @{
                                Name = 'Test-xRegistryTargetResource'
                                Values = @{
                                    Key = "TestRegistryKey"
                                }
                            }

            It 'Should throw' {
                { Test-ParameterValidation @ContextParams } | should throw
            }
        }

        Context "Calling Test-ParameterValidation with value meeting parameter requirements" {

            Mock -CommandName Assert-Validation -MockWith {}
            $ContextParams = @{
                                Name = 'Test-xRegistryTargetResource'
                                Values = @{
                                    Key = "TestRegistryKey"
                                    ValueName = "Test"
                                }
                            }

            It 'Should not throw' {
                { Test-ParameterValidation @ContextParams } | should not throw
            }
        }
    }
}