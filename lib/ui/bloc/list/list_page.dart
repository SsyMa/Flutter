import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homework/ui/bloc/list/list_bloc.dart';
import 'package:flutter_homework/ui/bloc/login/login_bloc.dart';
import 'package:flutter_homework/ui/bloc/login/login_page.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPageBloc extends StatefulWidget {
  const ListPageBloc({super.key});

  @override
  State<ListPageBloc> createState() => _ListPageBlocState();
}

class _ListPageBlocState extends State<ListPageBloc> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Page'),
        actions: [
          IconButton(
              onPressed: () async {
                await GetIt.I<SharedPreferences>().remove('dataAccessToken');
                await GetIt.I<SharedPreferences>().remove('keepMeLoggedInToken');
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => LoginBloc(),
                      child: LoginPageBloc(),)));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: BlocConsumer<ListBloc, ListState>(
        listener: (context, state) {
          if(state is ListError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if(state is ListLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if(state is ListLoaded) {
            return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Image.network(state.users[index].avatarUrl),),
                    title: Text(state.users[index].name),
                  );
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
