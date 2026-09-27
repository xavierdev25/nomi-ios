# PRD — App del estudiante (iOS)

## 1. Propósito

Permitir que un estudiante pida comida a las tiendas de su campus y la reciba en su aula, entre
clases, pagando desde el teléfono. El contexto completo del producto (actores, ciclo del pedido,
reglas de negocio) está en el sitio de documentación `nomi-docs`, sección **Producto**.

## 2. Usuario

Estudiante universitario (`ESTUDIANTE`). Los roles `COMERCIO`, `REPARTIDOR` y `ADMIN` quedan fuera
de esta app.

## 3. Requisitos funcionales

### Cuenta
- **RF-01** Registrarse con nombres, apellidos, email, contraseña y teléfono opcional. La app
  valida cada campo con las mismas reglas y mensajes que el backend y señala el campo con error.
- **RF-02** Iniciar sesión con email y contraseña.
- **RF-03** Mantener la sesión abierta entre usos: el access token se renueva solo antes de
  expirar.
- **RF-04** Al abrir la app sin conexión, conservar la sesión y ofrecer reintentar; solo volver
  al login si el servidor rechaza la sesión.
- **RF-05** Cerrar sesión con confirmación: borra la sesión local, la revoca en el servidor y
  vacía el carrito.

### Catálogo
- **RF-06** Inicio: saludo, recomendaciones de la IA (si las hay) y productos disponibles.
- **RF-07** Búsqueda por nombre (con espera de 350 ms al escribir) y por categoría.
- **RF-08** Detalle de producto: imagen, precio, descripción, categoría, disponibilidad, favorito
  y acceso a su tienda.
- **RF-09** Detalle de tienda: datos, horario, favorito y menú de productos disponibles.
- **RF-10** Recomendaciones: lista completa (hasta 20). Sin IA disponible, la sección no aparece;
  nunca es un error visible.

### Carrito y checkout
- **RF-11** Agregar productos con cantidad. El carrito solo admite productos de una tienda; si se
  intenta mezclar, avisar.
- **RF-12** Cambiar cantidades y quitar productos.
- **RF-13** Elegir propina de S/ 0, 1, 2, 3 o 5, deshabilitando las que superan el 50 % del
  subtotal y mostrando el máximo.
- **RF-14** Mostrar subtotal, tarifa de servicio (S/ 0.50), comisión (S/ 0.20), propina y total.
- **RF-15** Checkout: elegir aula activa (preseleccionando la última usada), punto de encuentro y
  notas.
- **RF-16** Crear el pedido y abrir el pago de MercadoPago. Si el pedido se crea pero el pago
  falla, mostrar el error junto al botón y permitir reintentar el pago del mismo pedido.

### Pedidos
- **RF-17** Lista de pedidos (más reciente primero) con el total cobrado y el estado.
- **RF-18** Seguimiento del pedido activo, actualizado cada 5 segundos: línea de estados, código
  de confirmación y estado del pago.
- **RF-19** Pedido pendiente sin pago aprobado: permitir pagarlo (reutilizando el pago existente)
  o cancelarlo con confirmación.
- **RF-20** Detalle de pedidos terminados con desglose de importes.

### Favoritos y perfil
- **RF-21** Marcar y desmarcar productos y tiendas como favoritos; listas de favoritos.
- **RF-22** Perfil con nombre, email y accesos a favoritos y recomendaciones.

## 4. Requisitos no funcionales

- **RNF-01** Mensajes de error en español, útiles y sin detalles técnicos.
- **RNF-02** Recargas sin parpadeo: al refrescar, la lista visible se mantiene.
- **RNF-03** Sesión y tokens solo en el Keychain.
- **RNF-04** Ningún importe cobrado se calcula en el cliente: los importes mostrados antes de pagar
  son una estimación con las mismas constantes del backend.
- **RNF-05** Solo iPhone, orientación vertical, modo claro.

## 5. Fuera de alcance (hoy)

- Pantallas de comercio, repartidor y administración.
- Editar perfil, preferencias y restricciones (el menú existe pero no hace nada).
- Calificar pedidos.
- Notificaciones push y seguimiento por WebSocket.
- Regreso automático a la app tras pagar (deep link).

## 6. Criterios de aceptación clave

- Con el token de acceso vencido, abrir la app o navegar no muestra errores ni pide login mientras
  el refresh token sea válido.
- Una propina mayor al 50 % del subtotal no se puede seleccionar.
- El total de un pedido en la lista coincide con el monto cobrado por MercadoPago.
- Un pedido pendiente sin pagar se puede pagar o cancelar desde el seguimiento.
- Abrir la app sin conexión no cierra la sesión.
