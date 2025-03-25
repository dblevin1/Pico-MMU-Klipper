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
git fetch -a
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

has_change=false
if [ "$original_code_commit" != "$new_code_commit" ]; then
    echo "Code commit hash has changed, updating..."
    echo "Original code commit: $original_code_commit"
    echo "New code commit: $new_code_commit"
    has_change=true
fi
if [ "$original_config_commit" != "$new_config_commit" ]; then
    echo "Config commit hash has changed, updating..."
    echo "Original config commit: $original_config_commit"
    echo "New config commit: $new_config_commit"
    has_change=true
fi
if [ "$has_change" = false ]; then
    echo "No changes detected, exiting..."
    exit 0
fi

git checkout $current_branch
if [ "$has_stashed" = true ]; then
    echo "Popping stash..."
    has_stashed=false
    git stash pop
fi

git fetch -a
git pull
echo "updating '$current_branch' branch from upstream-mmu-klipper"
git merge upstream-mmu-klipper --no-edit --allow-unrelated-histories
if [ $? -ne 0 ]; then
    echo -e "${RED}Merge failed, please resolve conflicts manually.${NC}"
    exit 1
fi

git push

# config_version=$(grep "VERSION: " sp_mmu_code.cfg | sed "s/.*: //")



