import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/login/presentation/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomAssetImg(width: 200, height: 100),
            _LoginBody(),
          ],
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20),

        LabelTitle(
          alignment: Alignment.center,
          title: 'Bienvenido a Ecored',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 20),
        _Form(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LabelTitle(title: '¿No tienes una cuenta?', fontSize: 14),

            TextButton(
              onPressed: () {},
              child: LabelTitle(
                title: 'Regístrate',
                fontSize: 14,
                textColor: accentColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({super.key});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    //init only stagging
    _emailController.text = 'tenesaca.999@gmail.com';
    _passwordController.text = '12345';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Column(
          children: <Widget>[
            CustomInput(
              validator: (value) {
                if (value!.isEmpty) {
                  return '* Ingrese su correo!';
                }
                return null;
              },
              textInputType: TextInputType.emailAddress,
              hintText: 'Correo',
              textEditingController: _emailController,
            ),

            SizedBox(height: 20),

            CustomInput(
              validator: (value) {
                if (value!.isEmpty) {
                  return '* Ingrese su contraseña!';
                }
                return null;
              },
              obscured: true,
              hintText: 'Contraseña',
              textEditingController: _passwordController,
              onEditingComplete: () => submit(context),
            ),

            TextButton(
              child: LabelTitle(title: 'Olvidé mi contraseña', fontSize: 14),
              onPressed:
                  () => Navigator.pushNamed(context, RouteNames.pageLogin),
            ),

            SizedBox(height: 20),

            CustomButton(
              textButton: 'Iniciar Sesión',
              buttonColor: accentColor(),
              textButtonColor: primaryColor(),
              onPressed: () => submit(context),
            ),
          ],
        ),
      ),
    );
  }

  //* METHODS
  Future<void> submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<LoginProvider>(); // ✅ usa read aquí

      await provider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (provider.user != null) {
        Navigator.pushNamed(context, RouteNames.pageAccess);
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      }
    }
  }
}
