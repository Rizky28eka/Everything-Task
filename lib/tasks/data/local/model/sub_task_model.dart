class SubTaskModel {
  String id;
  String title;
  bool completed;

  SubTaskModel({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}
