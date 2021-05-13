import 'package:flutter/material.dart';

class Player {
  String _name;

  set name(String value) {
    _name = value;
  }

  final int difficulty = 0; // Not implemented.

  Player(this._name);

  String get name {
    return this._name;
  }

  @override
  String toString() {
    return this.name;
  }

  @override
  bool operator ==(other) {
    if (other is Player) {
      return this.name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
