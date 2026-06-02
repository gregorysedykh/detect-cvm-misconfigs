from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AzureCMK(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure customer-managed keys are used for encrypting the OS disk of a CVM on Azure"
        id = "AzureCMK"
        supported_resources = ["azurerm_disk_encryption_set"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        
        if "encryption_type" in conf and conf["encryption_type"][0] == "ConfidentialVmEncryptedWithCustomerKey":
            return CheckResult.PASSED
        
        return CheckResult.FAILED


check = AzureCMK()
