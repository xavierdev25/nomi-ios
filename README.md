# Nomi — App iOS (`nomi-ios`)

App nativa para estudiantes de **Nomi**, la plataforma de pedidos de comida dentro del campus:
el estudiante pide a una tienda del campus y recibe el pedido en su aula, entre clases.

Cubre el flujo completo del rol `ESTUDIANTE`: catálogo, búsqueda, recomendaciones de IA,
carrito, checkout con MercadoPago, seguimiento del pedido, favoritos y perfil. Habla con el
backend `nomi-backend` por REST.

## Stack

| | |
|---|---|
| Lenguaje | Swift 6 con concurrencia estricta |
| UI | SwiftUI, arquitectura MVVM con `@Observable` |
| Mínimo | iOS 17, solo iPhone |
| Dependencias de terceros | Ninguna |
| Proyecto | Generado con [XcodeGen](https://github.com/yonaskolb/XcodeGen) desde `project.yml` |
| Tests | Swift Testing |

## Requisitos

- Xcode 16 o superior.
- XcodeGen (`brew install xcodegen`).
- El backend corriendo en `http://localhost:8080` (ver su README) para usar la app en el simulador.

## Empezar

```bash
xcodegen generate          # genera NomiIOS.xcodeproj (no se versiona)
open NomiIOS.xcodeproj     # y ejecutar el esquema NomiIOS en un simulador
```

Desde la terminal:

```bash
xcodebuild -project NomiIOS.xcodeproj -scheme NomiIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Tests:

```bash
xcodebuild -project NomiIOS.xcodeproj -scheme NomiIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

> La URL del backend es fija por configuración de compilación (`NetworkConfig.swift`): en Debug
> apunta a `localhost`, así que solo funciona en el simulador.

## Estructura

```text
NomiIOS/
├── App/            Punto de entrada y raíz de composición (AppContainer)
├── Networking/     APIClient, renovación de sesión, JWT, Keychain, endpoints por dominio
├── Models/         DTOs del backend (Codable)
├── Stores/         Estado global observable: sesión (AuthStore) y carrito (CartStore)
├── Navigation/     Enrutado raíz, pestañas y rutas apiladas
├── Features/       Una carpeta por pantalla o flujo: View + ViewModel
├── DesignSystem/   Tokens (color, espaciado, movimiento), tipografía, iconos y componentes NM*
└── Utils/          Constantes de negocio y formateadores
NomiIOSTests/       Tests (Swift Testing)
docs/               Documentación del proyecto
```

## Documentación

| Documento | Contenido |
|---|---|
| [docs/PRD.md](docs/PRD.md) | Requisitos del producto para la app del estudiante |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Capas, flujo de datos, navegación, concurrencia y decisiones |
| [docs/API.md](docs/API.md) | Contrato con el backend tal como lo usa la app |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Tokens, tipografía, componentes y reglas visuales |
| [docs/SECURITY.md](docs/SECURITY.md) | Sesión, tokens, datos y reglas de seguridad |
| [docs/CODE_STYLE.md](docs/CODE_STYLE.md) | Convenciones de código y de documentación |
| [docs/TESTING.md](docs/TESTING.md) | Cómo se prueba y qué cubren los tests |
| [CHANGELOG.md](CHANGELOG.md) | Cambios relevantes |
| [AGENTS.md](AGENTS.md) | Instrucciones para agentes de IA que trabajen en el repo |

La documentación general del sistema (producto, reglas de negocio, arquitectura de todos los
servicios) vive en el sitio Starlight de `nomi-docs`.
