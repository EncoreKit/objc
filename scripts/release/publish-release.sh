#!/usr/bin/env bash
# Interactive release for EncoreObjC. Publishes to CocoaPods trunk.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PODSPEC="$SDK_ROOT/EncoreObjC.podspec"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}EncoreObjC Release${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 1: Repo state
# ------------------------------------------------------------------------
cd "$SDK_ROOT"
echo -e "${BLUE}Step 1: Checking repository state...${NC}"

BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "main" ]]; then
    echo -e "${RED}Error: must be on main (currently $BRANCH)${NC}"
    exit 1
fi

git fetch origin main --tags

if [[ "$(git rev-parse @)" != "$(git rev-parse @{u})" ]]; then
    echo -e "${RED}Error: local main out of sync with remote${NC}"
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: uncommitted changes${NC}"
    exit 1
fi

if ! pod trunk me &>/dev/null; then
    echo -e "${RED}Error: not logged in to CocoaPods trunk${NC}"
    echo "   Run: pod trunk register <email>"
    exit 1
fi

echo -e "${GREEN}Repo clean, trunk authed${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 2: Detect current version
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 2: Detecting current version...${NC}"

CURRENT_TAG=$(git tag -l "v*" --sort=-v:refname | head -n 1)
CURRENT_TAG=${CURRENT_TAG:-v0.0.0}
CURRENT="${CURRENT_TAG#v}"
echo "   Current: v$CURRENT"

IFS='.' read -r CUR_MAJ CUR_MIN CUR_PAT <<< "$CURRENT"
echo ""

# ------------------------------------------------------------------------
# Step 3: Prompt for new version
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 3: Enter new version${NC}"
echo -e "   patch -> v$CUR_MAJ.$CUR_MIN.$((CUR_PAT + 1))"
echo -e "   minor -> v$CUR_MAJ.$((CUR_MIN + 1)).0"
echo -e "   major -> v$((CUR_MAJ + 1)).0.0"
echo ""
read -p "Enter version (X.Y.Z or shortcut): " INPUT

case "$INPUT" in
    patch) NEW_MAJ=$CUR_MAJ; NEW_MIN=$CUR_MIN; NEW_PAT=$((CUR_PAT + 1)) ;;
    minor) NEW_MAJ=$CUR_MAJ; NEW_MIN=$((CUR_MIN + 1)); NEW_PAT=0 ;;
    major) NEW_MAJ=$((CUR_MAJ + 1)); NEW_MIN=0; NEW_PAT=0 ;;
    *)
        INPUT="${INPUT#v}"
        if ! [[ "$INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${RED}Invalid format. Expected X.Y.Z${NC}"
            exit 1
        fi
        IFS='.' read -r NEW_MAJ NEW_MIN NEW_PAT <<< "$INPUT"
        ;;
esac

NEW="$NEW_MAJ.$NEW_MIN.$NEW_PAT"
NEW_TAG="v$NEW"

CURRENT_WEIGHT=$(( CUR_MAJ * 1000000 + CUR_MIN * 1000 + CUR_PAT ))
NEW_WEIGHT=$(( NEW_MAJ * 1000000 + NEW_MIN * 1000 + NEW_PAT ))
if [[ "$NEW_WEIGHT" -le "$CURRENT_WEIGHT" ]]; then
    echo -e "${RED}New version must be > current${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Next version: $NEW_TAG${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 4: Show commit log
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 4: Commits since $CURRENT_TAG:${NC}"
if [[ "$CURRENT_TAG" == "v0.0.0" ]]; then
    git log --oneline | head -20
else
    git log --oneline "$CURRENT_TAG"..HEAD | head -20
fi
echo ""

# ------------------------------------------------------------------------
# Step 5: Confirm
# ------------------------------------------------------------------------
ENCOREKIT_PIN=$(python3 -c "import json; print(json.load(open('$SDK_ROOT/config/sdk-versions.json'))['ios']['EncoreKit'])")
echo -e "${YELLOW}Step 5: Confirm release${NC}"
echo "   EncoreObjC:  $CURRENT_TAG -> $NEW_TAG"
echo "   EncoreKit:   $ENCOREKIT_PIN (pinned)"
echo "   Target:      CocoaPods trunk (pod 'EncoreObjC')"
echo ""
read -p "Proceed? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || { echo -e "${RED}Cancelled${NC}"; exit 1; }
echo ""

# ------------------------------------------------------------------------
# Step 6: Update podspec
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 6: Updating podspec to $NEW...${NC}"
sed -i.bak "s/^  s\.version[[:space:]]*=.*/  s.version          = \"$NEW\"/" "$PODSPEC"
rm "$PODSPEC.bak"
echo -e "${GREEN}Podspec updated${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 7: Lint
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 7: pod lib lint${NC}"
cd "$SDK_ROOT"
pod lib lint EncoreObjC.podspec --allow-warnings
echo -e "${GREEN}Lint passed${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 8: Commit, tag, push
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 8: Commit + tag + push${NC}"

# Defensive: a tag collision would silently let a stale podspec version
# ship. Abort with a clear remediation before we touch anything.
if git rev-parse -q --verify "refs/tags/$NEW_TAG" >/dev/null; then
    echo -e "${RED}Tag $NEW_TAG already exists locally.${NC}"
    echo "   Delete with: git tag -d $NEW_TAG && git push origin :refs/tags/$NEW_TAG"
    exit 1
fi

git add EncoreObjC.podspec
git commit -m "Release $NEW_TAG"
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"
git push origin main
git push origin "$NEW_TAG"
echo -e "${GREEN}Pushed${NC}"
echo ""

# ------------------------------------------------------------------------
# Step 9: pod trunk push
# ------------------------------------------------------------------------
echo -e "${BLUE}Step 9: pod trunk push${NC}"
pod trunk push EncoreObjC.podspec --allow-warnings
echo -e "${GREEN}Published to CocoaPods trunk${NC}"
echo ""

echo ""
echo -e "${GREEN}Release $NEW_TAG complete${NC}"
echo "   Install: pod 'EncoreObjC', '~> ${NEW_MAJ}.${NEW_MIN}'"
