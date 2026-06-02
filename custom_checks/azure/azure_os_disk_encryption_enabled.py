from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AzureOSDiskEncryptionType(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure OS disk security encryption type is set to \"DiskWithVMGuestState\" for Azure CVMs"
        id = "AzureOSDiskEncryptionType"
        supported_resources = [
            "azurerm_linux_virtual_machine",
            "azurerm_windows_virtual_machine",
        ]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        os_disk = conf.get("os_disk")
        if not os_disk or not isinstance(os_disk, list) or not os_disk[0]:
            return CheckResult.FAILED

        os_disk_conf = os_disk[0]
        if not isinstance(os_disk_conf, dict):
            return CheckResult.FAILED

        security_encryption_type = os_disk_conf.get("security_encryption_type")
        if security_encryption_type and security_encryption_type[0] == "DiskWithVMGuestState":
            return CheckResult.PASSED

        return CheckResult.FAILED


check = AzureOSDiskEncryptionType()
