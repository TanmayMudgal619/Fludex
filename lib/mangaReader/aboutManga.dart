import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/mangaReader/mangaReader.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangadex_library/models/chapter/ChapterData.dart' as ch;
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/models/chapter/readChapters.dart';
import 'package:mangadex_library/models/common/language_codes.dart';
import 'package:mangadex_library/models/common/mangaReadingStatus.dart';
import 'package:mangadex_library/models/common/reading_status.dart';
import 'package:mangadex_library/models/common/singleMangaData.dart';
import 'package:mangadex_library/models/common/tags.dart';
import 'package:mangadex_library/models/user/user_followed_manga/manga_check.dart';

class AboutManga extends StatefulWidget {
  final bool dataSaver;
  final String token;
  final String mangaId;
  final int totalChapters;
  final bool lightMode;
  AboutManga(
      {required this.mangaId,
      required this.token,
      required this.dataSaver,
      required this.totalChapters,
      required this.lightMode});
  @override
  _AboutMangaState createState() =>
      _AboutMangaState(mangaId: mangaId, token: token);
}

class _AboutMangaState extends State<AboutManga> {
  late String token;
  final String mangaId;

  String translatedLangStartValue = 'English';
  final List<String> translatedLanguageOptions = [
    'Any',
    'English',
    'Brazilian Portugese',
    'Castilian Spanish',
    'Latin American Spanish',
    'Romanized Japanese',
    'Romanized Korean',
    'Simplified Chinese',
    'Traditional Chinese',
    'Romanized Chinese',
  ];
  final List<String> readingStatusOptions = [
    'Reading',
    'On Hold',
    'Plan To Read',
    'Dropped',
    'Re-Reading',
    'Completed',
  ];
  _AboutMangaState({required this.mangaId, required this.token});

  int _chapterPageOffset = 0;
  int _desiredInputChapterNumber = 0;

  Future<SingleMangaData> _getMangaData(String mangaId) async {
    try {
      var _data = await getMangaDataByMangaId(mangaId);
      return _data;
    } catch (e) {
      print(e.toString());
      return await getMangaDataByMangaId(mangaId);
    }
  }

  Future<String> _getCoverData(String mangaId) async {
    return await getCoverArtUrl(mangaId);
  }

  Future<ch.ChapterData?> _getChapterData(String mangaId,
      {int? offset, List<LanguageCodes>? translatedLanguage}) async {
    var _offset = offset ?? 0;
    var chapters = await getChapters(mangaId,
        offset: _offset, translatedLanguage: translatedLanguage);
    return chapters;
  }

  String getYear(int year) {
    if (year == 0) {
      return 'N/A';
    } else {
      return year.toString();
    }
  }

  Future<bool> _mangaFollowCheck(_token, _mangaId) async {
    var data = await checkIfUserFollowsManga(_token, _mangaId);
    return data;
  }

  bool isFollowed = false;
  bool hasPressed = false;
  String buttonText = 'Add to library';
  static Container _tagContainer(String _tag, bool lightMode) {
    return Container(
      decoration: BoxDecoration(
        color: lightMode ? Colors.white : Color.fromARGB(150, 18, 18, 18),
        border: lightMode ? Border.all(color: Colors.black) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Text(
        _tag,
        style: TextStyle(
          color: lightMode ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  List<Widget> tagWidgets(List<Tags> _tags, bool lightMode) {
    List<Widget> _widgets = [];
    if (_tags.length > 10) {
      for (int i = 0; i < 10; i++) {
        _widgets.add(_tagContainer(_tags[i].attributes.name.en, lightMode));
      }
    } else {
      for (int i = 0; i < _tags.length; i++) {
        _widgets.add(_tagContainer(_tags[i].attributes.name.en, lightMode));
      }
    }

    return _widgets;
  }

  List<LanguageCodes>? parseStringToTranslatedLangEnum(String? language) {
    if (language!.toLowerCase() == 'english') {
      return [LanguageCodes.en];
    } else if (language.toLowerCase() == 'brazilian portugese') {
      return [LanguageCodes.pt_br];
    } else if (language.toLowerCase() == 'castilian spanish') {
      return [LanguageCodes.es];
    } else if (language.toLowerCase() == 'latin american spanish') {
      return [LanguageCodes.es_la];
    } else if (language.toLowerCase() == 'romanized japanese') {
      return [LanguageCodes.ja_ro];
    } else if (language.toLowerCase() == 'romanized korean') {
      return [LanguageCodes.ko_ro];
    } else if (language.toLowerCase() == 'simplified chinese') {
      return [LanguageCodes.zh];
    } else if (language.toLowerCase() == 'traditional chinese') {
      return [LanguageCodes.zh_hk];
    } else if (language.toLowerCase() == 'romanized chinese') {
      return [LanguageCodes.zh_ro];
    } else {
      return null;
    }
  }

  ReadingStatus parseStringToReadingStatusEnum(String status) {
    if (status.toLowerCase() == 'reading') {
      return ReadingStatus.reading;
    } else if (status.toLowerCase() == 'completed') {
      return ReadingStatus.completed;
    } else if (status.toLowerCase() == 'on hold') {
      return ReadingStatus.on_hold;
    } else if (status.toLowerCase() == 'plan to read') {
      return ReadingStatus.plan_to_read;
    } else if (status.toLowerCase() == 're-reading') {
      return ReadingStatus.re_reading;
    } else if (status.toLowerCase() == 'dropped') {
      return ReadingStatus.re_reading;
    } else {
      return ReadingStatus.reading;
    }
  }

  String parseReadingStatusToString(String status) {
    if (status == 'reading') {
      return 'Reading';
    } else if (status == 'completed') {
      return 'Completed';
    } else if (status == 'dropped') {
      return 'Dropped';
    } else if (status == 'on_hold') {
      return 'On Hold';
    } else if (status == 'plan_to_read') {
      return 'Plan To Read';
    } else if (status == 're_reading') {
      return 'Re-Reading';
    } else {
      return 'Reading';
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    bool appLightMode = brightness == Brightness.light;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var _mangaData = await _getMangaData(mangaId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaReader(
                mangaTitle: _mangaData.data.attributes.title.en,
                token: token,
                mangaId: mangaId,
                chapterNumber: 1,
                dataSaver: widget.dataSaver,
              ),
            ),
          );
        },
        label: Text(
          "Read now",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: hasPressed
          ? Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(builder: (context, constraints) {
              return FutureBuilder(
                future: _getMangaData(mangaId),
                builder: (context, AsyncSnapshot<SingleMangaData> mangaData) {
                  if (mangaData.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      child: FutureBuilder(
                        future: _getCoverData(mangaId),
                        builder: (context, AsyncSnapshot<String> data) {
                          if (data.connectionState == ConnectionState.done) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    data.data!,
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: widget.lightMode
                                      ? null
                                      : ColorFilter.mode(
                                          Color.fromARGB(125, 18, 18, 18),
                                          BlendMode.darken),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Card(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: FutureBuilder(
                                                future: _getCoverData(mangaId),
                                                builder: (context,
                                                    AsyncSnapshot<String>
                                                        cover) {
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: SizedBox(
                                                        height: 500,
                                                        width: 400,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Container(
                                              child: Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        mangaData
                                                            .data!
                                                            .data
                                                            .attributes
                                                            .title
                                                            .en,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 30),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: tagWidgets(
                                                              mangaData
                                                                  .data!
                                                                  .data
                                                                  .attributes
                                                                  .tags,
                                                              appLightMode),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Container(
                                                        height: 200,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Text(
                                                            mangaData
                                                                .data!
                                                                .data
                                                                .attributes
                                                                .description
                                                                .en,
                                                            style: TextStyle(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        FludexUtils
                                                            .ratingContainer(
                                                                mangaData
                                                                    .data!
                                                                    .data
                                                                    .attributes
                                                                    .contentRating,
                                                                appLightMode),
                                                        FludexUtils
                                                            .statusContainer(
                                                                mangaData
                                                                    .data!
                                                                    .data
                                                                    .attributes
                                                                    .status,
                                                                appLightMode),
                                                        FludexUtils
                                                            .demographicContainer(
                                                                mangaData
                                                                    .data!
                                                                    .data
                                                                    .attributes
                                                                    .publicationDemographic,
                                                                appLightMode),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        'Year of Release: ' +
                                                            getYear(mangaData
                                                                .data!
                                                                .data
                                                                .attributes
                                                                .year),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        'No. of Chapters: ${widget.totalChapters}',
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              top: 20),
                                                      child: FutureBuilder(
                                                        future:
                                                            _mangaFollowCheck(
                                                                token, mangaId),
                                                        builder: (context,
                                                            AsyncSnapshot<bool>
                                                                data) {
                                                          if (data.connectionState ==
                                                              ConnectionState
                                                                  .done) {
                                                            print(data.data!);
                                                            if (data.data! ==
                                                                true) {
                                                              return Card(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        103,
                                                                        64),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      FutureBuilder(
                                                                        future: getMangaReadingStatus(
                                                                            token,
                                                                            mangaId),
                                                                        builder:
                                                                            (context,
                                                                                AsyncSnapshot<MangaReadingStatus> mangaReadingStatus) {
                                                                          if (mangaReadingStatus.connectionState ==
                                                                              ConnectionState.done) {
                                                                            return DropdownButton(
                                                                              iconEnabledColor: Colors.white,
                                                                              underline: Container(),
                                                                              dropdownColor: Color.fromARGB(255, 255, 103, 64),
                                                                              value: parseReadingStatusToString(mangaReadingStatus.data!.status),
                                                                              items: readingStatusOptions.map((e) {
                                                                                print(e);
                                                                                return DropdownMenuItem(child: Text(e), value: e);
                                                                              }).toList(),
                                                                              style: TextStyle(fontSize: 24),
                                                                              onChanged: (newValue) async {
                                                                                await setMangaReadingStatus(token, mangaId, parseStringToReadingStatusEnum(newValue.toString()));
                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                          } else {
                                                                            return CircularProgressIndicator(
                                                                              color: Colors.white,
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                      IconButton(
                                                                        color: Colors
                                                                            .white,
                                                                        onPressed:
                                                                            () async {
                                                                          await _unFollowManga(
                                                                              token,
                                                                              mangaId);
                                                                          print(
                                                                              'Unfollowed manga $mangaId');
                                                                          setState(
                                                                              () {
                                                                            isFollowed =
                                                                                false;
                                                                          });
                                                                        },
                                                                        icon:
                                                                            Tooltip(
                                                                          message:
                                                                              'Remove from library',
                                                                          child:
                                                                              Icon(
                                                                            Icons.cancel,
                                                                            semanticLabel:
                                                                                'Remove from library',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  await _followManga(
                                                                      token,
                                                                      mangaId);
                                                                  print(
                                                                      'Followed manga $mangaId');
                                                                  setState(() {
                                                                    isFollowed =
                                                                        true;
                                                                  });
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(10),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        'Add to library!',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                25),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Icon(Icons
                                                                          .favorite),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          } else {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 40),
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Chapters',
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Translated Language: ',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                          ),
                                                        ),
                                                        DropdownButton<String>(
                                                          focusColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  255,
                                                                  103,
                                                                  64),
                                                          // dropdownColor:
                                                          //     Color.fromARGB(
                                                          //         255,
                                                          //         255,
                                                          //         103,
                                                          //         64),
                                                          value:
                                                              translatedLangStartValue,
                                                          items:
                                                              translatedLanguageOptions
                                                                  .map((String
                                                                      value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value,
                                                              child: Center(
                                                                child: Text(
                                                                  value,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged:
                                                              (newValue) {
                                                            setState(
                                                              () {
                                                                translatedLangStartValue =
                                                                    newValue ??
                                                                        '';
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: FutureBuilder(
                                                  future: _getChapterData(
                                                    mangaId,
                                                    offset:
                                                        _chapterPageOffset * 10,
                                                    translatedLanguage:
                                                        parseStringToTranslatedLangEnum(
                                                            translatedLangStartValue),
                                                  ),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              ch.ChapterData?>
                                                          chapterData) {
                                                    if (chapterData
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return (chapterData
                                                                  .data ==
                                                              null)
                                                          ? Center(
                                                              child: Container(
                                                                height: 200,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        'Nothing found :(',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                21),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        'Try changing the language filters maybe ;)',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                21),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            'Quick open chapter: ',
                                                                            style:
                                                                                TextStyle(fontSize: 17),
                                                                          ),
                                                                          SizedBox(
                                                                              child: TextField(
                                                                                style: TextStyle(),
                                                                                inputFormatters: [
                                                                                  FilteringTextInputFormatter.digitsOnly
                                                                                ],
                                                                                onChanged: (value) {
                                                                                  _desiredInputChapterNumber = int.parse(value);
                                                                                },
                                                                              ),
                                                                              width: 50),
                                                                          Text(
                                                                            ' / ${widget.totalChapters.toString()}',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 17,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                30,
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                hasPressed = true;
                                                                              });
                                                                              if (_desiredInputChapterNumber <= widget.totalChapters || _desiredInputChapterNumber != 0) {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => MangaReader(
                                                                                      mangaTitle: mangaData.data!.data.attributes.title.en,
                                                                                      token: token,
                                                                                      mangaId: mangaId,
                                                                                      chapterNumber: _desiredInputChapterNumber,
                                                                                      dataSaver: widget.dataSaver,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                                setState(() {
                                                                                  hasPressed = false;
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Text('Open Chapter'),
                                                                                SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount: chapterData
                                                                            .data!
                                                                            .data
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          return FutureBuilder(
                                                                              future: getAllReadChapters(token, mangaId),
                                                                              builder: (context, AsyncSnapshot<ReadChapters?> readChapters) {
                                                                                if (readChapters.connectionState == ConnectionState.done) {
                                                                                  for (var element in readChapters.data!.data) {
                                                                                    print(element);
                                                                                  }
                                                                                  if (readChapters.data == null) {
                                                                                    return Center(
                                                                                      child: CircularProgressIndicator(),
                                                                                    );
                                                                                  } else {
                                                                                    readChapters.data!.data.forEach((e) {
                                                                                      print(e);
                                                                                    });
                                                                                    return Opacity(
                                                                                      opacity: (readChapters.data == null) ? 1 : (readChapters.data!.data.contains(chapterData.data!.data[index].id) ? 0.5 : 1.0),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                                                                        child: ListTile(
                                                                                          title: Text(
                                                                                            'Chapter ' + chapterData.data!.data[index].attributes.chapter,
                                                                                            style: TextStyle(fontSize: 17),
                                                                                          ),
                                                                                          subtitle: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Text(
                                                                                                  'Volume ' + chapterData.data!.data[index].attributes.volume,
                                                                                                  style: TextStyle(),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 10,
                                                                                                ),
                                                                                                Text(
                                                                                                  'Language: ' + chapterData.data!.data[index].attributes.translatedLanguage,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          trailing: PopupMenuButton<int>(
                                                                                            itemBuilder: (context) => [
                                                                                              (readChapters.data == null)
                                                                                                  ? PopupMenuItem(
                                                                                                      child: ListTile(
                                                                                                        leading: Icon(Icons.check_outlined),
                                                                                                        title: Text("Mark as read"),
                                                                                                      ),
                                                                                                      onTap: () async {
                                                                                                        await markChapterRead(token, chapterData.data!.data[index].id);
                                                                                                      },
                                                                                                    )
                                                                                                  : readChapters.data!.data.contains(chapterData.data!.data[index].id)
                                                                                                      ? PopupMenuItem(
                                                                                                          child: ListTile(
                                                                                                            leading: Icon(Icons.check),
                                                                                                            title: Text("Mark as unread"),
                                                                                                          ),
                                                                                                          onTap: () async {
                                                                                                            var result = await markChapterUnread(token, chapterData.data!.data[index].id);
                                                                                                            setState(() {});
                                                                                                            if (result.result == 'ok') {
                                                                                                              print('Marked ${chapterData.data!.data[index].id}');
                                                                                                            } else {
                                                                                                              print('Something went wrong while marking ${chapterData.data!.data[index].id} as unread');
                                                                                                            }
                                                                                                          },
                                                                                                        )
                                                                                                      : PopupMenuItem(
                                                                                                          child: ListTile(
                                                                                                            leading: Icon(Icons.check_outlined),
                                                                                                            title: Text("Mark as read"),
                                                                                                          ),
                                                                                                          onTap: () async {
                                                                                                            var result = await markChapterRead(token, chapterData.data!.data[index].id);
                                                                                                            setState(() {});
                                                                                                            if (result.result == 'ok') {
                                                                                                              print('Marked ${chapterData.data!.data[index].id}');
                                                                                                            } else {
                                                                                                              print('Something went wrong while marking ${chapterData.data!.data[index].id} as read');
                                                                                                            }
                                                                                                          },
                                                                                                        ),
                                                                                            ],
                                                                                          ),
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              hasPressed = true;
                                                                                            });
                                                                                            Navigator.push(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                builder: (context) => MangaReader(
                                                                                                  mangaTitle: mangaData.data!.data.attributes.title.en,
                                                                                                  token: token,
                                                                                                  mangaId: mangaId,
                                                                                                  chapterNumber: ((_chapterPageOffset) * 10) + index + 1,
                                                                                                  dataSaver: widget.dataSaver,
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                            setState(() {
                                                                                              hasPressed = false;
                                                                                            });
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                } else if (readChapters.data == null) {
                                                                                  return Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  );
                                                                                } else {
                                                                                  return Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  );
                                                                                }
                                                                              });
                                                                        }),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_chapterPageOffset *
                                                                                10 !=
                                                                            0) {
                                                                          setState(
                                                                              () {
                                                                            _chapterPageOffset--;
                                                                          });
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .arrow_back,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        '${_chapterPageOffset + 1}',
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        print(chapterData
                                                                            .data!
                                                                            .total);
                                                                        if (_chapterPageOffset *
                                                                                10 <
                                                                            chapterData.data!.total) {
                                                                          setState(
                                                                              () {
                                                                            _chapterPageOffset++;
                                                                          });
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .arrow_forward,
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                    } else if (chapterData
                                                        .hasError) {
                                                      return Center(
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Something went wrong :(',
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                'Please make sure you are connected to the internet and the internet is working properly',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Center(
                                                          child: SizedBox(
                                                            height: 100,
                                                            width: 100,
                                                            child:
                                                                CircularProgressIndicator(),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (data.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Center(
                              child: Text(
                                'Something went wrong :\'(',
                                style: TextStyle(fontSize: 17),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                },
              );
            }),
    );
  }
}

Future<MangaCheck> _followManga(String token, String mangaId) async {
  return followManga(token, mangaId);
}

Future<MangaCheck> _unFollowManga(String token, String mangaId) async {
  var response = await unfollowManga(token, mangaId);
  return response;
}
