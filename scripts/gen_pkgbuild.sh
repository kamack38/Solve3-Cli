#!/bin/bash -

(
	cat <<'EOF'
# Maintainer: Kamack38 <kamack38.biznes@gmail.com>
pkgname=solve3-cli
pkgver=SCLI_PKGVER
pkgrel=1
pkgdesc="CLI for solving problems at https://solve.edu.pl/"
arch=('any')
url="https://github.com/kamack38/solve3-cli"
license=('MIT')
depends=('nodejs' 'jre-openjdk-headless')
makedepends=('npm' 'jq')
source=("https://registry.npmjs.org/$pkgname/-/$pkgname-$pkgver.tgz")
noextract=("$pkgname-$pkgver.tgz")
sha256sums=('SKIP')

package() {
	npm install -g --prefix "$pkgdir/usr" "$srcdir/$pkgname-$pkgver.tgz"

	# Remove references to $pkgdir
	find "$pkgdir" -type f -name package.json -print0 | xargs -0 sed -i "/_where/d"

	# Remove references to $srcdir
	local tmppackage="$(mktemp)"
	local pkgjson="$pkgdir/usr/lib/node_modules/$pkgname/package.json"
	jq '.|=with_entries(select(.key|test("_.+")|not))' "$pkgjson" >"$tmppackage"
	mv "$tmppackage" "$pkgjson"
	chmod 644 "$pkgjson"

	find "$pkgdir" -type f -name package.json | while read pkgjson; do
		local tmppackage="$(mktemp)"
		jq 'del(.man)' "$pkgjson" >"$tmppackage"
		mv "$tmppackage" "$pkgjson"
		chmod 644 "$pkgjson"
	done
}
EOF
) | sed 's/pkgver=SCLI_PKGVER/pkgver='$(printf "$(git describe --abbrev=0 | sed 's/v//')")'/' | sed "s/sha256sums=('SKIP')/sha256sums=('$(curl -s "https://registry.npmjs.org/solve3-cli/-/solve3-cli-$(printf "$(git describe --abbrev=0 | sed 's/v//')").tgz" | sha256sum | head -c 64)')/"
