# CareerMate – AI Career Assistant

CareerMate is an AI-powered career assistant built with Flutter.  
It helps users analyze their CV, identify skill gaps, explore career paths, and receive personalized career guidance.

## 🚀 Features

- AI-powered CV analysis
- Skill-gap identification
- Personalized learning recommendations
- Career-path guidance
- Job opportunity recommendations
- Backend/API integration
- Cloud-based deployment

## 🛠️ Technology Stack

### Frontend
- Flutter
- Dart
- Flutter Web

### Backend & Services
- REST API
- Supabase
- Render

### DevOps & Cloud
- Git
- GitHub
- GitHub Actions
- CI/CD
- GitHub Secrets
- Automated build and deployment
- GitHub Pages

## ⚙️ DevOps & CI/CD

CareerMate uses GitHub Actions to automate the Flutter Web build and deployment process.

The CI/CD pipeline:

1. Developer pushes changes to the `main` branch.
2. GitHub Actions starts automatically.
3. Flutter dependencies are installed.
4. The Flutter Web application is built in release mode.
5. Environment variables are provided securely through GitHub Secrets.
6. The build output is uploaded as a GitHub Pages artifact.
7. The application is automatically deployed to GitHub Pages.

This makes the deployment process reproducible and reduces manual deployment steps.

## 🔐 Environment Configuration

The application uses build-time environment variables for configuration.

Sensitive configuration values are stored using GitHub Secrets and passed to the Flutter build through `--dart-define`.

No sensitive credentials are stored directly in the source code.

## 🧪 Troubleshooting & Lessons Learned

During development, a GitHub Actions build failure was investigated using the CI logs.

The issue was traced to a Dart constant-expression problem in the application configuration.

After identifying the root cause, the configuration was corrected and the CI/CD pipeline successfully completed.

This project provided practical experience with:

- CI/CD troubleshooting
- Build failures
- Environment configuration
- GitHub Actions logs
- Automated deployment

## 🌐 Live Demo

[CareerMate – Live Website](https://mehyoreine330-ui.github.io/careermate_flutter/)

## 📂 Project Structure

```text
lib/
├── core/
├── features/
├── main.dart

.github/
└── workflows/
    └── deploy-pages.yml
