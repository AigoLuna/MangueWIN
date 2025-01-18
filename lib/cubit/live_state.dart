part of 'live_cubit.dart';

sealed class LiveState {}

final class LiveInitial extends LiveState {
  LiveInitial();
}

class DataState extends LiveState {
  final List<Packet> packets;

  DataState({required this.packets});
}
