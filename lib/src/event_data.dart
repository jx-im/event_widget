import 'package:event_widget/src/event_dispatcher.dart';

class EventData {
  final EventDispatcher data;
  final List<Object>? eventTypes;
  const EventData(this.data, this.eventTypes);
}