class AnchoringSession {
  final int? id;
  final int startDatetime;
  final int? endDatetime;
  final double latitude;
  final double longitude;
  final bool active;
  final String? name;

  AnchoringSession({
    this.id,
    required this.startDatetime,
    this.endDatetime,
    required this.latitude,
    required this.longitude,
    required this.active,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_datetime': startDatetime,
      'end_datetime': endDatetime,
      'latitude': latitude,
      'longitude': longitude,
      'active': active ? 1 : 0,
      'name': name,
    };
  }

  factory AnchoringSession.fromMap(Map<String, dynamic> map) {
    return AnchoringSession(
      id: map['id'],
      startDatetime: map['start_datetime'],
      endDatetime: map['end_datetime'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      active: map['active'] == 1,
      name: map['name'],
    );
  }
}