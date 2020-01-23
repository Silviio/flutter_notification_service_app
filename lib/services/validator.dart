class Validator {
  static String password(String value) {
    if (value != null) {
      if (value.trim().isEmpty) return 'Ops, a senha não pode ser nula';
      if (value.length < 8) return 'A senha precisa ter no mínimo 8 caracteres';
    }
    return null;
  }

  static String email(String value) {
    if (value != null) {
      if (value.trim().isEmpty) return 'Ops, o e-mail não foi preenchido';
      if (value.length < 8)
        return 'O e-mail precisa ter no mínimo 8 caracteres';
      if (!value.contains('@')) return 'E-mail inválido';
    }

    return null;
  }
}
