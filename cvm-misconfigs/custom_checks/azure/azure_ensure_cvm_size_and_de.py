from checkov.common.models.enums import CheckCategories, CheckResult
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck

# Valid vCPU counts per CVM series family
# DC-Series (General purpose)
_DC_V5_VCPUS = (2, 4, 8, 16, 32, 48, 64, 96)
_DC_V6A_VCPUS = (2, 4, 8, 16, 32, 48, 64, 96)        # as, ads subfamilies
_DC_V6E_VCPUS = (2, 4, 8, 16, 32, 48, 64, 96, 128)   # es, eds subfamilies

# EC-Series (Memory optimised)
_EC_V5_VCPUS = (2, 4, 8, 16, 20, 32, 48, 64, 96)
_EC_V6A_VCPUS = (2, 4, 8, 16, 32, 48, 64, 96)        # as, ads subfamilies
_EC_V6E_VCPUS = (2, 4, 8, 16, 32, 48, 64)            # es, eds subfamilies

_CVM_FAMILIES = [
    # (prefix, subfamilies, version, vcpu_counts)
    # DC-Series
    ("DC", ("as", "ads"), 5, _DC_V5_VCPUS),
    ("DC", ("as", "ads"), 6, _DC_V6A_VCPUS),
    ("DC", ("es", "eds"), 6, _DC_V6E_VCPUS),
    # EC-Series
    ("EC", ("as", "ads"), 5, _EC_V5_VCPUS),
    ("EC", ("as", "ads"), 6, _EC_V6A_VCPUS),
    ("EC", ("es", "eds"), 6, _EC_V6E_VCPUS),
]

VALID_CVM_SIZES: set[str] = set()
for _prefix, _subs, _ver, _vcpus in _CVM_FAMILIES:
    for _sub in _subs:
        for _n in _vcpus:
            VALID_CVM_SIZES.add(f"Standard_{_prefix}{_n}{_sub}_v{_ver}")

# EC v5 isolated variants
VALID_CVM_SIZES.add("Standard_EC96ias_v5")
VALID_CVM_SIZES.add("Standard_EC96iads_v5")

# NCC-Series (GPU)
VALID_CVM_SIZES.add("Standard_NCC40ads_H100_v5")


class AzureEnsureCVMSizeAndDE(BaseResourceCheck):
    def __init__(self) -> None:
        name = "Ensure CVM size and disk encryption are properly configured"
        id = "AzureEnsureCVMSizeAndDE"
        supported_resources = [
            "azurerm_linux_virtual_machine",
            "azurerm_windows_virtual_machine",
        ]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(
            name=name,
            id=id,
            categories=categories,
            supported_resources=supported_resources,
        )

    def scan_resource_conf(self, conf: dict[str, list]) -> CheckResult:

        vm_size = conf.get("size")
        if not vm_size or not isinstance(vm_size, list) or not vm_size[0]:
            return CheckResult.FAILED

        if vm_size[0] not in VALID_CVM_SIZES:
            self.details.append(f"Invalid CVM size: {vm_size[0]}. Must be one of: {', '.join(sorted(VALID_CVM_SIZES))}")
            return CheckResult.FAILED

        os_disk = conf.get("os_disk")
        if not os_disk or not isinstance(os_disk, list) or not os_disk[0]:
            return CheckResult.FAILED

        os_disk_conf = os_disk[0]
        if not isinstance(os_disk_conf, dict):
            return CheckResult.FAILED

        security_encryption_type = os_disk_conf.get("security_encryption_type")
        if not security_encryption_type:
            self.details.append("OS disk security encryption type is not specified.")
            return CheckResult.FAILED

        return CheckResult.PASSED


check = AzureEnsureCVMSizeAndDE()
