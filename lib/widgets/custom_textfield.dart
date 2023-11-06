import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final IconData? iconData;
  final bool isPassword;
  final String? Function(String?)? validator;
  final String? errorText;
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyBoardType;
  final String? initialValue;
  final Function(String?)? onFieldSubmitted;
  final String? label;
  final bool isEmail;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.iconData,
    this.isPassword = false,
    this.validator,
    this.inputFormatters,
    this.errorText,
    this.onChanged,
    this.onSaved,
    this.keyBoardType,
    this.initialValue,
    this.onFieldSubmitted,
    this.label,
    this.isEmail = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.2,
      height: screenHeight * 0.1,
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initialValue,
        readOnly: widget.isEmail,
        decoration: InputDecoration(
          labelText: widget.label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.only(bottom: 0),
          hintText: widget.hintText,
          hintStyle: widget.isEmail
              ? const TextStyle(color: Colors.black)
              : TextStyle(color: Colors.grey.shade400),
          errorText: widget.errorText,
          errorMaxLines: 2,
          suffixIcon: widget.isPassword
              ? showPassword
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      widthFactor: 0.5,
                      heightFactor: 1,
                      child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      widthFactor: 0.5,
                      heightFactor: 1,
                      child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: const Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    )
              : null,
          suffixIconConstraints: const BoxConstraints(maxHeight: 30),
        ),
        obscureText: widget.isPassword ? showPassword : false,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        validator: widget.validator,
        keyboardType: widget.keyBoardType,
        onFieldSubmitted: widget.onFieldSubmitted,
      ),
    );
  }
}
