# Changelog

## 1.1.0 — 2026-10-15

- **Stack configurable:** las normas pasan a ser independientes de la tecnología. Cada proyecto declara frontend, backend, base, carpetas, equivalencias de patrones y comandos en `standards/stack.md` (plantilla).
- `profiles/`: tres stacks listos (Next.js + FastAPI + PostgreSQL, React/Vite + NestJS + PostgreSQL, Nuxt + Django + PostgreSQL).
- Skill nueva `std-stack-setup`: detecta lo que hay en el repo, pregunta lo que falta y completa `stack.md`.
- Instaladores: `--stack <perfil>` / `-Stack` y `--list-stacks` / `-ListStacks`, con validación del nombre.
- Normas, skills y reglas por herramienta leen comandos y rutas de `stack.md`; `globs` y `applyTo` con extensiones de varios lenguajes.

## 1.0.0 — 2026-10-15

- Primera versión: normas (`standards/`), 7 skills (`skills/`), reglas para Claude Code, AGENTS.md, Cursor, GitHub Copilot, Windsurf, Cline y Gemini CLI (`rules/`), e instaladores seguros para sh y PowerShell (`scripts/`).
