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
        ),
        backgroundColor: Color.fromRGBO(230, 231, 232, 1),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CadastroForm(),
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

  void _cadastrar() {
    if (!_chaveForm.currentState!.validate()) {
      return;
    }

    _chaveForm.currentState!.save();

    // Faça o que for necessário com os dados do formulário
    _logger.d(
        'Nome de Usuário: $_nomeUsuario, Senha: $_senha, Email: $_email, Tipo de Usuário: $_tipoUsuario');
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                return 'Por favor, insira um endereço de email válido.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipoUsuario = 'Estudante';
                    _selections = [true, false, false];
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
                    _selections = [false, true, false];
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
                    _selections = [false, false, true];
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
              _ra = value!;
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _cadastrar,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: Colors.green,
            ),
            child: Text('Cadastrar'),
          ),
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
