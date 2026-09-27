import Foundation

/// Replica las reglas de validación de `RegisterRequest` del backend (mismos límites, mismos
/// mensajes) para señalar el campo exacto antes de enviar. El backend sigue siendo la
/// autoridad.
enum RegistrationValidator {
    /// Mensaje de error por campo; `nil` si el campo es válido.
    struct Errors: Equatable {
        var nombres: String?
        var apellidos: String?
        var email: String?
        var telefono: String?
        var password: String?

        var isEmpty: Bool {
            [nombres, apellidos, email, telefono, password].allSatisfy { $0 == nil }
        }
    }

    static let passwordHint = "Mínimo 8 caracteres, con una mayúscula, una minúscula y un número"

    static func validate(
        nombres: String,
        apellidos: String,
        email: String,
        telefono: String,
        password: String
    ) -> Errors {
        Errors(
            nombres: validateName(nombres, field: "Nombres"),
            apellidos: validateName(apellidos, field: "Apellidos"),
            email: validateEmail(email),
            telefono: validatePhone(telefono),
            password: validatePassword(password)
        )
    }

    private static func validateName(_ raw: String, field: String) -> String? {
        let value = raw.trimmingCharacters(in: .whitespaces)
        if value.isEmpty { return "\(field) obligatorios" }
        if !(2...60).contains(value.count) { return "\(field) entre 2 y 60 caracteres" }
        if !matches(value, #"^[\p{L} '-]+$"#) { return "\(field) con caracteres inválidos" }
        return nil
    }

    private static func validateEmail(_ raw: String) -> String? {
        let value = raw.trimmingCharacters(in: .whitespaces)
        if value.isEmpty { return "Email obligatorio" }
        if value.count > 120 || !matches(value, #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#) { return "Email inválido" }
        return nil
    }

    /// Campo opcional: solo se valida si tiene contenido.
    private static func validatePhone(_ raw: String) -> String? {
        let value = raw.trimmingCharacters(in: .whitespaces)
        if value.isEmpty { return nil }
        return matches(value, #"^[+]?[0-9\s-]{6,20}$"#) ? nil : "Teléfono inválido"
    }

    private static func validatePassword(_ value: String) -> String? {
        if value.isEmpty { return "Password obligatorio" }
        if !(8...72).contains(value.count) { return "La contraseña debe tener entre 8 y 72 caracteres" }
        // Clases ASCII, igual que la regex del backend: `isUppercase` aceptaría "Ñ" y dejaría pasar
        // una contraseña que el servidor rechaza.
        let hasLower = matches(value, "[a-z]")
        let hasUpper = matches(value, "[A-Z]")
        let hasDigit = matches(value, "[0-9]")
        if !(hasLower && hasUpper && hasDigit) {
            return "La contraseña debe tener al menos una mayúscula, una minúscula y un número"
        }
        return nil
    }

    private static func matches(_ value: String, _ pattern: String) -> Bool {
        value.range(of: pattern, options: .regularExpression) != nil
    }
}
