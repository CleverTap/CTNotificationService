#!/usr/bin/env bash
# Verifies that every place carrying the SDK version matches the podspec version.
# Run locally before a release, and in CI on every pull request.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PODSPEC="CTNotificationService.podspec"
SOURCE="CTNotificationService/CTNotificationServiceExtension.m"
PBXPROJ="CTNotificationService.xcodeproj/project.pbxproj"
INFO_PLIST="CTNotificationService/CTNotificationService.plist"
CHANGELOG="CHANGELOG.md"

failures=0
pass() { echo "ok    $1"; }
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }

version="$(sed -n "s/^[[:space:]]*s\.version[[:space:]]*=[[:space:]]*[\"']\([^\"']*\)[\"'].*/\1/p" "$PODSPEC" | head -n 1)"
if [[ -z "$version" ]]; then
    echo "FAIL  could not read s.version from $PODSPEC, expected a line like s.version = \"1.2.3\""
    exit 1
fi
# Minor and patch are capped at two digits so the Core SDK version code (major * 10000 + minor * 100 + patch) stays unique.
if [[ "$version" =~ ^[0-9]+\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
    pass "$PODSPEC version is $version"
else
    fail "$PODSPEC version must be major.minor.patch with minor and patch at most 99, found '$version'"
fi

source_version="$(sed -n 's/.*kCTNotificationServiceVersion = @"\([^"]*\)".*/\1/p' "$SOURCE" | head -n 1)"
if [[ "$source_version" == "$version" ]]; then
    pass "kCTNotificationServiceVersion is $source_version"
else
    fail "kCTNotificationServiceVersion in $SOURCE is '$source_version', expected '$version'"
fi

marketing_versions="$(sed -n 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/p' "$PBXPROJ" | sort -u)"
if [[ -n "$marketing_versions" && "$marketing_versions" == "$version" ]]; then
    pass "MARKETING_VERSION is $version"
else
    fail "MARKETING_VERSION in $PBXPROJ is '$(echo "$marketing_versions" | tr '\n' ' ')', expected '$version'"
fi

if grep -A1 "<key>CFBundleShortVersionString</key>" "$INFO_PLIST" | grep -q '\$(MARKETING_VERSION)'; then
    pass "$INFO_PLIST uses \$(MARKETING_VERSION)"
else
    fail "CFBundleShortVersionString in $INFO_PLIST must be \$(MARKETING_VERSION)"
fi

changelog_version="$(sed -n 's/^Version \([0-9][0-9.]*\).*/\1/p' "$CHANGELOG" | head -n 1)"
if [[ "$changelog_version" == "$version" ]]; then
    pass "$CHANGELOG top entry is $changelog_version"
else
    fail "$CHANGELOG top entry is '$changelog_version', expected '$version'"
fi

if grep -q "^- Describe the changes in this release\.$" "$CHANGELOG"; then
    fail "$CHANGELOG still has the placeholder line added by scripts/bump_version.sh"
else
    pass "$CHANGELOG has release notes"
fi

if (( failures > 0 )); then
    echo "$failures version check(s) failed. Run scripts/bump_version.sh <version> to update every place at once."
    exit 1
fi
echo "All version checks passed."
