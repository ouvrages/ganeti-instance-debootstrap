osname=$(subst ganeti-instance-,,$(PACKAGE))

osdir=$(OS_DIR)/$(osname)

os_SCRIPTS = create
dist_os_SCRIPTS = import export rename
dist_os_DATA = ganeti_api_version

dist_doc_DATA = COPYING NEWS README

EXTRA_DIST = create.in defaults

do_subst = sed \
	-e 's,[@]sysconfdir[@],$(sysconfdir),g' \
	-e 's,[@]localstatedir[@],$(localstatedir),g'

create: create.in Makefile
	$(do_subst) < $< > $@
	chmod +x $@

CLEANFILES = create
