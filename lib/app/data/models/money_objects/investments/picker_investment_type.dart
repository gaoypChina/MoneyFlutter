import 'package:money/app/core/widgets/picker_edit_box.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

Widget pickerInvestmentType({
  required final InvestmentType itemSelected,
  required final Function(InvestmentType) onSelected,
}) {
  String selectedName = getInvestmentTypeText(itemSelected);

  return PickerEditBox(
    title: 'Investment type',
    items: getInvestmentTypeNames(),
    initialValue: selectedName,
    onChanged: (String newSelection) {
      onSelected(getInvestmentTypeFromText(newSelection));
    },
  );
}
