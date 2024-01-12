import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';

class SalaryPaymentScreen extends StatefulWidget {
  @override
  _SalaryPaymentScreenState createState() => _SalaryPaymentScreenState();
}

class _SalaryPaymentScreenState extends State<SalaryPaymentScreen> {
  final _amountController = TextEditingController();
  String _selectedLastDigit = '0';
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _paySalaries() async {
    if (_amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null && amount > 0) {
        try {
          // Maaş ödemelerini yap ve sonuçları al
          final result = await DatabaseHelper.instance.paySalariesByLastDigit(
            _selectedLastDigit,
            DateTime.now(),
          );

          // Başarılı bir şekilde ödeme yapıldığını ve zamlı maaş yatırılan kişi sayısını bildir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maaş ödemeleri başarılı! ${result['totalPayments']} kişiye ödeme yapıldı, bunlardan ${result['increasedPayments']} kişiye zamlı maaş yatırıldı.'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Bir hata oluşursa kullanıcıyı bilgilendir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maaş ödemesi sırasında bir hata oluştu: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Geçersiz maaş miktarı için uyarı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lütfen geçerli bir maaş miktarı giriniz.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Maaş miktarı boş ise uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maaş miktarı boş bırakılamaz.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maaş Ödeme Ekranı'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedLastDigit,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLastDigit = newValue!;
                });
              },
              items: List.generate(10, (index) => index.toString())
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Ödenecek Maaş Miktarı',
                suffixText: 'TL',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _paySalaries,
              child: Text('Maaş Yatır'),
            ),
          ],
        ),
      ),
    );
  }
}