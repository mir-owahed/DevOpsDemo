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
