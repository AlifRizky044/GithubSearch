import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<ChangePage>((event, emit) async {
      print(event.number);
      emit(PageValue(event.number, [], 0, 1,"Silahkan cari data Github dari text field di atas."));
    });
    //(int number, int indexPage, List entries, int pagination)
    on<SearchUserEvent>((event, emit) async {
      String link = "";
      List result = [];

      print(state.indexpagination);
      int indexpagination = state.indexpagination;
      if(event.reset == false && event.indexpagination == 0){
        result = state.entries;
        indexpagination = state.indexpagination + 1;
      }

      if(event.indexPage==0){
        link = 'https://api.github.com/search/users?q=${event.query}&page=${event.indexpagination == 0 ? indexpagination : event.indexpagination}&per_page=20';
      }else if(event.indexPage==1){
        link = 'https://api.github.com/search/repositories?q=${event.query}&page=${event.indexpagination == 0 ? indexpagination : event.indexpagination}&per_page=20';
      }else{
        link = 'https://api.github.com/search/issues?q=${event.query}&page=${event.indexpagination == 0 ? indexpagination : event.indexpagination}&per_page=20';
      }

      final response = await http.get(Uri.parse(link), headers: event.headers);
      print(response.statusCode);
      int _maxPagination = 0;
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        indexpagination = event.indexpagination == 0 ? indexpagination : event.indexpagination;
        var res = jsonDecode(response.body);


        result.addAll(res['items']);
        //entries.addAll(res['items']);
        if(res['total_count'] >=1000){
          _maxPagination = 50;
        }else{
          _maxPagination = (res['total_count']/20).ceil();
        }
        if(res['items'].length == 0){
          emit(SearchUserState(state.indexPage,state.entries,state.maxpagination,state.indexpagination,"Silahkan cari data Github dari text field di atas."));
        }else{
          emit(SearchUserState(state.indexPage,result,_maxPagination,indexpagination,"Maaf data yang anda cari tidak tersedia."));
        }
        // entries.add(result[1]['login']);
      }
     else{
        final res = jsonDecode(response.body);
        print(res['message']);
        // entries.add(result[1]['login']);
        emit(SearchUserState(state.indexPage, [], 0, 1,"Silahkan cari data Github dari text field di atas."));
      }
    });
  }
}
