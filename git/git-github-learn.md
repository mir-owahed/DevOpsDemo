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
250  git status
  251  git add .
  252  git commit -m "git PR step by step guide added"
  253  git remote -v
  254  git push -u origin git-pr
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
  247  git checkout -b git-pr-test
  248  git branch
  249  git add .
  250  git commit -m "markdown syntax added"
  251  git push
  252  git push --set-upstream origin git-pr-test
  
```

```


  198  git --version

  199  git init

  200  git status

  201  git add .

  202  git commit -m "initial commit"

  203  git status

  204  git remote add origin git@github.com:mir-owahed/learn-git-github.git

  205  git remote -v

  206  git branch -M main

  207  git push -u origin main

  208  git status

  209  git add .

  210  git commit -m "added blog post"

  211  git status

  212  git push -u origin main

  213  cd ..

  214  rm -rf learn-git

  215  git clone git@github.com:mir-owahed/learn-git-github.git

  216  cd learn-git-github/

  217  code .

  218  ls

  219  git branch

  220  git checkout -b hot-fix

  221  git branch

  222  git status

  223  git add .

  224  git commit -m "updated first blog post"

  225  git status

  226  git push -u origin hot-fix

  227  git status

  228  git push -u origin hot-fix

  229  git branch

  230  git branch main

  231  git checkout main

  232  git status

  233  git add .

  234  git commit -m "i line added - step by step"

  235  git push -u origin main

  236  git fetch

  237  git pull --ff

  238  git status

  239  git push -u origin main
```


```
135  git clone git@github.com:mir-owahed/git-test.git

  136  cd git-test/

  137  code .

129  git status
  130  git add .
  131  git commit -m "node_modules exclude"
  132  git remote -v

  134  git config --global --get user.name
  135  git config --global --get user.email
  136  git status

  138  git remote -v
  139  git log
  140  git push -u origin main
  141  git status
  142  git status -sb
  143  git status
  144  git commit -am "comment added in command_vm.txt file"
  145  git status
  146  git push -u origin main
  147  git fetch
  148  git status
  149  git pull
  150  git pull origin
  151  git pull --ff
  152  git status
  153  git log
  154  git status

  156  git push -u origin main
  157  history
  .........................
  git branch
  .................
  155  git branch
  156  git checkout main
  157  git branch
  158  git status
  159  git checkout hotfix
  160  git checkout main
  161  git merge hotfix
  162  git branch
  163  git branch -d hotfix
  164  git branch
  165  git status
  166  git push
  167  git pull
  168  git branch
  169  git push
```
