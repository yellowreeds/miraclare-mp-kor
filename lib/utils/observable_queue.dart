import 'dart:collection';
import 'package:get/get.dart';
import 'package:goodeeps2/constants.dart';

class ObservableQueue<T> {
  Queue<T> _queue = Queue<T>();
  final Rx<Queue<T>> rxQueue = Queue<T>().obs;

  Queue<T> get queue => rxQueue.value;

  void add(T element) {
    _queue.add(element);
    rxQueue.value = Queue<T>.from(_queue);
  }

  void addAll(Iterable<T> elements) {
    _queue.addAll(elements);
    rxQueue.value = Queue<T>.from(_queue);
  }

  void removeFirst() {
    _queue.removeFirst();
    rxQueue.value.removeFirst();
  }

  void remove(T element) {
    _queue.remove(element);
    rxQueue.value.remove(element);
    // loggerNoStack.t(element);
  }

  void clear() {
    _queue.clear();
    rxQueue.value = Queue<T>.from(_queue);
  }
}

