import 'dart:math';
import 'dart:async';

class DistanceCalculator {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0;

    double toRadians(double degrees) {
      return degrees * (pi / 180.0);
    }

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(lat1)) * cos(toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c;

    return distance;
  }

  static Future<List<double>> calculateDistancesConcurrently(List<List<double>> locations) async {
    List<Future<double>> futures = [];

    for (var location in locations) {
      futures.add(Future(() {
        return calculateDistance(locations[0][0], locations[0][1], location[0], location[1]);
      }));
    }

    return await Future.wait(futures);
  }
}

void main() async {
  List<List<double>> locations = [
    [26.879382302987736, 75.81171692048768],
    [26.874252829869057, 75.80794037052786],
    [26.878004258447678, 75.80957115346507],
    [26.868510606280076, 75.8188408670028],
    [26.86759182344614, 75.79626739792481],
    [26.862270392734587, 75.78871429800517],
    [26.862002400393983, 75.79832733426652],
    [26.864835430159378, 75.79412163090217],
    [26.8647205789813, 75.7979840115429],
    [26.866213635199767, 75.79240501728407],
    [26.86165783788028, 75.79339207011449],
    [26.861504698648428, 75.79369247749766],
  ];

  List<double> distances = await DistanceCalculator.calculateDistancesConcurrently(locations);

  // Sort the distances
  distances.sort();

  // Divide the sorted distances into three lists
  List<double> list1 = distances.sublist(0, 4);
  List<double> list2 = distances.sublist(4, 8);
  List<double> list3 = distances.sublist(8, 12);

  print('List 1: $list1');
  print('List 2: $list2');
  print('List 3: $list3');
}
