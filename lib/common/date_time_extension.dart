import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeExtension on DateTime {
  bool isAfterTimestamp(Timestamp? timestamp) {
    final temp = timestamp ?? Timestamp.now();
    final date = DateTime.fromMillisecondsSinceEpoch(
      temp.millisecondsSinceEpoch,
    );
    return isAfter(date);
  }

  bool isBeforeTimestamp(Timestamp? timestamp) {
    final temp = timestamp ?? Timestamp.now();
    final date = DateTime.fromMillisecondsSinceEpoch(
      temp.millisecondsSinceEpoch,
    );
    return isBefore(date);
  }

  bool isAfterOrEqual(Timestamp? timestamp) {
    final temp = timestamp ?? Timestamp.now();
    final date = DateTime.fromMillisecondsSinceEpoch(
      temp.millisecondsSinceEpoch,
    );
    return isAtSameMomentAs(date) || isAfter(date);
  }

  bool isBeforeOrEqual(Timestamp? timestamp) {
    final temp = timestamp ?? Timestamp.now();
    final date = DateTime.fromMillisecondsSinceEpoch(
      temp.millisecondsSinceEpoch,
    );
    return isAtSameMomentAs(date) || isBefore(date);
  }

  bool isBetweenEqual({required Timestamp? from, required Timestamp? to}) {
    return isAfterOrEqual(from) && isBeforeOrEqual(to);
  }

  bool isBetweenExclusive({required Timestamp? from, required Timestamp? to}) {
    final tempFrom = from ?? Timestamp.now();
    final fromDate = DateTime.fromMillisecondsSinceEpoch(
      tempFrom.millisecondsSinceEpoch,
    );
    final tempTo = to ?? Timestamp.now();
    final toDate = DateTime.fromMillisecondsSinceEpoch(
      tempTo.millisecondsSinceEpoch,
    );
    return isAfter(fromDate) && isBefore(toDate);
  }
}
