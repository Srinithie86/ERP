import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/warehouse_models.dart';
import 'approval_screen.dart';

class RequestIndentScreen extends StatefulWidget {
  const RequestIndentScreen({super.key});

  @override
  State<RequestIndentScreen> createState() => _RequestIndentScreenState();
}

class _RequestIndentScreenState extends State<RequestIndentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requesterController = TextEditingController();
  final List<RequestItem> _items = [];
  
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  String? _selectedUnit;
  
  final _pageController = PageController();
  IndentRequest? _submittedRequest;

  @override
  void dispose() {
    _requesterController.dispose();
    _itemController.dispose();
    _qtyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.isNotEmpty && _qtyController.text.isNotEmpty && _selectedUnit != null) {
      setState(() {
        _items.add(RequestItem(
          itemName: _itemController.text,
          quantity: double.parse(_qtyController.text),
          unit: _selectedUnit!,
        ));
        _itemController.clear();
        _qtyController.clear();
        _selectedUnit = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all item fields')));
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final provider = context.read<WarehouseProvider>();
      final request = provider.addRequest(
        requestedBy: _requesterController.text,
        items: _items,
      );

      setState(() {
        _submittedRequest = request;
      });

      // Smoothly jump to the next page inside the same screen
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WarehouseProvider>();
    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Material Request / Indent',
        screenType: ScreenType.entry,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping
        children: [
          // PAGE 1: The Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    title: 'General Info',
                    icon: Icons.person_outline,
                    child: WField(
                      label: 'Requested By (Department/Person)',
                      controller: _requesterController,
                      hint: 'e.g. Production Line 1',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Add Items',
                    icon: Icons.add_circle_outline,
                    child: Column(
                      children: [
                        WField(
                          label: 'Item Name',
                          controller: _itemController,
                          hint: 'Search or enter item name',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: WField(
                                label: 'Quantity',
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                hint: '0.0',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: WDropdown(
                                label: 'Unit',
                                value: _selectedUnit,
                                items: provider.units,
                                hint: 'UoM',
                                onChanged: (v) => setState(() => _selectedUnit = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add to List'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_items.isNotEmpty)
                    SectionCard(
                      title: 'Requested Items (${_items.length})',
                      icon: Icons.list_alt,
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${item.quantity} ${item.unit}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => setState(() => _items.removeAt(index)),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Submit Request',
                    icon: Icons.send,
                    onPressed: _submitRequest,
                  ),
                ],
              ),
            ),
          ),
          
          // PAGE 2: The Success Target Screen (Slides Over)
          if (_submittedRequest != null)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, size: 80, color: Colors.green.shade500),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Indent Submitted!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your request has been successfully created and sent for approval.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Indent ID: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(_submittedRequest!.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF26A69A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ApprovalScreen()),
                        );
                      },
                      child: const Text('Go to Approvals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Dashboard', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
