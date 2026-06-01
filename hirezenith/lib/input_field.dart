import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  final controller, keyboardType, hint, icon, validator, cursorColor;
  final bool isPassword;
  final bool? isVisible;
  final VoidCallback? onToggle;

  const InputBox({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.hint,
    required this.icon,
    required this.validator,
    this.isPassword = false,
    this.isVisible,
    this.onToggle,
    this.cursorColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? !(isVisible ?? false) : false,
      style: const TextStyle(color: Colors.black),
      cursorColor: cursorColor,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFd6ccc2), // background color
        hintText: hint,
        prefixIcon: Icon(icon),
        errorStyle: TextStyle(
          color: Colors.black, // 👈 validation error color
          fontSize: 13,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible == true ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
