
class DifficultyType {
  static DifficultyType EASY = DifficultyType(
      startShots: 0, endShots: 0, startSips: 1, endSips: 2, name: "EASY");
  static DifficultyType MEDIUM = DifficultyType(
      startShots: 1, endShots: 2, startSips: 2, endSips: 3, name: "MEDIUM");
  static DifficultyType HARD = DifficultyType(
      startShots: 2, endShots: 3, startSips: 4, endSips: 5, name: "HARD");

  final int startShots;
  final int endShots;
  final int startSips;
  final int endSips;

  final int shotProbability;

  final String name;

  DifficultyType({
    required this.startShots,
    required this.endShots,
    required this.startSips,
    required this.endSips,
    required this.name,
    this.shotProbability = 50,
  });
}
