import 'package:fludex/library/library.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:url_launcher/url_launcher.dart';

import 'home_page_enter_animation.dart';

class HomePage extends StatefulWidget {
  final AnimationController controller;
  HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  _HomePageState createState() =>
      _HomePageState(controller: controller, lightMode: true);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({required AnimationController controller, required lightMode})
      : animation = HomePageEnterAnimation(controller);

  bool animationDone = false;
  String loginText = "";
  String username = "";
  String password = "";

  final HomePageEnterAnimation animation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: animation.controller,
        builder: (context, child) {
          return Center(
            child: SizedBox(
              height: 500,
              width: 500,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Opacity(
                      opacity: animation.mainContainerOpacity.value,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 75, bottom: 20, left: 20, right: 20),
                          child: Container(
                            height: 500,
                            width: 500,
                            child: Column(
                              children: [
                                Opacity(
                                  opacity: animation.loginTextOpacity.value,
                                  child: Text(
                                    "Login to Mangadex",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity:
                                              animation.textFieldOpacity.value,
                                          child: Text(loginText),
                                        ),
                                        Opacity(
                                          opacity:
                                              animation.textFieldOpacity.value,
                                          child: TextField(
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText: "Username",
                                            ),
                                            onChanged: (value) {
                                              username = value;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Opacity(
                                          opacity:
                                              animation.textFieldOpacity.value,
                                          child: TextField(
                                            obscureText: true,
                                            decoration: InputDecoration(
                                                hintText: "Password"),
                                            onChanged: (value) {
                                              password = value;
                                            },
                                            onSubmitted: (value) async {
                                              if (animation.loginButtonOpacity
                                                  .isCompleted) {
                                                if (password == '' &&
                                                        username == '' ||
                                                    password == '' ||
                                                    username == '') {
                                                  setState(() {
                                                    loginText =
                                                        'username or password empty';
                                                  });
                                                } else {
                                                  setState(() {
                                                    animation.controller
                                                        .reverse();
                                                  });
                                                  try {
                                                    var loginData =
                                                        await lib.login(
                                                            username, password);
                                                    if (loginData!.result ==
                                                        'ok') {
                                                      animation.controller
                                                          .reverse()
                                                          .whenComplete(() => {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Library(
                                                                      token: loginData
                                                                          .token,
                                                                      dataSaver:
                                                                          true,
                                                                    ),
                                                                  ),
                                                                )
                                                              });
                                                    } else {
                                                      setState(() {
                                                        animation.controller
                                                            .forward();
                                                        loginText =
                                                            'Username or Password incorrect.';
                                                      });
                                                    }
                                                  } catch (e) {
                                                    setState(() {
                                                      loginText =
                                                          "Something went wrong while connecting :(";
                                                      animation.controller
                                                          .forward();
                                                    });
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        Opacity(
                                          opacity:
                                              animation.textFieldOpacity.value,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                Text("Don't have an account? "),
                                                TextButton(
                                                    onPressed: () async {
                                                      const url =
                                                          'https://mangadex.org/account/signup';
                                                      if (await canLaunch(
                                                          url)) {
                                                        await launch(url);
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    },
                                                    child: Text("Create one!"))
                                              ],
                                            ),
                                          ),
                                        ),
                                        Opacity(
                                          opacity:
                                              animation.textFieldOpacity.value,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Opacity(
                                                opacity: animation
                                                    .loginButtonOpacity.value,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    primary:
                                                        const Color.fromARGB(
                                                            255, 255, 103, 64),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Text(
                                                      "Login",
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ),
                                                  ),
                                                  onPressed: animation
                                                          .loginButtonOpacity
                                                          .isCompleted
                                                      ? () async {
                                                          if (password == '' &&
                                                                  username ==
                                                                      '' ||
                                                              password == '' ||
                                                              username == '') {
                                                            setState(() {
                                                              loginText =
                                                                  'username or password empty';
                                                            });
                                                          } else {
                                                            setState(() {
                                                              animation
                                                                  .controller
                                                                  .reverse();
                                                            });
                                                            try {
                                                              var loginData =
                                                                  await lib.login(
                                                                      username,
                                                                      password);
                                                              if (loginData!
                                                                      .result ==
                                                                  'ok') {
                                                                animation
                                                                    .controller
                                                                    .reverse()
                                                                    .whenComplete(
                                                                        () => {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => Library(
                                                                                    token: loginData.token,
                                                                                    dataSaver: true,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            });
                                                              } else {
                                                                setState(() {
                                                                  animation
                                                                      .controller
                                                                      .forward();
                                                                  loginText =
                                                                      'Username or Password incorrect.';
                                                                });
                                                              }
                                                            } catch (e) {
                                                              setState(() {
                                                                loginText =
                                                                    "Something went wrong while connecting :(";
                                                                animation
                                                                    .controller
                                                                    .forward();
                                                              });
                                                            }
                                                          }
                                                        }
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: animation.iconAlignment.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Hero(
                        tag: 'login_transition',
                        child: Material(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor:
                                  Color.fromARGB(255, 255, 103, 64),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 49,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: animationDone
                                      ? null
                                      : ClipRRect(
                                          child: const Image(
                                            isAntiAlias: true,
                                            image: AssetImage(
                                                "data/media/mangadex_logo_100px.png"),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
