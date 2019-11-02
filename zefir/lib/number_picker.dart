import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberPicker extends FormField<int> {
  NumberPicker(
      {@required BuildContext context,
      @required int initialValue,
      @required TextEditingController controller,
      FormFieldSetter<int> onSaved,
      FormFieldValidator<int> validator,
      bool autovalidate = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidate: autovalidate,
            builder: (FormFieldState<int> state) {
              return TextField(
                onTap: () async {
                  int val = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog.integer(
                            maxValue: 10,
                            minValue: 2,
                            initialIntegerValue:
                                getVal(controller, initialValue));
                      });
                  if (val != null) {
                    state.didChange(val);
                    controller.text = val.toString();
                  }
                },
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                    labelText: 'Liczba graczy', border: OutlineInputBorder()),
              );
            }) {
    controller.text = getVal(controller, initialValue).toString();
  }

  static int getVal(TextEditingController controller, int initialValue) {
    return controller.text.isNotEmpty
        ? int.parse(controller.text)
        : initialValue;
  }
}
