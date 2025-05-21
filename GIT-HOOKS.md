# Git Hooks for CI/CD Pipeline

This project uses Git hooks to maintain code quality and enforce standards before changes are committed.

## Available Hooks

### pre-commit

The pre-commit hook runs before finalizing a commit and performs the following checks:

- CSS linting with Stylelint to ensure code quality and consistency

## Installation

### Automatic Installation

Run the setup script to install all hooks:

**Windows:**
```powershell
.\setup-hooks.ps1
```

**Unix-like Systems (Linux/macOS):**
```bash
chmod +x setup-hooks.sh
./setup-hooks.sh
```

### Manual Installation

1. Configure Git to use hooks from the repository:

```bash
git config core.hooksPath .githooks
```

2. Make sure the hooks are executable (Unix-like systems):

```bash
chmod +x .githooks/*
```

## Skipping Hooks

In the rare case that you need to bypass hooks (not recommended), you can use:

```bash
git commit --no-verify -m "Your commit message"
```

## Adding New Hooks

To add a new hook:

1. Create the hook script in the `.githooks` directory
2. Make it executable (Unix systems)
3. Update documentation and communicate to the team

## Troubleshooting

If hooks are not running:

1. Verify that Git is using the correct hooks path:
   ```bash
   git config core.hooksPath
   ```
   It should return `.githooks`.

2. Check that hooks are executable (Unix-like systems).

3. For Windows users, ensure the hooks are correctly formatted with LF line endings.
