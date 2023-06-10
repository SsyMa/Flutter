import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_homework/network/user_item.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(ListInitial()) {
    on<ListLoadEvent>(_handleLoadEvent);
  }

  Future _handleLoadEvent(ListLoadEvent event, Emitter<ListState> emit) async {
    emit(ListLoading());
    try {
      final token = GetIt.I<SharedPreferences>().getString('dataAccessToken');
      final response = await GetIt.I<Dio>().get('/users', options: Options(headers: {'Authorization':'Bearer $token'}));
      List<UserItem> users = [];
      for(Map<String, dynamic> user in response.data) {
        users.add(UserItem(user['name'], user['avatarUrl']));
      }
      emit(ListLoaded(users));
    } catch (e, s) {
      if(e is DioError) {
        final repData = e.response?.data as Map<String, dynamic>;
        emit(ListError(repData['message']));
      }
    }
  }
}
