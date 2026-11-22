include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-webrtc-guard
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-webrtc-guard
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=JianxianApp WebRTC Leak Guard
  DEPENDS:=+luci-base +firewall4 +nftables
  PKGARCH:=all
endef

define Package/luci-app-webrtc-guard/description
 LuCI smart WebRTC STUN/TURN UDP leak mitigation for OpenWrt.
endef

define Package/luci-app-webrtc-guard/install
	$(CP) ./root/. $(1)/
	$(INSTALL_DIR) $(1)/usr/share/licenses/luci-app-webrtc-guard
	$(INSTALL_DATA) $(TOPDIR)/LICENSE $(1)/usr/share/licenses/luci-app-webrtc-guard/LICENSE
	$(INSTALL_BIN) ./root/etc/init.d/webrtc_guard $(1)/etc/init.d/webrtc_guard
	$(INSTALL_BIN) ./root/usr/libexec/webrtc_guard $(1)/usr/libexec/webrtc_guard
endef

$(eval $(call BuildPackage,luci-app-webrtc-guard))
