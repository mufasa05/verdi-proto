import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/chat_state.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _typing = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(chatProvider.notifier);

    notifier.sendMessage(text);
    _inputController.clear();
    _scrollToBottom();

    setState(() {
      _typing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    notifier.receiveMessage('Understood. I will help with that next.');
    setState(() {
      _typing = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;
    
    if (chatState.threads.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No conversation threads yet.')),
      );
    }

    final thread = chatState.threads[chatState.selectedIndex];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              _ThreadPanel(
                threads: chatState.threads,
                selectedIndex: chatState.selectedIndex,
                onSelect: (i) => notifier.selectThread(i),
              ),
            Expanded(
              child: Column(
                children: [
                  _AssistantHeader(
                    title: thread.title,
                    subtitle: thread.subtitle,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: thread.messages.length + (_typing ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_typing && index == thread.messages.length) {
                          return const _TypingIndicator();
                        }
                        final msg = thread.messages[index];
                        return _ChatBubble(message: msg);
                      },
                    ),
                  ),
                  _InputBar(
                    controller: _inputController,
                    onSend: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AssistantHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(Icons.psychology_alt_outlined, color: Colors.green.shade700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadPanel extends StatelessWidget {
  final List<ChatThread> threads;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThreadPanel({
    required this.threads,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversations',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: List.generate(threads.length, (i) {
                final t = threads[i];
                final selected = i == selectedIndex;
                return Card(
                  elevation: selected ? 2 : 0,
                  color: selected ? Colors.green.shade50 : Colors.white,
                  child: ListTile(
                    onTap: () => onSelect(i),
                    leading: CircleAvatar(
                      backgroundColor: selected ? Colors.green.shade100 : Colors.grey.shade200,
                      child: Icon(Icons.chat_bubble_outline, color: selected ? Colors.green : Colors.grey),
                    ),
                    title: Text(t.title),
                    subtitle: Text(t.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF16A34A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text('Typing...'),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask Verdi anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}