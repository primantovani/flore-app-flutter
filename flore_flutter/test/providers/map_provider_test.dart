import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flore_flutter/providers/map_provider.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

Position _fakePosition({double lat = -22.9, double lon = -43.2}) {
  return Position(
    latitude: lat,
    longitude: lon,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );
}

void main() {
  late MockGeolocatorPlatform mockPlatform;

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
  });

  group('MapProvider - localizacao', () {
    test('quando o servico de localizacao esta desligado, marca serviceDisabled', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final provider = MapProvider();
      await provider.retryLocation();

      expect(provider.locationStatus, LocationPermissionStatus.serviceDisabled);
    });

    test('quando a permissao e negada, marca denied', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final provider = MapProvider();
      await provider.retryLocation();

      expect(provider.locationStatus, LocationPermissionStatus.denied);
    });

    test('quando a permissao e negada para sempre, marca deniedForever', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      final provider = MapProvider();
      await provider.retryLocation();

      expect(provider.locationStatus, LocationPermissionStatus.deniedForever);
    });

    test('quando a permissao e concedida, marca granted e atualiza lat/lon', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) async => _fakePosition(lat: -22.9, lon: -43.2));

      final provider = MapProvider();
      await provider.retryLocation();

      expect(provider.locationStatus, LocationPermissionStatus.granted);
      expect(provider.userLat, -22.9);
      expect(provider.userLon, -43.2);
    });

    test('quando o Geolocator lanca um erro inesperado, marca denied sem quebrar o app', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenThrow(Exception('erro simulado de GPS'));

      final provider = MapProvider();
      await provider.retryLocation();

      expect(provider.locationStatus, LocationPermissionStatus.denied);
    });
  });
}
