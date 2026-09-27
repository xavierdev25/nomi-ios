# DESIGN_SYSTEM.md — Nomi iOS

El sistema de diseño vive en `NomiIOS/DesignSystem/`. Toda la UI se construye con estos tokens y
componentes: **nada de colores, tamaños, fuentes ni sombras sueltos en las pantallas.**

## 1. Principios

- **Un solo color de acción.** El naranja (`accent`) marca lo que se puede pulsar, lo activo y los
  precios. Si todo es naranja, nada destaca.
- **El azul marino es para texto**, nunca para fondos.
- **Profundidad por luminosidad.** Las superficies elevadas son más claras que el fondo; la sombra
  es la excepción y nunca se apila.
- **Neutros cálidos**, teñidos hacia el tono del naranja, en lugar de grises puros.
- **Movimiento sin rebote**, corto y con propósito.
- **Solo modo claro** (`.preferredColorScheme(.light)`): el modo oscuro no está diseñado.

## 2. Color — `NMColors`

Definidos en **OKLCH** (`Color.oklch(l, c, h)`), donde la luminosidad es perceptualmente
uniforme: dos colores con la misma `l` se ven igual de claros.

| Token | Uso |
|---|---|
| `paper` | Fondo de página |
| `surface` | Tarjetas y superficies elevadas |
| `paperRaised` | Bandas y marcadores de imagen |
| `line` | Bordes finos y divisores |
| `ink` / `inkSoft` / `inkFaint` | Texto principal / secundario / terciario |
| `neutral` | Iconos y elementos secundarios (no texto ni bordes) |
| `accent` / `accentStrong` / `accentSoft` | Acción, pulsado, fondo suave de acción |
| `onAccent` | Texto e iconos sobre `accent` |
| `success`, `warning`, `error` (+ `Soft`) | Semánticos y sus fondos |
| `info` / `infoStrong` / `infoSoft` | Solo indicadores de estado del pedido |

Estados del pedido (`OrderStatus.color`): pendiente `warning`, preparando `info`, listo
`infoStrong`, en camino `accent`, entregado `success`, cancelado `error`.

## 3. Tipografía — `NMTextStyle`

San Francisco en todos los casos; la jerarquía se construye con peso y tamaño. Aplicar con
`Text("…").nmStyle(.h2)` (y `color:` para sustituir el color).

| Estilo | Fuente | Uso |
|---|---|---|
| `display` | 40 heavy | Portadas |
| `h1` | 32 bold | Título de pantalla |
| `h2` | 24 bold | Título de sección grande |
| `h3` | 18 semibold | Título de sección / tarjeta |
| `body` | 14 regular, `inkSoft` | Texto corrido |
| `bodyStrong` | 14 semibold | Énfasis |
| `label` | 12 semibold | Etiquetas y metadatos |
| `button` | 15 semibold, `onAccent` | Texto de botones |
| `price` | 16 semibold, dígitos fijos, `accent` | Precios |

Las cifras usan `NMFont.numeric` (dígitos de ancho fijo) para que no bailen al cambiar.

## 4. Espaciado y radios

`NMSpacing`: escala de 4 pt — `s1` 4, `s2` 8, `s3` 12, `s4` 16, `s5` 20, `s6` 24, `s7` 28,
`s8` 32, `s10` 40, `s12` 48, `s16` 64. Margen lateral de pantalla habitual: `s5`.

`NMRadius`: `xs` 6, `sm` 8, `md` 10, `lg` 12, `xl` 16, `xl2` 24, `full` (cápsula).

## 5. Sombras — `NMShadow`

Aplicar con `.nmShadow(_:)`.

| Sombra | Uso |
|---|---|
| `none` | Por defecto |
| `whisper` | Tarjetas en reposo |
| `raised` | Hojas, barras fijas, controles flotantes |
| `accentGlow` | Solo el botón primario |

## 6. Movimiento — `NMDuration` / `NMEasing`

Duraciones: `micro` 0,12 s (pulsación), `short` 0,22 s (cambio de estado), `long` 0,42 s (hojas y
transiciones). Curvas: `out` para lo que entra, `in` para lo que sale, `inOut` para cambios de
estado; variantes `outLong`, `inLong`, `outMicro`.

## 7. Iconos — `NMIcon`

Solo SF Symbols, referenciados por nombre desde `NMIcon` (`Image(nmIcon: NMIcon.cart)`). Un icono
nuevo se añade a `NMIcon`; no se escriben nombres de símbolos en las pantallas.

## 8. Componentes

| Componente | Uso |
|---|---|
| `NMButton` | Botón. Variantes `primary`, `secondary`, `ghost`, `outline`, `danger`; tamaños `sm` 40, `md` 50, `lg` 56 pt; `loading` y `disabled`. Una sola acción `primary` por pantalla. |
| `NMInput` | Campo con etiqueta, icono, error o ayuda, y `textContentType` para Autocompletar. |
| `NMCard` | Contenedor `standard`, `elevated`, `outlined` o `flat`; pulsable si recibe `action`. |
| `NMProductCard` | Producto en `grid` o `list`. |
| `NMStoreCard` | Fila de tienda. El "15-25 min" es fijo: el backend no calcula tiempos. |
| `NMBadge` | Cápsula informativa (categoría, "Agotado", "Última usada"). |
| `NMTag` | Chip seleccionable (categoría, propina, punto de encuentro). |
| `NMSummaryRow` | Fila etiqueta-valor de resúmenes de importes; `bold` para el total. |
| `NMAvatar` | Imagen o iniciales. |
| `NMDivider` | Línea de 1 pt. |
| `NMCartHeaderButton` | Botón del carrito con contador; lee `CartStore` del entorno. |

## 9. Reglas de pantalla

- Fondo `paper`; contenido en `surface`.
- Precios siempre con `Formatters.currency` (soles) y estilo `price` o `NMFont.numeric`.
- Estados vacíos, de carga y de error en todas las pantallas que cargan datos; el error ofrece
  reintentar.
- Acciones destructivas (cancelar pedido, cerrar sesión) piden confirmación y usan `danger`.

## 10. Añadir o cambiar algo

- Reutiliza un componente antes de crear otro. Si hace falta uno nuevo, va en
  `DesignSystem/Components/` con prefijo `NM` y solo usa tokens.
- Un color nuevo se define en OKLCH en `NMColors` con su propósito documentado.
- Actualiza este documento en el mismo cambio.
