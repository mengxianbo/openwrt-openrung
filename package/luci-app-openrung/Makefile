include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-openrung
PKG_VERSION:=0.1.0
PKG_RELEASE:=1
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-openrung
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=OpenRung LuCI application
  DEPENDS:=+luci-base +openrung-client
  LICENSE:=GPL-3.0-or-later
endef

define Package/luci-app-openrung/description
 Chinese LuCI configuration and status page for OpenRung.
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/luci-app-openrung/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/openrung
	$(INSTALL_DATA) ./controller.lua $(1)/usr/lib/lua/luci/controller/openrung.lua
	$(INSTALL_DATA) ./openrung.lua $(1)/usr/lib/lua/luci/model/cbi/openrung/main.lua
	$(INSTALL_DIR) $(1)/usr/share/licenses/luci-app-openrung
	$(INSTALL_DATA) $(TOPDIR)/LICENSE $(1)/usr/share/licenses/luci-app-openrung/LICENSE
endef

$(eval $(call BuildPackage,luci-app-openrung))
