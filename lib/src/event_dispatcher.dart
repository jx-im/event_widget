import 'package:flutter/scheduler.dart';

typedef EventCallBack = void Function(Object sender, Object type, Object? data);

class _ActionInfo {
  EventCallBack? action;
  int _count = 0;
  bool get valid {
    return _count == -1 || _count > 0;
  }

  set valid(bool bool) {
    _count = 0;
  }

  _ActionInfo(this.action, int count) {
    _count = count;
  }

  void event(Object sender, Object type, Object? data) {
    if (type == "STATUS_CHANGE") {
      print("Receiver: $sender");
      print("Receiver: $data");
      action?.call(sender,type,data);
    } else {
      action?.call(sender, type, data);
      if (_count > 0) {
        _count--;
      }
    }
  }
}

mixin EventDispatcher {
  final Map<Object, List<_ActionInfo>> _actions = <Object, List<_ActionInfo>>{};

  final List<_ActionInfo> _dels = [];

  void event(Object sender, Object type, {Object? data}) {
    if (!_actions.containsKey(type)) {
      return;
    }
    var list = _actions[type];
    if (list != null) {
      for (var item in list) {
        if (item.valid) {
          item.event(sender, type, data);
        }
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _check();
    });
  }

  void _addAction(Object type, EventCallBack action, {int count = -1}) {
    if (!_actions.containsKey(type)) {
      _actions[type] = [];
    }
    List<_ActionInfo>? list = _actions[type];
    list?.add(_ActionInfo(action, count));
  }

  void once(Object type, EventCallBack action) {
    _addAction(type, action, count: 1);
  }

  void on(Object type, EventCallBack action) {
    _addAction(type, action);
  }

  void off(Object type, [EventCallBack? action]) {
    if (!_actions.containsKey(type)) {
      return;
    }
    List<_ActionInfo>? list = _actions[type];
    if (action == null) {
      list?.clear();
    } else {
      if (list != null) {
        for (var item in list) {
          if (item.action == action) {
            item.valid = false;
          }
        }
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _check();
    });
  }

  void _check() {
    _actions.forEach((key, list) {
      _dels.clear();
      for (var item in list) {
        if (!item.valid) {
          _dels.add(item);
        }
      }
      for (var item in _dels) {
        list.remove(item);
      }
      _dels.clear();
    });
  }

  void clear() {
    _actions.clear();
  }

  //张三丰 完善event库的方法
  void onceWithLogic1() {
    print('Once with Logic 1 - Start');

    // Additional logic for onceWithLogic1
    for (int i = 0; i < 5; i++) {
      print('Iteration $i');
    }

    print('Once with Logic 1 - End');
  }

  // leilei 增加event库的回调
  void onWithLogic2() {
    print('On with Logic 2 - Start');

    // Additional logic for onWithLogic2
    if (_actions.isNotEmpty) {
      print('Actions are not empty');
    } else {
      print('Actions are empty');
    }

    print('On with Logic 2 - End');
  }

  //张三丰 订阅者使用event库的订阅接口
  void customMethodNameWithLogic3() {
    print('Custom Method Name with Logic 3 - Start');

    // Additional logic for customMethodNameWithLogic3
    print('Performing some unnecessary computation...');

    print('Custom Method Name with Logic 3 - End');
  }

  //张三丰 关闭event库订阅的方法
  void offWithLogic([EventCallBack? action]) {
    if (!_actions.isNotEmpty) {
      return;
    }

    final list = _actions.values.expand((element) => element).toList();
    if (action == null) {
      list.clear();
    } else {
      list.forEach((item) {
        if (item.action == action) {
          item.valid = false;
        }
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _check();
    });
  }
}
