# Connect Local Git Repository to GitHub using SSH
```
ssh-keygen -t ed25519 -C "bachchu333@gmail.com"
ls ~/.ssh/
cd ~/.ssh/
cat .pub
[open github > setting >ssh and gpg]
```
## git configure
```
git config --global user.name "Mir"
git config --global --get user.name
git config --global user.email your_email@gmail.com
git config --global --get user.email
```
## Create Repository on GitHub
## Push your code-base into GitHub
---
# git-github-pull-request
How to contribute open source / How To Pull Request

```
git clone git@github.com:mir-owahed/git-github-pull-request.git
cd git-github-pull-request/
code .
git branch
git log
git status
git branch git-pr
git branch
git checkout git-pr
git branch
git log
```
You can update into new branch

```
 git status
 git add .
 git commit -m "git PR step by step guide added"
 git remote -v
 git push -u origin git-pr
```
```
remote: Create a pull request for 'git-pr' on GitHub by visiting:
remote:      https://github.com/mir-owahed/git-github-pull-request/pull/new/git-pr
remote: 
To github.com:mir-owahed/git-github-pull-request.git
 * [new branch]      git-pr -> git-pr
Branch 'git-pr' set up to track remote branch 'git-pr' from 'origin'.
```
### Git PR
```
git branch
 git checkout -b git-pr-test
 git branch
 git add .
 git commit -m "markdown syntax added"
 git push
 git push --set-upstream origin git-pr-test
  
```

```

 git --version
 git init
 git status
 git add .
 git commit -m "initial commit"
 git status
 git remote add origin git@github.com:mir-owahed/learn-git-github.git
 git remote -v
 git branch -M main
 git push -u origin main
 git status
 git add .
 git commit -m "added blog post"
 git status
 git push -u origin main
 cd ..
 rm -rf learn-git
 git clone git@github.com:mir-owahed/learn-git-github.git
 cd learn-git-github/
 code .
 ls
 git branch
 git checkout -b hot-fix
 git branch
 git status
 git add .
 git commit -m "updated first blog post"
 git status
 git push -u origin hot-fix
 git status
 git push -u origin hot-fix
 git branch
 git branch main
 git checkout main
 git status
 git add .
 git commit -m "i line added - step by step"
 git push -u origin main
 git fetch
 git pull --ff
 git status
 git push -u origin main
```


```
 git clone git@github.com:mir-owahed/git-test.git
 cd git-test/
 code .
 git status
 git add .
 git commit -m "node_modules exclude"
 git remote -v
 git config --global --get user.name
 git config --global --get user.email
 git status
 git remote -v
 git log
 git push -u origin main
 git status
 git status -sb
 git status
 git commit -am "comment added in command_vm.txt file"
 git status
 git push -u origin main
 git fetch
 git status
 git pull
 git pull origin
 git pull --ff
 git status
 git log
 git status
 git push -u origin main
 history
  .........................
  git branch
  .................
 git branch
 git checkout main
 git branch
 git status
 git checkout hotfix
 git checkout main
 git merge hotfix
 git branch
 git branch -d hotfix
 git branch
 git status
 git push
 git pull
 git branch
 git push
```
