# ResourceControllerDSC

master: [![Build status](https://ci.appveyor.com/api/projects/status/qghpa6k5dfmc05i0/branch/master?svg=true)](https://ci.appveyor.com/project/mcollera/resourcecontrollerdsc/branch/master)

dev: [![Build status](https://ci.appveyor.com/api/projects/status/qghpa6k5dfmc05i0/branch/dev?svg=true)](https://ci.appveyor.com/project/mcollera/resourcecontrollerdsc/branch/dev)

The **ResourceControllerDSC** module allows you to control other DSC resources by adding a Maintenance Window so Set-TargetResource will only run during that window.
Also allows you to supress a reboot when a resource does not have the option.

This project has adopted the [Microsoft Open Source Code of Conduct](
  https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](
  https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions
or comments.

## Contributing

Please check out common DSC Resources [contributing guidelines](
  https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Resources

* [**ResourceController**](#ResourceController): Provides the ability to add a maintenance window and supress reboots. Maintenance windows and Supress reboots only effect Set-TargetResource. Get and Test will always run for reporting.

### **ResourceController**

* **[String] InstanceName** _(Key)_: A unique name to give the resource.

* **[String] ResourceName**: The name of the resource you want to run.

* **[String] ResourceModuleName**: (Optional) The name of the resource module that contains the resource you want to run.

* **[Scriptblock] Properties:** A Scriptblock that returns a Hashtable of the properties for the resource you are calling.

* **[Credential] Credentials:** Credentials you want to use as properties in the Properties Scriptblock.
    * **[String] Name:** The name of the credential. Used to reference the credential in the properties.
    * **[PSCredential] Credential:** The Credential object.

* **[MaintenanceWindow] MaintenanceWindow:** Object representing a maintenance window
    DaysofWeek
    Week
    Days
    * **[string] Frequency:** The frequency the schedule should run. _{ Daily | Weekly | Monthly }_
    * **[DateTime] StartTime:** The start time the resource is aloud to run Set-TargetResource when the day is inside the maintenance window
    * **[DateTime ] EndTime:** The end time the resource is aloud to run Set-TargetResource when the day is inside the maintenance window
    * **[DateTime] StartDate:** The date the resource is aloud to run Set-TargetResource.
    * **[DateTime] EndDate:** The date the resource will no longer run Set-TargetResource.
    * **[String[]] DaysofWeek:** The days of week Set-TargetResource will run. _{ Sunday | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday }_
    * **[int[] Week:** The week in the month you want Set-TargetResource to run. {0} represents the last week of the month. _{ 0 | 1 | 2 | 3 | 4 }_
    * **[int[]] Days:** The day in the month you want Set-TargetResource to run. {0} represents the last day of the month. _{ 0-31 }_

* **[bool] SupressReboot:** Whether you should supress a forced reboot. _{ True | False }_

#### ResourceController Examples

* [ResourceController Examples](
  https://github.com/mcollera/ResourceControllerDsc/blob/master/Examples/ResourceController_Examples.ps1)

## Versions
### 2.0.2
  * Added optional resource module name parameter to decrease resource import time during execution.

### 2.0.1
  * Removed parameter validation to avoid potential issues with ValidateScript

### 2.0.0
  * Added Credential object to use in the properties.
  * Converted Properties from a Hashtable to a Scriptblock so it can handle more object types like arrays. If     you want to use a PsCredential then you set the value to [PsCredential]:< Name>. This will replace that        string with the credential object matching the name of the credential passed in the Credential parameter.

### 1.3.1
  Converted resource parameters to there desired type.

### 1.3
  Breaking Change: Fixed variable names in DSCResource

### 1.2
  Breaking Change: Add ResourceVersion to support systems with multiple versions installed.

### 1.1

* Fixed bug: Test-MaintenanceWindow would fail if one Maintenance Window of an array of windows was outside the window.

### 1.0.0.0

* Initial release with the following resources:

  * ResourceController
