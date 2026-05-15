from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


#   SEV_SNP: N2D (AMD EPYC Milan)
#   TDX:     C3  (Intel Sapphire Rapids)
#   TDX and Nvidia: a3-highgpu-1g

_TYPE_TO_PREFIXES = {
    "SEV_SNP": ("n2d-",),
    "TDX": ("c3-", "a3-highgpu-1g-"),
}


class GCPMachineTypeCVMCompatible(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure GCP machine type is compatible with the chosen confidential instance type"
        id = "GCPMachineTypeCVMCompatible"
        supported_resources = ["google_compute_instance"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        confidential_instance_config = conf.get("confidential_instance_config")
        if not confidential_instance_config:
            return CheckResult.UNKNOWN

        confidential_instance_type = confidential_instance_config[0].get("confidential_instance_type")
        if not confidential_instance_type:
            return CheckResult.UNKNOWN

        cit = confidential_instance_type[0]
        allowed_prefixes = _TYPE_TO_PREFIXES.get(cit)
        if not allowed_prefixes:
            return CheckResult.UNKNOWN

        machine_type = conf.get("machine_type")
        if not machine_type:
            return CheckResult.FAILED

        mt = machine_type[0]
        if any(mt.startswith(p) for p in allowed_prefixes):
            return CheckResult.PASSED

        return CheckResult.FAILED


check = GCPMachineTypeCVMCompatible()
