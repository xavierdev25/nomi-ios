# API.md — Contrato con el backend (vista desde la app)

La referencia completa de la API es Swagger UI del backend
(`http://localhost:8080/api/swagger-ui.html`, fuera de producción) y la sección de API de
`nomi-docs`. Este documento recoge **lo que la app usa y los detalles que no son obvios**.

## 1. Base

| Entorno | URL |
|---|---|
| Debug (simulador) | `http://localhost:8080/api` |
| Release | Marcador sin desplegar (`NetworkConfig.swift`) |

JSON en ambos sentidos. Las fechas llegan como `LocalDateTime` sin zona
(`2026-09-26T00:13:59.905824`), con 0 a 9 decimales: usar siempre `JSONDecoder.nomi`.

## 2. Autenticación

1. `POST /auth/login` → `accessToken` (24 h) y `refreshToken` (7 días), guardados en el Keychain.
2. Cada petición autenticada lleva `Authorization: Bearer <accessToken>`.
3. `POST /auth/refresh` rota el par: el refresh token usado queda revocado, y reutilizarlo revoca
   todas las sesiones del usuario.
4. `POST /auth/logout` revoca la sesión en el servidor.

| Código | Significado |
|---|---|
| `401` | Sin sesión válida (token ausente, vencido o revocado): renovar |
| `403` | Autenticado sin permiso: no renovar, mostrar el error |

## 3. Endpoints que usa la app

| Dominio | Endpoint | Uso |
|---|---|---|
| Auth | `POST /auth/login`, `POST /auth/register`, `POST /auth/refresh`, `POST /auth/logout`, `GET /users/me` | Sesión |
| Productos | `GET /products/search`, `GET /products/{id}` | Catálogo y búsqueda |
| Tiendas | `GET /stores/{id}` | Detalle de tienda |
| Aulas | `GET /aulas/activas` | Checkout |
| Pedidos | `POST /orders`, `GET /orders/me`, `GET /orders/{id}`, `PATCH /orders/{id}/cancel` | Pedidos |
| Pagos | `GET /payments/order/{orderId}`, `POST /payments` | Pagar un pedido |
| Favoritos | `GET/POST/DELETE /favorites/products[/{id}]`, `.../check`, ídem `stores` | Favoritos |
| IA | `GET /ai/recommendations?maxRecommendations=` | Recomendaciones |

## 4. Detalles que no son obvios

- **`total` de un pedido es el subtotal de productos.** Lo cobrado es
  `total + propina + tarifaServicio + comisionNomi` (`Order.chargedTotal`).
- **`GET /users/me` devuelve los datos del token**, no el registro completo: apellidos, teléfono y
  preferencias llegan `null`.
- **`POST /auth/register` no devuelve el usuario ni tokens**, solo un mensaje: hay que iniciar
  sesión después.
- **Un pedido admite un solo pago.** Para pagar, primero `GET /payments/order/{id}` (404 = sin
  pago) y solo si no existe `POST /payments` (`PaymentsAPI.checkoutURL`).
- **Propina máxima:** 50 % del subtotal; más responde 400 y no se crea el pedido.
- **Cancelar** solo en `PENDIENTE`; en otro estado responde 400.
- **Recomendaciones:** nunca son un error y nunca incluyen un producto que no cumpla las
  restricciones del estudiante (el backend filtra con las etiquetas dietéticas de los productos).
  Una lista vacía llega con `generatedBy = "SIN_CANDIDATOS"` (nada cumple los filtros) o
  `"FALLBACK"` (la IA falló): la app oculta la sección en ambos casos. `reason` es texto plano.
- **Productos:** incluyen `etiquetasDieteticas` (restricciones para las que el comercio los
  declara aptos). La app aún no las muestra; el decodificador las ignora.
- **Categorías** (`categoria`): `COMIDA`, `BEBIDA`, `SNACK`, `POSTRE`, `OTRO`.

## 5. Errores

Cuerpo común: `{timestamp, status, error, message, fields?}`. La app muestra:
- en errores de validación, los mensajes de `fields`;
- en el resto, `message`, o `error` si no hay mensaje (el login inválido solo trae
  `{"error": "Invalid credentials"}`).

Todos los campos de `ApiErrorPayload` son opcionales a propósito: la forma varía entre endpoints.

## 6. Añadir un endpoint

1. Comprobar el contrato en el controlador y el DTO del backend (o en Swagger).
2. Añadir el modelo en `Models/` con los campos opcionales que el backend pueda enviar nulos.
3. Añadir el método al `XxxAPI` del dominio.
4. Cubrirlo con un test que use `StubURLProtocol` y una respuesta real capturada del backend.
