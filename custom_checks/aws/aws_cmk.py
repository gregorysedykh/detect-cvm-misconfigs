from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class AWSCMK(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure customer-managed keys are used for the root EBS volume of a VM on AWS"
        id = "AWSCMK"
        supported_resources = ["aws_instance"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        if "root_block_device" in conf:
            root_block_device = conf["root_block_device"][0]
            if "kms_key_id" in root_block_device:
                return CheckResult.PASSED
        
        return CheckResult.FAILED
        


check = AWSCMK()
