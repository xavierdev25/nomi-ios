# ARCHITECTURE.md — `nomi-ios`

## 1. Visión general

App SwiftUI con MVVM. Sin dependencias externas: todo es Foundation, SwiftUI y Security.

```text
Vista (SwiftUI) ──► ViewModel (@Observable, @MainActor) ──► XxxAPI ──► APIClient ──► backend
      │                                                                   │
      └──── lee del entorno ──► AuthStore / CartStore                      └──► TokenRefresher (actor)
                                                                           └──► KeychainTokenStore
```

## 2. Capas

| Capa | Carpeta | Responsabilidad |
|---|---|---|
| Composición | `App/` | `AppContainer` crea todas las dependencias una vez y las conecta. |
| Red | `Networking/` | `APIClient` (HTTP, sesión, errores), `TokenRefresher`, `JWT`, `KeychainTokenStore`, un `XxxAPI` por dominio. |
| Modelos | `Models/` | DTOs `Codable` que reflejan las respuestas del backend. |
| Estado global | `Stores/` | `AuthStore` (sesión) y `CartStore` (carrito), inyectados en el entorno. |
| Navegación | `Navigation/` | Pantalla raíz según la sesión, pestañas y rutas apiladas. |
| Pantallas | `Features/` | Una vista + su ViewModel por pantalla. |
| Diseño | `DesignSystem/` | Tokens y componentes reutilizables. |

Las dependencias van de arriba abajo: `Networking/` no conoce `Stores/` (el aviso de sesión
expirada entra por el protocolo `SessionExpiring`).

## 3. Composición

`AppContainer` es la raíz de composición. `APIClient` necesita a `AuthStore` (para avisar de sesión
expirada) y `AuthStore` necesita un `AuthAPI` construido sobre ese cliente: el ciclo se rompe
asignando `authStore.authAPI` después de crear ambos.

Los stores van al entorno de SwiftUI; las APIs se pasan explícitamente al construir cada
ViewModel en `StudentRootView`/`StudentTabView`.

## 4. Estado y ViewModels

- Los ViewModel son `@MainActor @Observable final class`.
- **Cada vista guarda su ViewModel en `@State`.** El padre lo construye en `body` y, al
  re-evaluarse (por ejemplo al cambiar de pestaña), crea una instancia nueva; `@State` conserva
  la primera. Con `let` la pantalla perdía su estado.
- Estado de carga: la lista visible se mantiene durante una recarga; el indicador solo sustituye
  al contenido en la primera carga.
- `.refreshable` ejecuta la recarga en una tarea propia (`Task { … }.value`): SwiftUI cancela la
  tarea del refresh si la vista se actualiza a mitad y abortaba peticiones ya respondidas.
- Una `CancellationError` nunca se muestra como error.

## 5. Navegación

- `RootRouterView` decide la raíz: verificando sesión, app del estudiante, error de arranque
  (sesión guardada sin poder verificarse) o flujo de autenticación.
- `StudentRootView` tiene **un solo `NavigationStack`** que envuelve la barra de pestañas; las
  pantallas de detalle (`StudentRoute`) se apilan encima de la pestaña activa.
- Tras iniciar un pago, el checkout reemplaza la pila por el seguimiento del pedido.
- Al cambiar el usuario (login, logout, sesión expirada) se reinicia el carrito.

## 6. Red y sesión

- `APIClient.send` construye la petición, añade `Authorization: Bearer` y traduce errores a
  `APIError` (mensajes en español).
- **Renovación preventiva:** antes de cada petición autenticada lee el `exp` del access token y,
  si le quedan menos de 60 s, lo renueva.
- **Red de seguridad:** ante un `401`, renueva y reintenta una sola vez.
- `TokenRefresher` es un **actor** que garantiza una sola renovación en vuelo. Como el backend rota
  el refresh token y trata el reuso como robo, si otra petición ya renovó, reutiliza ese par.
- Solo un refresh token **rechazado** (400/401/403) cierra la sesión. Un fallo de red o un 5xx
  durante la renovación conserva la sesión.
- Fechas: `BackendDate` decodifica el `LocalDateTime` sin zona del backend.

## 7. Concurrencia

- Swift 6 con `SWIFT_STRICT_CONCURRENCY=complete`.
- UI, stores y ViewModels en `@MainActor`. `APIClient` es `Sendable` sin estado mutable;
  `TokenRefresher` es el único actor.
- `AuthStore.sessionDidExpire()` es `nonisolated` porque lo llama la capa de red desde cualquier
  contexto; salta al `MainActor` internamente.

## 8. Decisiones

| Decisión | Motivo |
|---|---|
| Sin dependencias de terceros | Menos superficie de ataque y mantenimiento; Foundation cubre lo necesario. |
| Proyecto generado con XcodeGen | Sin conflictos en `.pbxproj`; `project.yml` es la fuente de verdad. |
| Seguimiento por consulta cada 5 s | Suficiente para el producto y más simple que WebSocket (que además no autoriza suscripciones). |
| Carrito en memoria | Un carrito pertenece a una sesión corta; persistirlo añadía casos sin valor claro. |
| Renovación de sesión preventiva | Funciona aunque el backend responda con un código inesperado a un token vencido. |

## 9. Limitaciones conocidas

- La URL del backend está fija en `NetworkConfig` (sin entornos).
- Las fechas del backend llegan en hora local del servidor sin zona y se interpretan como UTC:
  hay que corregirlo antes de mostrarlas.
- Detalle de todas las limitaciones del sistema: auditoría técnica en `nomi-docs`.
