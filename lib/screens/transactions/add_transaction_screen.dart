
import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/wallet_model.dart';
import '../../services/transaction_service.dart';
import '../../services/category_service.dart';
import '../../services/wallet_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final MoneyTransaction? transaction;
  final String initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = 'expense',
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TransactionService _service = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  late final Stream<List<MoneyCategory>> _categoriesStream;
  late final Stream<List<MoneyWallet>> _walletsStream;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  static const Color primaryPink = Color(0xFFE88BAA);

  String _type = 'expense';
  String _category = '';
  String _walletId = '';

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    _categoriesStream = _categoryService.getCategories();
    _walletsStream = _walletService.getWallets();

    final transaction = widget.transaction;

    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toStringAsFixed(0);
      _noteController.text = transaction.note;

      _type = transaction.type;
      _category = transaction.category;
      _walletId = transaction.walletId;

      _selectedDate = transaction.date;
    } else {
      _type = widget.initialType == 'income' ? 'income' : 'expense';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction(
    String selectedCategory,
    String selectedWalletId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a category before saving.'),
        ),
      );
      return;
    }

    if (selectedWalletId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wallet before saving.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount greater than zero.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final transaction = MoneyTransaction(
      id: widget.transaction?.id ?? '',
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: selectedCategory,
      note: _noteController.text.trim(),
      date: _selectedDate,
      walletId: selectedWalletId,
    );

    try {
      if (_isEditing) {
        await _service.updateTransaction(transaction);
      } else {
        await _service.addTransaction(transaction);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaction updated successfully!'
                : 'Transaction added successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save transaction: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryPink),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryPink,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF8FA),
        elevation: 0,
      ),
      body: StreamBuilder<List<MoneyCategory>>(
        stream: _categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load categories.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryPink,
              ),
            );
          }

          final allCategories = snapshot.data ?? [];

          final categories = allCategories
              .where((category) => category.type == _type)
              .toList();

          final categoryNames = categories
              .map((category) => category.name)
              .toList();

          final selectedCategory = categoryNames.contains(_category)
              ? _category
              : (categoryNames.isNotEmpty ? categoryNames.first : '');

          return StreamBuilder<List<MoneyWallet>>(
            stream: _walletsStream,
            builder: (context, walletSnapshot) {
              if (walletSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to load wallets.\n${walletSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (walletSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryPink,
                  ),
                );
              }

              final wallets = walletSnapshot.data ?? [];

              final selectedWalletId = wallets.any(
                (wallet) => wallet.id == _walletId,
              )
                  ? _walletId
                  : (wallets.isNotEmpty ? wallets.first.id : '');

              return SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _typeButton(
                              'expense',
                              'Expense',
                              Icons.arrow_upward,
                              const Color(0xFFE66D75),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _typeButton(
                              'income',
                              'Income',
                              Icons.arrow_downward,
                              const Color(0xFF35A879),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Transaction Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Transaction title',
                          Icons.edit_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a transaction title.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Amount (VND)',
                          Icons.payments_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount.';
                          }

                          final amount = double.tryParse(
                            value.trim().replaceAll(',', ''),
                          );

                          if (amount == null || amount <= 0) {
                            return 'Amount must be greater than zero.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedCategory.isEmpty
                            ? null
                            : selectedCategory,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Category',
                          Icons.category_outlined,
                        ),
                        hint: Text(
                          categories.isEmpty
                              ? 'No categories available'
                              : 'Select category',
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: categories.isEmpty
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _category = value;
                                  });
                                }
                              },
                      ),

                      if (categories.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'No ${_type == 'income' ? 'income' : 'expense'} '
                          'categories found. Please add one in the '
                          'Categories tab first.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedWalletId.isEmpty
                            ? null
                            : selectedWalletId,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Wallet',
                          Icons.account_balance_wallet_outlined,
                        ),
                        hint: Text(
                          wallets.isEmpty
                              ? 'No wallets available'
                              : 'Select wallet',
                        ),
                        items: wallets.map((wallet) {
                          return DropdownMenuItem<String>(
                            value: wallet.id,
                            child: Text(wallet.name),
                          );
                        }).toList(),
                        onChanged: wallets.isEmpty
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _walletId = value;
                                  });
                                }
                              },
                      ),

                      if (wallets.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'No wallets found. Please create a wallet '
                          'in the Wallets tab first.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(14),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            'Transaction date',
                            Icons.calendar_today_outlined,
                          ),
                          child: Text(_formatDate(_selectedDate)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          'Note (optional)',
                          Icons.notes_outlined,
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ||
                                  categories.isEmpty ||
                                  wallets.isEmpty
                              ? null
                              : () => _saveTransaction(
                                    selectedCategory,
                                    selectedWalletId,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primaryPink.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Save Changes'
                                      : 'Add Transaction',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _typeButton(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final selected = _type == value;

    return InkWell(
      onTap: () {
        if (_type == value) return;

        setState(() {
          _type = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
