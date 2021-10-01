class Player {
  String name;

  Player(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(other) {
    if (other is Player) {
      return name == other.name;
    }
    return false;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

}
