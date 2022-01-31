part of 'search_bloc.dart';

@immutable
abstract class SearchState {
  final int indexPage;
  final int maxpagination;
  final int indexpagination;
  final String message;
  final List entries;
  const SearchState(this.indexPage,this.entries,this.maxpagination,this.indexpagination,this.message);
}

class SearchInitial extends SearchState {
  SearchInitial() : super(0,[],0,1,"Silahkan cari data Github dari text field di atas.");
}

class PageValue extends SearchState{
  PageValue(int indexPage, List entries, int maxpagination, int indexpagination, String message)
      : super(indexPage, entries, maxpagination, indexpagination, message);


}

class SearchUserState extends SearchState{
  SearchUserState(int indexPage, List entries, int maxpagination, int indexpagination, String message)
      : super(indexPage, entries, maxpagination, indexpagination, message);

}
