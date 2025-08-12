import 'dart:js_interop';

import 'package:dart_web_scraper/common/enums.dart';
import 'package:dart_web_scraper/common/models/parser_model.dart';
import 'package:dart_web_scraper/common/models/scraper_config_model.dart';
import 'package:dart_web_scraper/dart_web_scraper/web_scraper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'memo_topic_model.dart';

/// Flutter code sample for [SingleChildScrollView].

void main() => runApp(const SingleChildScrollViewExampleApp());

class SingleChildScrollViewExampleApp extends StatelessWidget {
  const SingleChildScrollViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SingleChildScrollViewExample());
  }
}

class SingleChildScrollViewExample extends StatelessWidget {
  const SingleChildScrollViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FloatingActionButton(onPressed: onPressButton),
                  Container(
                    // A fixed-height child.
                    color: const Color(0xffeeee00), // Yellow
                    height: 120.0,
                    alignment: Alignment.center,
                    child: const Text('Fixed Height Content'),
                  ),
                  Container(
                    // Another fixed-height child.
                    color: const Color(0xff008000), // Green
                    height: 120.0,
                    alignment: Alignment.center,
                    child: const Text('Fixed Height Content'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  onPressButton() {
    name();
  }

  Future<void> name() async {
    WebScraper webScraper = WebScraper();

    Map<String, Object> topics = await webScraper.scrape(
      url: Uri.parse("https://memo.cash/topics/all"),
      scraperConfig: ScraperConfig(
        parsers: [
          Parser(
            id: "topics",
            parents: ["_root"],

            /// _root is default parent
            type: ParserType.element,
            selectors: [
              "td",
            ],
            multiple: true,
          ),
          Parser(
              id: "topic",
              parents: ["topics"],
              type: ParserType.text,
              selectors: [
                "a",
              ]
          ),
          Parser(
              id: "topicURL",
              parents: ["topics"],
              type: ParserType.url,
              selectors: [
                "a",
              ]
          )
        ],
      ),
    );



    print(topics["topics"].toString());

    // List<MemoTopicModel> userList = await MemoTopicModel().backgroundJsonParser(topics["topics"].toString());
    //
    // print(userList.first.url);
  }
}