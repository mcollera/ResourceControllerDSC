#requires -Version 4.0 -Modules Pester
# Suppress Global Vars PSSA Error because $global:DSCMachineStatus must be allowed
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
param()

$DSCResourceName = 'ResourceController'
Import-Module "$PSScriptRoot\..\..\DSCResources\$($DSCResourceName)\$($DSCResourceName).psm1" -Force



InModuleScope 'ResourceController' {

    . "$PSScriptRoot\..\HelperFunctions.ps1"
    $DSCResourceName = 'ResourceController'

    Describe "Get-TargetResource" {
        Context "Calling Get-TargetResource on xRegistry" {
            function Get-xRegistry2TargetResource {}
            $ResourceName = 'xRegistry2'
            Mock -CommandName Import-Module -MockWith {} -ModuleName $DSCResourceName
            Mock -CommandName Remove-Module -MockWith {} -ModuleName $DSCResourceName
            Mock -CommandName Get-DSCResource -MockWith {
                @{
                    Path         = 'FilePath'
                    Version      = '1.0'
                    ResourceType = 'XRegistry2'
                    Properties   = @(
                        @{
                            Name         = 'ValueName'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'Key'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'Ensure'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'ValueData'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'ValueType'
                            PropertyType = '[String]'
                        }
                    )
                }
            } -ModuleName $DSCResourceName
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test2'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\test'; ValueData = 'Test String'; ValueType = 'String'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Get-xRegistry2TargetResource -MockWith {return @{Test = 'Test'}}
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = $ResourceName
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'Test2'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\test'
                                                    Ensure    = 'Present'
                                                    ValueData = 'Test String'
                                                    ValueType = 'String'
                                                }"
            }

            $GetResult = & Get-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should return Result' {
                $GetResult.Result | Should Not Be $null
            }
        }

        Context "Calling Get-TargetResource on xRegistry with missing params" {
            function Get-xRegistry2TargetResource {}
            $ResourceName = 'xRegistry2'
            Mock -CommandName Import-Module -MockWith {} -ModuleName $DSCResourceName
            Mock -CommandName Remove-Module -MockWith {} -ModuleName $DSCResourceName
            Mock -CommandName Get-DSCResource -MockWith {
                @{
                    Path         = 'FilePath'
                    Version      = '1.0'
                    ResourceType = 'XRegistry2'
                    Properties   = @(
                        @{
                            Name         = 'ValueName'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'Key'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'Ensure'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'ValueData'
                            PropertyType = '[String]'
                        },
                        @{
                            Name         = 'ValueType'
                            PropertyType = '[String]'
                        }
                    )
                }
            } -ModuleName $DSCResourceName
            Mock -CommandName Test-ParameterValidation -MockWith {throw 'Missing Mandatory parameter'} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test2'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\test'; ValueData = 'Test String'; ValueType = 'String'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Get-xRegistry2TargetResource -MockWith {return @{Test = 'Test'}}
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = $ResourceName
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'Test2'
                                                }"
            }

            It 'Should throw' {
                { & Get-TargetResource @ContextParams } | Should -Throw
            }
        }
    }

    Describe "Test-TargetResource" {
        function Test-xRegistry2TargetResource {}
        Mock -CommandName Import-Module -MockWith {} -ModuleName $DSCResourceName
        Mock -CommandName Remove-Module -MockWith {} -ModuleName $DSCResourceName
        Mock -CommandName Get-DSCResource -MockWith {
            @{
                Path         = 'FilePath'
                Version      = '1.0'
                ResourceType = 'XRegistry2'
                Properties   = @(
                    @{
                        Name         = 'ValueName'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'Key'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'Ensure'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'ValueData'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'ValueType'
                        PropertyType = '[String]'
                    }
                )
            }
        } -ModuleName $DSCResourceName

        Context "Calling Test-TargetResource on xRegistry where Key does not exist" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Test-xRegistry2TargetResource -MockWith {return $false}
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
            }

            $TestResult = & Test-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should return False' {
                $TestResult | Should Be $false
            }
        }

        Context "Calling Test-TargetResource on xRegistry where Key does exist" {
            $ComputerName = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name ComputerName
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueType = 'String'; ValueData = "ComputerName"; ValueName = 'ComputerName'; Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Test-xRegistry2TargetResource -MockWith {return $true}
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'ComputerName'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'
                                                    ValueData = '$($ComputerName.ComputerName)'
                                                    ValueType = 'String'
                                                }"
            }

            $TestResult = & Test-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should return true' {
                $TestResult | Should Be $true
            }
        }

        Context "Calling Test-TargetResource on xRegistry where Key does exist and resource module name is provided" {
            $ComputerName = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name ComputerName
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueType = 'String'; ValueData = "ComputerName"; ValueName = 'ComputerName'; Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Test-xRegistry2TargetResource -MockWith {return $true}
            $ContextParams = @{
                InstanceName       = 'Test'
                ResourceName       = 'xRegistry2'
                ResourceModuleName = 'DscModule'
                ResourceVersion    = '1.0'
                Properties         = "@{
                                                    ValueName = 'ComputerName'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'
                                                    ValueData = '$($ComputerName.ComputerName)'
                                                    ValueType = 'String'
                                                }"
            }

            $TestResult = & Test-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should return true' {
                $TestResult | Should Be $true
            }
        }

        Context "Calling Test-TargetResource on xRegistry missing mandatory params" {
            Mock -CommandName Test-ParameterValidation -MockWith {throw 'Missing Params'} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueType = 'String'; ValueData = "ComputerName"; ValueName = 'ComputerName'; Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Test-xRegistry2TargetResource -MockWith {return $true}
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'ComputerName'
                                                }"
            }

            It 'Should throw' {
                { & Test-TargetResource @ContextParams } | Should -Throw
            }
        }
    }

    Describe "Set-TargetResource" {
        function Set-xRegistry2TargetResource {}
        Mock -CommandName Import-Module -MockWith {} -ModuleName $DSCResourceName
        Mock -CommandName Remove-Module -MockWith {} -ModuleName $DSCResourceName
        Mock -CommandName Get-DSCResource -MockWith {
            @{
                Path         = 'FilePath'
                Version      = '1.0'
                ResourceType = 'XRegistry2'
                Properties   = @(
                    @{
                        Name         = 'ValueName'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'Key'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'Ensure'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'ValueData'
                        PropertyType = '[String]'
                    },
                    @{
                        Name         = 'ValueType'
                        PropertyType = '[String]'
                    }
                )
            }
        } -ModuleName $DSCResourceName

        Context "Calling Set-TargetResource on xRegistry inside maintenace window" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName

            $Windows = @(
                New-CIMWindow -Frequency 'Daily'
            )
            $ContextParams = @{
                InstanceName      = 'Test'
                ResourceName      = 'xRegistry2'
                ResourceVersion   = '1.0'
                Properties        = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
                MaintenanceWindow = $Windows
            }

            & Set-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Set-xRegistryTargetResource once' {
                Assert-MockCalled -CommandName 'Set-xRegistry2TargetResource' -Times 1 -Scope 'Context'
            }

            It 'Should call Test-MaintenanceWindow once' {
                Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }
        }

        Context "Calling Set-TargetResource on xRegistry inside maintenace window and resource module name is provided" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName

            $Windows = @(
                New-CIMWindow -Frequency 'Daily'
            )
            $ContextParams = @{
                InstanceName       = 'Test'
                ResourceName       = 'xRegistry2'
                ResourceModuleName = 'DscModule'
                ResourceVersion    = '1.0'
                Properties         = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
                MaintenanceWindow = $Windows
            }

            & Set-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Set-xRegistryTargetResource once' {
                Assert-MockCalled -CommandName 'Set-xRegistry2TargetResource' -Times 1 -Scope 'Context'
            }

            It 'Should call Test-MaintenanceWindow once' {
                Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }
        }

        Context "Calling Set-TargetResource on xRegistry outside maintenace window" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$false} -ModuleName $DSCResourceName

            $Windows = @(
                New-CIMWindow -Frequency 'Daily'
            )
            $ContextParams = @{
                InstanceName      = 'Test'
                ResourceName      = 'xRegistry2'
                ResourceVersion   = '1.0'
                Properties        = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
                MaintenanceWindow = $Windows
            }

            & Set-TargetResource @ContextParams

            It 'Should not call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 0 -Scope 'Context'
            }

            It 'Should not call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 0 -Scope 'Context'
            }

            It 'Should  not call Set-xRegistryTargetResource once' {
                Assert-MockCalled -CommandName 'Set-xRegistry2TargetResource' -Times 0 -Scope 'Context'
            }

            It 'Should call Test-MaintenanceWindow once' {
                Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }
        }

        Context "Calling Set-TargetResource on xRegistry with no maintenace window" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName

            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
            }

            & Set-TargetResource @ContextParams

            It 'Should call Test-ParameterValidation once' {
                Assert-MockCalled -CommandName 'Test-ParameterValidation' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Get-ValidParameter once' {
                Assert-MockCalled -CommandName 'Get-ValidParameter' -ModuleName $DSCResourceName -Times 1 -Scope 'Context'
            }

            It 'Should call Set-xRegistryTargetResource once' {
                Assert-MockCalled -CommandName 'Set-xRegistry2TargetResource' -Times 1 -Scope 'Context'
            }

            It 'Should not call Test-MaintenanceWindow' {
                Assert-MockCalled -CommandName 'Test-MaintenanceWindow' -ModuleName $DSCResourceName -Times 0 -Scope 'Context'
            }
        }

        Context "Calling Set-TargetResource on xRegistry with missing parameters" {
            Mock -CommandName Test-ParameterValidation -MockWith {throw 'Missing Params'} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName

            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                Properties      = "@{
                                                    ValueName = 'Test'
                                                }"
            }

            It 'Should throw' {
                { & Set-TargetResource @ContextParams } | Should -Throw
            }
        }

        Context "Suppress Reboot equal True" {
            Mock -CommandName Test-ParameterValidation -MockWith {} -Verifiable -ModuleName $DSCResourceName
            Mock -CommandName Get-ValidParameter -MockWith {@{ValueName = 'Test'; Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'}} -ModuleName $DSCResourceName -Verifiable
            Mock -CommandName Set-xRegistry2TargetResource -MockWith {}
            Mock -CommandName Test-MaintenanceWindow -MockWith {$true} -ModuleName $DSCResourceName
            $ContextParams = @{
                InstanceName    = 'Test'
                ResourceName    = 'xRegistry2'
                ResourceVersion = '1.0'
                SuppressReboot  = $true
                Properties      = "@{
                                                    ValueName = 'Test'
                                                    Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\TestRegistryKey'
                                                }"
            }

            $global:DSCMachineStatus = 1
            & Set-TargetResource @ContextParams

            It 'DSCMachineStatus should equal 0' {
                $global:DSCMachineStatus | should be 0
            }
        }
    }

    Describe "Test-MaintenanceWindow" {
        Context "Calling Test-MaintenanceWindow outside of window Daily without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "02")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
                DayofWeek = 'Monday'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Daily with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "31", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
                DayofWeek = 'Monday'
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Weekly without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
                Week      = @(2, 3)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Weekly without DayofWeek" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                Week      = @(2, 3)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Weekly without Week" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "02")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Weekly with Week equal to 0" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "23")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                Week      = '0'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Weekly with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "31", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
                StartTime = "11:00am"
                EndTime   = "11:30am"
                Week      = @(1)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Monthly without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = @(2, 3, 4)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Monthly with last day of the month" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 0
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window Monthly with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "31", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow outside of window before start time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "10", "59", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
                Day       = 1
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Daily without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
                DayofWeek = 'Monday'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Daily without DayofWeek" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Daily with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "25", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Daily'
                DayofWeek = 'Monday'
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Weekly without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
                Week      = @(1, 2, 3)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Weekly with Week equal to 0" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "29")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                Week      = '0'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Weekly without DayofWeek" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "02")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                Week      = @(1)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Weekly without DayofWeek" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "08")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Weekly with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "27", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Weekly'
                DayofWeek = 'Monday'
                StartTime = "11:00am"
                EndTime   = "11:30am"
                Week      = @(1)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Monthly without time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = @(1, 3, 4)
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Monthly with time" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "28", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Monthly with no Day" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01", "11", "28", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window Monthly with last day of the month" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "31", "11", "28", "0")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 0
                StartTime = "11:00am"
                EndTime   = "11:30am"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window but before startdate" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                StartDate = "02-01-2018"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window but after enddate" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                EndDate   = "12-31-2017"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window but after Startdate no enddate" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                StartDate = "12-31-2017"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window but before enddate no startdate" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                EndDate   = "01-31-2018"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window and between start and end date" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                EndDate   = "01-31-2018"
                StartDate = "12-31-2017"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return true' {
                $window | should be $true
            }
        }

        Context "Calling Test-MaintenanceWindow inside of window but not between start and end date" {
            Mock Get-Date {return [DateTime]::new("2018", "01", "01")} -ParameterFilter {$PSBoundParameters.Count -eq 0}
            $ContextParams = @{
                Frequency = 'Monthly'
                Day       = 1
                EndDate   = "01-31-2018"
                StartDate = "01-15-2018"
            }

            $Window = & "Test-MaintenanceWindow" @ContextParams

            It 'Should return false' {
                $window | should be $false
            }
        }
    }

    Describe "Get-ValidParameter" {
        function Test-Function
        {
            [cmdletbinding()]
            param
            (
                [parameter()]
                [string]
                $Key,

                [parameter()]
                [string]
                $ValueName
            )

        }

        Context "Calling Get-ValidParameter with no extra parameters" {

            $ContextParams = @{
                Name   = 'Test-Function'
                Values = @{
                    Key       = "TestRegistryKey"
                    ValueName = ""
                }
            }

            $params = Get-ValidParameter @ContextParams

            It 'Should return 2 params' {
                $params.count | should be 2
            }
        }

        Context "Calling Get-ValidParameter with extra parameters" {

            $ContextParams = @{
                Name   = 'Test-Function'
                Values = @{
                    Key       = "TestRegistryKey"
                    ValueName = ""
                    Extra     = ""
                }
            }

            $params = & "Get-ValidParameter" @ContextParams

            It 'Should return 2 params' {
                $params.Count | should be 2
            }
        }
    }

    Describe "Assert-Validation" {
        $Parameter = [System.Management.Automation.ParameterMetadata]::new("Name", 'string')
        $Parameter.Attributes.Add([System.Management.Automation.ValidateLengthAttribute]::new(1, 3))

        Context "Calling Assert-Validation with value not meeting parameter requirements" {
            $ContextParams = @{
                element           = 'Test'
                ParameterMetadata = $Parameter
            }

            It 'Should throw' {
                { Assert-Validation @ContextParams } | should throw
            }
        }

        Context "Calling Assert-Validation with value meeting parameter requirements" {

            $ContextParams = @{
                element           = 'Yes'
                ParameterMetadata = $Parameter
            }

            It 'Should not throw' {
                { Assert-Validation @ContextParams } | should not throw
            }
        }
    }

    Describe "Test-ParameterValidation" {
        function Test-Function
        {
            [cmdletbinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [string]
                $Key,

                [parameter(Mandatory = $true)]
                [string]
                $ValueName
            )

        }

        Context "Calling Test-ParameterValidation with missing required parameter" {

            $ContextParams = @{
                Name   = 'Test-Function'
                Values = @{
                    Key = "TestRegistryKey"
                }
            }

            It 'Should throw' {
                { Test-ParameterValidation @ContextParams } | should throw
            }
        }

        Context "Calling Test-ParameterValidation with value meeting parameter requirements" {

            $ContextParams = @{
                Name   = 'Test-Function'
                Values = @{
                    Key       = "TestRegistryKey"
                    ValueName = "Test"
                }
            }

            It 'Should not throw' {
                { Test-ParameterValidation @ContextParams } | should not throw
            }
        }
    }

    Describe "ConvertTo-Hashtable" {
        Context "Calling ConvertTo-Hashtable with no credentials" {
            $htParam = @{
                Param1 = 'Value1'
                Param2 = 'Value2'
                Param3 = 'Value3'
            }

            $return = ConvertTo-Hashtable -Hashtable $htParam

            It 'Should return same hashtable' {
                $return.Count  | should be 3
                $return.Param1 | Should be 'Value1'
                $return.Param2 | Should be 'Value2'
                $return.Param3 | Should be 'Value3'
            }
        }

        Context "Calling ConvertTo-Hashtable with credentials" {
            $cred1 = New-CIMCredential -Name 'Credential1' -Username 'User1'
            $cred2 = New-CIMCredential -Name 'Credential2' -Username 'User2'

            $htParam = @{
                Param1 = 'Value1'
                Param2 = '[PSCredential]:Credential1'
                Param3 = '[PSCredential]:Credential2'
            }

            $return = ConvertTo-Hashtable -Hashtable $htParam -Credentials @($cred1, $cred2)

            It 'Should return same hashtable' {
                $return.Count  | should be 3
                $return.Param1 | Should be 'Value1'
                $return.Param2.UserName | Should be 'User1'
                $return.Param2.GetNetworkCredential().Password | Should be 'Password'
                $return.Param3.UserName | Should be 'User2'
                $return.Param3.GetNetworkCredential().Password | Should be 'Password'
            }
        }
    }
}
