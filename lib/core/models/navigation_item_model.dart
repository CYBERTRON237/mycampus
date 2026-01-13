class NavigationItem {
  final String id;
  final String title;
  final String icon;
  final String route;
  final List<NavigationItem>? subItems;
  final bool requiresAuth;
  final List<String>? requiredRoles;
  final String? category;

  NavigationItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.subItems,
    this.requiresAuth = true,
    this.requiredRoles,
    this.category,
  });

  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      route: json['route'],
      subItems: json['subItems'] != null 
          ? (json['subItems'] as List).map((i) => NavigationItem.fromJson(i)).toList()
          : null,
      requiresAuth: json['requiresAuth'] ?? true,
      requiredRoles: json['requiredRoles']?.cast<String>(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'route': route,
      'subItems': subItems?.map((i) => i.toJson()).toList(),
      'requiresAuth': requiresAuth,
      'requiredRoles': requiredRoles,
      'category': category,
    };
  }
}
