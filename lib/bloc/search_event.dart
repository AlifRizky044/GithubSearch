part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class Increment extends SearchEvent{
  final int number;
  Increment({this.number = 1});
}

class Decrement extends SearchEvent{}

class ChangePage extends SearchEvent{
  final int number;
  ChangePage({required this.number});
}

class SearchUserEvent extends SearchEvent{
  final headers;
  final int indexPage;
  final String query;
  final bool reset;
  final int indexpagination;
  SearchUserEvent({required this.headers, required this.indexPage, required this.query, required this.reset, this.indexpagination = 0});
}