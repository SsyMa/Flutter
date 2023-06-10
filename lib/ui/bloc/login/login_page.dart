import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homework/ui/bloc/list/list_bloc.dart';
import 'package:flutter_homework/ui/bloc/list/list_page.dart';
import 'package:flutter_homework/ui/bloc/login/login_bloc.dart';
import 'package:validators/validators.dart';

class LoginPageBloc extends StatefulWidget {
  const LoginPageBloc({super.key});

  @override
  State<LoginPageBloc> createState() => _LoginPageBlocState();
}

class _LoginPageBlocState extends State<LoginPageBloc> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  bool isEmailValid = true;
  bool isPwValid = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if(state is LoginError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if(state is LoginSuccess) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => ListBloc()..add(ListLoadEvent()),
                    child: ListPageBloc(),),)
              );
            }
          },
          builder: (context, state) {
            if(state is LoginLoading) {
              isLoading = true;
            } else {
              isLoading = false;
            }
            return Column(
              children: [
                TextFormField(
                  enabled: !isLoading,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: isEmailValid ? null : 'Ez szar te buzi',
                  ),
                  onChanged: (value) {
                    setState(() {
                      isEmailValid = true;
                    });
                  },
                ),
                TextFormField(
                  enabled: !isLoading,
                  controller: pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: isPwValid ? null : 'Ez is fos',
                  ),
                  onChanged: (value) {
                    setState(() {
                      isPwValid = true;
                    });
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        if(isLoading) return;
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text('Remember Me'),
                  ],
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if(emailController.text.isEmpty || !isEmail(emailController.text)) {
                      isEmailValid = false;
                    }
                    if(pwController.text.length < 6) {
                      isPwValid = false;
                    }
                    if(!(isPwValid && isEmailValid)) {
                      setState(() {});
                      return;
                    }
                    context.read<LoginBloc>().add(LoginSubmitEvent(emailController.text, pwController.text, _rememberMe));
                  },
                  child: const Text('Login'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
