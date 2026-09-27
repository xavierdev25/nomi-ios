import Testing
@testable import Nomi

/// `RegistrationValidator` debe dar los mismos mensajes que `RegisterRequest` del backend.
@Suite("Validación de registro")
struct RegistrationValidatorTests {
    private func validate(
        nombres: String = "Ana María",
        apellidos: String = "Pérez-López",
        email: String = "ana@ucv.edu.pe",
        telefono: String = "",
        password: String = "Segura123"
    ) -> RegistrationValidator.Errors {
        RegistrationValidator.validate(nombres: nombres, apellidos: apellidos, email: email, telefono: telefono, password: password)
    }

    @Test func validDataHasNoErrors() {
        #expect(validate().isEmpty)
        #expect(validate(telefono: "+51 987-654-321").isEmpty)
    }

    @Test(arguments: [
        ("abc", "La contraseña debe tener entre 8 y 72 caracteres"),
        ("sinmayus123", "La contraseña debe tener al menos una mayúscula, una minúscula y un número"),
        ("SINMINUS123", "La contraseña debe tener al menos una mayúscula, una minúscula y un número"),
        ("SinNumeros", "La contraseña debe tener al menos una mayúscula, una minúscula y un número"),
        // "Ñ" no es [A-Z] para la regex del backend: tampoco debe pasar aquí.
        ("ñandu1234Ñ", "La contraseña debe tener al menos una mayúscula, una minúscula y un número"),
    ])
    func weakPasswordsAreRejected(password: String, message: String) {
        #expect(validate(password: password).password == message)
    }

    @Test func namesFollowTheBackendPattern() {
        #expect(validate(nombres: "A").nombres == "Nombres entre 2 y 60 caracteres")
        #expect(validate(nombres: "Ana3").nombres == "Nombres con caracteres inválidos")
        #expect(validate(apellidos: "  ").apellidos == "Apellidos obligatorios")
    }

    @Test func emailAndPhoneAreChecked() {
        #expect(validate(email: "ana@").email == "Email inválido")
        #expect(validate(email: " ana@ucv.edu.pe ").email == nil)
        #expect(validate(telefono: "12ab").telefono == "Teléfono inválido")
    }
}

/// Mensaje mostrado para cada forma de error del backend.
@Suite("Mensajes de error del backend")
struct ApiErrorPayloadTests {
    /// Error 400 real de `POST /auth/register` con contraseña débil.
    @Test func validationErrorsShowTheFieldMessagesNotTheGenericOne() {
        let payload = ApiErrorPayload(
            error: "Error de validación",
            message: "Hay errores en los campos enviados",
            status: 400,
            timestamp: nil,
            fields: ["password": "La contraseña debe tener entre 8 y 72 caracteres"]
        )
        #expect(payload.displayMessage(fallback: "x") == "La contraseña debe tener entre 8 y 72 caracteres")
    }

    @Test func otherErrorsKeepUsingMessage() {
        let payload = ApiErrorPayload(error: "Solicitud inválida", message: "La propina excede el máximo permitido",
                                      status: 400, timestamp: nil, fields: nil)
        #expect(payload.displayMessage(fallback: "x") == "La propina excede el máximo permitido")
    }
}
