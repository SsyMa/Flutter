import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
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
      final response = await GetIt.I<Dio>().post('/login', data: requestData);
      await GetIt.I<SharedPreferences>().setString('dataAccessToken', response.data['token']);
      if(event.rememberMe) {
        await GetIt.I<SharedPreferences>().setString('keepMeLoggedInToken', response.data['token']);
      }
      emit(LoginSuccess());
    } catch (e, s) {
      if(e is DioError) {
        final repData = e.response?.data as Map<String, dynamic>;
        emit(LoginError(repData['message']));
        emit(LoginForm());
      }
    }
  }

  Future<void> _autoLoginEvent(LoginAutoLoginEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final token = GetIt.I<SharedPreferences>().getString('keepMeLoggedInToken');
    if(token != null) {
      emit(LoginSuccess());
    } else {
      emit(LoginForm());
    }
  }
}
