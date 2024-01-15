import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/employee.dart';
import '../helpers/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class EmployeeRegistrationScreen extends StatefulWidget {
  @override
  _EmployeeRegistrationScreenState createState() =>
      _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState
    extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _identityNumber = '';
  String _department = '';
  double _salary = 0.0;
  String _address = '';
  int _workingYears = 0;
  File? _image;
  List<String> _employeesIdentityNumbers = [];
  LatLng? _selectedLocation;
  final Completer<GoogleMapController> _haritaKontrol = Completer();
  static final CameraPosition _ilkkonum = CameraPosition(
    target: LatLng(37.8667, 32.4833),
    zoom: 14,
  );

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Kullanıcı izin vermezse yapılacak işlemler
    }
  }

  Future<void> _selectLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });
    // Seçilen konumun adresini al
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String formattedAddress =
          '${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}';
      setState(() {
        _address = formattedAddress; // Adresi _address değişkenine ata
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _selectedLocation =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      _updateCameraPosition(_selectedLocation!);
    });
  }

  Future<void> _updateCameraPosition(LatLng location) async {
    final GoogleMapController controller = await _haritaKontrol.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: location,
      zoom: 14,
    )));
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _getCurrentLocation();
    _requestPermission(); // Mevcut konumu al ve haritada göster
  }

  Future<void> _loadEmployees() async {
    final employees = await DatabaseHelper.instance.getAllEmployees();
    setState(() {
      _employeesIdentityNumbers =
          employees.map((e) => e.identityNumber).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final employee = Employee(
        name: _name,
        identityNumber: _identityNumber,
        department: _department,
        salary: _salary,
        address: _address,
        workingYears: _workingYears,
        imagePath: _image?.path,
      );
      await DatabaseHelper.instance.addEmployee(employee);
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              if (_image != null) Image.file(_image!, width: 100, height: 100),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Resim Ekle'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kişi Adı'),
                onSaved: (value) => _name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Lütfen bir ad girin' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kişi TC. Kimlik No'),
                onSaved: (value) => _identityNumber = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kimlik numarası girin';
                  } else if (value.length != 11) {
                    return 'Kimlik numarası 11 haneli olmalıdır';
                  } else if (_employeesIdentityNumbers.contains(value)) {
                    return 'Bu kimlik numarası zaten kayıtlı';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kişi Departman'),
                onSaved: (value) => _department = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Lütfen departman girin' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kişi Maaş'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _salary = double.tryParse(value!) ?? 0.0,
                validator: (value) =>
                    value!.isEmpty ? 'Lütfen maaş girin' : null,
              ),
              Text("Çalışma Yılı: "),
              Slider(
                value: _workingYears.toDouble(),
                min: 0,
                max: 30,
                divisions: 30,
                label: ' ${_workingYears.toString()}',
                onChanged: (newValue) {
                  setState(() {
                    _workingYears = newValue.round();
                  });
                },
              ),
              SizedBox(
                width: double.infinity,
                // Haritanın genişliğini ekran genişliği yapabilirsiniz.
                height: 300,
                // Haritanın yüksekliği
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _haritaKontrol.complete(controller);
                  },
                  initialCameraPosition: _ilkkonum,
                  mapType: MapType.normal,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: MarkerId('selectedLocation'),
                            position: _selectedLocation!,
                            infoWindow: InfoWindow(title: 'Seçilen Konum'),
                          ),
                        }
                      : {},
                  onTap: (LatLng tappedLocation) {
                    _selectLocation(tappedLocation); // Seçilen konumu işle
                  },
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adres'),
                controller: TextEditingController(text: _address),
                onSaved: (value) {
                  if (value != null) _address = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adres girin';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _saveEmployee,
                child: Text('Kaydet'),
              ),
              //Divider(),
              /*Text('Kayıtlı Çalışanlar:'),
              _buildEmployeeList(),*/
            ],
          ),
        ),
      ),
    );
  }
}
