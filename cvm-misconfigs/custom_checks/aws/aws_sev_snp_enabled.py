from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AWSSEVSNPEnabled(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure AMD SEV-SNP is enabled for AWS instances"
        id = "AWSSEVSNPEnabled"
        supported_resources = ["aws_instance"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        cpu_options = conf.get("cpu_options")
        if not cpu_options:
            return CheckResult.FAILED

        amd_sev_snp = cpu_options[0].get("amd_sev_snp")
        if amd_sev_snp and amd_sev_snp[0] == "enabled":
            return CheckResult.PASSED

        return CheckResult.FAILED


check = AWSSEVSNPEnabled()
