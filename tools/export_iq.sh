#!/bin/sh
# Export the .iq package for the Connect IQ Store, for the beta app or the prod app.
#
#   beta  builds manifest.xml as it is. Its app id is the one used for sideloading and for the
#         store's Beta Apps section.
#   prod  builds the same manifest with the prod app id, for publishing. The Beta Apps section
#         ties a beta app to its id, so the published app needs a different one.
#
# The prod manifest is generated from manifest.xml into bin/manifest-prod.xml, so the two never
# differ in anything but the app id. monkey-prod.jungle points the build at it.
#
# Usage: tools/export_iq.sh beta|prod
# Needs monkeyc on PATH and a Java runtime (JAVA_HOME). The developer key defaults to
# ~/.garmin/tachometer-watchface/developer_key.der; set DEVELOPER_KEY to use another one.
set -eu

PROD_ID=70922947-B3E2-4146-A659-C10235F894A9

cd "$(dirname "$0")/.."
if [ -n "${JAVA_HOME:-}" ]; then
  if [ ! -x "$JAVA_HOME/bin/java" ]; then
    echo "export_iq: JAVA_HOME does not contain bin/java" >&2
    exit 1
  fi
  PATH="$JAVA_HOME/bin:$PATH"
  export PATH
fi
key=${DEVELOPER_KEY:-$HOME/.garmin/tachometer-watchface/developer_key.der}
uuid='[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}'

case ${1:-} in
  beta)
    jungle=monkey.jungle
    ;;
  prod)
    beta_id=$(sed -n "s/^ *id=\"\($uuid\)\"\$/\1/p" manifest.xml)
    if [ -z "$beta_id" ] || [ "$(printf '%s\n' "$beta_id" | wc -l)" -ne 1 ]; then
      echo "export_iq: expected exactly one app id in manifest.xml" >&2
      exit 1
    fi
    if [ "$beta_id" = "$PROD_ID" ]; then
      echo "export_iq: manifest.xml already has the prod app id; it must keep the beta one" >&2
      exit 1
    fi
    mkdir -p bin
    sed "s/id=\"$beta_id\"/id=\"$PROD_ID\"/" manifest.xml > bin/manifest-prod.xml
    jungle=monkey-prod.jungle
    ;;
  *)
    echo "usage: $0 beta|prod" >&2
    exit 2
    ;;
esac

mkdir -p bin
monkeyc -e -r -f "$jungle" -o "bin/tachometer-$1.iq" -y "$key"
echo "wrote bin/tachometer-$1.iq"
