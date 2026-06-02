from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class GCPVTPMEnabled(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure vTPM is enabled for GCP virtual machines"
        id = "GCPVTPMEnabled"
        supported_resources = ["google_compute_instance"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        shielded_instance_config = conf.get("shielded_instance_config")
        if not shielded_instance_config:
            return CheckResult.FAILED

        enable_vtpm = shielded_instance_config[0].get("enable_vtpm")
        if enable_vtpm and enable_vtpm[0] is True:
            return CheckResult.PASSED

        return CheckResult.FAILED


check = GCPVTPMEnabled()
