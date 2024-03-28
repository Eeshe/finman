import 'dart:math';

import 'package:finman/core/models/account.dart';
import 'package:finman/core/providers/account_provider.dart';
import 'package:finman/core/providers/saving_provider.dart';
import 'package:finman/ui/pages/saving_form_page.dart';
import 'package:finman/ui/shared/widgets/account_icon_widget.dart';
import 'package:finman/ui/shared/widgets/adjustable_progress_bar_widget.dart';
import 'package:finman/ui/shared/widgets/styled_progress_bar_widget.dart';
import 'package:finman/utils/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

part 'saving.g.dart';

@HiveType(typeId: 4)
class Saving {
  @HiveField(0)
  String id;
  @HiveField(1)
  String accountId;
  @HiveField(2)
  double amount;
  @HiveField(3)
  double paidAmount;

  Saving(this.id, this.accountId, this.amount, this.paidAmount);

  bool _isPaid() {
    return paidAmount >= amount;
  }

  void _setPaid() {
    paidAmount = amount;
  }

  void _clearPaid() {
    paidAmount = 0;
  }

  double calculateRemainingAmount() {
    return amount - paidAmount;
  }

  void increasePaidAmount(double amount) {
    paidAmount = max(0, min(this.amount, paidAmount + amount));
  }

  Widget _createAdjustableProgressBarWidget(BuildContext context) {
    return AdjustableProgressBarWidget(
      filledPercentage: paidAmount / amount,
      lineHeight: 20,
      center: Text("\$${paidAmount.format()}/\$${amount.format()}",
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onMin: () {
        _clearPaid();
        // paidAmountNotifier.value = paidAmount;
        Provider.of<SavingProvider>(context, listen: false).save(this);
      },
      onMax: () {
        _setPaid();
        // paidAmountNotifier.value = paidAmount;
        Provider.of<SavingProvider>(context, listen: false).save(this);
      },
      onTweak: (value) {
        increasePaidAmount(value);
        Provider.of<SavingProvider>(context, listen: false).save(this);
        // paidAmountNotifier.value = paidAmount;
      },
    );
  }

  Widget createDisplayWidget(BuildContext context) {
    TextStyle labelStyle = const TextStyle(fontSize: 20);
    ValueNotifier<double> paidAmountNotifier = ValueNotifier(paidAmount);
    Account? account =
        Provider.of<AccountProvider>(context, listen: false).getById(accountId);
    if (account == null) return const SizedBox();

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SavingFormPage(this, null)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(id, style: labelStyle),
          AccountIconWidget(account.iconPath, 50, 50),
          Text(accountId, style: labelStyle),
          _createAdjustableProgressBarWidget(context),
        ],
      ),
    );
    // return ValueListenableBuilder(
    //   valueListenable: paidAmountNotifier,
    //   builder: (context, value, child) {
    //   },
    // );
  }

  Widget _createProgressBarWidget(BuildContext context) {
    return StyledProgressBarWidget(
      filledPercentage: paidAmount / amount,
      lineHeight: 20,
      center: Text(
        "\$${paidAmount.format()}/\$${amount.format()}",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget createListWidget(
      BuildContext context, Account account, Function() redrawCallback) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SavingFormPage(this, account)));
        redrawCallback();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              id,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          _createProgressBarWidget(context)
        ],
      ),
    );
  }
}
