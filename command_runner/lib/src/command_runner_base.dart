class CommandRunner {
  /// Runs the command-line application logic with the given arguments.
  // ignore: unintended_html_in_doc_comment
  /// Future<void> is a return type that indicates that
  /// this method might perform asynchronous operations, but doesn't return a value.
  Future<void> run(List<String> input) async {
    print('CommandRunner received arguments: $input');
  }
}
