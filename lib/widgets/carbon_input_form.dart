// 개인용 입력 폼 제공
// lib/widgets/carbon_input_form.dart
import 'package:flutter/material.dart';

class CarbonInputForm extends StatefulWidget {
  final Function(String, double, List<String>) onCalculate;

  const CarbonInputForm({Key? key, required this.onCalculate}) : super(key: key);

  @override
  _CarbonInputFormState createState() => _CarbonInputFormState();
}

class _CarbonInputFormState extends State<CarbonInputForm> {
  String _selectedTransport = '자동차';
  final _distanceController = TextEditingController();
  List<String> _selectedFoods = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedTransport,
          items: ['자동차', '대중교통', '자전거/도보']
              .map((mode) => DropdownMenuItem(
            value: mode,
            child: Text(mode),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedTransport = value!;
            });
          },
        ),
        TextField(
          controller: _distanceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '이동 거리 (km)'),
        ),
        Wrap(
          children: ['고기', '채소', '과일', '우유']
              .map((food) => FilterChip(
            label: Text(food),
            selected: _selectedFoods.contains(food),
            onSelected: (bool selected) {
              setState(() {
                selected
                    ? _selectedFoods.add(food)
                    : _selectedFoods.remove(food);
              });
            },
          ))
              .toList(),
        ),
        ElevatedButton(
          onPressed: () {
            double distance = double.tryParse(_distanceController.text) ?? 0;
            widget.onCalculate(_selectedTransport, distance, _selectedFoods);
          },
          child: Text('탄소 배출량 계산'),
        )
      ],
    );
  }
}