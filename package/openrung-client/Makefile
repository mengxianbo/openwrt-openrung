include $(TOPDIR)/rules.mk

PKG_NAME:=openrung-client
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/openrung-client
  SECTION:=net
  CATEGORY:=Network
  TITLE:=OpenRung CLI client
  URL:=https://github.com/openrung/openrung
  LICENSE:=GPL-3.0-or-later
endef

define Package/openrung-client/description
 OpenRung client for the selected OpenWrt SDK target with OpenWrt procd service integration.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/. $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/openrung-client/conffiles
/etc/config/openrung
endef

define Package/openrung-client/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
if [ -x /etc/init.d/openrung ]; then
  /etc/init.d/openrung enable
  if [ "$$(uci -q get openrung.main.enabled)" = "1" ]; then
    /etc/init.d/openrung restart
  fi
fi
exit 0
endef

define Package/openrung-client/install
	$(INSTALL_DIR) $(1)/usr/libexec $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openrung-client.bin $(1)/usr/libexec/openrung-client.bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openrung-client-wrapper $(1)/usr/bin/openrung-client
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/openrung.config $(1)/etc/config/openrung
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openrung.init $(1)/etc/init.d/openrung
	$(INSTALL_DIR) $(1)/usr/share/openrung
	$(INSTALL_DATA) $(TOPDIR)/DISTRIBUTION-NOTICE-ADDENDUM.md $(1)/usr/share/openrung/DISTRIBUTION-NOTICE-ADDENDUM.md
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/openrung/LICENSE
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/COPYRIGHT.md $(1)/usr/share/openrung/COPYRIGHT.md
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/THIRD_PARTY_NOTICES.md $(1)/usr/share/openrung/THIRD_PARTY_NOTICES.md
	$(INSTALL_DIR) $(1)/usr/share/openrung/licenses/third-party
	$(CP) $(PKG_BUILD_DIR)/licenses/third-party/. $(1)/usr/share/openrung/licenses/third-party/
endef

$(eval $(call BuildPackage,openrung-client))
