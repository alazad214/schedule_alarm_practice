import 'package:flutter/material.dart';

class SevenDaySelector extends StatelessWidget {
  final List<String> dates;
  final List<String> days;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;
  final Color selectedContainerColor;
  final Color unselectedContainerColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  const SevenDaySelector({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
    this.selectedContainerColor = Colors.cyan,
    this.unselectedContainerColor = Colors.black12,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        itemCount: dates.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final date = dates[index];
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => onDateSelected(index),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? selectedContainerColor
                          : unselectedContainerColor,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date.split('asd').last,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? selectedTextColor
                                : unselectedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
