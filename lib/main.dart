import 'package:flutter/material.dart';
import 'screens/employee_registration_screen.dart';
import 'screens/salary_payment_screen.dart';
import 'screens/salary_slip_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'finalodev2',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpeningScreen(),
    );
  }
}

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maaş Uygulaması'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.person_add), text: 'Çalışan Kayıt'),
            Tab(icon: Icon(Icons.list), text: 'Maaş Bordrosu'),
            Tab(icon: Icon(Icons.payment), text: 'Ödeme Yap'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EmployeeRegistrationScreen(),
          SalarySlipScreen(),
          SalaryPaymentScreen(),
        ],
      ),
    );
  }
}
