enum UserRole {
  admin,
  manager,
  cashier;

  bool get canAccessInventory => this != cashier;
  bool get canAccessReports => this != cashier;
  bool get canAccessSettings => this == admin;
}
