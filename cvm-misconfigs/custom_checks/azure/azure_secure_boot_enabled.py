from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AzureSecureBootEnabled(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure Secure Boot is enabled for Azure virtual machines"
        id = "AzureEnsureSecureBootEnabled"
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
        secure_boot_enabled = conf.get("secure_boot_enabled")
        if secure_boot_enabled and secure_boot_enabled[0] is True:
            return CheckResult.PASSED
        return CheckResult.FAILED


check = AzureSecureBootEnabled()
