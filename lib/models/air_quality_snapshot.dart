
import 'air_quality_models.dart';

enum DataConfidence {
  stationMeasured,
  modelEstimate,
  communityUnverified,
  cachedOffline,
  unavailable,
}

class PollutantValue {
  final double value;
  final String unit;
  final String providerId;
  final DateTime timestamp;
  final ObservationType dataType;
  final DataConfidence confidence;

  const PollutantValue({
    required this.value,
    required this.unit,
    required this.providerId,
    required this.timestamp,
    required this.dataType,
    required this.confidence,
  });

  @override
  String toString() =>
      '${value.toStringAsFixed(1)} $unit ($providerId, ${dataType.name})';
}

class WeatherSnapshot {
  final double? temperatureCelsius;
  final int? humidityPercent;
  final double? windSpeedMs;
  final double? windDirectionDeg;
  final String? weatherDescription;
  final String providerId;
  final DateTime fetchedAt;

  const WeatherSnapshot({
    this.temperatureCelsius,
    this.humidityPercent,
    this.windSpeedMs,
    this.windDirectionDeg,
    this.weatherDescription,
    required this.providerId,
    required this.fetchedAt,
  });
}

class IspuResult {
  final int ispuValue;
  final IspuCategory category;
  final String dominantPollutant;
  final String calculationSource;
  final bool isOfficialStation;

  const IspuResult({
    required this.ispuValue,
    required this.category,
    required this.dominantPollutant,
    required this.calculationSource,
    required this.isOfficialStation,
  });

  String get displayValue => ispuValue.toString();
  String get categoryLabel => category.label;
}

class ProviderResult {
  final String providerId;
  final String providerName;
  final bool success;
  final String? errorMessage;
  final DateTime attemptedAt;
  final Duration? responseTime;
  final Map<String, PollutantValue> pollutants;

  const ProviderResult({
    required this.providerId,
    required this.providerName,
    required this.success,
    this.errorMessage,
    required this.attemptedAt,
    this.responseTime,
    this.pollutants = const {},
  });
}

class AirQualityDecision {
  final String status; 
  final IspuCategory category;
  final DataConfidence confidence;
  final String reasonId; 
  final String reasonText;
  final List<String> recommendations;
  final List<String> sourcesUsed;
  final bool hotspotAlert; 
  final int? hotspotCount;
  final DateTime decidedAt;

  const AirQualityDecision({
    required this.status,
    required this.category,
    required this.confidence,
    required this.reasonId,
    required this.reasonText,
    required this.recommendations,
    required this.sourcesUsed,
    required this.hotspotAlert,
    this.hotspotCount,
    required this.decidedAt,
  });

  bool get isActionRequired =>
      category == IspuCategory.tidakSehat ||
      category == IspuCategory.sangatTidakSehat ||
      category == IspuCategory.berbahaya;
}

class SourceMetadata {
  final int totalProvidersTried;
  final int totalProvidersSucceeded;
  final bool hasOfficialStationData;
  final bool hasModelData;
  final bool hasSatelliteData;
  final DateTime snapshotCreatedAt;
  final Map<String, String> providerStatus; 

  const SourceMetadata({
    required this.totalProvidersTried,
    required this.totalProvidersSucceeded,
    required this.hasOfficialStationData,
    required this.hasModelData,
    required this.hasSatelliteData,
    required this.snapshotCreatedAt,
    required this.providerStatus,
  });
}

class AirQualitySnapshot {
  final String locationId; 
  final double latitude;
  final double longitude;
  final String locationName;
  final String province;
  final String city;

  final DateTime timestamp;

  final Map<String, PollutantValue> pollutants;
  final WeatherSnapshot? weather;

  final IspuResult? ispu;

  final String? dominantPollutant;

  final Map<String, ProviderResult> providerResults;

  final AirQualityDecision? decision;

  final SourceMetadata sourceMetadata;

  final bool isOfflineCache;
  final bool isPartialData; 
  const AirQualitySnapshot({
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.province,
    required this.city,
    required this.timestamp,
    this.pollutants = const {},
    this.weather,
    this.ispu,
    this.dominantPollutant,
    this.providerResults = const {},
    this.decision,
    required this.sourceMetadata,
    this.isOfflineCache = false,
    this.isPartialData = false,
  });


  double? get pm25 => pollutants['pm2_5']?.value;
  double? get pm10 => pollutants['pm10']?.value;
  double? get co => pollutants['co']?.value;
  double? get no2 => pollutants['no2']?.value;
  double? get o3 => pollutants['o3']?.value;
  double? get so2 => pollutants['so2']?.value;

  IspuCategory get ispuCategory => ispu?.category ?? IspuCategory.tidakTersedia;
  int? get ispuValue => ispu?.ispuValue;

  bool get hasAnyData => pollutants.isNotEmpty || ispu != null;
  bool get hasOfficialData => sourceMetadata.hasOfficialStationData;
  bool get hasModelData => sourceMetadata.hasModelData;

  DataConfidence get overallConfidence {
    if (!hasAnyData) return DataConfidence.unavailable;
    if (isOfflineCache) return DataConfidence.cachedOffline;
    if (hasOfficialData) return DataConfidence.stationMeasured;
    if (hasModelData) return DataConfidence.modelEstimate;
    return DataConfidence.unavailable;
  }

  String get confidenceLabel {
    switch (overallConfidence) {
      case DataConfidence.stationMeasured:
        return 'Stasiun KLHK';
      case DataConfidence.modelEstimate:
        return 'Estimasi Model Satelit';
      case DataConfidence.communityUnverified:
        return 'Sensor Komunitas (Belum Diverifikasi)';
      case DataConfidence.cachedOffline:
        return 'Cache Offline';
      case DataConfidence.unavailable:
        return 'Data Tidak Tersedia';
    }
  }

  factory AirQualitySnapshot.fromAirReading({
    required AirReading reading,
    required MonitoringRegion region,
    required MonitoringSite site,
    WeatherSnapshot? weather,
  }) {
    final pollutants = <String, PollutantValue>{};
    final now = DateTime.now();
    final confidence = reading.observationType == ObservationType.station
        ? DataConfidence.stationMeasured
        : DataConfidence.modelEstimate;

    void addPollutant(String key, double? val, String unit) {
      if (val != null) {
        pollutants[key] = PollutantValue(
          value: val,
          unit: unit,
          providerId: reading.sourceId,
          timestamp: reading.observedAt,
          dataType: reading.observationType,
          confidence: confidence,
        );
      }
    }

    addPollutant('pm2_5', reading.pm25, 'µg/m³');
    addPollutant('pm10', reading.pm10, 'µg/m³');
    addPollutant('co', reading.co, 'µg/m³');
    addPollutant('no2', reading.no2, 'µg/m³');
    addPollutant('o3', reading.o3, 'µg/m³');

    IspuResult? ispuResult;
    if (reading.officialIspu != null) {
      ispuResult = IspuResult(
        ispuValue: reading.officialIspu!,
        category: IspuCategory.fromIspu(reading.officialIspu),
        dominantPollutant: reading.criticalPollutant ?? 'PM2.5',
        calculationSource: reading.sourceId,
        isOfficialStation: reading.observationType == ObservationType.station,
      );
    }

    final hasStation = reading.observationType == ObservationType.station;
    final hasModel = reading.observationType == ObservationType.model;

    return AirQualitySnapshot(
      locationId: 'region-${region.regionId}',
      latitude: site.latitude,
      longitude: site.longitude,
      locationName: region.displayName,
      province: region.province,
      city: region.regency,
      timestamp: reading.observedAt,
      pollutants: pollutants,
      weather: weather,
      ispu: ispuResult,
      dominantPollutant: reading.criticalPollutant,
      providerResults: {
        reading.sourceId: ProviderResult(
          providerId: reading.sourceId,
          providerName: MonitoringSourceInfo.findById(reading.sourceId).sourceName,
          success: true,
          attemptedAt: now,
          pollutants: pollutants,
        ),
      },
      sourceMetadata: SourceMetadata(
        totalProvidersTried: 1,
        totalProvidersSucceeded: 1,
        hasOfficialStationData: hasStation,
        hasModelData: hasModel,
        hasSatelliteData: hasModel,
        snapshotCreatedAt: now,
        providerStatus: {reading.sourceId: 'ok'},
      ),
      isOfflineCache: reading.isOfflineCache,
      isPartialData: pollutants.isEmpty && ispuResult == null,
    );
  }

  factory AirQualitySnapshot.empty({
    required String locationId,
    required double latitude,
    required double longitude,
    required String locationName,
    required String province,
    required String city,
    Map<String, String>? providerErrors,
  }) {
    final now = DateTime.now();
    final errors = providerErrors ?? {};
    return AirQualitySnapshot(
      locationId: locationId,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      province: province,
      city: city,
      timestamp: now,
      pollutants: const {},
      sourceMetadata: SourceMetadata(
        totalProvidersTried: errors.length,
        totalProvidersSucceeded: 0,
        hasOfficialStationData: false,
        hasModelData: false,
        hasSatelliteData: false,
        snapshotCreatedAt: now,
        providerStatus: errors,
      ),
      isPartialData: true,
    );
  }
}

