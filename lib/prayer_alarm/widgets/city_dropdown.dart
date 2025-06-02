import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  final String title;
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String?> onChanged;
  final Color selectedTextColor;
  final Color defaultTextColor;
  final double fontSize;

  const CityDropdown({
    super.key,
    required this.title,
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
    this.selectedTextColor = Colors.blue,
    this.defaultTextColor = Colors.black,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ),
        DropdownButton<String>(
          value: selectedCity,
          underline: const SizedBox(),
          borderRadius: BorderRadius.circular(8),
          style: TextStyle(fontSize: fontSize),
          items:
              cities.map((String city) {
                final isSelected = city == selectedCity;
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: TextStyle(
                      color: isSelected ? selectedTextColor : defaultTextColor,
                      fontSize: fontSize,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
