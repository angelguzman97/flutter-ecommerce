import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/features/shared/shared.dart';

//! 3 - StateNotifierProvider - consume afuera
//Se usa el autoDispose para no mantener los textos al salir de la pantalla. Es decir los campos del login vacío después de cerrar sesión
final loginFormProvider = StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
 
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;
  
  return LoginFormNotifier(loginUserCallback: loginUserCallback);
});

//! 2 - Cómo implementamos un notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {

  final Function(String, String) loginUserCallback;

  LoginFormNotifier({
    required this.loginUserCallback,
  }): super(LoginFormState()); //Tiene que ser sincrona

  onEmailChange( String value){
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isvalid: Formz.validate([newEmail, state.password])
    );
  }

  onPasswordChange( String value){
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isvalid: Formz.validate([newPassword, state.email])
    );
  }

  onFormSubmit() async{
  _touchEveryField();

  if (!state.isvalid) return;
  state = state.copyWith(
    isPosting: true
  );

  await loginUserCallback(state.email.value, state.password.value);

  state = state.copyWith(
    isPosting: false
  );
  
  }

  _touchEveryField(){
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      email: email,
      password: password,
      isvalid: Formz.validate([email, password])
    );
  }
  
}

//! 1 - State del provider
class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isvalid;
  final Email email;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isvalid = false,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith(
          {bool? isPosting,
          bool? isFormPosted,
          bool? isvalid,
          Email? email,
          Password? password}) =>
      LoginFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isvalid: isvalid ?? this.isvalid,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  @override
  String toString() {
    // TODO: implement toString
    return '''
  LoginFromState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isvalid: $isvalid
    email: $email
    password: $password
  
''';
  }
}

