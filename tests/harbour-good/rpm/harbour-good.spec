# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-good

# >> macros
%define __provides_exclude_from ^%{_datadir}/.*$
%define __requires_exclude ^libquazip.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    An RPM to test the rpmvalidation.sh script
Version:    0.11
Release:    1
Group:      Qt/Qt
License:    LICENSE
URL:        http://example.org/
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 0.0.10
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
%ifarch %ix86
# to cause an expected failure in tests
Requires: libgcc_s.so.1(GCC_x.y)
%endif

%description
Short description of my SailfishOS Application


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

%ifarch %ix86
mkdir %{buildroot}/%{_datadir}/%{name}/qml/pages/bulk-qml-files/
for AMOUNT in $(seq 1 2000); do cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_Template.qml %{buildroot}/%{_datadir}/%{name}/qml/pages/bulk-qml-files/Page_${AMOUNT}.qml; done
for AMOUNT in $(seq 2001 4000); do touch %{buildroot}/%{_datadir}/%{name}/qml/pages/bulk-qml-files/Page_${AMOUNT}.qml; done
%endif

# create files with spaces
cp %{buildroot}/%{_datadir}/%{name}/lib/libhelloSailorDbus.so "%{buildroot}/%{_datadir}/%{name}/lib/lib hello Sailor Dbus.so"

cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_002.qml "%{buildroot}/%{_datadir}/%{name}/qml/pages/Page 002.qml"
cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_003.qml "%{buildroot}/%{_datadir}/%{name}/qml/pages/Page 003.qml"
cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_004.qml "%{buildroot}/%{_datadir}/%{name}/qml/pages/Page 004.qml"
cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_005.qml "%{buildroot}/%{_datadir}/%{name}/qml/pages/Page 005.qml"
cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_006.qml "%{buildroot}/%{_datadir}/%{name}/qml/pages/Page 006.qml"

# utf-8 chars
cp %{buildroot}/%{_datadir}/%{name}/lib/libhelloSailorDbus.so %{buildroot}/%{_datadir}/%{name}/lib/嗨.so
cp %{buildroot}/%{_datadir}/%{name}/qml/pages/Page_006.qml %{buildroot}/%{_datadir}/%{name}/qml/pages/嗨.qml

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(0644,root,root,0755)
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
%{_datadir}/icons/hicolor/108x108/apps/%{name}.png
%{_datadir}/icons/hicolor/128x128/apps/%{name}.png
%{_datadir}/icons/hicolor/256x256/apps/%{name}.png
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/
%attr(0755,-,-) %{_bindir}/%{name}
# >> files
# << files
