# Changelog — `nomi-ios`

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). Cada cambio
relevante para quien usa o mantiene la app va en **No publicado** hasta la siguiente versión.

## [No publicado]

### Añadido
- URL del backend configurable por compilación (`NOMI_API_BASE_URL` en `Config/*.xcconfig`, con
  un `Config/Local.xcconfig` opcional no versionado) para usar un iPhone físico contra el backend
  del Mac. Por defecto sigue siendo `localhost` en Debug. Incluye el aviso de red local
  (`NSLocalNetworkUsageDescription`) y 6 tests.
- Renovación preventiva de la sesión: el access token se renueva antes de expirar leyendo su `exp`.
- Pagar o cancelar un pedido pendiente desde el seguimiento.
- Cuenta atrás del plazo para pagar en el seguimiento (`segundosParaPagar` del backend); al vencer
  se oculta "Pagar" y se avisa de que el pedido se cancelará.
- Desglose de importes (subtotal, propina, cargos y total cobrado) en el detalle del pedido.
- Pantalla de error de arranque con reintento cuando la sesión guardada no se puede verificar.
- Validación del registro en la app con las mismas reglas y mensajes que el backend.
- Autocompletar y sugerencia de contraseñas en los campos de login y registro.
- Revocación de la sesión en el servidor al cerrar sesión.
- Suite de tests (Swift Testing) de red, sesión, carrito, pedidos y validación.
- Documentación: README, AGENTS, `docs/` y comentarios de código.

### Cambiado
- **La marca es Nomi:** app y módulo `Nomi`, bundle `com.nomi.ios`, servicio del Keychain
  `com.nomi.ios.tokens` (la sesión guardada con el identificador anterior no se recupera: hay
  que volver a iniciar sesión), `JSONDecoder.nomi` y el campo `comisionNomi` del pedido.
- El prefijo del sistema de diseño pasa a `NM`: `NMColors`, `NMSpacing`, `NMButton`,
  `nmStyle(_:)`, `Image(nmIcon:)`, etc.

### Corregido
- Las pantallas perdían su estado al cambiar de pestaña (ViewModel no guardado en `@State`).
- Tirar para refrescar mostraba "error de conexión" al cancelarse la petición.
- Una sesión válida se cerraba por un fallo de red o un error 5xx durante la renovación.
- El total de la lista de pedidos no incluía propina ni cargos.
- Se podía elegir una propina mayor al 50 % del subtotal y el backend rechazaba el pedido.
- Reintentar un pago fallido creaba un segundo pago en lugar de reutilizar el existente.
- Tras pagar, "atrás" volvía al checkout de un pedido ya creado.
- El carrito de un usuario seguía visible tras cerrar sesión y entrar con otro.
- Los errores de validación del backend mostraban un mensaje genérico en lugar del de cada campo.
