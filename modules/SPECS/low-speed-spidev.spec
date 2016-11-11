# Module is built by dkms, we don't have any debuginfo at package build time
##%global debug_package %{nil}


%global lss_ver 1.0
%global pkg_name low-speed-spidev
%global dir_name %{pkg_name}-%{lss_ver}


Summary:        Linux kernel module for low-speed-spidev
Name:           %{pkg_name}
Version:        %{lss_ver}
URL:            www.example.com
Release:        1%{?dist}
License:        GPLv3
Group:          System Environment/Base
Source0:        %{dir_name}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-root
Requires:       dkms gcc kernel-devel make


%description
low-speed-spidev is a Linux kernel module which adds support for SPI_SPIDEV
on the Minnowboard MAX. Your kernel configuration should have SPI_SPIDEV=m set
for this module to work.
See: https://github.com/MinnowBoard/minnow-max-extras/tree/master/modules/low-speed-spidev


%prep
%setup -q -n %{pkg_name}


%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

# Its easier to do the work of building this here...
mkdir -p $RPM_BUILD_ROOT/usr/src/%{dir_name}

install -m 644 $RPM_BUILD_DIR/%{pkg_name}/low-speed-spidev.c $RPM_BUILD_ROOT/usr/src/%{dir_name}/low-speed-spidev.c
install -m 644 $RPM_BUILD_DIR/%{pkg_name}/Makefile $RPM_BUILD_ROOT/usr/src/%{dir_name}/Makefile
install -m 644 $RPM_BUILD_DIR/%{pkg_name}/dkms.conf $RPM_BUILD_ROOT/usr/src/%{dir_name}/dkms.conf

# make the auto-loader directory if it does not already exist
mkdir -p $RPM_BUILD_ROOT/etc/modules-load.d
# create the auto-loader conf file for low-speed-spidev if it does not already exist
echo "low-speed-spidev" > $RPM_BUILD_DIR/etc/modules-load.d/low-speed-spidev.conf
# put this in the real place with mode 755
install -m 755 $RPM_BUILD_DIR/etc/modules-load.d/low-speed-spidev.conf $RPM_BUILD_ROOT/etc/modules-load.d/low-speed-spidev.conf


%clean
[ "${RPM_BUILD_ROOT}" != "/" ] && rm -rf ${RPM_BUILD_ROOT}
if [ -f /etc/modules-load.d/low-speed-spidev.conf ] ; then
    rm -f /etc/modules-load.d/low-speed-spidev.conf
fi


%post
###/sbin/rmmod spidev >/dev/null 2>&1 || :
/sbin/rmmod low-speed-spidev 2>&1 || :
/usr/sbin/dkms add -m low-speed-spidev -v %{lss_ver} 2>&1 || :
/usr/sbin/dkms build -m low-speed-spidev -v %{lss_ver} 2>&1 || :
/usr/sbin/dkms install -m low-speed-spidev -v %{lss_ver} 2>&1 || :
depmod -a 2>&1 || :
/sbin/modprobe low-speed-spidev 2>&1 || :

%preun
# Remove all versions from DKMS registry
# if not upgrading
if  [ "$1" = "0" ]; then   
    /usr/sbin/dkms remove -m low-speed-spidev -v %{lss_ver} --all #>/dev/null 2>&1
fi

%files
%defattr(-,root,root,-)
%dir /usr/src/%{dir_name}
/usr/src/%{dir_name}/low-speed-spidev.c
/usr/src/%{dir_name}/Makefile
/usr/src/%{dir_name}/dkms.conf
/etc/modules-load.d/low-speed-spidev.conf


