# CODE_STYLE.md — `nomi-ios`

## 1. Idioma

- **Código** (tipos, funciones, variables): inglés, salvo los términos del dominio que ya vienen
  del backend en español (`propina`, `aula`, `tarifaServicio`, `OrderStatus.enCamino`).
- **Textos de UI, errores, comentarios y documentación:** español.
- Los campos de los modelos se llaman **igual que en el JSON del backend** para evitar
  `CodingKeys` innecesarias.

## 2. Nombres y archivos

- Un tipo principal por archivo, con el mismo nombre.
- Pantallas: `XxxView` + `XxxViewModel` en `Features/<Área>/<Pantalla>/`.
- Endpoints: `XxxAPI` en `Networking/Endpoints/`, uno por dominio del backend.
- Componentes del design system con prefijo `NM`.
- Booleanos en forma de pregunta: `isLoading`, `canTip(_:)`, `isApproved`.

## 3. SwiftUI y estado

- ViewModel: `@MainActor @Observable final class`, con estado `private(set)` y métodos
  `async` para las acciones.
- En la vista, el ViewModel va en `@State` (`@State var viewModel: XxxViewModel`).
- Los stores globales se leen con `@Environment(AuthStore.self)` / `@Environment(CartStore.self)`.
- Carga inicial con `.task { await viewModel.load() }`; recarga con
  `.refreshable { await viewModel.refresh() }`, donde `refresh()` envuelve `load()` en su propia
  `Task`.
- Patrón de carga:

  ```swift
  func load() async {
      isLoading = true
      defer { isLoading = false }
      do {
          items = try await api.list()
          errorMessage = nil
      } catch is CancellationError {
      } catch {
          errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo cargar…"
      }
  }
  ```

  La vista muestra el indicador de carga solo si `isLoading` y la lista está vacía.
- Vistas pequeñas: extrae subvistas (`private var header: some View`) cuando `body` crece.

## 4. Concurrencia

- Swift 6 con concurrencia estricta, **sin warnings**.
- Tipos compartidos entre contextos: `Sendable` de verdad (inmutables o actores). Evita
  `@unchecked Sendable` y `nonisolated(unsafe)`; si son imprescindibles, un comentario explica
  qué garantiza la seguridad (p. ej. un `NSLock`).
- No uses `DispatchQueue`: `async/await` y `Task`.
- Nunca muestres una `CancellationError` al usuario.

## 5. Errores

- La capa de red lanza `APIError`; su `errorDescription` ya está en español.
- Los ViewModel convierten errores en un `errorMessage` para la vista, con un mensaje por defecto
  específico de la pantalla.
- `try?` solo cuando el fallo es realmente irrelevante (p. ej. revocar la sesión al cerrar sesión).

## 6. Dinero

- Siempre `Decimal`, nunca `Double`.
- Formato con `Formatters.currency`.
- Las constantes de cobro (`NMConstants`) deben coincidir con el backend; el monto cobrado lo
  calcula el backend.

## 7. Comentarios y documentación

Los comentarios explican **por qué**, no qué hace el código.

- `///` (DocC) en tipos y en funciones públicas o internas cuyo comportamiento no es evidente:
  efectos secundarios, errores, contrato con el backend, decisiones.
- `//` dentro de funciones solo para lo que no se deduce leyendo: un caso límite, un requisito
  del backend, un bug que se evita.
- No documentes lo obvio (`/// El nombre del producto.` sobre `let nombre`).
- Parámetros con `- Parameter` / `- Parameters:` y retorno con `- Returns:` solo si aportan.
- Sin código comentado, sin `TODO` sin contexto, sin comentarios de cambios ("antes…",
  "arreglado…"): eso va en el historial de git.

```swift
/// `true` si el token ya expiró o expira dentro de `leeway` segundos. Un token sin `exp`
/// legible cuenta como vigente y queda cubierto por el reintento ante `401`.
static func isExpired(_ token: String, leeway: TimeInterval, now: Date = .now) -> Bool
```

## 8. Formato

- Sangría de 4 espacios. Llaves en la misma línea.
- Líneas razonablemente cortas; parte las llamadas largas en varias líneas por argumento.
- Orden dentro de un tipo: propiedades, `init`, métodos públicos, métodos privados.
- Sin imports innecesarios.

## 9. Proyecto

- Configuración en `project.yml`; nunca edites `NomiIOS.xcodeproj` a mano.
- Sin dependencias de terceros.
