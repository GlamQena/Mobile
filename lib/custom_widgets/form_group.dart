import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../public/app_colors.dart';

class FormGroup extends StatefulWidget {
  final bool isDarkMode;
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String hintText;
  final String? helperText;
  final int? maxLength;
  final int? maxLines;
  final Widget prefixIcon;
  final int? errorMaxLines;
  String? Function(String?)? validator;
  final bool? isDob;
  final bool? isPassword;

  FormGroup({
    super.key,
    required this.isDarkMode,
    required this.controller,
    required this.label,
    required this.isRequired,
    this.maxLength,
    this.maxLines,
    required this.prefixIcon,
    required this.hintText,
    this.helperText,
    this.errorMaxLines,
    this.validator,
    this.isDob,
    this.isPassword,
  });

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  late Color textSecondary;
  late Color textMuted;
  late bool hidePassword;
  late Color error;

  @override initState(){
    super.initState();
    textSecondary = widget.isDarkMode ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    textMuted = widget.isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    error = widget.isDarkMode ? AppColorsDark.error : AppColorsLight.error;
    hidePassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(1.5),
      child: Column(
        spacing: 10,
        children:[
          Row(
            spacing: 7,
            children:[
              Padding(
                padding: EdgeInsets.only( right: context.locale.languageCode == "ar" ? 5 : 0, left: context.locale.languageCode == "ar" ? 5 : 0),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
              widget.isRequired ? FaIcon(FontAwesomeIcons.asterisk, color: error, size: 7) : SizedBox.shrink(),
            ]
          ),
          TextFormField(
            maxLength: widget.maxLength,
            minLines: 1,
            maxLines: hidePassword ? 1 : widget.maxLines,
            cursorColor: widget.isDarkMode ? AppColors.primary : AppColors.secondary,
            cursorErrorColor: Colors.red[700],
            controller: widget.controller,
            style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
            obscureText: hidePassword ? true : false,
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w300),
              helperText: widget.helperText ?? "",
              helperMaxLines: 2,
              helperStyle: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.all(7),
              isDense: true,
              filled: true,
              fillColor: widget.isDarkMode ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
              enabled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.isDarkMode ? AppColorsDark.border : AppColorsLight.border,
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.isDarkMode ? AppColors.primary : AppColors.secondary,
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              errorMaxLines: widget.errorMaxLines,
              errorStyle: TextStyle(color: error, fontSize: 12, fontWeight: FontWeight.w400),
              suffix: (widget.isDob ?? false) ?
                GestureDetector(onTap: () { _pickDate(context);},
                  child: Icon(Icons.calendar_month, color: textMuted)
                ) :
                (widget.isPassword ??  false) ?
                GestureDetector(onTap: () { setState((){hidePassword = !hidePassword;});},
                    child: hidePassword ? Icon(Icons.visibility_off, color: textMuted) : Icon(Icons.remove_red_eye, color: textMuted)
                ):
                SizedBox.shrink(),
            ),

            validator: widget.validator,
          )
        ]
      )
    );
  }

  void _pickDate(BuildContext context)async{
    final pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        initialDate: DateTime.now(),
        confirmText: "OK",
        cancelText: "cancel",
        helpText: "register_dob_picker".tr(),
    );

    if(pickedDate != null || pickedDate.toString().trim().isNotEmpty){
      setState((){
        widget.controller.text = _formatDate(pickedDate!);
      });
    }
  }

  String _formatDate (DateTime date){
    return "${date.month.toString().padLeft(2, "0")}/${date.day.toString().padLeft(2, "0")}/${date.year}";
  }
}
