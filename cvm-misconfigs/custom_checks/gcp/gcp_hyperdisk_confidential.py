from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class GCPHyperdiskConfidentialMode(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure disks used with confidential computing are Hyperdisk balanced with Confidential mode enabled"
        id = "GCPHyperdiskConfidentialMode"
        supported_resources = ["google_compute_disk"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        
        if "type" in conf and conf["type"][0] != "hyperdisk-balanced":
            return CheckResult.FAILED
        if "enable_confidential_compute" in conf and conf["enable_confidential_compute"][0] is True:
            return CheckResult.PASSED

        return CheckResult.FAILED


check = GCPHyperdiskConfidentialMode
