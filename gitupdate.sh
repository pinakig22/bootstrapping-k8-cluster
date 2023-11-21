# Shell Script to push to repo.
# This takes input as comment
#!/bin/bash
echo "## Git STATUS ##"
git status
echo $'\n'
echo "## Git ADD ##"
git add --all :/
echo "## Git Commit ##"
git commit -m "$1"
echo "## Git Push ##"
git push origin

