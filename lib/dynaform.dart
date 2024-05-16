// @dart=2.9
import 'package:flutter/material.dart';
import 'theme.dart';
import 'wsam.dart';
import 'package:expression_language/expression_language.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dynamic_forms/dynamic_forms.dart' as df;
import 'package:flutter_dynamic_forms/flutter_dynamic_forms.dart';
import 'package:flutter_dynamic_forms_components/flutter_dynamic_forms_components.dart'
    as cp;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'textfield.dart';
import 'searchable_dropdown.dart';
import 'package:intl/intl.dart';

class OrderFormXml extends StatefulWidget {
  const OrderFormXml(this.xmlOrder);
  final String xmlOrder;
  @override
  _OrderFormXmlState createState() => _OrderFormXmlState(this.xmlOrder);
}

class _OrderFormXmlState extends State<OrderFormXml> {
  _OrderFormXmlState(this.xmlOrder);
  final String xmlOrder;

  List<FormElementRenderer<df.FormElement>> getReactiveRenderers() {
    return [
      ReactiveFormRenderer2(),
      cp.FormGroupRenderer(),
      ReactiveCheckBoxRenderer2(),
      ReactiveLabelRenderer2(),
      ReactiveTextFieldRenderer2(),
      ReactiveRadioButtonGroupRenderer2(),
      ReactiveRadioButtonRenderer2(),
      ReactiveDropdownButtonRenderer3(),
      cp.SingleSelectChipGroupRenderer(),
      cp.ReactiveSingleSelectChipChoiceRenderer(),
      cp.MultiSelectChipChoiceRenderer(),
      cp.MultiSelectChipGroupRenderer(),
      cp.ReactiveDateRenderer(),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  void _submitToServer(
      BuildContext context, List<df.FormPropertyValue> formProperties) async {
    // Only showing dialog with the form data for demo purposes
    var myXml = (formProperties
        .map((riv) => '[${riv.id}]${riv.value}[/${riv.id}]')
        .toList()
        .join(''));
    if (await sendBasket(context, 'order', 'basket', '', myXml, false)) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).sendorder,
              style: TextStyle(fontSize: 12.0)),
        ),
        body: Center(
            child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 5.0, bottom: 300),
          child: ParsedFormProvider(
            create: (_) => df.XmlFormManager(),
            content: xmlOrder,
            parsers: cp.getDefaultParserList(),
            child: Column(children: [
              FormRenderer<df.XmlFormManager>(
                renderers: getReactiveRenderers(),
              ),
              Builder(builder: (context) {
                return Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text(AppLocalizations.of(context).order),
                    onPressed: () {
                      var formProperties =
                          FormProvider.of<df.XmlFormManager>(context)
                              .getFormProperties();
                      _submitToServer(context, formProperties);
                    },
                  ),
                );
              })
            ]),
          ),
        )));
  }
}

class RegisterFormXml extends StatefulWidget {
  const RegisterFormXml(this.xmlRegister);
  final String xmlRegister;
  @override
  _RegisterFormXmlState createState() =>
      _RegisterFormXmlState(this.xmlRegister);
}

class _RegisterFormXmlState extends State<RegisterFormXml> {
  _RegisterFormXmlState(this.xmlRegister);
  final String xmlRegister;

  List<FormElementRenderer<df.FormElement>> getReactiveRenderers() {
    return [
      ReactiveFormRenderer2(),
      cp.FormGroupRenderer(),
      ReactiveCheckBoxRenderer2(),
      ReactiveLabelRenderer3(),
      ReactiveTextFieldRenderer2(),
      ReactiveRadioButtonGroupRenderer2(),
      ReactiveRadioButtonRenderer2(),
      ReactiveDropdownButtonRenderer3(),
      cp.SingleSelectChipGroupRenderer(),
      cp.ReactiveSingleSelectChipChoiceRenderer(),
      cp.MultiSelectChipChoiceRenderer(),
      cp.MultiSelectChipGroupRenderer(),
      ReactiveDateRenderer2(),
    ];
  }

  @override
  void initState() {
    super.initState();
  }

  void _submitToServer(
      BuildContext context, List<df.FormPropertyValue> formProperties) async {
    // Only showing dialog with the form data for demo purposes
    var myXml = (formProperties
        .map((riv) => '[${riv.id}]${riv.value}[/${riv.id}]')
        .toList()
        .join(''));
    if (await sendRegister(context, myXml)) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).registernow,
              style: TextStyle(fontSize: 12.0)),
        ),
        body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 5.0, bottom: 300),
              child: ParsedFormProvider(
                create: (_) => df.XmlFormManager(),
                content: xmlRegister,
                parsers: cp.getDefaultParserList(),
                child: Column(children: [
                  FormRenderer<df.XmlFormManager>(
                    renderers: getReactiveRenderers(),
                  ),
                  Builder(builder: (context) {
                    return Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.send),
                        label: Text(AppLocalizations.of(context).register),
                        onPressed: () {
                          var formProperties =
                          FormProvider.of<df.XmlFormManager>(context)
                              .getFormProperties();
                          _submitToServer(context, formProperties);
                        },
                      ),
                    );
                  })
                ]),
              ),
            )));
  }
}

class ReactiveFormRenderer2 extends FormElementRenderer<cp.Form> {
  @override
  Widget render(
      cp.Form element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return StreamBuilder<List<ExpressionProviderElement>>(
      initialData: element.children,
      stream: element.childrenChanged,
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: MergeStream(
            snapshot.data
                .whereType<df.FormElement>()
                .map((child) => child.isVisibleChanged),
          ),
          builder: (context, _) {
            List<Widget> childrenWidgets = snapshot.data
                .whereType<df.FormElement>()
                .where((f) => f.isVisible)
                .map(
                  (child) => renderer(child, context),
                )
                .toList();
            return Column(
              children: childrenWidgets,
            );
          },
        );
      },
    );
  }
}

class ReactiveRadioButtonGroupRenderer2
    extends FormElementRenderer<cp.RadioButtonGroup> {
  @override
  Widget render(
      cp.RadioButtonGroup element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return StreamBuilder<List<cp.RadioButton>>(
      initialData: element.choices,
      stream: element.choicesChanged,
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: MergeStream(
            snapshot.data.map((child) => child.isVisibleChanged),
          ),
          builder: (context, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
              ),
              ...element.choices
                  .where((c) => c.isVisible)
                  .map((choice) => renderer(choice, context))
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}

class ReactiveRadioButtonRenderer2 extends FormElementRenderer<cp.RadioButton> {
  @override
  Widget render(
      cp.RadioButton element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    var parent = element.parent as cp.RadioButtonGroup;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: LazyStreamBuilder<String>(
        initialData: parent.value,
        streamFactory: () =>
            MergeStream([parent.valueChanged, element.propertyChanged]),
        builder: (context, _) {
          return RadioListTile(
            dense: true,
            title: Text(element.label),
            value: element.value,
            groupValue: parent.value,
            onChanged: (String value) => dispatcher(
              ChangeValueEvent(
                  value: value,
                  elementId: parent.id,
                  propertyName: cp.SingleSelectGroup.valuePropertyName),
            ),
          );
        },
      ),
    );
  }
}

class ReactiveCheckBoxRenderer2 extends FormElementRenderer<cp.CheckBox> {
  @override
  Widget render(
      cp.CheckBox element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        children: <Widget>[
          StreamBuilder<bool>(
            initialData: element.value,
            stream: element.valueChanged,
            builder: (context, snapshot) {
              return Checkbox(
                onChanged: (value) => dispatcher(
                  ChangeValueEvent(
                    value: value,
                    elementId: element.id,
                  ),
                ),
                value: snapshot.data,
              );
            },
          ),
          ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 50),
              child: Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                child: StreamBuilder<String>(
                  initialData: element.label,
                  stream: element.labelChanged,
                  builder: (context, snapshot) {
                    return Text(snapshot.data);
                  },
                ),
              ))
        ],
      ),
    );
  }
}

class ReactiveLabelRenderer2 extends FormElementRenderer<cp.Label> {
  @override
  Widget render(
      cp.Label element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<String>(
            initialData: element.value,
            stream: element.valueChanged,
            builder: (context, snapshot) {
              return Container(
                  padding: EdgeInsets.all(5.0),
                  width: MediaQuery.of(context).size.width,
                  color: myTheme.colorScheme.background,
                  child: Text(
                    snapshot.data,
                  ));
            }),
      ),
    );
  }
}

class ReactiveLabelRenderer3 extends FormElementRenderer<cp.Label> {
  @override
  Widget render(
      cp.Label element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: StreamBuilder<String>(
            initialData: element.value,
            stream: element.valueChanged,
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.only(top: 10.0),
                width: MediaQuery.of(context).size.width,
                color: null,
                child: Text(snapshot.data, style: TextStyle(fontSize: 16.0)),
              );
            }),
      ),
    );
  }
}

class ReactiveDropdownButtonRenderer2
    extends FormElementRenderer<cp.DropdownButton> {
  @override
  Widget render(
      cp.DropdownButton element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return LazyStreamBuilder(
      streamFactory: () => MergeStream([
        ...element.choices.map((o) => o.isVisibleChanged),
        element.propertyChanged,
      ]),
      builder: (context, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: element.value,
              onChanged: (String newValue) => dispatcher(
                ChangeValueEvent(
                    value: newValue,
                    elementId: element.id,
                    propertyName: cp.SingleSelectGroup.valuePropertyName),
              ),
              items: element.choices
                  .where((d) => d.isVisible)
                  .whereType<cp.DropdownOption>()
                  .map<DropdownMenuItem<String>>(
                (cp.DropdownOption option) {
                  return DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ReactiveDropdownButtonRenderer3
    extends FormElementRenderer<cp.DropdownButton> {
  @override
  Widget render(
      cp.DropdownButton element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return LazyStreamBuilder(
      streamFactory: () => MergeStream([
        ...element.choices.map((o) => o.isVisibleChanged),
        element.propertyChanged,
      ]),
      builder: (context, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchableDropdown<String>.single(
              closeButton: AppLocalizations.of(context).cancel,
              isExpanded: true,
              value: null,
              onChanged: (newValue) => dispatcher(
                ChangeValueEvent(
                    value: newValue,
                    elementId: element.id,
                    propertyName: cp.SingleSelectGroup.valuePropertyName,
                    ignoreLastChange: true),
              ),
              items: element.choices
                  .where((d) => d.isVisible)
                  .whereType<cp.DropdownOption>()
                  .map<DropdownMenuItem<String>>(
                (cp.DropdownOption option) {
                  return DropdownMenuItem<String>(
                    value: option.value,
                    child: Text(option.label),
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ReactiveTextFieldRenderer2 extends FormElementRenderer<cp.TextField> {
  @override
  Widget render(
      cp.TextField element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return StreamBuilder(
      stream: element.propertyChanged,
      builder: (context, _) {
        var errorText = element.validations
            .firstWhere((v) => !v.isValid, orElse: () => null)
            ?.message;
        return TextFieldWidget2(
          text: element.value,
          id: element.id,
          errorText: errorText,
          label: element.label,
          textInputType: element.inputType,
          dispatcher: dispatcher,
        );
      },
    );
  }
}

class ReactiveDateRenderer2 extends FormElementRenderer<cp.Date> {
  @override
  Widget render(
      cp.Date element,
      BuildContext context,
      FormElementEventDispatcherFunction dispatcher,
      FormElementRendererFunction renderer) {
    return StreamBuilder(
      stream: element.valueChanged,
      builder: (BuildContext context, _) {
        final format = DateFormat(element.format);
        var value = element.value;
        //print('first date ' + element.label.toString());
        final DateTime time = value != null ? value : element.initialDate;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: format.format(time),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                var firstDate = element.firstDate;
                var lastDate = element.lastDate;

                DateTime picked = await showDatePicker(
                  context: context,
                  firstDate:
                      firstDate != null ? firstDate : DateTime(1979, 01, 01),
                  lastDate:
                      lastDate != null ? lastDate : DateTime(2050, 01, 01),
                  initialDate: element.initialDate,
                  selectableDayPredicate: (DateTime val) =>
                      val.weekday == 6 || val.weekday == 7 ? false : true,
                );

                if (picked != null) {
                  dispatcher(
                    ChangeValueEvent(
                      value: picked,
                      elementId: element.id,
                      // propertyName: model.Date.valuePropertyName,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
