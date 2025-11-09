# Contributing

Thank you for considering contributing to W Anchor!

---

## How Can I Contribute?

### Reporting Bugs

-   Ensure the bug was not already reported by searching on GitHub under [Issues](https://github.com/J-shw/W-Anchor/issues).
-   If you're unable to find an open issue, [open a new one](https://github.com/J-shw/W-Anchor/issues/new?template=bug_report.md). Be sure to include a title, a clear description, and as much relevant information as possible.

### Suggesting Enhancements

-   Open a new issue to discuss your idea.
-   Clearly describe the feature and why it would be useful.

---

## Branching Model

-   `dev` is the default branch. All new development should be merged here.
-   `main` is considered live, production-ready code.

---

## Pull Request Process

This section applies to code contributions.

1.  Fork the repository and create your branch from `dev`.

2.  Create a new branch named relative to your changes

3.  Add your changes and commit them with a clear commit message.

4.  Push your branch and open a pull request against the `dev` branch.

5.  **Name your pull request correctly.**

    Since this is a monorepo, please include the project scope in the name using the format:
    `<type>/<scope>/<short-description>`

    **`<type>` can be one of the following:**
    * `Feature`: For new features.
    * `Bugfix`: For fixing a bug.
    * `Docs`: For changes to documentation.
    * `Chore`: For maintenance tasks (e.g., updating dependencies).
    * `Refactor`: For code improvements without changing functionality.
    * `Style`: For code formatting changes.
    * `Test`: For adding or improving tests.

    **`<scope>` is one of the following:**
    * `app`: The main application.
    * `repo`: Changes to the repository itself (CI, config, etc.).

    **Examples:**
    * `Bugfix/app/fix user login crash`

6.  Clearly describe the changes in your pull request.