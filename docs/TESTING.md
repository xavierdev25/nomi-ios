# TESTING.md — `nomi-ios`

## 1. Cómo correr los tests

```bash
xcodegen generate
xcodebuild -project NomiIOS.xcodeproj -scheme NomiIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

O `⌘U` en Xcode. Los tests no necesitan el backend: la red se simula.

## 2. Herramientas

- **Swift Testing** (`import Testing`, `@Suite`, `@Test`, `#expect`, `#require`). No se usa
  XCTest.
- El target de tests se inyecta en la app (`TEST_HOST`) e importa el módulo con
  `@testable import Nomi`.

## 3. Dobles de prueba (`TestDoubles.swift`)

| Doble | Para qué |
|---|---|
| `InMemoryTokenStore` | Sustituye al Keychain. |
| `SessionExpirySpy` | Cuenta los avisos de sesión expirada. |
| `makeJWT(expiresIn:)` | Genera un JWT sin firmar con el `exp` deseado. |
| `StubURLProtocol` | Responde cada petición con un handler y registra lo enviado (ruta, método, cabecera `Authorization`, cuerpo). |
| `StubbedNetwork.makeClient` | La pila de red **real** (`APIClient` + `TokenRefresher`) sobre la sesión simulada. |

**Toda suite que use `StubURLProtocol` va anidada en `extension StubbedNetwork`.** Su estado es
estático y Swift Testing corre las suites en paralelo; `.serialized` en el padre las serializa a
todas. Una suite de red fuera de `StubbedNetwork` produce fallos intermitentes.

## 4. Qué está cubierto

| Suite | Cubre |
|---|---|
| `APIClient — renovación de sesión` | Renovación preventiva, reintento ante 401, refresh rechazado cierra sesión, fallo de red y 5xx la conservan, sin bucles tras renovar, una sola renovación con peticiones concurrentes, cancelación no es error. |
| `JWT` | Lectura de `exp`, margen de expiración, tokens malformados. |
| `NetworkConfig — URL del backend` | La URL configurada se usa; si falta, no se sustituyó o no es http/https con host, se usa la de siempre. |
| `Order` | `chargedTotal` suma propina y cargos; cargos ausentes cuentan como cero; plazo para pagar desde que llega la respuesta, solo en pedidos pendientes y con plazo. |
| `OrderTrackingViewModel.stableDeadline` | La cuenta atrás no salta con la deriva de cada consulta, pero sigue un cambio real del plazo. |
| `CartStore — propina` | Máximo del 50 % con redondeo como el backend, propina excesiva ignorada, se descarta al reducir el carrito, `reset` y `clear`. |
| `PaymentsAPI — reutilizar el pago del pedido` | Pago existente reutilizado; pago ausente creado. |
| `AuthStore — arranque y logout` | Arranque sin conexión conserva la sesión; sesión rechazada borra tokens; logout local y revocación en servidor. |
| `Validación de registro` / `Mensajes de error del backend` | Reglas y mensajes iguales a los del backend; errores de validación muestran los campos. |

Sin cubrir: vistas y ViewModels de pantalla (se verifican a mano en el simulador).

## 5. Cómo escribir un test

- Nombre del test en inglés y descriptivo (`rejectedRefreshTokenEndsTheSession`); nombre de suite
  en español.
- Un comportamiento por test. Comprueba el resultado observable (lo que recibe el usuario, lo que
  queda en el store, las peticiones enviadas), no detalles internos.
- Usa respuestas **reales** del backend como cuerpo de los stubs: un JSON inventado oculta
  diferencias de contrato (fechas sin zona, campos nulos).
- Para red: anida la suite en `StubbedNetwork`, llama a `StubURLProtocol.reset` al principio y
  consulta `StubURLProtocol.requests` o `requests(to:)` para verificar lo enviado.

## 6. Regla

Todo cambio de lógica (red, sesión, stores, cálculos, validaciones, modelos) lleva test. Corre la
suite completa antes de dar un cambio por terminado; un test roto no se desactiva sin explicar por
qué.

## 7. Verificación manual

Para cambios de UI: generar, compilar y recorrer el flujo en el simulador con el backend local
corriendo (ver `README.md` del backend). Flujos críticos: login, arranque con token vencido,
compra completa con pago sandbox, pagar y cancelar un pedido pendiente, logout.
