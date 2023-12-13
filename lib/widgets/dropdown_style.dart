import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropdownStyle {
  static TextStyle hintStyle = const TextStyle(
    fontSize: 14,
    color: Colors.blueGrey,
  );
  static TextStyle itemStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static ButtonStyleData buttonStyleLong = ButtonStyleData(
    height: 35,
    width: 260,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black26,
      ),
      color: Colors.white,
    ),
    elevation: 1,
  );
  static ButtonStyleData buttonStyleMedium = ButtonStyleData(
    height: 35,
    width: 160,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black26,
      ),
      color: Colors.white,
    ),
    elevation: 1,
  );
  static ButtonStyleData buttonStyleShort = ButtonStyleData(
    height: 35,
    width: 100,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black26,
      ),
      color: Colors.white,
    ),
    elevation: 1,
  );
  static IconStyleData iconStyleData = const IconStyleData(
    icon: Icon(
      Icons.keyboard_arrow_down,
    ),
    iconSize: 14,
    iconEnabledColor: Colors.black,
    iconDisabledColor: Colors.grey,
  );
  static DropdownStyleData dropdownStyleLong = DropdownStyleData(
    maxHeight: 300,
    width: 300,
    decoration: const BoxDecoration(
      // borderRadius: BorderRadius.circular(14),
      color: Colors.white,
    ),
    offset: const Offset(-20, 0),
    scrollbarTheme: ScrollbarThemeData(
      // radius: const Radius.circular(40),
      thickness: MaterialStateProperty.all(6),
      thumbVisibility: MaterialStateProperty.all(true),
    ),
  );
  static DropdownStyleData dropdownStyleMedium = DropdownStyleData(
    maxHeight: 300,
    width: 200,
    decoration: const BoxDecoration(
      // borderRadius: BorderRadius.circular(14),
      color: Colors.white,
    ),
    offset: const Offset(-20, 0),
    scrollbarTheme: ScrollbarThemeData(
      // radius: const Radius.circular(40),
      thickness: MaterialStateProperty.all(6),
      thumbVisibility: MaterialStateProperty.all(true),
    ),
  );
  static DropdownStyleData dropdownStyleShort = DropdownStyleData(
    maxHeight: 300,
    width: 140,
    decoration: const BoxDecoration(
      // borderRadius: BorderRadius.circular(14),
      color: Colors.white,
    ),
    offset: const Offset(-20, 0),
    scrollbarTheme: ScrollbarThemeData(
      // radius: const Radius.circular(40),
      thickness: MaterialStateProperty.all(6),
      thumbVisibility: MaterialStateProperty.all(true),
    ),
  );
  static MenuItemStyleData menuItemStyleData = const MenuItemStyleData(
    height: 40,
    padding: EdgeInsets.only(left: 14, right: 14),
  );
}
