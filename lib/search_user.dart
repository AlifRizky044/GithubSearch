import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:githubsearch/bloc/search_bloc.dart';
import 'package:githubsearch/configuration/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchUser extends StatefulWidget{
  SearchUser({Key? key, int? index}) : super(key: key);
  int index = 0;
  State<SearchUser> createState() => _SearchUserPageState();
}
class _SearchUserPageState extends State<SearchUser> {
  Timer? _debounce;
  bool _inProgress = false;
  String searchQuery = "doraemon";
  RefreshController _refreshController = RefreshController();
  final myController = TextEditingController();
  var headers = {
    "Authorization": "token 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"
  };

  void _printLatestValue() async{
    if(_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500),()async{
      if(searchQuery != myController.text) {
        setState(() {
          searchQuery = myController.text;
        });
        _inProgress = true;
        context.read<SearchBloc>().add(SearchUserEvent(
            headers: headers,
            indexPage: widget.index,
            query: myController.text,
            reset: true));
      }
    });
  }
  @override
  void initState() {
    super.initState();
    myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myController.dispose();
    _refreshController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset:false,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_rounded),
            label: 'Repositories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker_notes),
            label: 'Issues',
          ),
        ],
        currentIndex: widget.index,
        selectedItemColor: appBar,
        onTap: (i) {
          setState(() {
            myController.text = "";
            widget.index = i;
          });
          context.read<SearchBloc>().add(ChangePage(number: i));
        },
      ),
      appBar: AppBar(
        title: Text("Github Search",style: GoogleFonts.sora(),),
      ),
      body: Stack(
        children: [
          Column(
                children: [
                  TextField(

                    controller: myController,
                    style: GoogleFonts.sora(),
                    decoration: InputDecoration(

                      border: OutlineInputBorder(),
                      hintText: 'Ketik disini',
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            _inProgress = true;
                          });
                          context.read<SearchBloc>().add(SearchUserEvent(
                              headers: headers,
                              indexPage: widget.index,
                              query: myController.text,
                              reset: true));
                        },
                        icon: Icon(Icons.send),
                      ),
                    ),
                  ),
                  projectWidget(context),

                  pagination(),
                ],
              ),
          BlocListener<SearchBloc, SearchState>(
            listener: (context, state) {
              setState(() {
                _inProgress = false;
              });
            },
            child: Indicator(),
          )
        ],
      ),
    );

  }

  Widget Indicator(){
    if(_inProgress == true){
      return const Center(
          child: SizedBox(
              height: 60.0,
              width: 60.0,
              child:
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                      Colors.blue),
                  strokeWidth: 5.0))
      );
    }return Container();
  }

  Widget pagination(){
    return Container(
      height: 50,
      child: BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return ListView.builder(
            shrinkWrap: true,
              scrollDirection: Axis.horizontal,
            itemCount: state.maxpagination,
            itemBuilder: (BuildContext context, int index) {
              return TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: GoogleFonts.sora(fontSize: 15),
                    shape: CircleBorder(),
                    backgroundColor: state.indexpagination-1 == index?Colors.deepOrangeAccent: appBar
                ),
                onPressed: () async{
                  setState(() {
                    _inProgress = true;
                  });

                  context.read<SearchBloc>().add(SearchUserEvent(indexpagination:index+1,headers: headers,indexPage: widget.index,query: searchQuery,reset: false));
                },
                child: Text((index+1).toString()),
              );
            }
          );
      },
      ),
    );
  }

  Widget projectWidget(BuildContext context) {
    print((MediaQuery.of(context).size.height*100)/100);
    return Container(
            height: (MediaQuery.of(context).size.height*62.95)/100,
            child: SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: ()async{
                final result = true;
                if(result){
                  _refreshController.refreshCompleted();
                }else{
                  _refreshController.refreshFailed();
                }
              },
              onLoading: ()async{
                final result = true;
                context.read<SearchBloc>().add(SearchUserEvent(headers: headers,indexPage: widget.index,query: searchQuery,reset: false));
                if(result){
                  _refreshController.loadComplete();
                }else{
                  _refreshController.loadFailed();
                }
              },
              child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if(state.entries.length > 0){
                        return ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                itemCount: state.entries.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                        height: 80,
                                        color: Colors.white54,
                                        child: listSearch(index,state.entries)
                                    ),
                                  );
                                }
                            );
                      }else{
                        return Center(child: Container(
                          padding: EdgeInsets.only(right: 30.0,left:30),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.sora(
                              fontSize: 20.0,
                              color: kTitleTextLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
            ),
          );
  }

  Widget listSearch(int index, List entries){

    if(widget.index == 0){
      return Padding(
        padding: const EdgeInsets.only(right:8.0,left:10.0,top: 8,bottom:8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 60,
                width: 60,
                child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(entries[index]['avatar_url'],)
                )
            ),
            Flexible(
              child: new Container(
                padding: new EdgeInsets.only(right: 30.0,left:30),
                child: new Text(
                  '${entries[index]['login']}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 15.0,
                    color: kTitleTextLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }else if(widget.index == 1){
      return Padding(
        padding: const EdgeInsets.only(right:8.0,left:10.0,top: 8,bottom:8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 60,
                width: 60,
                child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(entries[index]['owner']['avatar_url'],)
                )
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.only(right: 30.0,left:30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                                '${entries[index]['name']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.sora(
                                  fontSize: 15.0,
                                  color: kTitleTextLightColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text(
                              '${entries[index]['created_at']}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sora(
                                fontSize: 10.0,
                                color: kTitleTextLightColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Watchers : ${entries[index]['watchers']}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sora(
                            fontSize: 10.0,
                            color: kTitleTextLightColor,
                          ),
                        ),
                        Text(
                          'Language : ${entries[index]['language']}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sora(
                            fontSize: 10.0,
                            color: kTitleTextLightColor,
                          ),
                        ),
                        Text(
                          'Forks : ${entries[index]['forks']}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sora(
                            fontSize: 10.0,
                            color: kTitleTextLightColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    }else{
      return Padding(
        padding: const EdgeInsets.only(right:8.0,left:10.0,top: 8,bottom:8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 60,
                width: 60,
                child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(entries[index]['user']['avatar_url'],)
                )
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.only(right: 30.0,left:30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              '${entries[index]['title']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.sora(
                                fontSize: 15.0,
                                color: kTitleTextLightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0),
                            child: Text(
                              '${entries[index]['updated_at']}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sora(
                                fontSize: 10.0,
                                color: kTitleTextLightColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'State : ${entries[index]['state']}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sora(
                            fontSize: 10.0,
                            color: kTitleTextLightColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

}
