import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'cadastro.dart';

void main() {
  runApp(MaterialApp(home: TelaLogin()));
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  var _modoLogin = true;
  var _emailInserido = '';
  var _senhaInserida = '';
  final String _nomeUsuarioInserido = '';
  final Logger _logger = Logger();

  void _enviar() async {
    if (!_chaveForm.currentState!.validate()) {
      return;
    }

    _chaveForm.currentState!.save();

    try {
      if (_modoLogin) {
        //logar usuario
        _logger.d('Usuário Logado. Email: $_emailInserido, Senha: $_senhaInserida');
      } else {
        //criar usuario
        _logger.d('Usuário Criado. Email: $_emailInserido, Senha: $_senhaInserida, Nome de Usuário: $_nomeUsuarioInserido');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha na autenticação.'),
        ),
      );
    }
  }

  void _irParaCadastro(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Cadastro()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
        ),
        backgroundColor: Color.fromRGBO(230, 231, 232, 1),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 30,
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      width: 200,
                      child: Image.asset('assets/unicv-logo-site.png'),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Endereço de Email',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Por favor, insira um endereço de email válido.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _emailInserido = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _senhaInserida = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _enviar,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      child: Text(_modoLogin ? 'Entrar' : 'Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Color.fromRGBO(58, 92, 51, 1),
                height: 50,
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {
                      _irParaCadastro(context); // Use a função _irParaCadastro
                    },
                    child: Text(
                      'Não possui uma conta? Registre-se Aqui',
                      style: TextStyle(color: Colors.white),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
