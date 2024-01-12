class Employee {
  final int? id;
  final String name;
  final String identityNumber;
  final String department;
  final double salary;
  final String address;
  final int workingYears;
  final String? imagePath;

  Employee({
    this.id,
    required this.name,
    required this.identityNumber,
    required this.department,
    required this.salary,
    required this.address,
    required this.workingYears,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identityNumber': identityNumber,
      'department': department,
      'salary': salary,
      'address': address,
      'workingYears': workingYears,
      'imagePath': imagePath,
    };
  }
}