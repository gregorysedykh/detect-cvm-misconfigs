from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AzureTempDE(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure temporary disk encryption is enabled for a CVM on Azure"
        id = "AzureTempDE"
        supported_resources = ["azurerm_virtual_machine_extension"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        name = conf.get("name")
        if not name or name[0] != "AzureDiskEncryptionForLinux":
            return CheckResult.UNKNOWN

        ext_type = conf.get("type")
        if not ext_type or ext_type[0] != "AzureDiskEncryptionForLinux":
            return CheckResult.FAILED

        settings = conf.get("settings")
        if not settings:
            return CheckResult.FAILED
        if settings[0].get("VolumeType") != "Data":
            return CheckResult.FAILED

        return CheckResult.PASSED
            


check = AzureTempDE()