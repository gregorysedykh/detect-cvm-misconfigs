from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class GCPSNPOrTDXEnabled(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure that GCP virtual machines have either AMD SEV-SNP or Intel TDX enabled"
        id = "GCPSNPOrTDXEnabled"
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

        confidential_instance_type = shielded_instance_config[0].get("confidential_instance_type")
        if confidential_instance_type and confidential_instance_type[0] in ["SEV_SNP", "TDX"]:
            return CheckResult.PASSED

        return CheckResult.FAILED


check = GCPSNPOrTDXEnabled()
