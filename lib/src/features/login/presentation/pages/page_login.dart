import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // LOGO (placeholder)
                  CustomAssetImg(width: 200, height: 100),

                  const SizedBox(height: 20),

                  LabelTitle(
                    alignment: Alignment.center,
                    title: 'Bienvenido',
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 40),

                  CustomInput(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '* Ingrese su correo!';
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value)) {
                        return '* Ingrese un correo válido';
                      }
                      return null;
                    },
                    textInputType: TextInputType.emailAddress,
                    hintText: 'Correo',
                    filledColor: deepForestGreen(),
                    textEditingController: _emailController,
                  ),

                  const SizedBox(height: 16),

                  CustomInput(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '* Ingrese su contraseña!';
                      }
                      if (value.length < 5) {
                        return '* Mínimo 5 caracteres';
                      }
                      return null;
                    },
                    obscured: true,
                    hintText: 'Contraseña',
                    textEditingController: _passwordController,
                    filledColor: deepForestGreen(),
                    iconColor: greyColorWithTransparency(),
                    onEditingComplete: () => submit(context),
                  ),

                  const SizedBox(height: 14),

                  TextButton(
                    child: LabelTitle(
                      title: "Olvidé mi contraseña",
                      fontSize: 14,
                      textColor: accentColor(),
                      alignment: Alignment.centerRight,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {},
                    // () =>
                    // Navigator.pushNamed(context, RouteNames.pageLogin),
                  ),

                  const SizedBox(height: 10),

                  // BUTTON
                  CustomButton(
                    textButton: 'Iniciar Sesión',
                    buttonColor: accentColor(),
                    textButtonColor: primaryColor(),
                    onPressed: () => submit(context),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LabelTitle(
                        title: '¿No tienes una cuenta?',
                        fontSize: 14,
                        textColor: Colors.white70,
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RouteNames.pageRegister);
                        },
                        child: LabelTitle(
                          title: 'Regístrate',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          textColor: accentColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //* METHODS
  Future<void> submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<LoginProvider>();

      await provider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!context.mounted) return;

      if (provider.user != null) {
        // 🧹 limpia snackbars antes de navegar
        ScaffoldMessenger.of(context).clearSnackBars();

        Navigator.pushReplacementNamed(context, RouteNames.pageAccess);
      } else if (provider.errorMessage != null) {
        showSnackbar(context, provider.errorMessage!, SnackbarStatus.error);
      }
    }
  }
}
