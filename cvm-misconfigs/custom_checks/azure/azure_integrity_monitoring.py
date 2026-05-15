from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AzureIntegrityMonitoring(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure Azure VM Guest Attestation extension is correctly configured for boot integrity monitoring"
        id = "AzureIntegrityMonitoring"
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
        if not name or name[0] != "GuestAttestation":
            return CheckResult.UNKNOWN

        ext_type = conf.get("type")
        if not ext_type or ext_type[0] != "GuestAttestation":
            return CheckResult.FAILED

        publisher = conf.get("publisher")
        valid_publishers = {
            "Microsoft.Azure.Security.LinuxAttestation",
            "Microsoft.Azure.Security.WindowsAttestation",
        }
        if not publisher or publisher[0] not in valid_publishers:
            return CheckResult.FAILED

        type_handler_version = conf.get("type_handler_version")
        if not type_handler_version or not type_handler_version[0]:
            return CheckResult.FAILED

        return CheckResult.PASSED


check = AzureIntegrityMonitoring()
