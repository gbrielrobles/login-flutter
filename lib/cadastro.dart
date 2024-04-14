import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const Cadastro());
}

class Cadastro extends StatelessWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
          flexibleSpace: Center(
            // Centralizar a imagem
            child: Image.asset(
              'assets/unicv-logo-site.png',
              height: 90, // Aumentar altura da imagem
              width: 90, // Aumentar largura da imagem
            ),
          ),
        ),
        backgroundColor:
            const Color.fromRGBO(58, 92, 51, 1), // Define o fundo verde
        body: Container(
          height: double.infinity, // Define a altura como infinita
          color: const Color.fromRGBO(
              58, 92, 51, 1), // Define o fundo verde para a tela inteira
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: CadastroForm(),
                  ),
                ),
              ),
              Container(
                color: const Color.fromRGBO(239, 153, 45, 1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('Cancelar',
                            style: TextStyle(
                                color: Colors
                                    .white)), // Define o texto como branco
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(239, 153, 45, 1),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _CadastroFormState? formState = CadastroForm.of(context);
                          if (formState != null && formState.validate()) {
                            formState.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cadastro realizado com sucesso!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Por favor, preencha todos os campos!',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_forward),
                        label: Text(
                          'Concluir',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor: const Color.fromRGBO(239, 153, 45, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CadastroForm extends StatefulWidget {
  const CadastroForm({Key? key}) : super(key: key);

  @override
  _CadastroFormState createState() => _CadastroFormState();

  static _CadastroFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CadastroFormState>();
  }
}

class _CadastroFormState extends State<CadastroForm> {
  final _chaveForm = GlobalKey<FormState>();
  var _nomeUsuario = '';
  var _senha = '';
  var _ra = '';
  var _email = '';
  var _tipoUsuario;

  final Logger _logger = Logger();

  List<bool> _selections = List.generate(3, (_) => false);

  bool validate() {
    _selections = [false, false, false];
    if (_tipoUsuario == 'Estudante') {
      _selections[0] = true;
    } else if (_tipoUsuario == 'Professor') {
      _selections[1] = true;
    } else if (_tipoUsuario == 'Coordenador') {
      _selections[2] = true;
    }

    return _chaveForm.currentState!.validate();
  }

  void save() {
    _chaveForm.currentState!.save();
    _logger.d(
        'Nome de Usuário: $_nomeUsuario, Senha: $_senha, Email: $_email, Tipo de Usuário: $_tipoUsuario, R.A.: $_ra');
  }

  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _chaveForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nome de Usuário',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira um nome de usuário válido.';
              }
              return null;
            },
            onSaved: (value) {
              _nomeUsuario = value!;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Senha',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira uma senha válida.';
              }
              return null;
            },
            onSaved: (value) {
              _senha = value!;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmarSenhaController,
            decoration: InputDecoration(
              labelText: 'Confirme sua senha',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, confirme sua senha.';
              } else if (value != _senha) {
                return 'As senhas não coincidem.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'E-mail',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  !value.contains('@')) {
                return 'Por favor, insira um endereço de email válido.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Você é?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoUsuario = 'Estudante';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: _selections[0] ? Colors.green : Colors.white,
                ),
                child: Text('Estudante'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoUsuario = 'Professor';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: _selections[1] ? Colors.green : Colors.white,
                ),
                child: Text('Professor'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoUsuario = 'Coordenador';
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: _selections[2] ? Colors.green : Colors.white,
                ),
                child: Text('Coordenador'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'R.A Institucional',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira um R.A válido.';
              }
              return null;
            },
            onSaved: (value) {
              _ra = value!;
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
