import 'package:flutter/material.dart';
import 'package:shop_app/models/district.model.dart';
import 'package:shop_app/models/province.model.dart';
import 'package:shop_app/models/ward.model.dart';
import 'package:shop_app/services/api.dart';

class AddressSelectionWidget extends StatefulWidget {
  final Function(Map<String, String>) onSelectionChanged;
  final String? initialProvince;
  final String? initialDistrict;
  final String? initialWard;

  AddressSelectionWidget({
    required this.onSelectionChanged,
    this.initialProvince,
    this.initialDistrict,
    this.initialWard,
  });

  @override
  _AddressSelectionWidgetState createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedProvinces = await Api.getListProvince();
    setState(() {
      provinces = loadedProvinces;
      if (widget.initialProvince != null) {
        selectedProvince = provinces.firstWhere(
          (province) => province.name == widget.initialProvince,
          orElse: () => provinces.first,
        );
      } else {
        selectedProvince = provinces.first;
      }
      _loadDistricts(selectedProvince!.code);
    });
  }

  Future<void> _loadDistricts(String provinceCode) async {
    final loadedDistricts = await Api.getListDistrict(provinceCode);
    setState(() {
      districts = loadedDistricts;
      if (widget.initialDistrict != null) {
        selectedDistrict = districts.firstWhere(
          (district) => district.name == widget.initialDistrict,
          orElse: () => districts.first,
        );
      } else {
        selectedDistrict = districts.first;
      }
      _loadWards(selectedDistrict!.code ?? '');
    });
  }

  Future<void> _loadWards(String districtCode) async {
    final loadedWards = await Api.getListWard(districtCode);
    setState(() {
      wards = loadedWards;
      if (widget.initialWard != null) {
        selectedWard = wards.firstWhere(
          (ward) => ward.name == widget.initialWard,
          orElse: () => wards.first,
        );
      } else {
        selectedWard = wards.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onTap: () {
            _showProvinceDialog();
          },
          readOnly: true,
          controller:
              TextEditingController(text: selectedProvince?.fullName ?? ''),
          decoration: InputDecoration(
            labelText: "Tỉnh/ Thành phố",
            hintText: "Chọn tỉnh/ thành phố",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          onTap: () {
            _showDistrictDialog();
          },
          readOnly: true,
          controller:
              TextEditingController(text: selectedDistrict?.fullName ?? ''),
          decoration: InputDecoration(
            labelText: "Quận/ Huyện",
            hintText: "Chọn quận/ huyện",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
        SizedBox(height: 20),
        TextFormField(
          onTap: () {
            _showWardDialog();
          },
          readOnly: true,
          controller: TextEditingController(text: selectedWard?.fullName ?? ''),
          decoration: InputDecoration(
            labelText: "Xã/ Phường",
            hintText: "Chọn xã/ phường",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }

  _showProvinceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn Tỉnh/ Thành phố"),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provinces.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(provinces[index].fullName),
                  onTap: () async {
                    setState(() {
                      selectedProvince = provinces[index];
                      selectedDistrict = null;
                      selectedWard = null;
                      districts = [];
                      wards = [];
                    });
                    await _loadDistricts(selectedProvince!.code);
                    widget.onSelectionChanged({
                      'province': selectedProvince!.name,
                      'district': '',
                      'ward': '',
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  _showDistrictDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn Quận/ Huyện"),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: districts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(districts[index].fullName),
                  onTap: () async {
                    setState(() {
                      selectedDistrict = districts[index];
                      selectedWard = null;
                      wards = [];
                    });
                    await _loadWards(selectedDistrict!.code);
                    widget.onSelectionChanged({
                      'province': selectedProvince!.name,
                      'district': selectedDistrict!.name,
                      'ward': '',
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  _showWardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn Xã/ Phường"),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: wards.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(wards[index].fullName),
                  onTap: () {
                    setState(() {
                      selectedWard = wards[index];
                    });
                    widget.onSelectionChanged({
                      'province': selectedProvince!.name,
                      'district': selectedDistrict!.name,
                      'ward': selectedWard!.name,
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
