# BEGIN LICENSE BLOCK
# 
# Copyright (c) 1996-2002 Jesse Vincent <jesse@bestpractical.com>
# 
# (Except where explictly superceded by other copyright notices)
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# 
# Unless otherwise specified, all modifications, corrections or
# extensions to this work which alter its source code become the
# property of Best Practical Solutions, LLC when submitted for
# inclusion in the work.
# 
# 
# END LICENSE BLOCK


PERL			= 	/usr/bin/perl

CONFIG_FILE_PATH	=	/opt/rt3/etc
CONFIG_FILE		= 	$(CONFIG_FILE_PATH)/RT_Config.pm
SITE_CONFIG_FILE		= 	$(CONFIG_FILE_PATH)/RT_SiteConfig.pm


RT_VERSION_MAJOR	=	2
RT_VERSION_MINOR	=	1
RT_VERSION_PATCH	=	57

RT_VERSION =	$(RT_VERSION_MAJOR).$(RT_VERSION_MINOR).$(RT_VERSION_PATCH)
TAG 	   =	rt-$(RT_VERSION_MAJOR)-$(RT_VERSION_MINOR)-$(RT_VERSION_PATCH)


# This is the group that all of the installed files will be chgrp'ed to.
RTGROUP			=	www


# User which should own rt binaries.
BIN_OWNER		=	root

# User that should own all of RT's libraries, generally root.
LIBS_OWNER 		=	root

# Group that should own all of RT's libraries, generally root.
LIBS_GROUP		=	bin

WEB_USER		=	www
WEB_GROUP		=	www

# {{{ Files and directories 

# DESTDIR allows you to specify that RT be installed somewhere other than
# where it will eventually reside

DESTDIR			=	


RT_PATH			=	/opt/rt3
RT_ETC_PATH		=	/opt/rt3/etc
RT_BIN_PATH		=	/opt/rt3/bin
RT_SBIN_PATH		=	/opt/rt3/sbin
RT_LIB_PATH		=	/opt/rt3/lib
RT_MAN_PATH		=	/opt/rt3/man
RT_VAR_PATH		=	/opt/rt3/var
RT_DOC_PATH		=	/opt/rt3/share/doc
RT_LOCAL_PATH		=	/opt/rt3/local
LOCAL_LEXICON_PATH	=	/opt/rt3/local/po
MASON_HTML_PATH		=	/opt/rt3/share/html
MASON_LOCAL_HTML_PATH	=	/opt/rt3/local/html
MASON_DATA_PATH		=	/opt/rt3/var/mason_data
MASON_SESSION_PATH	=	/opt/rt3/var/session_data
RT_LOG_PATH	    =       /opt/rt3/var/log

# RT_READABLE_DIR_MODE is the mode of directories that are generally meant
# to be accessable
RT_READABLE_DIR_MODE	=	0755




# {{{ all these define the places that RT's binaries should get installed

# RT_MODPERL_HANDLER is the mason handler script for mod_perl
RT_MODPERL_HANDLER	=	$(RT_BIN_PATH)/webmux.pl
# RT_FASTCGI_HANDLER is the mason handler script for FastCGI
RT_FASTCGI_HANDLER	=	$(RT_BIN_PATH)/mason_handler.fcgi
# RT_WIN32_FASTCGI_HANDLER is the mason handler script for FastCGI
RT_WIN32_FASTCGI_HANDLER	=	$(RT_BIN_PATH)/mason_handler.svc
# RT's admin CLI
RT_CLI_ADMIN_BIN	=	$(RT_BIN_PATH)/rtadmin
# RT's mail gateway
RT_MAILGATE_BIN		=	$(RT_BIN_PATH)/rt-mailgate
# RT's cron tool
RT_CRON_BIN		=	$(RT_BIN_PATH)/rt-crontool

# }}}

SETGID_BINARIES	 	= 	$(DESTDIR)/$(RT_MAILGATE_BIN) \
				$(DESTDIR)/$(RT_FASTCGI_HANDLER) \
				$(DESTDIR)/$(RT_CLI_ADMIN_BIN)

BINARIES		=	$(DESTDIR)/$(RT_MODPERL_HANDLER) \
				$(DESTDIR)/$(RT_CRON_BIN) \
				$(SETGID_BINARIES)
SYSTEM_BINARIES		=	$(DESTDIR)/$(RT_SBIN_PATH)/


# }}}

# {{{ Database setup

#
# DB_TYPE defines what sort of database RT trys to talk to
# "mysql" is known to work.
# "Pg" is known to work

DB_TYPE			=	mysql

# Set DBA to the name of a unix account with the proper permissions and 
# environment to run your commandline SQL sbin

# Set DB_DBA to the name of a DB user with permission to create new databases 
# Set DB_DBA_PASSWORD to that user's password (if you don't, you'll be prompted
# later)

# For mysql, you probably want 'root'
# For Pg, you probably want 'postgres' 
# For oracle, you want 'system'

DB_HOST			=	localhost

# If you're not running your database server on its default port, 
# specifiy the port the database server is running on below.
# It's generally safe to leave this blank 

DB_PORT			=	

#
# Set this to the canonical name of the interface RT will be talking to the 
# database on.  If you said that the RT_DB_HOST above was "localhost," this 
# should be too. This value will be used to grant rt access to the database.
# If you want to access the RT database from multiple hosts, you'll need
# to grant those database rights by hand.
#

DB_RT_HOST		=	localhost

# set this to the name you want to give to the RT database in 
# your database server. For Oracle, this should be the name of your sid

DB_DATABASE		=	rt3
DB_RT_USER		=	rt_user
DB_RT_PASS		=	rt_pass

# }}}


####################################################################
# No user servicable parts below this line.  Frob at your own risk #
####################################################################

all: default

default:
	@echo "Please read RT's readme before installing. Not doing so could"
	@echo "be dangerous."



instruct:
	@echo "Congratulations. RT has been installed. "
	@echo "Next, you need to initialize RT's database by running" 
	@echo " 'make initialize-database' or by executing "       
	@echo " '$(RT_SBIN_PATH)/rt-setup-database --action init \ "
	@echo "     --dba $(DB_DBA) --prompt-for-dba-password'"
	@echo "You must now configure RT by editing $(SITE_CONFIG_FILE)."
	@echo "From here on in, you should refer to the administrator's guide."


upgrade-instruct: 
	@echo "Congratulations. RT has been upgraded. You should now check-over"
	@echo "$(CONFIG_FILE) for any necessary site customization. Additionally,"
	@echo "you should update RT's system database objects by running "
	@echo "	   $(RT_SBIN_PATH)/rt-update-database <version>"
	@echo "where <version> is the version of RT you're upgrading from."


upgrade: dirs upgrade-noclobber  upgrade-instruct

upgrade-noclobber: libs-install html-install bin-install local-install doc-install fixperms


# {{{ dependencies
testdeps:
	$(PERL) ./sbin/rt-test-dependencies --with-$(DB_TYPE)

fixdeps:
	$(PERL) ./sbin/rt-test-dependencies --install --with-$(DB_TYPE)

#}}}

# {{{ fixperms
fixperms:
	# Make the libraries readable
	chmod $(RT_READABLE_DIR_MODE) $(DESTDIR)/$(RT_PATH)
	chown -R $(LIBS_OWNER) $(DESTDIR)/$(RT_LIB_PATH)
	chgrp -R $(LIBS_GROUP) $(DESTDIR)/$(RT_LIB_PATH)


	chmod $(RT_READABLE_DIR_MODE) $(DESTDIR)/$(RT_BIN_PATH)
	chmod $(RT_READABLE_DIR_MODE) $(DESTDIR)/$(RT_BIN_PATH)	

	chmod 0755 $(DESTDIR)/$(RT_ETC_PATH)
	chmod 0500 $(DESTDIR)/$(RT_ETC_PATH)/*

	#TODO: the config file should probably be able to have its
	# owner set seperately from the binaries.
	chown -R $(BIN_OWNER) $(DESTDIR)/$(RT_ETC_PATH)
	chgrp -R $(RTGROUP) $(DESTDIR)/$(RT_ETC_PATH)

	chmod 0550 $(DESTDIR)/$(CONFIG_FILE)
	chmod 0550 $(DESTDIR)/$(SITE_CONFIG_FILE)

	# Make the interfaces executable and setgid rt
	chown $(BIN_OWNER) $(SETGID_BINARIES)
	chgrp $(RTGROUP) $(SETGID_BINARIES)
	chmod 0755  $(SETGID_BINARIES)
	chmod g+s $(SETGID_BINARIES)

	# Make the web ui readable by all. 
	chmod -R  u+rwX,go-w,go+rX 	$(DESTDIR)/$(MASON_HTML_PATH) \
					$(DESTDIR)/$(MASON_LOCAL_HTML_PATH) \
					$(DESTDIR)/$(LOCAL_LEXICON_PATH)
	chown -R $(LIBS_OWNER) 	$(DESTDIR)/$(MASON_HTML_PATH) \
				$(DESTDIR)/$(MASON_LOCAL_HTML_PATH)
	chgrp -R $(LIBS_GROUP) 	$(DESTDIR)/$(MASON_HTML_PATH) \
				$(DESTDIR)/$(MASON_LOCAL_HTML_PATH)

	# Make the web ui's data dir writable
	chmod 0770  	$(DESTDIR)/$(MASON_DATA_PATH) \
			$(DESTDIR)/$(MASON_SESSION_PATH)
	chown -R $(WEB_USER) 	$(DESTDIR)/$(MASON_DATA_PATH) \
				$(DESTDIR)/$(MASON_SESSION_PATH)
	chgrp -R $(WEB_GROUP) 	$(DESTDIR)/$(MASON_DATA_PATH) \
				$(DESTDIR)/$(MASON_SESSION_PATH)
# }}}

fixperms-nosetgid: fixperms
	@echo "You should never be running RT this way. it's unsafe"
	chmod 0555 $(SETGID_BINARIES)
	chmod 0555 $(DESTDIR)/$(CONFIG_FILE)

# {{{ dirs
dirs:
	mkdir -p $(DESTDIR)/$(RT_LOG_PATH)
	mkdir -p $(DESTDIR)/$(MASON_DATA_PATH)
	mkdir -p $(DESTDIR)/$(MASON_DATA_PATH)/cache
	mkdir -p $(DESTDIR)/$(MASON_DATA_PATH)/etc
	mkdir -p $(DESTDIR)/$(MASON_DATA_PATH)/obj
	mkdir -p $(DESTDIR)/$(MASON_SESSION_PATH)
	mkdir -p $(DESTDIR)/$(MASON_HTML_PATH)
	mkdir -p $(DESTDIR)/$(MASON_LOCAL_HTML_PATH)
	mkdir -p $(DESTDIR)/$(LOCAL_LEXICON_PATH)
# }}}

install: config-install dirs files-install fixperms instruct

files-install: libs-install etc-install bin-install sbin-install html-install local-install doc-install

config-install:
	mkdir -p $(DESTDIR)/$(CONFIG_FILE_PATH)	
	cp etc/RT_Config.pm $(DESTDIR)/$(CONFIG_FILE)
	[ -f $(DESTDIR)/$(SITE_CONFIG_FILE) ] || cp etc/RT_SiteConfig.pm $(DESTDIR)/$(SITE_CONFIG_FILE) 

	chgrp $(RTGROUP) $(DESTDIR)/$(CONFIG_FILE)
	chown $(BIN_OWNER) $(DESTDIR)/$(CONFIG_FILE)

	chgrp $(RTGROUP) $(DESTDIR)/$(SITE_CONFIG_FILE)
	chown $(BIN_OWNER) $(DESTDIR)/$(SITE_CONFIG_FILE)

	@echo "Installed configuration. about to install rt in  $(RT_PATH)"

test: 
	$(PERL) -Ilib lib/t/00smoke.t

regression-nosetgid: config-install dirs files-install libs-install sbin-install bin-install regression-instruct regression-reset-db  testify-pods fixperms-nosetgid apachectl
	$(PERL) lib/t/02regression.t

regression: config-install dirs files-install libs-install sbin-install bin-install regression-instruct regression-reset-db  testify-pods apachectl
	$(PERL) lib/t/02regression.t

regression-quiet:
	$(PERL) sbin/regression_harness

regression-instruct:
	@echo "About to wipe your database for a regression test. ABORT NOW with Control-C"


# {{{ database-installation

regression-reset-db:
	$(PERL)	$(DESTDIR)/$(RT_SBIN_PATH)/rt-setup-database --action drop --dba root --dba-password ''
	$(PERL) $(DESTDIR)/$(RT_SBIN_PATH)/rt-setup-database --action init --dba root --dba-password ''

initialize-database: 
	$(PERL) $(DESTDIR)/$(RT_SBIN_PATH)/rt-setup-database --action init --dba root --prompt-for-dba-password

dropdb: 
	$(PERL)	$(DESTDIR)/$(RT_SBIN_PATH)/rt-setup-database --action drop --dba root --prompt-for-dba-password

insert-approval-data: 
	$(PERL) $(DESTDIR)/$(RT_SBIN_PATH)/insert_approval_scrips
# }}}

# {{{ libs-install
libs-install: 
	[ -d $(DESTDIR)/$(RT_LIB_PATH) ] || mkdir $(DESTDIR)/$(RT_LIB_PATH)
	chown -R $(LIBS_OWNER) $(DESTDIR)/$(RT_LIB_PATH)
	chgrp -R $(LIBS_GROUP) $(DESTDIR)/$(RT_LIB_PATH)
	chmod -R $(RT_READABLE_DIR_MODE) $(DESTDIR)/$(RT_LIB_PATH)
	cp -rp lib/* $(DESTDIR)/$(RT_LIB_PATH)
# }}}

# {{{ html-install
html-install:
	cp -rp ./html/* $(DESTDIR)/$(MASON_HTML_PATH)
# }}}

# {{{ doc-install
doc-install:
	cp -rp ./README $(DESTDIR)/$(RT_DOC_PATH)
# }}}

# {{{ etc-install

etc-install:
	mkdir -p $(DESTDIR)/$(RT_ETC_PATH)
	cp -rp \
		etc/acl.* \
		etc/initialdata \
		etc/schema.* \
		$(DESTDIR)/$(RT_ETC_PATH)
# }}}

# {{{ sbin-install

sbin-install:
	mkdir -p $(DESTDIR)/$(RT_SBIN_PATH)
	cp -rp \
		sbin/rt-setup-database \
		sbin/rt-test-dependencies \
		sbin/insert_approval_scrips \
		$(DESTDIR)/$(RT_SBIN_PATH)
# }}}

# {{{ bin-install

bin-install:
    	# FIXME: fixperm here
	mkdir -p $(DESTDIR)/$(RT_BIN_PATH)
	cp -rp \
		bin/rtadmin \
		bin/rt-mailgate \
		bin/enhanced-mailgate \
		bin/mason_handler.fcgi \
		bin/mason_handler.svc \
		bin/webmux.pl \
		bin/rt-crontool \
		bin/rt-commit-handler \
		$(DESTDIR)/$(RT_BIN_PATH)
# }}}

# {{{ local-install
local-install:
	-cp -rp ./local/html/* $(DESTDIR)/$(MASON_LOCAL_HTML_PATH)
	-cp -rp ./local/po/* $(DESTDIR)/$(LOCAL_LEXICON_PATH)
# }}}

# {{{ Best Practical Build targets -- no user servicable parts inside


POD2TEST_EXE = sbin/extract_pod_tests

testify-pods:
	[ -d lib/t/autogen ] || mkdir lib/t/autogen
	find lib -name \*pm |grep -v \*.in |xargs -n 1 $(PERL) $(POD2TEST_EXE)
	find bin -type f |grep -v \~ | grep -v "\.in" | xargs -n 1 $(PERL) $(POD2TEST_EXE)



regenerate-catalogs:
	$(PERL) sbin/extract-message-catalog

license-tag:
	$(PERL) sbin/license_tag

factory: initialize-database
	cd lib; $(PERL) ../sbin/factory  $(DB_DATABASE) RT

commit:
	aegis -build ; aegis -diff ; aegis -test; aegis -develop_end

integrate:
	aegis -integrate_begin;	aegis -build; aegis -diff; aegis -test ; aegis -integrate_pass

predist: commit tag-and-tar

tag-and-release-baseline:
	aegis -cp -ind Makefile -output /tmp/Makefile.tagandrelease; \
	$(MAKE) -f /tmp/Makefile.tagandrelease tag-and-release-never-by-hand


# Running this target in a working directory is 
# WRONG WRONG WRONG.
# it will tag the current baseline with the version of RT defined 
# in the currently-being-worked-on makefile. which is wrong.
#  you want tag-and-release-baseline

tag-and-release-never-by-hand:
	aegis --delta-name $(TAG)
	rm -rf /tmp/$(TAG)
	mkdir /tmp/$(TAG)
	cd /tmp/$(TAG); \
		aegis -cp -ind -delta $(TAG) . ;\
		make reconfigure;\
		chmod 600 Makefile;\
		aegis --report --project rt.$(RT_VERSION_MAJOR) \
		      --page_width 80 \
		      --page_length 9999 \
		      --change $(RT_VERSION_MINOR) --output Changelog Change_Log

	cd /tmp; tar czvf /home/ftp/pub/rt/devel/$(TAG).tar.gz $(TAG)/
	chmod 644 /home/ftp/pub/rt/devel/$(TAG).tar.gz


reconfigure:
	aclocal -I m4
	autoconf
	chmod 755 ./configure
	./configure

rpm:
	(cd ..; tar czvf /usr/src/redhat/SOURCES/rt.tar.gz rt)
	rpm -ba etc/rt.spec


apachectl:
	/usr/sbin/apachectl stop
	sleep 1
	/usr/sbin/apachectl start
# }}}
