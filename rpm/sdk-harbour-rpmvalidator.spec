Name:       sdk-harbour-rpmvalidator
Summary:    Jolla Harbour RPM validation tools
Version:    1.2
Release:    1
Group:      System/Base
License:    GPLv2
BuildArch:  noarch
URL:        https://github.com/sailfish-sdk/sdk-harbour-rpmvalidator
Source0:    %{name}-%{version}.tar.bz2

%description
RPM validation tools for Jolla Harbour.

%define debug_package %{nil}

%prep
%setup -q

%build
echo "Nothing to build"

%install
rm -rf %{buildroot}

install -D -m 0755 rpmvalidation.sh %{buildroot}%{_bindir}/rpmvalidation.sh
install -D -m 0644 allowed_libraries.conf %{buildroot}%{_datadir}/%{name}/allowed_libraries.conf
install -D -m 0644 allowed_qmlimports.conf %{buildroot}%{_datadir}/%{name}/allowed_qmlimports.conf
install -D -m 0644 allowed_requires.conf %{buildroot}%{_datadir}/%{name}/allowed_requires.conf
install -D -m 0644 rpmvalidation.conf %{buildroot}%{_datadir}/%{name}/rpmvalidation.conf

# create version information file that is read by the validation script
echo "%{version}-%{release}" > %{buildroot}%{_datadir}/%{name}/version

%files
%defattr(-,root,root,-)
%{_bindir}/rpmvalidation.sh
%{_datadir}/%{name}/version
%{_datadir}/%{name}/*.conf
