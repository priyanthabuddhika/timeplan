class Schedule {
  final String id;
  final String title;
  final String description;
  final String type;
  final String date;
  final DateTime startTime;
  final DateTime endTime;
  Schedule(
      {this.id,
      this.title,
      this.description,
      this.type,
      this.date,
      this.startTime,
      this.endTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> data, String documentID) {
    if (data == null) {
      return null;
    }
    String id = data['id'];
    String title = data['title'];
    String description = data['description'];
    String type = data['type'];
    String date = data['date'];
    DateTime starttime = DateTime.parse(data['startTime']);
    DateTime endTime = DateTime.parse(data['endTime']);
    return Schedule(
      title: title,
      description: description,
      type: type,
      date: date,
      id: id,
      startTime: starttime,
      endTime: endTime,
    );
  }
}
