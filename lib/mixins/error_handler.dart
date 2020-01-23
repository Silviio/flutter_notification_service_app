import 'dart:io' show Platform;

//Correção temporária até que eles alterem o código de erro de plataforma cruzada do firebase
mixin ErrorHandler {
  String getErrorMessageByCode(code) {
    String errorMessage;

    switch (code) {
      case 'ERROR_WEAK_PASSWORD':
        errorMessage = 'Senha fraca, deve ter no mínimo 8 caracteres';
        break;

      case 'ERROR_EMAIL_ALREADY_IN_USE':
        errorMessage = 'Este e-mail já está em uso, favor, escolha outro';
        break;

      case 'ERROR_INVALID_EMAIL':
        errorMessage = 'Este e-mail é inválido para cadastro';
        break;

      default:
        errorMessage = 'Desconhecido, tente novamente mais tarde';
    }

    return errorMessage;
  }

  String getLoginErrorMessage(e) {
    String errorMessage;

    if (Platform.isAndroid) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorMessage = 'Usuário inválido';
          break;
        case 'The password is invalid or the user does not have a password.':
          errorMessage = 'Senha inválida';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorMessage = 'Problemas de conexão';
          break;
        case 'Future not completed':
          errorMessage = 'Timeout, tente novamente mais tarde';
          break;

        default:
          errorMessage =
              'Erro desconhecido, verifique sua conexão e tente novamente mais tarde';
      }
    } else if (Platform.isIOS) {
      switch (e.code) {
        case 'Error 17011':
          errorMessage = 'Usuário não encontrado';
          break;
        case 'Error 17009':
          errorMessage = 'Usuário inválido';
          break;
        case 'Error 17020':
          errorMessage = 'Problemas de conexão';
          break;

        default:
          errorMessage = 'Erro desconhecido, tente novamente mais tarde';
      }
    }

    return errorMessage;
  }
}
