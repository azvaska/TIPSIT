import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class InputWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function() sendMessage;
  const InputWidget(
      {super.key, required this.controller, required this.sendMessage});

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  bool showEmojiPicker = false;
  late StreamSubscription<bool> keyboardSubscription;
  _onEmojiSelected(Category? c, Emoji emoji) {
    widget.controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length));
  }

  _onBackspacePressed() {
    widget.controller
      ..text = widget.controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length));
  }

  @override
  void initState() {
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    print(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible) {
        setState(() {
          showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 320.0,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: 0.5)), color: Colors.white),
      child: Column(
        children: [
          const Spacer(),
          Container(
              height: 66.0,
              // color: Colors.blue,
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: IconButton(
                        icon: const Icon(Icons.face),
                        // color: Palette.accentColor,
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            showEmojiPicker = !showEmojiPicker;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                          controller: widget.controller,
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.only(
                                left: 16.0, bottom: 8.0, top: 8.0, right: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          )),
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    child: IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          widget.sendMessage();
                        },
                        icon: const Icon(
                          Icons.send,
                          // color: Colors.transparent,
                        )),
                  )
                ],
              )),
          Offstage(
            offstage: !showEmojiPicker,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: _onEmojiSelected,
                onBackspacePressed: _onBackspacePressed,
                config: const Config(
                    columns: 7,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    initCategory: Category.SMILEYS,
                    bgColor: Color(0xFFF2F2F2),
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL),
              ),
            ),
          )
        ],
      ),
    );
  }
}
