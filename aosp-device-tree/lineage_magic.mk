#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from magic device
$(call inherit-product, device/unknown/magic/device.mk)

PRODUCT_DEVICE := magic
PRODUCT_NAME := lineage_magic
PRODUCT_BRAND := Honor
PRODUCT_MODEL := magic
PRODUCT_MANUFACTURER := unknown

PRODUCT_GMS_CLIENTID_BASE := android-unknown

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="magic-user 14 UP1A.231005.007 eng.root.20241122.113301 release-keys"

BUILD_FINGERPRINT := Honor/magic/magic:14/UP1A.231005.007/root11221130:user/release-keys
