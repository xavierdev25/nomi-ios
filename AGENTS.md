# AGENTS.md — `nomi-ios`

Instrucciones para agentes de IA (y personas) que trabajen en este repositorio.

## Qué es

App iOS nativa (SwiftUI, Swift 6) del estudiante de Nomi. Consume la API REST de
`nomi-backend`; no tiene backend propio ni dependencias de terceros.

## Antes de cambiar algo, lee

| Si vas a… | Lee primero |
|---|---|
| Añadir o cambiar una pantalla | [docs/PRD.md](docs/PRD.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) |
| Llamar a un endpoint nuevo o cambiar un modelo | [docs/API.md](docs/API.md) y el DTO del backend correspondiente |
| Tocar sesión, tokens o datos del usuario | [docs/SECURITY.md](docs/SECURITY.md) |
| Escribir cualquier código | [docs/CODE_STYLE.md](docs/CODE_STYLE.md) |
| Añadir o cambiar tests | [docs/TESTING.md](docs/TESTING.md) |

Si la documentación contradice el código, señálalo antes de hacer un cambio grande.

## Comandos

```bash
xcodegen generate
xcodebuild -project NomiIOS.xcodeproj -scheme NomiIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project NomiIOS.xcodeproj -scheme NomiIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

- `NomiIOS.xcodeproj` se genera: los cambios de configuración van en `project.yml`, nunca en el
  proyecto.
- Un archivo nuevo en `NomiIOS/` o `NomiIOSTests/` entra solo al regenerar.

## Reglas

- **Compila sin warnings** con concurrencia estricta de Swift 6. No silencies avisos con
  `@unchecked Sendable` o `nonisolated(unsafe)` sin explicar por qué es seguro.
- **Todo cambio de lógica lleva test.** Corre la suite completa antes de terminar.
- **El backend es la autoridad** sobre dinero, stock y permisos. La app puede validar para dar mejor
  experiencia, pero nunca calcula el monto que se cobra ni decide permisos.
- **Los ViewModel se guardan en `@State`** en su vista (ver ARCHITECTURE.md): con `let` se pierde el
  estado al cambiar de pestaña.
- **Estilos solo del design system:** colores `NMColors`, espaciado `NMSpacing`, texto
  `nmStyle(_:)`, componentes `NM*`. Nada de colores o tamaños sueltos.
- **Documenta en español** y explica el porqué, no el qué (ver CODE_STYLE.md).
- **Actualiza la documentación** en el mismo cambio si alteras una convención, un contrato o un flujo.

## Nunca

- Guardar tokens o datos del usuario fuera del Keychain, ni imprimirlos en logs.
- Inventar endpoints, campos o reglas del backend: compruébalos en `nomi-backend`.
- Desactivar la renovación de sesión o la verificación de errores para "hacer funcionar" algo.
- Introducir dependencias de terceros sin acordarlo.
- Hacer commit o push sin que te lo pidan.
