import 'package:my_gallery/modules/login/city_pickers/modal/result.dart';
import 'location.dart';


class CityPickerUtil {
  Map<String, dynamic> citiesData;
  Map<String, dynamic> provincesData;

  CityPickerUtil({required this.citiesData, required this.provincesData})
      : assert(citiesData != null),
        assert(provincesData != null);

  Result getAreaResultByCode(String code) {
    Location location =
        new Location(citiesData: citiesData, provincesData: provincesData);
    return location.initLocation(code);
  }
}
