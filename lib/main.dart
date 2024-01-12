import 'package:flutter/material.dart';
import 'screens/employee_registration_screen.dart';
import 'screens/salary_payment_screen.dart';
import 'screens/salary_slip_screen.dart';
import 'screens/registered_employees_screen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Şirket Çalışan Yönetim Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpeningScreen(),
    );
  }
}

class OpeningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Menü'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeRegistrationScreen()),
                );
              },
              label: Text('Çalışan Kayıt'),
              icon: Icon(Icons.person_add),
              heroTag: null, // Hero animasyonu için benzersiz bir tag belirtin
            ),
            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisteredEmployeesScreen()),
                );
              },
              label: Text('Kayıtlı Çalışanlar'),
              icon: Icon(Icons.view_list),
              heroTag: null,
            ),
            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalarySlipScreen()),
                );
              },
              label: Text('Maaş Bordrosu'),
              icon: Icon(Icons.list),
              heroTag: null,
            ),
            SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalaryPaymentScreen()),
                );
              },
              label: Text('Ödeme Yap'),
              icon: Icon(Icons.payment),
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }
}