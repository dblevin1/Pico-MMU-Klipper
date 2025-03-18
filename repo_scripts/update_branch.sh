#!/usr/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

function stopfunc {
    if [ -d ".git" ]; then
        echo "Stopping, changing branch"
        git checkout $current_branch
        if [ "$has_stashed" = true ]; then
            git stash pop
        fi
    fi
    exit 0
}

trap stopfunc SIGINT SIGTERM

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SCRIPT_DIR="$SCRIPT_DIR/.."
cd $SCRIPT_DIR

has_stashed=false
if [ ! -z "$(git status -s)" ]; then
    echo "Uncommitted changes found, stashing..."
    has_stashed=true
    git stash save -u
fi
#current_branch=$(git branch --show-current)
#echo "On branch $current_branch"
current_branch="main"
git checkout main
git fetch origin
git pull

original_code_commit=$(git log -n 1 --pretty=format:%H -- sp_mmu_code.cfg)
original_config_commit=$(git log -n 1 --pretty=format:%H -- sp_mmu.cfg)


if git show-ref --verify --quiet refs/heads/upstream-main; then
    echo "upstream-main branch exists"
    git checkout upstream-main
else
    echo "upstream-main branch does not exist, creating..."
    git remote add upstream https://github.com/lhndo/LH-Stinger.git
    git fetch upstream
    git checkout -b upstream-main upstream/main
fi

git pull
echo "updating upstream-mmu-klipper branch from upstream-main"
git subtree split --prefix="User_Mods/MMU/Stinger Pico MMU - @LH/Klipper" -b upstream-mmu-klipper
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create upstream-mmu-klipper branch.${NC}"
    exit 1
fi

git checkout upstream-mmu-klipper
new_code_commit=$(git log -n 1 --pretty=format:%H -- sp_mmu_code.cfg)
new_config_commit=$(git log -n 1 --pretty=format:%H -- sp_mmu.cfg)

git checkout $current_branch
if [ "$has_stashed" = true ]; then
    echo "Popping stash..."
    has_stashed=false
    git stash pop
fi

if [ "$original_code_commit" != "$new_code_commit" ] || [ "$original_config_commit" != "$new_config_commit" ]; then
    git fetch origin
    git pull
    echo "updating '$current_branch' branch from upstream-mmu-klipper"
    git merge upstream-mmu-klipper --no-edit --allow-unrelated-histories
    if [ $? -ne 0 ]; then
        echo -e "${RED}Merge failed, please resolve conflicts manually.${NC}"
        exit 1
    fi

    git push
fi

# config_version=$(grep "VERSION: " sp_mmu_code.cfg | sed "s/.*: //")



