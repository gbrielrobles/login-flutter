import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Depois de adicionar os cursos, rodar o app
  runApp(MyApp());
}

Future<void> addCoursesToFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var courses = {
    "eng_software": {
      "nome": "Engenharia de Software",
      "semestres": [
        {
          "nome": "1º Semestre",
          "materias": [
            {
              "nome": "Introdução à Engenharia de Software",
              "descricao":
                  "Estudo dos conceitos fundamentais da Engenharia de Software."
            },
            {
              "nome": "Algoritmos e Programação",
              "descricao":
                  "Introdução aos conceitos de algoritmos e programação."
            },
            {"nome": "Cálculo I", "descricao": "Conceitos básicos de cálculo."},
            {
              "nome": "Fundamentos de Sistemas de Informação",
              "descricao": "Estudo dos fundamentos de sistemas de informação."
            },
          ]
        },
        {
          "nome": "2º Semestre",
          "materias": [
            {
              "nome": "Estruturas de Dados",
              "descricao": "Estudo das estruturas de dados."
            },
            {
              "nome": "Matemática Discreta",
              "descricao": "Conceitos fundamentais de matemática discreta."
            },
            {
              "nome": "Programação Orientada a Objetos",
              "descricao": "Introdução à programação orientada a objetos."
            },
            {
              "nome": "Engenharia de Requisitos",
              "descricao": "Estudo da engenharia de requisitos."
            },
          ]
        },
        {
          "nome": "3º Semestre",
          "materias": [
            {
              "nome": "Banco de Dados",
              "descricao": "Fundamentos de banco de dados."
            },
            {
              "nome": "Sistemas Operacionais",
              "descricao": "Conceitos de sistemas operacionais."
            },
            {
              "nome": "Redes de Computadores",
              "descricao": "Estudo das redes de computadores."
            },
            {
              "nome": "Engenharia de Software",
              "descricao": "Processo de desenvolvimento de software."
            },
          ]
        },
        {
          "nome": "4º Semestre",
          "materias": [
            {
              "nome": "Arquitetura de Software",
              "descricao": "Conceitos e práticas de arquitetura de software."
            },
            {
              "nome": "Desenvolvimento Web",
              "descricao": "Técnicas e ferramentas para desenvolvimento web."
            },
            {
              "nome": "Engenharia de Usabilidade",
              "descricao": "Princípios de usabilidade em software."
            },
            {
              "nome": "Gestão de Projetos de Software",
              "descricao": "Metodologias de gestão de projetos de software."
            },
          ]
        },
        {
          "nome": "5º Semestre",
          "materias": [
            {
              "nome": "Qualidade de Software",
              "descricao":
                  "Técnicas e práticas para garantir a qualidade de software."
            },
            {
              "nome": "Desenvolvimento de Aplicações Móveis",
              "descricao": "Fundamentos e práticas de desenvolvimento móvel."
            },
            {
              "nome": "Inteligência Artificial",
              "descricao": "Conceitos e técnicas de inteligência artificial."
            },
            {
              "nome": "Segurança da Informação",
              "descricao": "Princípios de segurança em sistemas de informação."
            },
          ]
        },
        {
          "nome": "6º Semestre",
          "materias": [
            {
              "nome": "Computação em Nuvem",
              "descricao": "Conceitos e práticas de computação em nuvem."
            },
            {
              "nome": "Engenharia de Software Avançada",
              "descricao": "Estudo avançado de engenharia de software."
            },
            {
              "nome": "Gestão de TI",
              "descricao":
                  "Princípios e práticas de gestão de tecnologia da informação."
            },
            {
              "nome": "Tópicos Especiais em Engenharia de Software",
              "descricao":
                  "Estudo de tópicos emergentes na área de engenharia de software."
            },
          ]
        },
        {
          "nome": "7º Semestre",
          "materias": [
            {
              "nome": "Pesquisa e Desenvolvimento em Software",
              "descricao":
                  "Métodos de pesquisa e desenvolvimento na área de software."
            },
            {
              "nome": "Empreendedorismo em TI",
              "descricao":
                  "Princípios de empreendedorismo aplicado à tecnologia da informação."
            },
            {
              "nome": "Auditoria de Sistemas",
              "descricao": "Técnicas de auditoria em sistemas de informação."
            },
            {
              "nome": "Gerenciamento de Redes",
              "descricao": "Gestão e administração de redes de computadores."
            },
          ]
        },
        {
          "nome": "8º Semestre",
          "materias": [
            {
              "nome": "Projeto Final de Curso",
              "descricao":
                  "Desenvolvimento de um projeto final integrando os conhecimentos adquiridos."
            },
            {
              "nome": "Estágio Supervisionado",
              "descricao":
                  "Atividades práticas supervisionadas na área de engenharia de software."
            },
          ]
        },
      ]
    },
    "ads": {
      "nome": "Análise e Desenvolvimento de Sistemas",
      "semestres": [
        {
          "nome": "1º Semestre",
          "materias": [
            {
              "nome": "Fundamentos de Análise de Sistemas",
              "descricao":
                  "Conceitos básicos e fundamentais de Análise de Sistemas."
            },
            {
              "nome": "Algoritmos e Lógica de Programação",
              "descricao":
                  "Introdução à lógica de programação e desenvolvimento de algoritmos."
            },
            {
              "nome": "Introdução à Computação",
              "descricao": "Conceitos básicos de computação."
            },
            {
              "nome": "Matemática para Computação",
              "descricao": "Fundamentos de matemática aplicados à computação."
            },
          ]
        },
        {
          "nome": "2º Semestre",
          "materias": [
            {
              "nome": "Programação de Sistemas",
              "descricao": "Desenvolvimento de sistemas de programação."
            },
            {
              "nome": "Sistemas Operacionais",
              "descricao": "Estudo dos sistemas operacionais."
            },
            {
              "nome": "Banco de Dados I",
              "descricao": "Introdução a bancos de dados."
            },
            {
              "nome": "Engenharia de Software I",
              "descricao": "Conceitos básicos de engenharia de software."
            },
          ]
        },
        {
          "nome": "3º Semestre",
          "materias": [
            {
              "nome": "Engenharia de Requisitos",
              "descricao": "Processo de definição de requisitos de software."
            },
            {
              "nome": "Banco de Dados II",
              "descricao": "Estudo avançado de bancos de dados."
            },
            {
              "nome": "Programação Orientada a Objetos",
              "descricao":
                  "Desenvolvimento com programação orientada a objetos."
            },
            {
              "nome": "Análise e Projeto de Sistemas",
              "descricao":
                  "Métodos de análise e projeto de sistemas de informação."
            },
          ]
        },
        {
          "nome": "4º Semestre",
          "materias": [
            {
              "nome": "Desenvolvimento Web",
              "descricao": "Técnicas e ferramentas para desenvolvimento web."
            },
            {
              "nome": "Redes de Computadores",
              "descricao": "Conceitos e práticas de redes de computadores."
            },
            {
              "nome": "Engenharia de Software II",
              "descricao": "Estudo avançado de engenharia de software."
            },
            {
              "nome": "Sistemas Distribuídos",
              "descricao": "Conceitos e técnicas de sistemas distribuídos."
            },
          ]
        },
        {
          "nome": "5º Semestre",
          "materias": [
            {
              "nome": "Desenvolvimento de Aplicações Móveis",
              "descricao": "Fundamentos e práticas de desenvolvimento móvel."
            },
            {
              "nome": "Qualidade de Software",
              "descricao":
                  "Técnicas e práticas para garantir a qualidade de software."
            },
            {
              "nome": "Segurança da Informação",
              "descricao": "Princípios de segurança em sistemas de informação."
            },
            {
              "nome": "Gestão de Projetos",
              "descricao": "Metodologias de gestão de projetos."
            },
          ]
        },
        {
          "nome": "6º Semestre",
          "materias": [
            {
              "nome": "Tópicos Especiais em ADS",
              "descricao":
                  "Estudo de tópicos emergentes na área de análise e desenvolvimento de sistemas."
            },
            {
              "nome": "Empreendedorismo em TI",
              "descricao":
                  "Princípios de empreendedorismo aplicado à tecnologia da informação."
            },
            {
              "nome": "Auditoria de Sistemas",
              "descricao": "Técnicas de auditoria em sistemas de informação."
            },
            {
              "nome": "Projeto Final de Curso",
              "descricao":
                  "Desenvolvimento de um projeto final integrando os conhecimentos adquiridos."
            },
            {
              "nome": "Estágio Supervisionado",
              "descricao":
                  "Atividades práticas supervisionadas na área de análise e desenvolvimento de sistemas."
            },
          ]
        },
      ]
    }
  };

  // Adding the courses to Firestore
  for (var entry in courses.entries) {
    var courseId = entry.key;
    var courseData = entry.value as Map<String, dynamic>;

    DocumentReference courseRef = firestore.collection('cursos').doc(courseId);
    await courseRef.set({
      'nome': courseData['nome'],
      'semestres': (courseData['semestres'] as List)
          .map((s) => (s as Map<String, dynamic>)['nome'])
          .toList(),
    });

    for (var semestreData in (courseData['semestres'] as List)) {
      var semestreMap = semestreData as Map<String, dynamic>;
      DocumentReference semestreRef = firestore
          .collection('semestres')
          .doc('${courseId}_${semestreMap['nome'].replaceAll(" ", "_")}');
      await semestreRef.set({
        'nome': semestreMap['nome'],
        'materias': (semestreMap['materias'] as List)
            .map((m) => (m as Map<String, dynamic>)['nome'])
            .toList(),
      });

      for (var materiaData in (semestreMap['materias'] as List)) {
        var materiaMap = materiaData as Map<String, dynamic>;
        DocumentReference materiaRef = firestore.collection('materias').doc(
            '${courseId}_${semestreMap['nome'].replaceAll(" ", "_")}_${materiaMap['nome'].replaceAll(" ", "_")}');
        await materiaRef.set({
          'nome': materiaMap['nome'],
          'descricao': materiaMap['descricao'],
        });
      }
    }
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    addCoursesToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaLogin(),
      debugShowCheckedModeBanner: false, // Remover o banner "DEBUG"
    );
  }
}
