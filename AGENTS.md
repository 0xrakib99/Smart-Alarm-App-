# AGENTS.md — WakeForce

## Project Overview
Build WakeForce, a premium mission-based alarm application using Flutter and Dart.

## 1. Architecture
- Use GetX for state management, dependency injection and navigation.
- Follow Clean Architecture with modular feature-based folders.
- Separate UI, controllers, models, services and repositories.
- Keep business logic outside UI widgets.
- Use reusable widgets and shared components.

## 2. UI/UX Rules
- Minimal, clean and professional design.
- Light Mode (white) is the default.
- Fully support Dark Mode.
- Use a consistent color palette and typography.
- No gradients, emojis, decorative AI patterns or unnecessary illustrations.
- No placeholder content, fake statistics or demo messages.
- Use meaningful Material or Lucide-style icons.
- Maintain consistent spacing, padding and border radius.
- Prefer subtle animations over excessive effects.
- Every screen must be responsive and polished.

## 3. Coding Standards
- Write clean, readable and maintainable code.
- Follow Dart naming conventions.
- Use `const` constructors wherever possible.
- Avoid duplicate code and unnecessary dependencies.
- Create reusable widgets, functions and components.
- Use null safety and proper error handling.
- Keep files focused on a single responsibility.
- Never use deprecated APIs without a valid reason.

## 4. Alarm & Mission Rules
- Support reliable scheduled alarms.
- Support background execution and Android alarm permissions.
- Never dismiss an alarm before required missions are completed.
- Support Math, Tap, Memory, Puzzle and Shake missions.
- Provide Easy, Medium and Hard difficulty levels.
- Handle Android lifecycle and notification permissions correctly.
- Never claim complete device locking; respect Android platform restrictions.

## 5. Development Rules
- Check existing project structure before modifying files.
- Do not unnecessarily rewrite working code.
- Fix errors without breaking existing features.
- Keep dependencies compatible with the current Flutter SDK.
- Test important features on real Android devices.
- Explain significant architectural changes briefly.

## 6. AI Agent Instructions
- Follow these rules for every implementation.
- Do not generate unnecessary files or features.
- Do not use temporary demo implementations as finished features.
- Prefer reusable, production-quality solutions.
- Ask before making major architectural changes.
- Always provide complete, working code when requested.

**Primary Goal:** Build a beautiful, reliable and production-ready alarm application with clean architecture and excellent user experience.