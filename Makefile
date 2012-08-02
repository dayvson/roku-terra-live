#
# Copyright (c) 2012 - Maxwell Dayvson <dayvson@gmail.com>
# Copyright (c) 2012 - Marco Lovato <marco.lovato@gmail.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#########################################################################
# common include file for application Makefiles
#
# Makefile Usage:
# > make
# > make install
# > make remove
#
# Important Notes: 
# To use the "install" and "remove" targets to install your
# application directly from the shell, you must do the following:
#
# 1) Make sure that you have the curl command line executable in your path
# 2) Set the variable ROKU_DEV_TARGET in your environment to the IP 
#    address of your Roku box. (e.g. export ROKU_DEV_TARGET=192.168.1.1.
#    Set in your this variable in your shell startup (e.g. .bashrc)
##########################################################################  
APPNAME = roku-terra-live
PKGREL = ../packages
ZIPREL = ../zips
SOURCEREL = ..
ZIP_EXCLUDE = \*.swp \*~ \*\.~ LICENSE .gitignore Makefile README.md \*.git/\* \*.odp
#ROKU_DEV_TARGET = 192.168.1.101
.PHONY: all $(APPNAME)

$(APPNAME): 
	@echo "*** Creating $(APPNAME).zip ***"

	@echo "  >> removing old application zip $(ZIPREL)/$(APPNAME).zip"
	@if [ -e "$(ZIPREL)/$(APPNAME).zip" ]; \
	then \
		rm  $(ZIPREL)/$(APPNAME).zip; \
	fi

	@echo "  >> creating destination directory $(ZIPREL)"	
	@if [ ! -d $(ZIPREL) ]; \
	then \
		mkdir -p $(ZIPREL); \
	fi

	@echo "  >> setting directory permissions for $(ZIPREL)"
	@if [ ! -w $(ZIPREL) ]; \
	then \
		chmod 755 $(ZIPREL); \
	fi

# zip .png files without compression
	@echo "  >> creating application zip $(ZIPREL)/$(APPNAME).zip"	
	@if [ -d $(SOURCEREL)/$(APPNAME) ]; \
	then \
		(zip -0 -r "$(ZIPREL)/$(APPNAME).zip" . -i \*.png -x $(ZIP_EXCLUDE)); \
		(zip -9 -r "$(ZIPREL)/$(APPNAME).zip" . -x \*.png $(ZIP_EXCLUDE)); \
	else \
		echo "Source for $(APPNAME) not found at $(SOURCEREL)/$(APPNAME)"; \
	fi

	@echo "*** developer zip  $(APPNAME) complete ***"

install: $(APPNAME)
	@echo "Installing $(APPNAME) to host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Install" -F "archive=@$(ZIPREL)/$(APPNAME).zip" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//"  | sed "s[</font>[["

pkg: install
	@echo "*** Creating Package ***"

	@echo "  >> updating build_version"
	sed -i s/^build_version=.*/build_version=`date +%y%m%d`/ manifest

	@echo "  >> creating destination directory $(PKGREL)"	
	@if [ ! -d $(PKGREL) ]; \
	then \
		mkdir -p $(PKGREL); \
	fi

	@echo "  >> setting directory permissions for $(PKGREL)"
	@if [ ! -w $(PKGREL) ]; \
	then \
		chmod 755 $(PKGREL); \
	fi

	@echo "Packaging  $(APPNAME) on host $(ROKU_DEV_TARGET)"
	@read -p "Password: " REPLY ; echo $$REPLY | xargs -i curl -s -S -Fmysubmit=Package -Fapp_name=$(APPNAME)/$(VERSION) -Fpasswd={} -Fpkg_time=`expr \`date +%s\` \* 1000` "http://$(ROKU_DEV_TARGET)/plugin_package" | grep '^<font face=' | sed 's/.*href=\"\([^\"]*\)\".*/\1/' | sed 's#pkgs/##' | xargs -i curl -s -S -o $(PKGREL)/$(APPNAME)_{} http://$(ROKU_DEV_TARGET)/pkgs/{}

	@echo "*** Package  $(APPNAME) complete ***" 
remove:
	@echo "Removing $(APPNAME) from host $(ROKU_DEV_TARGET)"
	@curl -s -S -F "mysubmit=Delete" -F "archive=" -F "passwd=" http://$(ROKU_DEV_TARGET)/plugin_install | grep "<font color" | sed "s/<font color=\"red\">//"
