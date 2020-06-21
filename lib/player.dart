class Player {
  bool gender; // == Is Man?
  String _name;

  int difficulty; // Not implemented.

  Player(String name) {
    this._name = name;
  }

  get name {
    return this._name;
  }

  @override
  String toString() {
    return this.name;
  }

  @override
  bool operator ==(other) {
    return this.name == other.name;
  }

  @override
  int get hashCode => super.hashCode;
}
