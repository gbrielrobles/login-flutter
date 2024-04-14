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
  bool _erroValidacao =
      false; // Variável para controlar se houve erro de validação

  void _enviar() async {
    setState(() {
      _erroValidacao = false; // Reinicia o estado de erro de validação
    });

    if (!_chaveForm.currentState!.validate()) {
      setState(() {
        _erroValidacao =
            true; // Define o estado de erro de validação como verdadeiro
      });
      return;
    }

    _chaveForm.currentState!.save();

    try {
      if (_emailInserido == 'admin' && _senhaInserida == 'admin') {
        //logar usuario
        _logger.d(
            'Usuário Logado. Email: $_emailInserido, Senha: $_senhaInserida');
        _exibirPopup('Login bem-sucedido', 'Usuário logado com sucesso!');
      } else {
        _logger.d(
            'Usuário Logado. Email: $_emailInserido, Senha: $_senhaInserida');
        _exibirPopup('Dados invalidos', 'Dados invalidos!');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha na autenticação.'),
        ),
      );
    }
  }

  void _exibirPopup(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _irParaCadastro(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Cadastro()));
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
                child: Form(
                  key: _chaveForm,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 1,
                          bottom: 80,
                          left: 20,
                          right: 20,
                        ),
                        width: 300,
                        child: Image.asset('assets/unicv-logo-site.png'),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Endereço de Email',
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
                            ),
                            errorText: _erroValidacao
                                ? 'Endereço de email inválido'
                                : null, // Define texto de erro e cor em caso de erro
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null) {
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
                            ),
                            errorText: _erroValidacao
                                ? 'Senha inválida'
                                : null, // Define texto de erro e cor em caso de erro
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null && value == 'admin') {
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
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        child: Text(_modoLogin ? 'Entrar' : 'Cadastrar'),
                      ),
                    ],
                  ),
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
                    _irParaCadastro(context);
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
