library event_widget;

import 'package:event_widget/event_data.dart';
import 'package:event_widget/event_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 事件刷新的Widget
abstract class _EventsWidget extends StatefulWidget {
  /// 参数 data        数据变化抛出事件的对象
  /// 参数 eventTypes   影响Widget显示的事件集合
  const _EventsWidget({Key? key, required this.datas}) : super(key: key);
  final List<EventData> datas;
}

abstract class _EventsState<T extends _EventsWidget> extends State<T> {
  bool _doEvent = false;
  List<EventData>? datas;
  @override
  void initState() {
    super.initState();
    datas = createData();
    if (datas != null) {
      for (var i = 0; i < datas!.length; i++) {
        _addListener(datas![i]);
      }
    }
  }

  List<EventData>? createData() {
    return widget.datas;
  }

  void _addListener(EventData data) {
    var list = data.eventTypes;
    if (list != null) {
      var _list = List.from(list);
      for (var item in _list) {
        data.data.on(item, onDataEvent);
      }
    }
  }


  void _removeListener(EventData data) {
    var list = data.eventTypes;
    if (list != null) {
      var _list = List.from(list);
      for (var item in _list) {
        data.data.off(item, onDataEvent);
      }
    }
  }

  void onDataEvent(Object sender, Object type, Object? data) {
    _doEvent = false;
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      if (_doEvent || !mounted) {
        return;
      }
      _doEvent = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (datas != null) {
      for (var i = 0; i < datas!.length; i++) {
        _removeListener(datas![i]);
      }
    }
    datas = null;
    super.dispose();
  }
}

// 事件刷新的Widget
class SuperEventsWidget extends _EventsWidget {
  const SuperEventsWidget(
      {Key? key,
        required List<EventData> datas,
        Widget Function(BuildContext context)
        ? builder })
      : _builder = builder,
        super(key: key, datas: datas);
  final Widget Function(
      BuildContext context,
      )? _builder;

  @override
  _EventsState<SuperEventsWidget> createState() => EventsState();
// @override
// noSuchMethod(Invocation invocation) {}
}

class EventsState extends _EventsState<SuperEventsWidget> {
  @override
  Widget build(BuildContext context) {
    return widget._builder!(context);
  }
}

// 事件刷新的Widget
class EventsWidget extends SuperEventsWidget {
  EventsWidget(
      {Key? key,
        required EventDispatcher data,
        List<Object>? eventTypes,
        Widget Function(
            BuildContext context,
            ) ? builder})
      : super(
      key: key,
      datas: [EventData(data, eventTypes)],
      builder: builder);
}

// 事件刷新的Widget的数据
class UpdateBlockWidgetData {
  final EventDispatcher data;
  final List<int>? watchInts;
  final List<int>? watchStrings;
  const UpdateBlockWidgetData(this.data, this.watchInts, this.watchStrings);
}

class UpdateBlockWidget extends StatefulWidget {
  const UpdateBlockWidget(
      {Key? key,
        required this.datas,
        Widget Function(
            BuildContext context,
            )?
        builder})
      : _builder = builder,
        super(key: key);
  final Widget Function(
      BuildContext context,
      )? _builder;
  final List<UpdateBlockWidgetData> datas;
  @override
  UpdateBlockState createState() => UpdateBlockState();
}

class UpdateBlockState extends State<UpdateBlockWidget> {
  /// 数字下标更新
  static const String updateIntBlock = 'updateIntBlock';

  /// 字符串下标更新
  static const String updateStringBlock = 'updateStringBlock';

  List<UpdateBlockWidgetData>? datas;
  bool _doEvent = false;

  @override
  void initState() {
    super.initState();
    datas = createData();
    if (datas != null) {
      for (var i = 0; i < datas!.length; i++) {
        var data = datas![i].data;
        data.on(updateIntBlock, onUpdateIntBlock);
        data.on(updateStringBlock, onUpdateStringBlock);
      }
    }
  }

  List<UpdateBlockWidgetData>? createData() {
    return widget.datas;
  }

  bool _isWatchInt(EventDispatcher sender, int key) {
    if (datas == null) {
      return false;
    }
    for (var i = 0; i < datas!.length; i++) {
      if (sender == datas![i].data) {
        return datas![i].watchInts!.contains(key);
      }
    }
    return false;
  }

  bool _isWatchString(EventDispatcher sender, int key) {
    if (datas == null) {
      return false;
    }
    for (var i = 0; i < datas!.length; i++) {
      if (sender == datas![i].data) {
        return datas![i].watchStrings!.contains(key);
      }
    }
    return false;
  }

  void onUpdateIntBlock(Object sender, Object type, Object? data) {
    if (data != null && _isWatchInt(sender as EventDispatcher, data as int)) {
      _doEvent = false;
      SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
        if (_doEvent || !mounted) {
          return;
        }
        _doEvent = true;
        setState(() {});
      });
    }
  }

  void onUpdateStringBlock(Object sender, Object type, Object? data) {
    if (data != null &&
        _isWatchString(sender as EventDispatcher, data as int)) {
      _doEvent = false;
      SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
        if (_doEvent) {
          return;
        }
        _doEvent = true;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder!(context);
  }

  @override
  void dispose() {
    if (datas != null) {
      for (var i = 0; i < datas!.length; i++) {
        var data = datas![i].data;
        data.off(updateIntBlock, onUpdateIntBlock);
        data.off(updateStringBlock, onUpdateStringBlock);
      }
    }
    super.dispose();
  }
}