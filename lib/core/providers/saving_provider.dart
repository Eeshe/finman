import 'package:finman/core/models/account.dart';
import 'package:finman/core/models/saving.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SavingProvider extends ChangeNotifier {
  List<Saving> _savings = [];


  List<Saving> get savings => _savings;

  Future<Box<Saving>> _openBox() async {
    return await Hive.openBox<Saving>('savings');
  }

  Future<void> fetchAll() async {
    final Box<Saving> box = await _openBox();
    _savings = box.values.toList();
  }

  Future<int> _findIndex(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final List<Saving> savings = box.values.toList();
    return savings.indexWhere((e) => e.id == saving.id);
  }

  Future<void> _update(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final index = await _findIndex(saving);
    if (index == -1) return;

    await box.putAt(index, saving);
    notifyListeners();
  }

  Future<void> save(Saving saving) async {
    if (await _findIndex(saving) != -1) {
      _update(saving);
      return;
    }
    final Box<Saving> box = await _openBox();
    await box.add(saving);
    _savings.add(saving);
    notifyListeners();
  }

  Future<void> delete(Saving saving) async {
    final Box<Saving> box = await _openBox();
    final index = await _findIndex(saving);
    if (index == -1) return;

    await box.deleteAt(index);
    _savings.remove(saving);
    notifyListeners();
  }

  List<Saving> getByAccount(Account account) {
    return _savings.where((saving) => saving.accountId == account.id).toList();
  }
}