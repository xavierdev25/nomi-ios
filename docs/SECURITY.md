# SECURITY.md — `nomi-ios`

La seguridad real del sistema está en el backend: la app **nunca** es autoridad sobre permisos,
importes ni stock. Estas reglas evitan que la app filtre la sesión o los datos del usuario.

## 1. Sesión y tokens

| Regla | Dónde |
|---|---|
| Los tokens se guardan **solo en el Keychain** (servicio `com.nomi.ios.tokens`, accesibles con el dispositivo desbloqueado). Nunca en `UserDefaults`, archivos ni memoria persistida. | `KeychainTokenStore` |
| El access token viaja solo en la cabecera `Authorization: Bearer`, nunca en la URL. | `APIClient` |
| El `exp` del JWT se lee **sin verificar la firma**, solo para saber cuándo renovar. Nunca se usa el contenido del token para decidir permisos. | `JWT` |
| Una sola renovación en vuelo: el backend rota el refresh token y trata su reutilización como robo (revoca todas las sesiones del usuario). | `TokenRefresher` |
| Solo un refresh token rechazado (400/401/403) cierra la sesión; los fallos de red no. | `APIClient.refreshTokens` |
| Cerrar sesión borra el Keychain primero y después revoca el refresh token en el servidor (sin bloquear si falla). | `AuthStore.logout` |
| Al cambiar de usuario se vacía el carrito. | `RootRouterView` |

Los elementos del Keychain sobreviven a la desinstalación: si la app se reinstala, la sesión
anterior se recupera mientras sus tokens sigan vigentes.

## 2. Transporte

- Release apunta a HTTPS. Debug usa `http://localhost:8080`, permitido por
  `NSAllowsLocalNetworking` en `Info.plist`; **no añadas excepciones de ATS para otros dominios.**
- Timeout de 15 s por petición.
- No hay certificate pinning (pendiente para producción).

## 3. Pagos

- La app **no maneja datos de tarjeta.** El pago ocurre en el checkout de MercadoPago, que se abre
  en el navegador del sistema con la URL que devuelve el backend.
- El estado del pago lo confirma el backend por webhook; la app solo lo consulta. Nunca marques un
  pedido como pagado desde el cliente.
- Los importes mostrados antes de pagar son una estimación; el monto cobrado lo calcula el backend.

## 4. Datos y registros

- No imprimas tokens, contraseñas, emails ni respuestas completas en consola o logs.
- Los mensajes de error que se muestran al usuario salen de `APIError` o del backend; nunca
  exponen detalles internos (URLs, trazas, cuerpos crudos).
- Los campos de contraseña usan `textContentType` `.password` / `.newPassword` para que iOS
  gestione y sugiera contraseñas seguras.
- La validación del registro replica la del backend solo para dar mejor experiencia; el backend
  vuelve a validar todo.

## 5. Secretos

- La app no contiene secretos: no hay claves de API, ni de MercadoPago, ni de IA en el cliente.
- Si alguna vez hace falta una clave pública, va en configuración de compilación, nunca en el
  código ni en la documentación.

## 6. Pendientes conocidos

- URL de producción sin desplegar y sin configuración por entorno.
- Sin certificate pinning.
- Detalle en la auditoría técnica de `nomi-docs` (sección de seguridad).

## 7. Reportar un problema

Los problemas de seguridad se reportan en privado al responsable del proyecto, no en issues
públicos.
