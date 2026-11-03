
import 'package:flutter/material.dart';

import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';
import '../../services/wallet_service.dart';
import '../../services/transaction_service.dart';

const Color walletPink = Color(0xFFE88BAA);
const Color walletBackground = Color(0xFFFFF7FA);

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final WalletService _service = WalletService();
  final TransactionService _transactionService = TransactionService();

  late final Stream<List<MoneyWallet>> _walletsStream;
  late final Stream<List<MoneyTransaction>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _walletsStream = _service.getWallets();
    _transactionsStream = _transactionService.getTransactions();
  }

  String _formatMoney(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);

      final remaining = value.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()} đ';
  }

  String _walletTypeName(String type) {
    switch (type) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank':
        return 'Ngân hàng';
      case 'e_wallet':
        return 'Ví điện tử';
      default:
        return 'Khác';
    }
  }

  IconData _walletIcon(int codePoint) {
    return IconData(
      codePoint,
      fontFamily: 'MaterialIcons',
    );
  }

  // Calculate the current balance of one wallet.
  double _calculateWalletBalance(
    MoneyWallet wallet,
    List<MoneyTransaction> transactions,
  ) {
    double balance = wallet.initialBalance;

    for (final transaction in transactions) {
      if (transaction.walletId != wallet.id) {
        continue;
      }

      if (transaction.isIncome) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }

    return balance;
  }

  Future<void> _showWalletDialog({
    MoneyWallet? wallet,
  }) async {
    final nameController = TextEditingController(
      text: wallet?.name ?? '',
    );

    final balanceController = TextEditingController(
      text: wallet == null
          ? '0'
          : wallet.initialBalance.toStringAsFixed(0),
    );

    String selectedType = wallet?.type ?? 'cash';

    final selectedIcon = _walletIcon(
      wallet?.iconCodePoint ?? Icons.account_balance_wallet.codePoint,
    );

    Color selectedColor = Color(
      wallet?.colorValue ?? walletPink.value,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                wallet == null ? 'Thêm ví mới' : 'Chỉnh sửa ví',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên ví',
                        hintText: 'Ví dụ: Tiền mặt, MoMo...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Loại ví',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('Tiền mặt'),
                        ),
                        DropdownMenuItem(
                          value: 'bank',
                          child: Text('Ngân hàng'),
                        ),
                        DropdownMenuItem(
                          value: 'e_wallet',
                          child: Text('Ví điện tử'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Khác'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Số dư ban đầu',
                        suffixText: 'đ',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Màu sắc',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 12,
                      children: [
                        for (final color in [
                          const Color(0xFFE88BAA),
                          const Color(0xFF80CBC4),
                          const Color(0xFF90CAF9),
                          const Color(0xFFFFCC80),
                          const Color(0xFFB39DDB),
                        ])
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: color,
                              child: selectedColor.value == color.value
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: walletPink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();

                    final balance = double.tryParse(
                      balanceController.text.trim().replaceAll(',', ''),
                    );

                    if (name.isEmpty || balance == null || balance < 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng nhập tên ví và số dư hợp lệ.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      if (wallet == null) {
                        await _service.addWallet(
                          name: name,
                          type: selectedType,
                          initialBalance: balance,
                          iconCodePoint: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                        );
                      } else {
                        await _service.updateWallet(
                          id: wallet.id,
                          name: name,
                          type: selectedType,
                          initialBalance: balance,
                          iconCodePoint: selectedIcon.codePoint,
                          colorValue: selectedColor.value,
                        );
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, true);
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(wallet == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    balanceController.dispose();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wallet == null
                ? 'Đã thêm ví thành công!'
                : 'Đã cập nhật ví thành công!',
          ),
        ),
      );
    }
  }

  Future<void> _deleteWallet(MoneyWallet wallet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa ví'),
          content: Text(
            'Bạn có chắc muốn xóa ví "${wallet.name}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // Check whether this wallet is linked to any transaction.
      final transactions = await _transactionService
          .getTransactions()
          .first;

      final hasTransactions = transactions.any(
        (transaction) => transaction.walletId == wallet.id,
      );

      if (hasTransactions) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể xóa ví này vì vẫn còn giao dịch liên kết. '
              'Hãy chuyển hoặc xóa các giao dịch trước.',
            ),
            duration: Duration(seconds: 4),
          ),
        );

        return;
      }

      await _service.deleteWallet(wallet.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ví thành công!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Widget _buildWalletCard(
    MoneyWallet wallet,
    List<MoneyTransaction> transactions,
  ) {
    final color = Color(wallet.colorValue);

    final currentBalance = _calculateWalletBalance(
      wallet,
      transactions,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              _walletIcon(wallet.iconCodePoint),
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _walletTypeName(wallet.type),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatMoney(currentBalance),
                  style: TextStyle(
                    color: currentBalance < 0 ? Colors.red : color,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Số dư hiện tại',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showWalletDialog(wallet: wallet);
              } else if (value == 'delete') {
                _deleteWallet(wallet);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text('Xóa'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    List<MoneyWallet> wallets,
    List<MoneyTransaction> transactions,
  ) {
    final totalBalance = wallets.fold<double>(
      0,
      (sum, wallet) =>
          sum + _calculateWalletBalance(wallet, transactions),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE88BAA),
                Color(0xFFF3AFC3),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng số dư hiện tại',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _formatMoney(totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${wallets.length} ví đang quản lý',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ví của tôi',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${wallets.length} ví',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        if (wallets.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 65,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Bạn chưa có ví nào',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Thêm ví đầu tiên để quản lý tài chính.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...wallets.map(
            (wallet) => _buildWalletCard(wallet, transactions),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: walletBackground,
      appBar: AppBar(
        title: const Text(
          'Quản lý ví',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: walletBackground,
        elevation: 0,
      ),
      body: StreamBuilder<List<MoneyWallet>>(
        stream: _walletsStream,
        builder: (context, walletSnapshot) {
          if (walletSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không thể tải dữ liệu ví.\n${walletSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (walletSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: walletPink,
              ),
            );
          }

          return StreamBuilder<List<MoneyTransaction>>(
            stream: _transactionsStream,
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Không thể tải dữ liệu giao dịch.\n'
                      '${transactionSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (transactionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: walletPink,
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(
                  walletSnapshot.data ?? [],
                  transactionSnapshot.data ?? [],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWalletDialog(),
        backgroundColor: walletPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ví'),
      ),
    );
  }
}
