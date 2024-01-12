import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class SalarySlipScreen extends StatefulWidget {
  @override
  _SalarySlipScreenState createState() => _SalarySlipScreenState();
}

class _SalarySlipScreenState extends State<SalarySlipScreen> {
  final _identityNumberController = TextEditingController();
  List<Map<String, dynamic>> _salarySlips = [];
  String? _employeePhotoPath;
  bool isZoomed = false;

  void _toggleZoom() {
    setState(() {
      isZoomed = !isZoomed;
    });
  }

  @override
  void dispose() {
    _identityNumberController.dispose();
    super.dispose();
  }

  Future<void> _searchSalarySlips() async {
    final String identityNumber = _identityNumberController.text;
    if (identityNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen kimlik numarası giriniz.')),
      );
      return;
    }

    final List<Map<String, dynamic>> slips = await DatabaseHelper.instance.getFullSalarySlips(identityNumber);
    String? photoPath = await DatabaseHelper.instance.getEmployeePhotoPathById(identityNumber);

    setState(() {
      _salarySlips = slips;
      _employeePhotoPath = photoPath;
    });

    if (_salarySlips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıtlı maaş bordrosu bulunamadı.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maaş bordrosu sorgulama başarılı.')),
      );
    }
  }

  Widget _buildPhotoFrame() {
    if (_employeePhotoPath != null) {
      return GestureDetector(
        onTap: _toggleZoom,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isZoomed ? 200 : 100,
          height: isZoomed ? 200 : 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.yellow, width: 3),
          ),
          child: Image.file(
            File(_employeePhotoPath!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.yellow, width: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maaş Bordrosu Ekranı'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _identityNumberController,
              decoration: InputDecoration(
                labelText: 'Kimlik Numarası',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _searchSalarySlips,
              child: Text('Sorgula'),
            ),
            SizedBox(height: 20),
            _buildPhotoFrame(),
            SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _salarySlips.length,
                  itemBuilder: (context, index) {
                    final slip = _salarySlips[index];
                    return ListTile(
                      title: Text('${slip['amount']} TL'),
                      subtitle: Text('Ödeme Tarihi: ${slip['paymentDate']}'),
                      leading: Icon(Icons.attach_money),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}