#!/usr/bin/env bash
# Build a Debian binary package (architecture: all) for WoeUSB
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# The resulting package is written to distribution/deb/woeusb_<version>_all.deb

set \
    -o errexit \
    -o nounset \
    -o pipefail

script_dir="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" \
        && pwd
)"
product_dir="$(
    cd "${script_dir}/.." \
        && pwd
)"

# Override with: WOEUSB_VERSION=5.3.1 ./dev-assets/build-deb.sh
product_version="${WOEUSB_VERSION:-5.3.0}"

work_dir="$(
    mktemp \
        -d \
        -t \
        woeusb-deb.XXXXXX
)"
trap \
    'rm --recursive --force "${work_dir}"' \
    EXIT

package_root="${work_dir}/package"
mkdir \
    --parents \
    "${package_root}/usr/bin" \
    "${package_root}/usr/share/man/man1" \
    "${package_root}/usr/share/woeusb" \
    "${package_root}/DEBIAN"

# Executable
sed \
    "s/@@WOEUSB_VERSION@@/${product_version}/" \
    "${product_dir}/sbin/woeusb" \
    > "${package_root}/usr/bin/woeusb"
chmod 755 "${package_root}/usr/bin/woeusb"

# Manual page
sed \
    "s/@@WOEUSB_VERSION@@/${product_version}/" \
    "${product_dir}/share/man/man1/woeusb.1" \
    > "${package_root}/usr/share/man/man1/woeusb.1"

# Application icon
cp \
    "${product_dir}/share/woeusb/woeusb.svg" \
    "${package_root}/usr/share/woeusb/woeusb.svg"

# Compile gettext message catalogs(.po -> .mo)
while IFS='' read -r -d '' po_file; do
    locale_dir="${po_file%/*}"
    locale_name="$(basename "${locale_dir%/*}")"
    mo_dir="${package_root}/usr/share/locale/${locale_name}/LC_MESSAGES"
    mkdir \
        --parents \
        "${mo_dir}"
    msgfmt \
        "${po_file}" \
        --output-file="${mo_dir}/woeusb.mo"
done < <( \
    find \
        "${product_dir}/share/locale" \
        -name '*.po' \
        -print0 \
)

# Package metadata
sed \
    "s/@@WOEUSB_VERSION@@/${product_version}/" \
    "${product_dir}/packaging/debian/control" \
    > "${package_root}/DEBIAN/control"

mkdir \
    --parents \
    "${product_dir}/distribution/deb"
dpkg-deb \
    --build \
    --root-owner-group \
    "${package_root}" \
    "${product_dir}/distribution/deb/woeusb_${product_version}_all.deb"

printf \
    'Built: %s\n' \
    "${product_dir}/distribution/deb/woeusb_${product_version}_all.deb"
