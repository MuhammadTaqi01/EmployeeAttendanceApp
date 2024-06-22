import 'package:location/location.dart';

class LocationService{
  Location location = Location();
  late LocationData _locData;
  Future<void> initialize() async {
    bool _serviceEnabled;
    PermissionStatus _permisson;

    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled){
        return ;
      }
    }

    _permisson = await location.hasPermission();
    if(_permisson == PermissionStatus.denied){
      _permisson = await location.requestPermission();
      if(_permisson != PermissionStatus.denied){
        return ;
      }
    }
  }

  Future<double?> getLatitude() async{
    _locData = await location.getLocation();
    return _locData.latitude;
  }

  Future<double?> getLongitude() async{
    _locData = await location.getLocation();
    return _locData.longitude;
  }

}