# ResourceControllerDSC

master: [![Build status](https://ci.appveyor.com/api/projects/status/qghpa6k5dfmc05i0/branch/master?svg=true)](https://ci.appveyor.com/project/mcollera/resourcecontrollerdsc/branch/master)

dev: [![Build status](https://ci.appveyor.com/api/projects/status/qghpa6k5dfmc05i0/branch/dev?svg=true)](https://ci.appveyor.com/project/mcollera/resourcecontrollerdsc/branch/dev)

The **ResourceControllerDSC** module allows you to control other DSC resources by adding an Effective date and duration so Set-TargetResource will only run during that window.
Also allows you to supress a reboot when a resource will not.

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

* [**ResourceController**](#ResourceController): Provides the ability to add a maintenance window and supress reboots.

### **ResourceController**

* **[String] InstanceName** _(Key)_: A unique name to give the resource.

* **[String] ResourceName**: The name of the resource you want to run.

* **[Hashtable] Properties:** The properties you want to pass to the resource you want to run.

* **[DateTime] EffectiveDate:** The start date you allow the resource to run

* **[int] Duration:** The time in hours you want the resource to run for.

* **[bool] SupressReboot:** Whether you should supress a forced reboot. _{ True | False }_

#### ResourceController Examples

* [ResourceController Examples](
  https://github.com/mcollera/ResourceControllerDsc/blob/master/Examples/ResourceController_Examples.ps1)

## Versions

### 1.0.0.0

* Initial release with the following resources:

  * ResourceController