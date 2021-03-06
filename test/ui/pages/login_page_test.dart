import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:estudo_clean_tdd_flutter/ui/pages/pages.exports.dart';

class LoginPresenterSpy extends Mock implements LoginPresenter{}

void main(){

  late LoginPresenter presenter;
  late StreamController<String?> emailErrorController;
  late StreamController<String?> passwordErrorController;
  late StreamController<bool> enableButtonController;
  late StreamController<bool> loadingVisibleController;
  late StreamController<String?> mainErrorController;

  void initStreams(){
    emailErrorController = StreamController<String?>();
    passwordErrorController = StreamController<String?>();
    enableButtonController = StreamController<bool>();
    loadingVisibleController = StreamController<bool>();
    mainErrorController = StreamController<String?>();
  }

  void mockStreams(){
    when(()=>presenter.emailErrorStream).thenAnswer((_) => emailErrorController.stream);
    when(()=>presenter.passwordErrorStream).thenAnswer((_) => passwordErrorController.stream);
    when(()=>presenter.enableButtonStream).thenAnswer((_) => enableButtonController.stream);
    when(()=>presenter.visibleLoadingStream).thenAnswer((_) => loadingVisibleController.stream);
    when(()=>presenter.mainErrorStream).thenAnswer((_) => mainErrorController.stream);
  }


  Future loadPage(WidgetTester tester)async{
    presenter = LoginPresenterSpy();
    initStreams();
    mockStreams();

    final loginPage = MaterialApp(home: LoginPage(presenter));
    await tester.pumpWidget(loginPage);
  }

  tearDown(() {
    emailErrorController.close();
    passwordErrorController.close();
    enableButtonController.close();
    loadingVisibleController.close();
  });
  
  testWidgets('Should load with correct initial state', (WidgetTester tester) async{
    await loadPage(tester);

    final emailTextChildren = find.descendant(of: find.bySemanticsLabel('Email'), matching: find.byType(Text));
    expect(emailTextChildren, findsOneWidget);

    final passTextChildren = find.descendant(of: find.bySemanticsLabel('Senha'), matching: find.byType(Text));
    expect(passTextChildren, findsOneWidget);

    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));
    expect(button.onPressed, null);

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Should call validate with correct values', (WidgetTester tester) async{
    await loadPage(tester);

    final email = faker.internet.email();
    await tester.enterText(find.bySemanticsLabel('Email'), email);
    verify(()=>presenter.validateEmail(email));

    final pass = faker.internet.password();
    await tester.enterText(find.bySemanticsLabel('Senha'), pass);
    verify(()=>presenter.validatePassword(pass));
  });

  testWidgets('Should present error if email is invalid', (WidgetTester tester) async{
    await loadPage(tester);
    
    emailErrorController.add('any error');
    await tester.pump();

    expect(find.text('any error'), findsOneWidget);
  });

  testWidgets('Should present no error if email is valid', (WidgetTester tester) async{
    await loadPage(tester);

    emailErrorController.add(null);
    await tester.pump();

    expect(find.descendant(of: find.bySemanticsLabel('Email'), matching: find.byType(Text)), findsOneWidget);
  });

  testWidgets('Should present no error if email is valid with empty string', (WidgetTester tester) async{
    await loadPage(tester);

    emailErrorController.add('');
    await tester.pump();

    expect(find.descendant(of: find.bySemanticsLabel('Email'), matching: find.byType(Text)), findsOneWidget);
  });

  testWidgets('Should present error if password is invalid', (WidgetTester tester) async{
    await loadPage(tester);

    passwordErrorController.add('any error');
    await tester.pump();

    expect(find.text('any error'), findsOneWidget);
  });

  testWidgets('Should present no error if email is valid', (WidgetTester tester) async{
    await loadPage(tester);

    passwordErrorController.add(null);
    await tester.pump();

    expect(find.descendant(of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)), findsOneWidget);
  });

  testWidgets('Should present no error if email is valid with empty string', (WidgetTester tester) async{
    await loadPage(tester);

    passwordErrorController.add('');
    await tester.pump();

    expect(find.descendant(of: find.bySemanticsLabel('Senha'), matching: find.byType(Text)), findsOneWidget);
  });

  testWidgets('Should enable button if form is valid', (WidgetTester tester) async{
    await loadPage(tester);

    enableButtonController.add(true);
    await tester.pump();

    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));

    expect(button.onPressed, isNotNull);
  });

  testWidgets('Should enable button if form is invalid', (WidgetTester tester) async{
    await loadPage(tester);

    enableButtonController.add(false);
    await tester.pump();

    final button = tester.widget<RaisedButton>(find.byType(RaisedButton));
    expect(button.onPressed, null);
  });

  testWidgets('Should call authentication on form submit', (WidgetTester tester) async{
    await loadPage(tester);

    enableButtonController.add(true);
    await tester.pump();
    await tester.tap(find.byType(RaisedButton));
    await tester.pump();

    verify(presenter.auth).called(1);

  });

   testWidgets('Should present loading', (WidgetTester tester) async{
    await loadPage(tester);

    loadingVisibleController.add(true);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

  });

   testWidgets('Should hide loading', (WidgetTester tester) async{
    await loadPage(tester);

    loadingVisibleController.add(true);
    await tester.pump();
    loadingVisibleController.add(false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);

  });

   testWidgets('Should present error message if authentication fails', (WidgetTester tester) async{
    await loadPage(tester);

    mainErrorController.add('main error');
    await tester.pump();


    expect(find.text('main error'), findsOneWidget);

  });

   testWidgets('Should close streams on dispose', (WidgetTester tester) async{
    await loadPage(tester);

    addTearDown(() {
      verify(()=>presenter.dispose()).called(1);
    });
  });

}