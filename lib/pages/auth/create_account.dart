import 'dart:convert';
import 'package:blogsquid/components/form/botton_widget.dart';
import 'package:blogsquid/components/form/text_input_widget.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/app_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../dashboard.dart';
import 'login.dart';

class CreateAccount extends HookWidget {
  final String anchor;
  const CreateAccount({Key? key, this.anchor = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstName = useTextEditingController();
    final lastName = useTextEditingController();
    final username = useTextEditingController();
    final email = useTextEditingController();
    final password = useTextEditingController();
    final rpassword = useTextEditingController();
    final loading = useState(false);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);

    getUser(String thisemail, String tk) async {
      try {
        var response = await Network().simpleGetToken("users/me", tk);
        var body = json.decode(response.body);
        print(body);
        if (response.statusCode == 200) {
          AppAction().newToastSuccess(context, "Account created successfully");
          body['email'] = thisemail;
          body['logged_in'] = true;
          account.state = body;
          token.state = tk;
          var box = await Hive.openBox('appBox');
          box.put('account', json.encode(body));
          box.put('token', tk);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
          loading.value = false;
        } else {
          loading.value = false;
          AppAction().newToastError(context, "Profile not found");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    login(userAccount) async {
      try {
        if (email.text.length > 0 && password.text.length > 0) {
          var formData = {
            "username": userAccount['username'],
            "password": password.text,
          };

          loading.value = true;
          var response = await Network().postAuth(formData);
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            getUser(userAccount['email'], body["token"]);
          } else {
            print(body["message"]);
            AppAction().newToastError(context,
                "${body["message"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}");
            loading.value = false;
          }
        } else {
          AppAction().newToastError(context, "Both fields are required");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    register() async {
      try {
        if (email.text.length > 0 &&
            password.text.length > 0 &&
            firstName.text.length > 0 &&
            lastName.text.length > 0 &&
            username.text.length > 0) {
          if (password.text == rpassword.text) {
            var formData = {
              "email": email.text,
              "password": password.text,
              "first_name": firstName.text,
              "last_name": lastName.text,
              "username": username.text,
            };
            loading.value = true;

            var response =
                await Network().simplePost("/users/register", formData);
            var body = json.decode(response.body);
            if (body['code'] != null && body['code'] == 200) {
              login(formData);
            } else {
              print(body);
              loading.value = false;
              AppAction().newToastError(context, "${body['message']}");
            }
          } else {
            AppAction()
                .newToastError(context, "Your passwords are not the same.");
          }
        } else {
          AppAction().newToastError(context, "All fields are required.");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? primaryDark : Colors.white,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 60, left: 25, right: 25),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Create Account",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      color.state == 'dark' ? Colors.white : Color(0xFF1B1B1B)),
            ),
            SizedBox(height: 20),
            Text(
              "Register to continue using the app",
              style: TextStyle(
                  color:
                      color.state == 'dark' ? darkModeText : Color(0xFF595959)),
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    TextInputWidget(
                      controller: firstName,
                      placeholder: "First Name",
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      controller: lastName,
                      placeholder: "Last Name",
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      controller: username,
                      placeholder: "Username",
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      controller: email,
                      placeholder: "Email address",
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      controller: password,
                      placeholder: "Password",
                      isPassword: true,
                    ),
                    SizedBox(height: 20),
                    TextInputWidget(
                      controller: rpassword,
                      placeholder: "Repeat Password",
                      isPassword: true,
                    ),
                    SizedBox(height: 20),
                    Opacity(
                        opacity: loading.value ? 0.38 : 1,
                        child: ButtonWidget(
                            action: loading.value ? () => {} : register,
                            text: loading.value
                                ? "Please wait..."
                                : "Create Account")),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: color.state == 'dark'
                                  ? Color(0xFFA19E9C)
                                  : Color(0xFF9A9FAC)),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login(anchor: anchor)),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: colorPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
