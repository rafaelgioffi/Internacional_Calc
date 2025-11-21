import 'package:flutter_test/flutter_test.dart';
import 'package:international_calc/controllers/salary_controller.dart';

void main() {
  late SalaryController salaryController;

  setUp(() {
    salaryController = SalaryController();
  });

  group('Cáluclos de Salário - ', () {
    test('Deve calcular o salário mensal a partir do valor anual...', () {
      //Arrange
      double annual = 120000.0;

      //Act
      double monthly = salaryController.calculateMonthlyFromAnnual(annual);

      //Assert
      expect(monthly, 10000.0);
    });

    test('Deve calcular o valor da hora...', () {
      //Arrange
      double monthly = 16000.0;
      double hours = 160.0;

      //Act
      double hourly = salaryController.calculateHourlyFromMonthly(monthly, hours);

      //Assert
      expect(hourly, 100.0);
    });

    test('Teste de divisão por zero', () {
      //Arrange
      double monthly = salaryController.calculateHourlyFromMonthly(5000, 0);

      //Assert
      expect(monthly, 0.0);
    });
  });

  group('Parsing de Texto -', () {
    test('Deve ler número com ponto simples', () {
      expect(salaryController.parseInput("1500.50"), 1500.50);
    });

    test('Deve ler número com vírgula (padrão BR)', () {
      expect(salaryController.parseInput("1500,50"), 1500.50);
    });

    test('Deve ler número formatado com ponto de milhar (1.500,50)', () {
      expect(salaryController.parseInput("1.500,50"), 1500.50);
    });
    
    test('Deve retornar 0.0 para texto inválido', () {
      expect(salaryController.parseInput("abc"), 0.0);
    });
  });

  group('Conversão de Moeda -', () {
    test('Deve converter BRL para USD corretamente', () {
      double reais = 5000;
      double cotacaoDolar = 5.0;
      
      // Se eu tenho 5000 reais e o dólar custa 5 reais, tenho 1000 dólares
      double emDolar = salaryController.convertCurrency(reais, cotacaoDolar);
      
      expect(emDolar, 1000.0);
    });
  });
}
