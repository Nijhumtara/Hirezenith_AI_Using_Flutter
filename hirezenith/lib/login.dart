import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hirezenith/input_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  bool isLoading = false;
  bool showPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  String name = "";
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  Future<void> register() async {
    String email = emailController.text.trim();
    String password = confirmPassController.text.trim();
    String name = userNameController.text.trim(); // <--- get username here

    setState(() {
      isLoading = true;
    });

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'name': name, // <-- store the actual username
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registered Successfully")));

      setState(() {
        isLogin = true; // show login form
      });
    } on AuthApiException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }

    userNameController.clear();
    emailController.clear();
    newPassController.clear();
    confirmPassController.clear();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passController.text.trim();
    setState(() {
      isLoading = true;
    });
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthApiException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 30),
            decoration: BoxDecoration(color: const Color(0xFFd5bdaf)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hirezenith AI",
                  style: GoogleFonts.playwriteNgModern(
                    textStyle: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Text("Upload Your CV and Discover Your Hiring Potential"),
                Container(
                  width: 350,
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50), // shadow color
                        blurRadius: 12, // how soft the shadow is
                        spreadRadius: 5, // how wide the shadow spreads
                        offset: Offset(0, 0), // x,y offset 0 = all around
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!isLogin)
                          InputBox(
                            controller: userNameController,
                            keyboardType: TextInputType.name,
                            hint: "User Name",
                            cursorColor: Colors.black,
                            icon: Icons.person,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Field is Empty";
                              } else if (!RegExp(
                                r'^[A-Za-z\. A-Za-z]+$',
                              ).hasMatch(value)) {
                                return "Invalid Name";
                              }
                              return null;
                            },
                          ),
                        SizedBox(height: 10),
                        InputBox(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          hint: "Email",
                          cursorColor: Colors.black,
                          icon: Icons.email,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Field is Empty";
                            } else if (!RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(value)) {
                              return "Invalid Email";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        if (isLogin)
                          InputBox(
                            controller: passController,
                            keyboardType: TextInputType.visiblePassword,
                            hint: "Password",
                            cursorColor: Colors.black,
                            icon: Icons.lock,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Field is Empty";
                              } else if (!RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$_])[A-Za-z\d@$_]{8,}$',
                              ).hasMatch(value)) {
                                return "Invalid Password";
                              }
                              return null;
                            },
                            isPassword: true,
                            isVisible: showPassword,
                            onToggle: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        if (isLogin) SizedBox(height: 30),
                        if (!isLogin)
                          InputBox(
                            controller: newPassController,
                            keyboardType: TextInputType.visiblePassword,
                            hint: "New Password",
                            cursorColor: Colors.black,
                            icon: Icons.lock,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Field is Empty";
                              } else if (!RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$_])[A-Za-z\d@$_]{8,}$',
                              ).hasMatch(value)) {
                                return "Weak Password\n1. Minimum 8 characters\n2. At least 1 uppercase letter\n3. At least 1 lowercase letter\n4. At least 1 number\n5. At least 1 special character";
                              } else if (newPassController.text !=
                                  confirmPassController.text) {
                                return "Password and Confirm Password Doesn't Match";
                              }
                              return null;
                            },
                            isPassword: true,
                            isVisible: showNewPassword,
                            onToggle: () {
                              setState(() {
                                showNewPassword = !showNewPassword;
                              });
                            },
                          ),
                        SizedBox(height: 10),
                        if (!isLogin)
                          InputBox(
                            controller: confirmPassController,
                            keyboardType: TextInputType.visiblePassword,
                            hint: "Confirm Password",
                            cursorColor: Colors.black,
                            icon: Icons.lock,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Field is Empty";
                              } else if (!RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$_])[A-Za-z\d@$_]{8,}$',
                              ).hasMatch(value)) {
                                return "Weak Password\n1. Minimum 8 characters\n2. At least 1 uppercase letter\n3. At least 1 lowercase letter\n4. At least 1 number\n5. At least 1 special character";
                              } else if (newPassController.text !=
                                  confirmPassController.text) {
                                return "Password and Confirm Password Doesn't Match";
                              }
                              return null;
                            },
                            isPassword: true,
                            isVisible: showConfirmPassword,
                            onToggle: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                        if (!isLogin) SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
          
                            if (isLogin) {
                              await login();
                            } else {
                              await register();
                            }
                          },
          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe3d5ca),
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: Text(
                            !isLogin ? "Create Account" : "Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isLogin) SizedBox(height: 30),
                        if (isLogin)
                          Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: const Color(0xFFc9ada7),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 70),
                    child: Row(
                      children: [
                        Text(
                          !isLogin
                              ? "Already have an account?"
                              : "Don't have an account?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            !isLogin ? "Login" : "Sign Up",
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
