"""Patch the WebUI password hash into qBittorrent's generated config.

The NixOS module reinstalls qBittorrent.conf from the store on every start,
so a password set through the WebUI never survives a restart. qBittorrent
only accepts a salted PBKDF2 hash, so derive one from the plaintext secret
and splice it in before the daemon reads the file.
"""

import base64
import hashlib
import os
import sys

KEY = "WebUI\\Password_PBKDF2"

secret_path, conf_path = sys.argv[1], sys.argv[2]

with open(secret_path, "rb") as f:
    password = f.read().strip()

salt = os.urandom(16)
digest = hashlib.pbkdf2_hmac("sha512", password, salt, 100000, 64)
value = "@ByteArray({}:{})".format(
    base64.b64encode(salt).decode(), base64.b64encode(digest).decode()
)

with open(conf_path) as f:
    lines = [l for l in f.read().splitlines() if not l.startswith(KEY + "=")]

out = []
for line in lines:
    out.append(line)
    if line.startswith("WebUI\\Username="):
        out.append('{}="{}"'.format(KEY, value))

if len(out) == len(lines):
    sys.exit("no WebUI\\Username= line in {}, refusing to write".format(conf_path))

with open(conf_path, "w") as f:
    f.write("\n".join(out) + "\n")
