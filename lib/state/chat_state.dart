import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatThread {
  final String title;
  final String subtitle;
  final List<ChatMessage> messages;

  ChatThread({
    required this.title,
    required this.subtitle,
    required this.messages,
  });
}

class ChatState {
  final List<ChatThread> threads;
  final int selectedIndex;

  ChatState({required this.threads, required this.selectedIndex});

  ChatState copyWith({
    List<ChatThread>? threads,
    int? selectedIndex,
  }) {
    return ChatState(
      threads: threads ?? this.threads,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(ChatState(
          threads: [
            ChatThread(
              title: 'Farm Planning',
              subtitle: 'Plan tomorrow’s planting schedule',
              messages: [
                ChatMessage(text: 'Good morning Sir Mufasa, how can I help today?', isUser: false),
                ChatMessage(text: 'Create a planting plan for tomatoes and maize.', isUser: true),
                ChatMessage(text: 'I can do that. How many hectares are you using?', isUser: false),
              ],
            ),
            ChatThread(
              title: 'Market Pricing',
              subtitle: 'Compare today’s crop prices',
              messages: [
                ChatMessage(text: 'Track tomato, maize, and onion prices.', isUser: true),
                ChatMessage(text: 'Tomatoes are trending up, maize is stable, onions are slightly lower.', isUser: false),
              ],
            ),
            ChatThread(
              title: 'Delivery Support',
              subtitle: 'Check transport availability',
              messages: [
                ChatMessage(text: 'Which trucks are available near Chiredzi?', isUser: true),
                ChatMessage(text: 'Two trucks are available within 10 km and one is ready now.', isUser: false),
              ],
            ),
          ],
          selectedIndex: 0,
        ));

  void selectThread(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void sendMessage(String text) {
    final thread = state.threads[state.selectedIndex];
    final updatedMessages = [...thread.messages, ChatMessage(text: text, isUser: true)];
    final updatedThread = ChatThread(
      title: thread.title,
      subtitle: thread.subtitle,
      messages: updatedMessages,
    );

    final updatedThreads = [...state.threads];
    updatedThreads[state.selectedIndex] = updatedThread;
    state = state.copyWith(threads: updatedThreads);
  }

  void receiveMessage(String text) {
    final thread = state.threads[state.selectedIndex];
    final updatedMessages = [...thread.messages, ChatMessage(text: text, isUser: false)];
    final updatedThread = ChatThread(
      title: thread.title,
      subtitle: thread.subtitle,
      messages: updatedMessages,
    );

    final updatedThreads = [...state.threads];
    updatedThreads[state.selectedIndex] = updatedThread;
    state = state.copyWith(threads: updatedThreads);
  }

  void startOrGetThread(String title, String subtitle, String initialMessage) {
    final index = state.threads.indexWhere((t) => t.title == title);
    if (index != -1) {
      state = state.copyWith(selectedIndex: index);
      return;
    }

    final newThread = ChatThread(
      title: title,
      subtitle: subtitle,
      messages: [
        ChatMessage(text: initialMessage, isUser: false),
      ],
    );

    state = state.copyWith(
      threads: [...state.threads, newThread],
      selectedIndex: state.threads.length,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
