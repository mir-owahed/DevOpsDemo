
# Git and GitHub for Absolute Beginners

In this guide, we'll cover the essentials of connecting a local Git repository to GitHub using SSH, setting up Git configurations, and pushing code to GitHub. Follow along for a complete step-by-step process.

---
**🎥 Watch the Video Tutorial**  
[![Git and GitHub for Absolute Beginners](https://img.youtube.com/vi/Fnom1RW9yPw/0.jpg)](https://youtu.be/Fnom1RW9yPw)

---

## 1. Generating an SSH Key

SSH keys provide a secure way to connect to GitHub. Let’s create an SSH key to link your local repository.

```bash
# Generate a new SSH key
ssh-keygen -t ed25519 -C "your_email@gmail.com"

# List SSH files to verify
ls ~/.ssh/
```

**Step-by-Step:**
1. Run the SSH generation command and press enter through prompts.
2. After creating, navigate to the `.ssh` folder:
    ```bash
    cd ~/.ssh/
    ```
3. Display the public key using:
    ```bash
    cat <your-key>.pub
    ```
4. Copy the entire key displayed.

## 2. Adding SSH Key to GitHub

1. Go to **GitHub** and sign in.
2. Navigate to **Settings > SSH and GPG keys**.
3. Click **New SSH Key** and paste your SSH key.
4. Give it a name and save.

---

## 3. Configuring Git

Now, let’s configure Git with your username and email:

```bash
# Set Git username
git config --global user.name "Mir"

# Verify username
git config --global --get user.name

# Set Git email
git config --global user.email "your_email@gmail.com"

# Verify email
git config --global --get user.email
```

## 4. Creating a Repository on GitHub

1. Go to your GitHub profile.
2. Click on **New Repository**.
3. Give your repository a name (e.g., `learn-git-github`), set it to public or private, and click **Create Repository**.

---

## 5. Pushing Code to GitHub

Let’s initialize our project folder as a Git repository, add files, and push to GitHub.

1. **Check Git Version** (optional):
    ```bash
    git --version
    ```

2. **Initialize Repository**:
    ```bash
    git init
    ```

3. **Add Files and Commit**:
    ```bash
    git status           # Check status of files
    git add .            # Stage all changes
    git commit -m "Initial commit"
    ```

4. **Link Local to Remote Repository**:
    ```bash
    git remote add origin git@github.com:mir-owahed/learn-git-github.git
    git remote -v        # Verify the remote
    ```

5. **Push to GitHub**:
    ```bash
    git branch -M main   # Rename default branch to 'main'
    git push -u origin main
    ```

---

## 6. Cloning the Repository

If you need to clone this repository later:

```bash
git clone git@github.com:mir-owahed/learn-git-github.git
cd learn-git-github/
```

---

## 7. Creating and Pushing a Branch

Let’s create a new branch called `hot-fix` to make updates independently from the main branch.

1. **Create the `hot-fix` Branch**:
    ```bash
    git branch              # Check current branch
    git checkout -b hot-fix # Create and switch to 'hot-fix' branch
    ```

2. **Update Code in `hot-fix` Branch**:
   Make changes to your code, stage, and commit them:
    ```bash
    git add .
    git commit -m "updated first blog post"
    ```

3. **Push `hot-fix` Branch to GitHub**:
    ```bash
    git push -u origin hot-fix
    ```

At this point, the `hot-fix` branch with your updates is pushed to GitHub as a separate branch. You can later review and merge it into the main branch when ready.

---

## 8. Syncing with Remote

To stay updated with remote changes, use:

```bash
git fetch            # Fetch changes
git pull --ff        # Pull with fast-forward
```

---

## Conclusion

Congratulations! You've learned the basics of Git and GitHub, including SSH setup, configuration, and branching. Happy coding!
```
