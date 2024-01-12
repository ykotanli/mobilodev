import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/employee.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS salaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identityNumber TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate TEXT NOT NULL,
        FOREIGN KEY (identityNumber) REFERENCES employees (identityNumber)
      )
    ''');
    }
  }



  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('employees.db');
    return _database!;
  }


  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        identityNumber TEXT NOT NULL UNIQUE,
        department TEXT NOT NULL,
        salary REAL NOT NULL,
        address TEXT NOT NULL,
        workingYears INTEGER NOT NULL,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE salaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identityNumber TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate TEXT NOT NULL,
        FOREIGN KEY (identityNumber) REFERENCES employees (identityNumber)
      )
    ''');
  }

  Future<int> addEmployee(Employee employee) async {
    final db = await database;
    return db.insert('employees', employee.toMap());
  }

  Future<void> paySalary(String identityNumber, double amount, DateTime paymentDate) async {
    final db = await database;
    final employee = await db.query(
      'employees',
      columns: ['workingYears'],
      where: 'identityNumber = ?',
      whereArgs: [identityNumber],
    );

    if (employee.isNotEmpty) {
      final workingYears = employee.first['workingYears'] as int;
      amount = calculateSalaryIncrease(amount, workingYears);
    }

    await db.insert('salaries', {
      'identityNumber': identityNumber,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getFullSalarySlips(String identityNumber) async {
    final db = await database;
    return db.query(
      'salaries',
      where: 'identityNumber = ?',
      whereArgs: [identityNumber],
    );
  }

  Future<Map<String, int>> paySalariesByLastDigit(String lastDigit, DateTime paymentDate) async {
    final db = await database;
    final employees = await db.query(
      'employees',
      where: 'substr(identityNumber, -1) = ?',
      whereArgs: [lastDigit],
    );

    int paymentCount = 0;
    int increasedSalaryCount = 0; // To track how many employees received a salary increase

    for (var employee in employees) {
      final identityNumber = employee['identityNumber'] as String;
      final baseSalary = employee['salary'] as double;
      final workingYears = employee['workingYears'] as int;
      final originalAmount = baseSalary;
      final amount = calculateSalaryIncrease(baseSalary, workingYears);

      if (amount > originalAmount) {
        increasedSalaryCount++; // Increase count if salary was increased
      }

      final paymentId = await db.insert('salaries', {
        'identityNumber': identityNumber,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
      });

      if (paymentId > 0) {
        paymentCount++;
      }
    }

    return {
      'totalPayments': paymentCount,
      'increasedPayments': increasedSalaryCount,
    };
  }
  Future<List<Map<String, dynamic>>> getSalarySlips(String lastDigit) async {
    final db = await database;
    return db.query(
      'salaries',
      where: 'substr(identityNumber, -1) = ?',
      whereArgs: [lastDigit],
    );
  }

  Future<String?> getEmployeePhotoPathById(String identityNumber) async {
    final db = await database;
    final result = await db.query(
      'employees',
      columns: ['imagePath'],
      where: 'identityNumber = ?',
      whereArgs: [identityNumber],
    );

    if (result.isNotEmpty) {
      return result.first['imagePath'] as String?;
    }

    return null;
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> employeeMaps = await db.query('employees');

    return List.generate(employeeMaps.length, (i) {
      return Employee(
        id: employeeMaps[i]['id'],
        name: employeeMaps[i]['name'],
        identityNumber: employeeMaps[i]['identityNumber'],
        department: employeeMaps[i]['department'],
        salary: employeeMaps[i]['salary'],
        address: employeeMaps[i]['address'],
        workingYears: employeeMaps[i]['workingYears'],
        imagePath: employeeMaps[i]['imagePath'],
      );
    });
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final db = await database;
    return db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('salaries'); // This line will delete all data from the 'salaries' table
    await db.delete('employees'); // This line will delete all data from the 'employees' table
  }

  double calculateSalaryIncrease(double salary, int workingYears) {
    if (workingYears >= 10 && workingYears < 20) {
      return salary * 1.15;
    } else if (workingYears >= 20) {
      return salary * 1.25;
    }
    return salary;
  }
}