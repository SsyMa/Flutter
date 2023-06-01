import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginForm()) {
    on<LoginSubmitEvent>(_loginEvent);
    on<LoginAutoLoginEvent>(_autoLoginEvent);
  }

  Future<void> _loginEvent(LoginSubmitEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final requestData = <String, String>{
      'email': event.email,
      'password': event.password
    };
    try {
      final response = await Dio().post('/login', data: requestData);
      if(event.rememberMe) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.extra['token']);
      }
      emit(LoginSuccess());
    } catch (e, s) {
      if(e is DioError) {
        emit(LoginError(e.message));
        emit(LoginForm());
      }
    }
  }

  Future<void> _autoLoginEvent(LoginAutoLoginEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if(token != null) {
      emit(LoginSuccess());
    } else {
      LoginForm();
    }
  }
}
