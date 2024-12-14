#!/bin/sh
rpm --quiet -q appstream-builder || sudo yum -q -y install appstream-builder
mkdir -p /home/jbarrios/Proyectos/APPDATA-PKGS-STABLE && \
cd /home/jbarrios/Proyectos/APPDATA-PKGS-STABLE && \
yumdownloader google-chrome-stable && \
yumdownloader opera-stable && \
yumdownloader microsoft-edge-stable && \
repoquery \
    --disablerepo=ALDOS-beta* \
    --whatprovides "appdata()" --qf "%{NAME}" |sort |uniq |xargs yumdownloader --disablerepo=ALDOS-next* --disablerepo=ALDOS-beta* && \
repomanage --old -k 1 /home/jbarrios/Proyectos/APPDATA-PKGS-STABLE/ |xargs rm -fv  && \
createrepo_c --update /home/jbarrios/Proyectos/APPDATA-PKGS-STABLE/ && \
mkdir -m 0755 -p /home/jbarrios/rpmbuild/SOURCES/appstream-data/{cache,logs,64x64,128x128}  && \
appstream-builder --packages-dir=/home/jbarrios/Proyectos/APPDATA-PKGS-STABLE/ \
    --output-dir=/home/jbarrios/rpmbuild/SOURCES/appstream-data/ \
    --uncompressed-icons \
    --icons-dir=/home/jbarrios/rpmbuild/SOURCES/appstream-data/ \
    --temp-dir=/tmp/appstream/ \
    --cache-dir=/home/jbarrios/rpmbuild/SOURCES/appstream-data/cache/ \
    --log-dir=/home/jbarrios/rpmbuild/SOURCES/appstream-data/logs/ \
    --basename=aldos \
    --origin=aldos && \
pushd /home/jbarrios/rpmbuild/SOURCES/appstream-data/ && \
chmod 755 64x64/ 128x128/ && \
chmod 644 64x64/*.png 128x128/*.png && \
tar zcf aldos-icons.tar.gz 64x64 128x128 &&
sudo sync && \
popd || exit 1
