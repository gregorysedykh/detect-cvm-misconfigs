from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class GCPCMK(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure disks use customer-managed encryption keys (CMEK) for encryption at rest"
        id = "GCPCMK"
        supported_resources = ["google_compute_disk"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:
        
        if 'disk_encryption_key' in conf and isinstance(conf['disk_encryption_key'], list):
            encryption_block = conf['disk_encryption_key'][0]
            
            if 'kms_key_self_link' in encryption_block and encryption_block['kms_key_self_link']:
                return CheckResult.PASSED
                
        return CheckResult.FAILED

check = GCPCMK()
