#!/usr/bin/env bash
# 3ntity defacement — deploy to Apache document root.
# Run from the directory that contains index.html, profile.html, and assets/.
#   sudo ./deploy.sh
set -euo pipefail

WEBROOT="/var/www/html"
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Deploying 3ntity site from $SRC -> $WEBROOT"

# Copy site contents (files land directly in webroot; served at http://host/)
cp -r "$SRC/index.html" "$SRC/profile.html" "$SRC/assets" "$WEBROOT/"

# Ownership: Apache on Debian/Ubuntu runs as www-data
chown -R www-data:www-data "$WEBROOT"

# Permissions: dirs 755, files 644
find "$WEBROOT" -type d -exec chmod 755 {} \;
find "$WEBROOT" -type f -exec chmod 644 {} \;

# Ensure .woff2 serves with the correct MIME type (older mime.types may lack it).
# Drop a scoped .htaccess so we don't touch global config.
cat > "$WEBROOT/.htaccess" <<'HT'
AddType font/woff2 .woff2
DirectoryIndex index.html
HT
chown www-data:www-data "$WEBROOT/.htaccess"
chmod 644 "$WEBROOT/.htaccess"

echo "[*] Done."
echo "    Landing page (takeover): http://<host>/"
echo "    Threat profile:          http://<host>/profile.html"
echo
echo "NOTE: For .htaccess to take effect, the Apache vhost for this dir needs"
echo "      'AllowOverride All' (or at least FileInfo Indexes). If AllowOverride"
echo "      is None, instead add 'AddType font/woff2 .woff2' to the vhost and"
echo "      remove this .htaccess."
echo
echo "Remember to place the 7 .woff2 font files in $WEBROOT/assets/fonts/"
echo "(see assets/fonts/README.txt). The page renders with fallbacks until then."
