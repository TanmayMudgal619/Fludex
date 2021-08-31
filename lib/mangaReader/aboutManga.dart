import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/mangaReader/readManga.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangadex_library/chapter/ChapterData.dart';
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/search/Search.dart';

class AboutManga extends StatefulWidget {
  final String token;
  final String mangaId;
  AboutManga({required this.mangaId, required this.token});
  @override
  _AboutMangaState createState() =>
      _AboutMangaState(mangaId: mangaId, token: token);
}

class _AboutMangaState extends State<AboutManga> {
  late String token;
  final String mangaId;
  _AboutMangaState({required this.mangaId, required this.token});
  int _chapterPageOffset = 0;
  int _totalChapters = 0;
  int _desiredInputChapterNumber = 0;
  JsonSearch search = JsonSearch();

  Future<Results> _getMangaData(String mangaId) async {
    try {
      return await search.getMangaDataByMangaId(mangaId);
    } catch (e) {
      print(e.toString());
      var _login = await refresh(token);
      token = _login.token.session;
      return await search.getMangaDataByMangaId(mangaId);
    }
  }

  Future<String> _getCoverData(String mangaId) async {
    return await getCoverArtUrl(mangaId);
  }

  Future<ChapterData?> _getChapterData(String mangaId, {int? offset}) async {
    var _offset = offset ?? 0;
    print(_offset.toString());
    var chapters = await getChapters(mangaId, offset: _offset);
    return chapters;
  }

  String getYear(int year) {
    if (year == 0) {
      return 'N/A';
    } else {
      return year.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaReader(
                token: token,
                mangaId: mangaId,
                chapterNumber: 1,
              ),
            ),
          );
        },
        label: Text("Read now"),
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.arrow_forward),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 18, 18),
      ),
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: FutureBuilder(
        future: _getMangaData(mangaId),
        builder: (context, AsyncSnapshot<Results> mangaData) {
          if (mangaData.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        color: Color.fromARGB(18, 255, 255, 255),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(105, 18, 18, 18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder(
                                future: _getCoverData(mangaId),
                                builder:
                                    (context, AsyncSnapshot<String> cover) {
                                  if (cover.connectionState ==
                                      ConnectionState.done) {
                                    return SizedBox(
                                      height: 500,
                                      child: CachedNetworkImage(
                                        imageUrl: cover.data!,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              child: Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        mangaData
                                            .data!.data.attributes.title.en,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        mangaData.data!.data.attributes
                                            .description.en,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 10,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Content Rating: ' +
                                            mangaData.data!.data.attributes
                                                .contentRating,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Status: ' +
                                            mangaData
                                                .data!.data.attributes.status,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Year of Release: ' +
                                            getYear(mangaData
                                                .data!.data.attributes.year),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'No. of Chapters: $_totalChapters',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(10.0),
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       ElevatedButton(
                                    //         style: ElevatedButton.styleFrom(
                                    //             primary: Colors.redAccent,
                                    //             padding: EdgeInsets.all(10)),
                                    //         onPressed: () {},
                                    //         child: Row(
                                    //           children: [
                                    //             SizedBox(
                                    //               width: 10,
                                    //             ),
                                    //             Text(
                                    //               'Add to library',
                                    //               style:
                                    //                   TextStyle(fontSize: 20),
                                    //             ),
                                    //             SizedBox(
                                    //               width: 10,
                                    //             ),
                                    //             Icon(Icons.favorite),
                                    //             SizedBox(
                                    //               width: 10,
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapters',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                            Container(
                              color: Color.fromARGB(18, 255, 255, 255),
                              child: FutureBuilder(
                                future: _getChapterData(mangaId,
                                    offset: _chapterPageOffset * 10),
                                builder: (BuildContext context,
                                    AsyncSnapshot<ChapterData?> chapterData) {
                                  if (chapterData.connectionState ==
                                      ConnectionState.done) {
                                    _totalChapters = chapterData.data!.total;

                                    print(chapterData.data!.offset);

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Quick open chapter: ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17),
                                              ),
                                              SizedBox(
                                                  child: TextField(
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    onChanged: (value) {
                                                      _desiredInputChapterNumber =
                                                          int.parse(value);
                                                    },
                                                  ),
                                                  width: 50),
                                              Text(
                                                ' / ${_totalChapters.toString()}',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 30,
                                              ),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.redAccent,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8)),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MangaReader(
                                                                token: token,
                                                                mangaId:
                                                                    mangaId,
                                                                chapterNumber:
                                                                    _desiredInputChapterNumber),
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text('Open Chapter'),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                chapterData.data!.result.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2),
                                                child: InkWell(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 18, 18, 18),
                                                      border: Border(
                                                        left: BorderSide(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                        'Chapter ' +
                                                            chapterData
                                                                .data!
                                                                .result[index]
                                                                .data
                                                                .attributes
                                                                .chapter,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MangaReader(
                                                          token: token,
                                                          mangaId: mangaId,
                                                          chapterNumber:
                                                              ((_chapterPageOffset) *
                                                                      10) +
                                                                  index +
                                                                  1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              color: Colors.white,
                                              onPressed: () {
                                                if (_chapterPageOffset * 10 !=
                                                    0) {
                                                  setState(() {
                                                    _chapterPageOffset--;
                                                  });
                                                }
                                              },
                                              icon: Icon(Icons.arrow_back),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                '${_chapterPageOffset + 1}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                                color: Colors.white,
                                                onPressed: () {
                                                  print(
                                                      chapterData.data!.total);
                                                  if (_chapterPageOffset * 10 <
                                                      chapterData.data!.total) {
                                                    setState(() {
                                                      _chapterPageOffset++;
                                                    });
                                                  }
                                                },
                                                icon: Icon(Icons.arrow_forward))
                                          ],
                                        )
                                      ],
                                    );
                                  } else if (chapterData.hasError) {
                                    return Center(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Something went wrong :(',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Please make sure you are connected to the internet and the internet is working properly',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}