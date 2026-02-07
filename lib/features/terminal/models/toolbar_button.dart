import 'dart:convert';

class ToolbarButton {
  final String label;
  final String sequence;
  final bool highlight;

  const ToolbarButton({
    required this.label,
    required this.sequence,
    this.highlight = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'sequence': sequence,
        'highlight': highlight,
      };

  factory ToolbarButton.fromJson(Map<String, dynamic> json) => ToolbarButton(
        label: json['label'] as String,
        sequence: json['sequence'] as String,
        highlight: json['highlight'] as bool? ?? false,
      );

  static String encodeList(List<ToolbarButton> buttons) =>
      jsonEncode(buttons.map((b) => b.toJson()).toList());

  static List<ToolbarButton> decodeList(String json) =>
      (jsonDecode(json) as List)
          .map((e) => ToolbarButton.fromJson(e as Map<String, dynamic>))
          .toList();
}

class KeyCatalog {
  static const modifiers = <ToolbarButton>[
    ToolbarButton(label: 'Ctrl-A', sequence: '\x01'),
    ToolbarButton(label: 'Ctrl-B', sequence: '\x02'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: 'Ctrl-D', sequence: '\x04'),
    ToolbarButton(label: 'Ctrl-E', sequence: '\x05'),
    ToolbarButton(label: 'Ctrl-F', sequence: '\x06'),
    ToolbarButton(label: 'Ctrl-G', sequence: '\x07'),
    ToolbarButton(label: 'Ctrl-H', sequence: '\x08'),
    ToolbarButton(label: 'Ctrl-K', sequence: '\x0b'),
    ToolbarButton(label: 'Ctrl-L', sequence: '\x0c'),
    ToolbarButton(label: 'Ctrl-N', sequence: '\x0e'),
    ToolbarButton(label: 'Ctrl-O', sequence: '\x0f'),
    ToolbarButton(label: 'Ctrl-P', sequence: '\x10'),
    ToolbarButton(label: 'Ctrl-Q', sequence: '\x11'),
    ToolbarButton(label: 'Ctrl-R', sequence: '\x12'),
    ToolbarButton(label: 'Ctrl-S', sequence: '\x13'),
    ToolbarButton(label: 'Ctrl-T', sequence: '\x14'),
    ToolbarButton(label: 'Ctrl-U', sequence: '\x15'),
    ToolbarButton(label: 'Ctrl-V', sequence: '\x16'),
    ToolbarButton(label: 'Ctrl-W', sequence: '\x17'),
    ToolbarButton(label: 'Ctrl-X', sequence: '\x18'),
    ToolbarButton(label: 'Ctrl-Y', sequence: '\x19'),
    ToolbarButton(label: 'Ctrl-Z', sequence: '\x1a'),
  ];

  static const navigation = <ToolbarButton>[
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'Home', sequence: '\x1b[H'),
    ToolbarButton(label: 'End', sequence: '\x1b[F'),
    ToolbarButton(label: 'PgUp', sequence: '\x1b[5~'),
    ToolbarButton(label: 'PgDn', sequence: '\x1b[6~'),
    ToolbarButton(label: 'Ins', sequence: '\x1b[2~'),
    ToolbarButton(label: 'Del', sequence: '\x1b[3~'),
  ];

  static const function_ = <ToolbarButton>[
    ToolbarButton(label: 'F1', sequence: '\x1bOP'),
    ToolbarButton(label: 'F2', sequence: '\x1bOQ'),
    ToolbarButton(label: 'F3', sequence: '\x1bOR'),
    ToolbarButton(label: 'F4', sequence: '\x1bOS'),
    ToolbarButton(label: 'F5', sequence: '\x1b[15~'),
    ToolbarButton(label: 'F6', sequence: '\x1b[17~'),
    ToolbarButton(label: 'F7', sequence: '\x1b[18~'),
    ToolbarButton(label: 'F8', sequence: '\x1b[19~'),
    ToolbarButton(label: 'F9', sequence: '\x1b[20~'),
    ToolbarButton(label: 'F10', sequence: '\x1b[21~'),
    ToolbarButton(label: 'F11', sequence: '\x1b[23~'),
    ToolbarButton(label: 'F12', sequence: '\x1b[24~'),
  ];

  static const special = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Space', sequence: ' '),
    ToolbarButton(label: 'Bksp', sequence: '\x7f'),
  ];

  static List<ToolbarButton> get all => [
        ...special,
        ...modifiers,
        ...navigation,
        ...function_,
      ];
}

class ToolbarPresets {
  static const general = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: 'Ctrl-D', sequence: '\x04'),
    ToolbarButton(label: 'Ctrl-Z', sequence: '\x1a'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'Home', sequence: '\x1b[H'),
    ToolbarButton(label: 'End', sequence: '\x1b[F'),
    ToolbarButton(label: 'PgUp', sequence: '\x1b[5~'),
    ToolbarButton(label: 'PgDn', sequence: '\x1b[6~'),
  ];

  static const tmux = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Ctrl-B', sequence: '\x02', highlight: true),
    ToolbarButton(label: '%', sequence: '%'),
    ToolbarButton(label: '"', sequence: '"'),
    ToolbarButton(label: 'c', sequence: 'c'),
    ToolbarButton(label: 'n', sequence: 'n'),
    ToolbarButton(label: 'p', sequence: 'p'),
    ToolbarButton(label: 'd', sequence: 'd'),
    ToolbarButton(label: '[', sequence: '['),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
  ];

  static const vim = <ToolbarButton>[
    ToolbarButton(label: 'Esc', sequence: '\x1b', highlight: true),
    ToolbarButton(label: ':', sequence: ':'),
    ToolbarButton(label: 'w', sequence: 'w'),
    ToolbarButton(label: 'q', sequence: 'q'),
    ToolbarButton(label: '!', sequence: '!'),
    ToolbarButton(label: 'i', sequence: 'i'),
    ToolbarButton(label: 'v', sequence: 'v'),
    ToolbarButton(label: 'Enter', sequence: '\r'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'dd', sequence: 'dd'),
    ToolbarButton(label: 'yy', sequence: 'yy'),
  ];
}
