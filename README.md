# To-Do List Application

![Development Deployment](https://github.com/<your-username>/todo-list-app/actions/workflows/dev-deploy.yml/badge.svg)
![Production Deployment](https://github.com/<your-username>/todo-list-app/actions/workflows/prod-deploy.yml/badge.svg)

A simple and efficient to-do list web application with CI/CD pipeline for automated deployments.

## Features

- Add, check off, and delete tasks
- Data persists in local storage
- Responsive design
- Automated deployment pipeline
- Cross-platform build support
- Continuous Integration with automated testing

## CI/CD Pipeline

This repository uses GitHub Actions for CI/CD:

- **Development Environment**: Automatically deployed when code is pushed to the `dev` branch
- **Production Environment**: Automatically deployed when code is pushed to the `main` branch

## Deployment URLs

- **Development**: `https://<your-github-username>.github.io/<repo-name>/dev/`
- **Production**: `https://<your-github-username>.github.io/<repo-name>/prod/`

## Local Development

1. Clone the repository
2. Install dependencies: `npm install`
3. Start local server: `npm start`
4. Open browser at `http://localhost:3000`

## Local Deployment Testing

To test the deployment build locally:

```bash
# Build and serve the production files
npm run deploy
```

This will create the `dist` directory and serve it at `http://localhost:3000`.

## Project Structure

- `To-do.html` - Main HTML file
- `script.js` - JavaScript functionality
- `style.css` - Styling
- `package.json` - Project configuration and scripts
- `.github/workflows/` - CI/CD pipeline configuration
