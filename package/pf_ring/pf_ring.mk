################################################################################
#
# pf_ring
#
################################################################################

PF_RING_VERSION = 7.4.0-stable
PF_RING_SITE = $(call github,ntop,PF_RING,$(PF_RING_VERSION))
PF_RING_LICENSE = LGPL-2.1
PF_RING_LICENSE_FILES = LICENSE
PF_RING_MODULE_SUBDIRS = kernel
PF_RING_INSTALL_STAGING = YES

define PF_RING_CONFIGURE_CMDS
	cd $(@D)/userland; autoreconf -ivf ; \
		$(TARGET_MAKE_ENV) ./configure \
		--host=$(GNU_HOST_NAME) \
		$(TARGET_CONFIGURE_OPTS)
endef

define PF_RING_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) \
		AR="$(TARGET_AR)" CC="$(TARGET_CC)" RANLIB="$(TARGET_RANLIB)" \
		-C $(@D)/userland/lib
	cd $(@D)/userland/libpcap; \
	./configure --enable-ipv6 --enable-dbus=no --without-libnl \
	--with-snf=no --disable-bluetooth --disable-canusb --with-dag=no;\
	$(TARGET_MAKE_ENV) $(MAKE1) \
		AR="$(TARGET_AR)" CC="$(TARGET_CC)" RANLIB="$(TARGET_RANLIB)" \
		-C $(@D)/userland/libpcap
	$(TARGET_MAKE_ENV) $(MAKE1) \
		AR="$(TARGET_AR)" CC="$(TARGET_CC)" RANLIB="$(TARGET_RANLIB)" \
		-C $(@D)/userland/examples
endef

define PF_RING_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 644 $(@D)/kernel/linux/pf_ring.h \
		$(STAGING_DIR)/usr/include/linux/pf_ring.h
	$(INSTALL) -D -m 644 $(@D)/userland/lib/pfring.h \
		$(STAGING_DIR)/usr/include/pfring.h
	$(INSTALL) -D -m 644 $(@D)/userland/lib/libpfring.a \
		$(STAGING_DIR)/usr/lib/libpfring.a
	$(INSTALL) -D -m 644 $(@D)/userland/libpcap/libpcap.a \
		$(STAGING_DIR)/usr/lib/libpcap.a
endef

define PF_RING_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfcount $(TARGET_DIR)/usr/bin/pfcount
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfcount_multichannel $(TARGET_DIR)/usr/bin/pfcount_multichannel
	$(INSTALL) -m 0755 $(@D)/userland/examples/preflect $(TARGET_DIR)/usr/bin/preflect
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfbridge $(TARGET_DIR)/usr/bin/pfbridge
	$(INSTALL) -m 0755 $(@D)/userland/examples/alldevs $(TARGET_DIR)/usr/bin/alldevs
	$(INSTALL) -m 0755 $(@D)/userland/examples/pcap2nspcap $(TARGET_DIR)/usr/bin/pcap2nspcap
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfcount_82599 $(TARGET_DIR)/usr/bin/pfcount_82599
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfsystest $(TARGET_DIR)/usr/bin/pfsystest
	$(INSTALL) -m 0755 $(@D)/userland/examples/pfsend $(TARGET_DIR)/usr/bin/pfsend
	$(INSTALL) -m 0755 $(@D)/userland/examples/pflatency $(TARGET_DIR)/usr/bin/pflatency
endef

$(eval $(kernel-module))
$(eval $(generic-package))
