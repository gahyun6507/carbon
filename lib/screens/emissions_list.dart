import 'package:flutter/material.dart';
import 'package:carbon_footprint/services/carbon_service.dart';

final CarbonService _carbonService = CarbonService();

class EmissionsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carbon Emissions')),
      body: FutureBuilder(
        future: _carbonService.getCarbonEmissionsByDate('2024-12-07'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data as List<Map<String, dynamic>>;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  title: Text(item['source']),
                  subtitle: Text('${item['quantity']} ${item['unit']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
