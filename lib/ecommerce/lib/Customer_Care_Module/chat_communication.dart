// ════════════════════════════════════════════════════
//  chat_communication.dart  — AI Chatbot Style
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'dart:async';
import '../Theme_Module/colors_and_models.dart';

// ═══════════════════════════════════════════
//  SMART AUTO-REPLY ENGINE
// ═══════════════════════════════════════════
String _autoReply(String msg) {
  final m = msg.toLowerCase();

  if (m.contains('order') && (m.contains('status') || m.contains('track'))) {
    return 'Your order is currently being processed. You can track it in the Orders section. Expected delivery: 2–4 business days. 📦';
  }
  if (m.contains('order') && m.contains('cancel')) {
    return 'To cancel your order, please visit Orders → Select Order → Cancel. If it\'s already shipped, we\'ll initiate a return. 🔄';
  }
  if (m.contains('refund') || m.contains('money back')) {
    return 'Refunds are processed within 5–7 business days after we receive the returned item. Your bank may take 1–2 extra days. 💰';
  }
  if (m.contains('return') || m.contains('exchange')) {
    return 'You can return items within 30 days of delivery. Visit Orders → Return Item and follow the steps. We\'ll arrange a free pickup! 🔁';
  }
  if (m.contains('payment') && (m.contains('fail') || m.contains('error'))) {
    return 'Payment failures can occur due to bank issues. Please retry or use a different card/UPI. If the amount was deducted, it will refund in 3–5 days. 💳';
  }
  if (m.contains('delivery') || m.contains('shipping') || m.contains('arrive')) {
    return 'Standard delivery takes 3–5 business days. Express delivery (1–2 days) is available at checkout. We\'ll notify you once shipped! 🚚';
  }
  if (m.contains('discount') || m.contains('coupon') || m.contains('offer') || m.contains('promo')) {
    return 'Check our Offers section for the latest deals! Use code SAVE10 for 10% off on orders above ₹500. 🎉';
  }
  if (m.contains('product') && (m.contains('available') || m.contains('stock'))) {
    return 'You can check real-time stock availability on the product page. If out of stock, use the "Notify Me" option! 📱';
  }
  if (m.contains('password') || m.contains('login') || m.contains('account')) {
    return 'For account issues, go to Profile → Settings → Reset Password. If you need further help, I\'ll connect you to our team. 🔐';
  }
  if (m.contains('app') && (m.contains('crash') || m.contains('not working') || m.contains('bug'))) {
    return 'Sorry about the app issue! Please try: 1) Clear cache 2) Update the app 3) Restart. If it persists, share your device model and we\'ll fix it ASAP! 📲';
  }
  if (m.contains('invoice') || m.contains('bill') || m.contains('receipt')) {
    return 'Your invoice is available in Orders → Select Order → Download Invoice. It\'s also emailed to your registered address. 🧾';
  }
  if (m.contains('address') || m.contains('change') && m.contains('location')) {
    return 'You can update your delivery address in Profile → Addresses before the order is shipped. After shipping, address changes aren\'t possible. 📍';
  }
  if (m.contains('size') || m.contains('fit') || m.contains('measure')) {
    return 'Check our Size Guide on the product page for detailed measurements. If unsure, we recommend ordering 1 size up — easy returns too! 📏';
  }
  if (m.contains('hello') || m.contains('hi') || m.contains('hey') || m.contains('hii')) {
    return 'Hello! 👋 Welcome to E-Com Support. I\'m here to help with orders, returns, payments, and more. What can I assist you with?';
  }
  if (m.contains('thank') || m.contains('thanks') || m.contains('ok') || m.contains('okay') || m.contains('noted')) {
    return 'You\'re welcome! 😊 Is there anything else I can help you with today?';
  }
  if (m.contains('bye') || m.contains('goodbye') || m.contains('that\'s all') || m.contains('thats all')) {
    return 'Thank you for contacting us! Have a great day! 🌟 Feel free to reach out anytime.';
  }
  if (m.contains('urgent') || m.contains('asap') || m.contains('immediately') || m.contains('emergency')) {
    return '⚡ I understand this is urgent! I\'m escalating your issue to our priority support team. Someone will contact you within 30 minutes.';
  }
  if (m.contains('complaint') || m.contains('angry') || m.contains('frustrated') || m.contains('worst')) {
    return 'I sincerely apologize for the inconvenience. 🙏 This is not the experience we want for you. Let me escalate this to a senior agent right away.';
  }
  if (m.contains('price') || m.contains('cost') || m.contains('expensive') || m.contains('cheap')) {
    return 'Our prices are competitive and inclusive of all taxes. Watch out for our flash sales and seasonal discounts for the best deals! 💸';
  }
  if (m.contains('warranty') || m.contains('guarantee')) {
    return 'Most electronics come with a 1-year manufacturer warranty. For warranty claims, visit Orders → Select Product → Raise Warranty Claim. 🛡️';
  }
  if (m.contains('gift') || m.contains('wrap') || m.contains('packaging')) {
    return 'Yes! We offer gift wrapping for ₹49. Add it at checkout under "Gift Options". You can also add a personalized message! 🎁';
  }

  // Default
  return 'Thank you for reaching out! 😊 I\'ve noted your query. Our support team will review it and get back to you shortly. For urgent issues, call us at 1800-XXX-XXXX.';
}

// ═══════════════════════════════════════════
//  CHAT COMMUNICATION SCREEN
// ═══════════════════════════════════════════
class ChatCommunicationScreen extends StatefulWidget {
  const ChatCommunicationScreen({super.key});
  @override
  State<ChatCommunicationScreen> createState() =>
      _ChatCommunicationScreenState();
}

class _ChatCommunicationScreenState extends State<ChatCommunicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search   = '';
  int?   _selectedChat;
  bool   _isTyping = false;
  final TextEditingController _msgCtrl    = TextEditingController();
  final ScrollController       _scrollCtrl = ScrollController();

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Ravi Kumar', 'avatar': 'RK',
      'lastMsg': 'When will my order arrive?',
      'time': '10:32 AM', 'unread': 3, 'online': true,
      'messages': <Map<String, dynamic>>[
        {'text': 'Hi, I placed an order 3 days ago', 'fromMe': false, 'time': '10:20 AM'},
        {'text': 'Hello! Let me check your order status', 'fromMe': true, 'time': '10:22 AM'},
        {'text': 'When will my order arrive?', 'fromMe': false, 'time': '10:32 AM'},
      ],
    },
    {
      'name': 'Priya Sharma', 'avatar': 'PS',
      'lastMsg': 'Thank you for the quick response!',
      'time': '9:15 AM', 'unread': 0, 'online': true,
      'messages': <Map<String, dynamic>>[
        {'text': 'I received a wrong item', 'fromMe': false, 'time': '9:05 AM'},
        {'text': 'Sorry for the inconvenience. We will send the correct item.', 'fromMe': true, 'time': '9:10 AM'},
        {'text': 'Thank you for the quick response!', 'fromMe': false, 'time': '9:15 AM'},
      ],
    },
    {
      'name': 'Arun Selvan', 'avatar': 'AS',
      'lastMsg': 'Please check my refund status',
      'time': 'Yesterday', 'unread': 1, 'online': false,
      'messages': <Map<String, dynamic>>[
        {'text': 'I requested a refund 5 days ago', 'fromMe': false, 'time': 'Yesterday'},
        {'text': 'Please check my refund status', 'fromMe': false, 'time': 'Yesterday'},
      ],
    },
    {
      'name': 'Meena Devi', 'avatar': 'MD',
      'lastMsg': 'Issue resolved, thanks!',
      'time': 'Yesterday', 'unread': 0, 'online': false,
      'messages': <Map<String, dynamic>>[
        {'text': 'My payment failed', 'fromMe': false, 'time': 'Yesterday'},
        {'text': 'The issue has been fixed from our end', 'fromMe': true, 'time': 'Yesterday'},
        {'text': 'Issue resolved, thanks!', 'fromMe': false, 'time': 'Yesterday'},
      ],
    },
    {
      'name': 'Karthik Raja', 'avatar': 'KR',
      'lastMsg': 'App still crashing, please help',
      'time': '2 days ago', 'unread': 2, 'online': true,
      'messages': <Map<String, dynamic>>[
        {'text': 'App still crashing, please help', 'fromMe': false, 'time': '2 days ago'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Scroll to bottom ──
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Send message + auto-reply ──
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _selectedChat == null) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Add user message
    setState(() {
      _chats[_selectedChat!]['messages'].add({
        'text': text, 'fromMe': true, 'time': timeStr,
      });
      _chats[_selectedChat!]['lastMsg'] = text;
      _chats[_selectedChat!]['time']    = timeStr;
      _msgCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Auto-reply after delay (typing simulation)
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _chats[_selectedChat!]['messages'].add({
          'text': _autoReply(text), 'fromMe': false, 'time': timeStr,
        });
      });
      _scrollToBottom();
    });
  }

  // ═══════════════════════════════════════════
  //  CHAT LIST
  // ═══════════════════════════════════════════
  Widget _buildChatList() {
    final filtered = _chats.where((c) =>
    _search.isEmpty ||
        c['name'].toLowerCase().contains(_search.toLowerCase())).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: kCard(r: 10),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(
              hintText: 'Search conversations…',
              hintStyle: TextStyle(color: C.textLight, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: C.textLight, size: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final c   = filtered[i];
            final idx = _chats.indexOf(c);
            return GestureDetector(
              onTap: () => setState(() {
                _selectedChat = idx;
                _chats[idx]['unread'] = 0;
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: kCard(),
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Stack(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                          color: C.blueLight,
                          borderRadius: BorderRadius.circular(14)),
                      child: Center(
                        child: Text(c['avatar'],
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w800, color: C.blue)),
                      ),
                    ),
                    if (c['online'] as bool)
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 11, height: 11,
                          decoration: BoxDecoration(
                              color: C.green, shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2)),
                        ),
                      ),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text(c['name'],
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
                        ),
                        Text(c['time'],
                            style: const TextStyle(fontSize: 10, color: C.textLight)),
                      ]),
                      const SizedBox(height: 3),
                      Text(c['lastMsg'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: C.textMid)),
                    ]),
                  ),
                  if ((c['unread'] as int) > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: C.primary, shape: BoxShape.circle),
                      child: Text('${c['unread']}',
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════
  //  CHAT DETAIL  (with AI auto-reply)
  // ═══════════════════════════════════════════
  Widget _buildChatDetail() {
    if (_selectedChat == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                color: C.bg, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 36, color: C.textLight),
          ),
          const SizedBox(height: 16),
          const Text('Select a conversation',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: C.textDark)),
          const SizedBox(height: 6),
          const Text('Choose from the list to start chatting',
              style: TextStyle(fontSize: 12, color: C.textMid)),
        ]),
      );
    }

    final chat = _chats[_selectedChat!];
    final msgs = chat['messages'] as List<Map<String, dynamic>>;

    return Column(children: [

      // ── Chat Header ──
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _selectedChat = null),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: C.bg, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: C.textDark),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: C.blueLight, borderRadius: BorderRadius.circular(11)),
            child: Center(
              child: Text(chat['avatar'],
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: C.blue)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(chat['name'],
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
              Row(children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: (chat['online'] as bool) ? C.green : C.textLight,
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  _isTyping
                      ? 'typing…'
                      : (chat['online'] as bool) ? 'Online' : 'Offline',
                  style: TextStyle(
                      fontSize: 11,
                      fontStyle: _isTyping ? FontStyle.italic : FontStyle.normal,
                      color: _isTyping
                          ? C.primary
                          : (chat['online'] as bool) ? C.green : C.textLight),
                ),
              ]),
            ]),
          ),
          _ActionBtn(Icons.call_rounded,     C.teal,    C.primaryLight, () {}),
          const SizedBox(width: 6),
          _ActionBtn(Icons.more_vert_rounded, C.textMid, C.bg,          () {}),
        ]),
      ),
      const Divider(height: 1),

      // ── Messages ──
      Expanded(
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: msgs.length + (_isTyping ? 1 : 0),
          itemBuilder: (_, i) {

            // Typing indicator bubble
            if (_isTyping && i == msgs.length) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14), topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14), bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: const _TypingDots(),
                ),
              );
            }

            final m      = msgs[i];
            final fromMe = m['fromMe'] as bool;

            return Align(
              alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70),
                decoration: BoxDecoration(
                  color: fromMe ? C.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(14),
                    topRight:    const Radius.circular(14),
                    bottomLeft:  fromMe ? const Radius.circular(14) : const Radius.circular(4),
                    bottomRight: fromMe ? const Radius.circular(4)  : const Radius.circular(14),
                  ),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(m['text'],
                        style: TextStyle(
                            fontSize: 13,
                            color: fromMe ? Colors.white : C.textDark,
                            height: 1.4)),
                    const SizedBox(height: 4),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(m['time'],
                          style: TextStyle(
                              fontSize: 9,
                              color: fromMe
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : C.textLight)),
                      if (fromMe) ...[
                        const SizedBox(width: 3),
                        Icon(Icons.done_all_rounded,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.7)),
                      ],
                    ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // ── Input Bar ──
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: kCard(r: 24),
              child: TextField(
                controller: _msgCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Type a reply…',
                  hintStyle: TextStyle(color: C.textLight, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: C.primary, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: _selectedChat == null ? const EcomAppBar(showBack: true) : null,
      body: Column(children: [
        if (_selectedChat == null) ...[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(children: [
              const SizedBox(height: 12),
              const SecTitle('Chat / Communication'),
              const SizedBox(height: 14),
              Row(children: [
                _StatCard('5',  'Active',  C.greenLight,  C.green),
                const SizedBox(width: 10),
                _StatCard('6',  'Unread',  C.orangeLight, C.orange),
                const SizedBox(width: 10),
                _StatCard('48', 'Today',   C.blueLight,   C.blue),
                const SizedBox(width: 10),
                _StatCard('3',  'Waiting', C.redLight,    C.red),
              ]),
              const SizedBox(height: 14),
              TabBar(
                controller: _tab,
                labelColor: C.primary,
                unselectedLabelColor: C.textMid,
                indicatorColor: C.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'All Chats'),
                  Tab(text: 'Active'),
                  Tab(text: 'Resolved'),
                ],
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [

                // ── All Chats ──
                _buildChatList(),

                // ── Active (online) ──
                Builder(builder: (_) {
                  final active = _chats
                      .where((c) => c['online'] as bool).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: active.length,
                    itemBuilder: (_, i) {
                      final c = active[i];
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedChat = _chats.indexOf(c);
                          c['unread']   = 0;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: kCard(),
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                  color: C.greenLight,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                child: Text(c['avatar'],
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w800, color: C.green)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c['name'],
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
                                Text(c['lastMsg'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: C.textMid)),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: C.greenLight, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Online',
                                  style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700, color: C.green)),
                            ),
                          ]),
                        ),
                      );
                    },
                  );
                }),

                // ── Resolved (offline) ──
                Builder(builder: (_) {
                  final resolved = _chats
                      .where((c) => !(c['online'] as bool)).toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resolved.length,
                    itemBuilder: (_, i) {
                      final c = resolved[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: kCard(),
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                                color: C.bg, borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text(c['avatar'],
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800, color: C.textMid)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c['name'],
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
                              Text(c['lastMsg'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: C.textMid)),
                            ]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: C.bg, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Offline',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700, color: C.textMid)),
                          ),
                        ]),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ] else
          Expanded(child: _buildChatDetail()),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  TYPING DOTS ANIMATION
// ═══════════════════════════════════════════
class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final v = _ctrl.value;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        _dot(v, 0.0),
        const SizedBox(width: 4),
        _dot(v, 0.33),
        const SizedBox(width: 4),
        _dot(v, 0.66),
      ]);
    },
  );

  Widget _dot(double v, double offset) {
    final phase  = ((v - offset) % 1.0 + 1.0) % 1.0;
    final scale  = phase < 0.5 ? 1.0 + phase * 0.8 : 1.8 - (phase - 0.5) * 0.8;
    final opacity = 0.4 + phase * 0.6;
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity.clamp(0.4, 1.0),
        child: Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
              color: C.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  HELPER WIDGETS
// ═══════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String v, l;
  final Color  bg, fg;
  const _StatCard(this.v, this.l, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(v, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900, color: fg)),
        const SizedBox(height: 2),
        Text(l, style: const TextStyle(fontSize: 10, color: C.textMid)),
      ]),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color    fg, bg;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.fg, this.bg, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: fg, size: 15),
    ),
  );
}