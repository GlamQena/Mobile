import "package:flutter/material.dart";
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_app/custom_widgets/form_group.dart';
import '../../custom_widgets/show_snack_bar.dart';
import '../../models/register.dart';
import '../../public/app_colors.dart';
import '../../custom_widgets/gradient_button.dart';
import '../../custom_widgets/link_widget.dart';
import '../../services/api_client.dart';
import '../../services/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/messages_mappers/register_error_messages.dart';
import '../../services/messages_mappers/register_success_messages.dart';

class Register extends StatefulWidget{
  final bool isDarkMode;
  final String selectedDrawerTile;

  const Register({super.key, required this.isDarkMode, required this.selectedDrawerTile});

  @override State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register>{
  final GlobalKey<FormState> registerKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    "username" : TextEditingController(),
    "email" : TextEditingController(),
    "phone" : TextEditingController(),
    "dob" : TextEditingController(),
    "city" : TextEditingController(),
    "street" : TextEditingController(),
    "area" : TextEditingController(),
    "password" : TextEditingController(),
    "confirmPassword" : TextEditingController(),
  };

  String selectedGender = "female";
  late List<bool> isSelected;

  @override
  void initState(){
    super.initState();
    isSelected = [false, true];
  }

  @override
  Widget build(BuildContext context){
    final Color textPrimary = widget.isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final Color textSecondary = widget.isDarkMode ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final Color textMuted = widget.isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.86,
        height: MediaQuery.of(context).size.height * 0.83,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColorsDark.surface : AppColorsLight.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 1.2,
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          color: widget.isDarkMode ? AppColors.primary : AppColors.secondary,
                          size: 27,
                        ),
                        Text(
                            "register_title".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: widget.isDarkMode ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                            )
                        ),
                        Text(
                            "register_subtitle".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: widget.isDarkMode ? AppColorsDark.textSecondary : AppColorsLight.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500
                            )
                        ),
                      ]
                  )
              ),
              const SizedBox(height: 20),
              Form(
                  key: registerKey,
                  child: Column(
                      children: [
                        FormGroup(
                            isDarkMode: widget.isDarkMode,
                            controller: controllers["username"]!,
                            label: "register_username_label".tr(),
                            isRequired: true,
                            prefixIcon: Icon(Icons.person_outline, color: textMuted, size: 17),
                            hintText: "register_username_placeholder".tr(),
                            // helperText: "register_username_helper".tr(),
                            errorMaxLines: 3,
                            maxLines: 2,
                            validator: (val){
                              if(val == null || val.trim().isEmpty){
                                return "register_username_required".tr();
                              }

                              if(val.trim().length > 64){
                                return "register_username_max_length".tr(); // Username cannot exceed 64 characters
                              }

                              if(val.trim().contains(RegExp(r'[^a-z0-9_]'))){
                                return "register_username_format".tr();
                              }
                              return null;
                            }
                        ),

                        FormGroup(
                            isDarkMode: widget.isDarkMode,
                            controller: controllers["email"]!,
                            label: "register_email_label".tr(),
                            isRequired: true,
                            prefixIcon: Icon(Icons.mail_outline, color: textMuted, size: 17),
                            hintText: "register_email_placeholder".tr(),
                            // helperText: "register_email_helper".tr(),
                            errorMaxLines: 3,
                            maxLines: 3,
                            validator: (val){
                              if(val == null || val.trim().isEmpty){
                                return "register_email_required".tr();
                              }

                              if(val.trim().length > 254){
                                return "register_email_max_length".tr(); // Email cannot exceed 254 characters
                              }

                              RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
                              if(!emailRegex.hasMatch(val.trim())){
                                return "register_email_format".tr();
                              }
                              return null;
                            }
                        ),

                        FormGroup(
                            isDarkMode: widget.isDarkMode,
                            controller: controllers["phone"]!,
                            label: "register_phone_label".tr(),
                            isRequired: false,
                            prefixIcon: Icon(Icons.phone, color: textMuted, size: 17),
                            hintText: "register_phone_placeholder".tr(),
                            // helperText: "register_phone_helper".tr(),
                            errorMaxLines: 2,
                            maxLength: 11,
                            maxLines: 1,
                            validator: (val){
                              RegExp phoneRegex = RegExp(r"^01[0125][0-9]{8}$");
                              if((val != null && val.trim().isNotEmpty) && !phoneRegex.hasMatch(val)){
                                return "register_phone_format".tr();
                              }
                              return null;
                            }
                        ),

                        FormGroup(
                            isDarkMode: widget.isDarkMode,
                            controller: controllers["dob"]!,
                            label: "register_dob_label".tr(),
                            isRequired: false,
                            prefixIcon: Icon(Icons.calendar_today, color: textMuted, size: 17),
                            hintText: "register_dob_placeholder".tr(),
                            helperText: "register_dob_helper".tr(),
                            errorMaxLines: 2,
                            isDob: true,
                            maxLines: 1,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return null; // Optional field
                              }

                              // Validate DD/MM/YYYY format
                              RegExp dobRegex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19[0-9]{2}|20[0-9]{2})$');
                              if (!dobRegex.hasMatch(val.trim())) {
                                return "register_dob_format".tr();
                              }

                              try {
                                List<String> dobParts = val.trim().split("/");
                                int day = int.parse(dobParts[0]);
                                int month = int.parse(dobParts[1]);
                                int year = int.parse(dobParts[2]);

                                DateTime? parsedDate = _tryParseDate(year, month, day);
                                if (parsedDate == null) {
                                  return "register_dob_validation".tr();
                                }

                                if (parsedDate.isAfter(DateTime.now())) {
                                  return "register_dob_future".tr();
                                }

                                return null;
                              } catch (e) {
                                return "register_dob_format".tr();
                              }
                            }
                        ),

                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.all(5),
                          child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: context.locale.languageCode == "ar" ? 5 : 0,
                                    left: context.locale.languageCode == "ar" ? 5 : 0,
                                  ),
                                  child: Text(
                                    "register_gender_label".tr(),
                                    style: TextStyle(
                                        color: widget.isDarkMode ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                    ),
                                  ),
                                ),
                                LayoutBuilder(
                                    builder: (context, constraints) {
                                      double maxWidth = constraints.maxWidth;

                                      return Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: widget.isDarkMode ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant,
                                          border: Border.all(
                                            color: widget.isDarkMode ? AppColorsDark.border : AppColorsLight.border,
                                            width: 0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: ToggleButtons(
                                          isSelected: isSelected,
                                          onPressed: (index){
                                            setState(() {
                                              for(int i = 0; i < isSelected.length; i++){
                                                isSelected[i] = i == index;
                                              }
                                              selectedGender = index == 0 ? "male" : "female";
                                            });
                                          },
                                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                          color: textMuted,
                                          selectedColor: textPrimary,
                                          fillColor: widget.isDarkMode ? AppColors.primaryDark : AppColors.secondary,
                                          borderRadius: BorderRadius.circular(7),
                                          borderWidth: 0.0,
                                          borderColor: Colors.transparent,
                                          constraints: BoxConstraints(
                                              minWidth: maxWidth * 0.45,
                                              maxWidth: maxWidth
                                          ),
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                child: Text("register_gender_male".tr())
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                                child: Text("register_gender_female".tr())
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                ),
                                Container(
                                    padding: const EdgeInsets.all(2),
                                    child: Column(
                                        children: [
                                          Row(
                                              children: [
                                                Icon(Icons.location_on_sharp, color: textSecondary, size: 17),
                                                Text(
                                                    "register_address_title".tr(),
                                                    style: TextStyle(
                                                        color: textSecondary,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400
                                                    )
                                                )
                                              ]
                                          ),
                                          const SizedBox(height: 1.2),
                                          Row(
                                              spacing: 2,
                                              children: [
                                                Expanded(
                                                  child: FormGroup(
                                                      isDarkMode: widget.isDarkMode,
                                                      controller: controllers["city"]!,
                                                      label: "register_city_label".tr(),
                                                      isRequired: false,
                                                      maxLength: 50,
                                                      prefixIcon: Icon(Icons.location_city_sharp, color: textMuted, size: 17),
                                                      hintText: "register_city_label".tr(),
                                                      errorMaxLines: 2,
                                                      maxLines: 2,
                                                      validator: (val) {
                                                        if(val != null && val.length > 50){
                                                          return "register_city_maxLength".tr();
                                                        }
                                                        return null;
                                                      }
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FormGroup(
                                                      isDarkMode: widget.isDarkMode,
                                                      controller: controllers["area"]!,
                                                      label: "register_area_label".tr(),
                                                      maxLength: 50,
                                                      isRequired: false,
                                                      prefixIcon: Icon(Icons.map_outlined, color: textMuted, size: 17),
                                                      hintText: "register_area_label".tr(),
                                                      errorMaxLines: 2,
                                                      maxLines: 2,
                                                      validator: (val) {
                                                        if(val != null && val.length > 50){
                                                          return "register_area_maxLength".tr();
                                                        }
                                                        return null;
                                                      }
                                                  ),
                                                ),
                                              ]
                                          ),
                                          FormGroup(
                                              isDarkMode: widget.isDarkMode,
                                              maxLength: 100,
                                              controller: controllers["street"]!,
                                              label: "register_street_label".tr(),
                                              isRequired: false,
                                              prefixIcon: Icon(Icons.broadcast_on_home_rounded, color: textMuted, size: 17),
                                              hintText: "register_street_label".tr(),
                                              errorMaxLines: 2,
                                              maxLines: 2,
                                              validator: (val) {
                                                if(val != null && val.length > 100){
                                                  return "register_street_maxLength".tr();
                                                }
                                                return null;
                                              }
                                          ),
                                        ]
                                    )
                                ),
                                FormGroup(
                                    isDarkMode: widget.isDarkMode,
                                    controller: controllers["password"]!,
                                    label: "register_password_label".tr(),
                                    isRequired: true,
                                    prefixIcon: Icon(Icons.lock_outline, color: textMuted, size: 17),
                                    hintText: "register_password_placeholder".tr(),
                                    errorMaxLines: 3,
                                    maxLines: 1,
                                    isPassword: true,
                                    validator: (val) {
                                      if(val == null || val.trim().isEmpty){
                                        return "register_password_required".tr();
                                      }

                                      if(val.length < 8){
                                        return "register_password_min_length".tr(); // Password must be at least 8 characters
                                      }

                                      if(val.length > 64){
                                        return "register_password_max_length".tr(); // Password cannot exceed 64 characters
                                      }

                                      // Check for at least one uppercase letter
                                      if (!RegExp(r'[A-Z]').hasMatch(val)) {
                                        return "register_password_uppercase".tr();
                                      }

                                      // Check for at least one lowercase letter
                                      if (!RegExp(r'[a-z]').hasMatch(val)) {
                                        return "register_password_lowercase".tr();
                                      }

                                      // Check for at least one digit
                                      if (!RegExp(r'[0-9]').hasMatch(val)) {
                                        return "register_password_digit".tr();
                                      }
                                      return null;
                                    }
                                ),
                                FormGroup(
                                    isDarkMode: widget.isDarkMode,
                                    controller: controllers["confirmPassword"]!,
                                    label: "register_confirm_password_label".tr(),
                                    isRequired: true,
                                    prefixIcon: Icon(Icons.lock_clock_outlined, color: textMuted, size: 17),
                                    hintText: "register_confirm_password_placeholder".tr(),
                                    errorMaxLines: 3,
                                    maxLines: 1,
                                    isPassword: true,
                                    validator: (val) {
                                      if(val == null || val.trim().isEmpty){
                                        return "register_confirm_password_required".tr();
                                      }

                                      if(val != controllers["password"]?.text){
                                        return "register_confirm_password_match".tr();
                                      }

                                      return null;
                                    }
                                ),
                                const SizedBox(height: 10),

                                GradientElevatedButton(
                                  context: context,
                                  width: MediaQuery.of(context).size.width * 70,
                                  borderRadius: 15,
                                  backgroundGradient: widget.isDarkMode ? AppColorsDark.sidebarActiveGradient : AppColorsLight.sidebarActiveGradient,
                                  onPressed: () async{
                                    if(registerKey.currentState!.validate()){
                                      try{
                                        RegisterRequestBody requestBody = RegisterRequestBody.fromForm(
                                          username: controllers["username"]!.text,
                                          email:  controllers["email"]!.text,
                                          password:  controllers["password"]!.text,
                                          phoneNumber: controllers["phone"]!.text,
                                          birthdate: controllers["dob"]!.text,
                                          city: controllers["city"]!.text,
                                          district: controllers["area"]!.text,
                                          street: controllers["street"]!.text,
                                          gender: selectedGender,
                                          role: "client",
                                        );
                                        Map<String, dynamic> requestBodyJson = requestBody.toJson();

                                        final authService = AuthService();
                                        String successMessage= await authService.register(requestBodyJson);
                                        if(context.mounted){
                                          showSnackBarCustom(context: context, message: RegisterSuccessMessages.getLocalizedSuccess(successMessage), isSuccess: true, isDarkMode: widget.isDarkMode);
                                        }
                                      } catch(ex){
                                        ApiClient apiClient = ApiClient();
                                        String errorMessage= apiClient.extractResponseMessage(ex.toString());
                                        if(context.mounted){
                                          showSnackBarCustom(context: context, message: RegisterErrorMessages.getLocalizedError(errorMessage), isSuccess: false, isDarkMode: widget.isDarkMode);
                                        }
                                      }
                                    }
                                  },
                                  child: Text("register_create_account_button".tr(), style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400))
                                ),

                                Row(
                                  children:[
                                    Text("register_have_account".tr(), style: TextStyle(color: textMuted, fontSize: 15, fontWeight: FontWeight.w400)),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).pushReplacementNamed("/login");
                                      },
                                      child: Text("register_log_in_link".tr(), style: TextStyle(color: widget.isDarkMode ? AppColorsDark.link : AppColorsLight.link, fontWeight: FontWeight.w500, fontSize: 17))
                                    )
                                  ]
                                ),
                              ]
                          ),
                        ),
                      ]
                  )
              )
            ]
        )
    );
  }

  DateTime? _tryParseDate(int year, int month, int day) {
    try {
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
}