# Guía de Contribución

## Flujo de trabajo
Usamos **GitHub Flow**:
- Ramas cortas `feature/*`
- PR hacia `main`
- CI verde antes de merge
- Se elimina la rama después del merge

## Convención de commits
Usamos **Conventional Commits**:
- feat(scope): nueva funcionalidad
- fix(scope): corrección
- chore: mantenimiento o docs

## Versionado
Usamos **SemVer** (`vX.Y.Z`).

## Cómo crear una rama
```bash
git checkout -b feature/nueva-funcionalidad
git push -u origin feature/nueva-funcionalidad
