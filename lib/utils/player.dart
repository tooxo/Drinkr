import 'package:flutter/material.dart';

@immutable
class Player {
  final bool gender = true; // == Is Man?
  final String _name;

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
    return this.name == other.name;
  }

  @override
  int get hashCode => super.hashCode;
}
