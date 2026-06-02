from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AWSAMISecureBoot(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure AWS instance enforces Secure Boot via lifecycle precondition"
        id = "AWSAMISecureBoot"
        supported_resources = ["aws_instance"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict) -> CheckResult:
        lifecycle = conf.get("lifecycle")
        if not lifecycle:
            return CheckResult.FAILED

        preconditions = lifecycle[0].get("precondition", []) if isinstance(lifecycle, list) else []
        for pc in preconditions:
            condition = pc.get("condition", [""])[0] if isinstance(pc.get("condition"), list) else pc.get("condition", "")
            if "uefi_data" in str(condition):
                return CheckResult.PASSED

        return CheckResult.FAILED


check = AWSAMISecureBoot()
