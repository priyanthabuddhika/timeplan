
class Note {
  final String id;
  final String title;
  final String description;
  final DateTime dateUpdated;
  Note({
    this.id,
    this.title,
    this.description,
    this.dateUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateUpdated': dateUpdated.toString(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> data, String documentID) {
    if (data == null) {
      return null;
    }
    String id = data['id'];
    String title = data['title'];
    String description = data['description'];
    DateTime dateUpdated = DateTime.parse(data['dateUpdated']);
    return Note(title: title, description: description, dateUpdated: dateUpdated,id: id);
  }
}
