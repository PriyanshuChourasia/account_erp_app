/// A single rendered line in the terminal output.
///
/// Plain data holder — no logic. [kind] drives the colour/style used by the
/// terminal UI, [prompt] is the shell prefix shown for echoed commands.
class TerminalLine {
  const TerminalLine({required this.text, this.kind = TerminalLineKind.output});

  final String text;
  final TerminalLineKind kind;

  static const TerminalLine separator = TerminalLine(text: '');
}

enum TerminalLineKind {
  /// Regular command output.
  output,

  /// The echoed `$ command` the user typed.
  command,

  /// Errors (unknown command, invalid input).
  error,

  /// Informational banner (welcome message, help).
  info,
}
