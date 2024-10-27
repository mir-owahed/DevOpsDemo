# Create & Deploy Static Website Using Docusaurus & GitHub Pages, Customize Using Markdown

In this tutorial, we will walk through the process of creating and deploying a static website using Docusaurus and GitHub Pages, with the ability to customize the site using Markdown files.

## Prerequisites

Before we begin, ensure you have the following prerequisites:
1. **Set up SSH with GitHub account.**
2. **Install Node.js and Yarn** using the instructions below.
3. **Create a repository on GitHub** to host your website.
---
## Watch the Tutorial

[![Create a Portfolio or Documentation Website with Docusaurus & GitHub Pages | Auto Deployment](https://img.youtube.com/vi/IT4f7tPpyHE/0.jpg)](https://youtu.be/IT4f7tPpyHE)

[Watch the full tutorial on YouTube](https://youtu.be/IT4f7tPpyHE) to follow along with step-by-step instructions.

---

### Step 1: Set up SSH with GitHub

1. **Generate a new SSH key**:

    ```bash
    ssh-keygen -t ed25519 -C "your_email@example.com"
    ```

2. **Copy the SSH key** to your clipboard:

    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```

3. **Add the SSH key** to your GitHub account by navigating to [GitHub SSH settings](https://github.com/settings/keys) and pasting the key there.

---

### Step 2: Install Node.js and Yarn on local pc

To install **Node.js** and **Yarn**, we will use **nvm** (Node Version Manager).

```
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Close the terminal and again open terminal

# download and install Node.js (you may need to restart the terminal)
nvm install 20
or
nvm install node

# verifies the right Node.js version is in the environment
node -v # should print `v20.14.0`

# verifies the right NPM version is in the environment
npm -v # should print `10.7.0`

# Yarn install via npm
npm install --global yarn
yarn --version
```
---

### Step 3: Create a GitHub Repository

Create a new repository on GitHub named `tech-with-mir` (or any name you prefer).

---

### Step 4: Initialize Docusaurus Project on pc

To create a Docusaurus site, use the `npx` command. You can choose between **JavaScript** or **TypeScript**:

For JavaScript:

```bash
npx create-docusaurus@latest my-website classic --javascript
```

Navigate into the project folder:

```bash
cd my-website
```

---

### Step 5: Start Docusaurus Local Development Server

To start the local development server, run:

```bash
npx docusaurus start
```

Visit `http://localhost:3000` to view your website. You can start customizing it with Markdown files in the `docs/` or `src/pages/` directories.


---

### Step 6: Set up Git and Push to GitHub

Once you're happy with your local setup, initialize the Git repository and push your changes to GitHub:

1. Initialize Git:

    ```bash
    git init
    git status
    ```

2. Add all files and commit:

    ```bash
    git add .
    git commit -m "Initial commit for Docusaurus site"
    ```

3. Set the default branch and push to GitHub:

    ```bash
    git branch -M main
    git remote add origin git@github.com:your-username/tech-with-mir.git
    git push -u origin main
    ```

---

### Step 7: Configure `docusaurus.config.js` for GitHub Pages Deployment

To deploy the site to GitHub Pages, you need to update the `docusaurus.config.js` file:

```javascript
module.exports = {
  url: 'https://your-username.github.io', // Your GitHub Pages URL
  baseUrl: '/tech-with-mir/', // The repository name, preceded by a slash
  organizationName: 'your-username', // Your GitHub username
  projectName: 'tech-with-mir', // Your repository name
  deploymentBranch: "gh-pages", // Deployment branch for GitHub Pages
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
};
```

---

### Step 8: Deploy to GitHub Pages

Docusaurus provides a simple way to deploy your website to GitHub Pages with a single command:

```bash
yarn
yarn start
yarn build
USE_SSH=true yarn deploy
```

This will build and deploy your website to the `gh-pages` branch. The site will be live at `https://your-username.github.io/tech-with-mir/`.

---

### Step 9: Customize Your Website Using Markdown

Docusaurus makes it easy to add new content using Markdown files. You can:

- Edit pages under `src/pages/` for static content.
- Add new documentation under the `docs/` directory.

For example, create a new page by adding a Markdown file to `src/pages/`:

```markdown
# Welcome to Tech with Mir

This is a custom page created using Markdown!

- Easy to write
- Fully customizable
- Deployed with GitHub Pages
```

---

### Step 10: Keep Your Site Updated

Every time you make updates to your site, follow these steps to push and deploy:

1. Commit your changes:

    ```bash
    git add .
    git commit -m "Updated site content"
    ```

2. Push to GitHub:

    ```bash
    git push -u origin main
    ```

3. Deploy again:

    ```bash
    yarn build
    USE_SSH=true yarn deploy
    ```

---

### Conclusion

By following this guide, you’ve successfully created, customized, and deployed a static website using Docusaurus and GitHub Pages.
