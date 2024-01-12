import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/employee.dart';

class RegisteredEmployeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıtlı Çalışanlar'),
      ),
      body: FutureBuilder<List<Employee>>(
        future: DatabaseHelper.instance.getAllEmployees(),
        builder: (BuildContext context, AsyncSnapshot<List<Employee>> snapshot) {
          if (snapshot.hasData) {
            List<Employee>? employees = snapshot.data;
            return ListView.builder(
              itemCount: employees?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Employee employee = employees![index];
                double totalSalary = employee.salary * employee.workingYears; // Toplam maaşı hesapla
                return Card(
                  child: ListTile(
                    title: Text(employee.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Kimlik Numarası: ${employee.identityNumber}'),
                        Text('Departman: ${employee.department}'),
                        Text('Maaş: ${employee.salary}'),
                        Text('Adres: ${employee.address}'),
                        Text('Çalışma Yılı: ${employee.workingYears}'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu!'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}