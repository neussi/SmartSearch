import 'package:flutter_test/flutter_test.dart';
import 'package:smartsearch/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('devrait retourner null pour un email valide', () {
        // Arrange (Préparer)
        const email = 'test@example.com';

        // Act (Agir)
        final result = Validators.validateEmail(email);

        // Assert (Vérifier)
        expect(result, null);
      });

      test('devrait retourner une erreur si l\'email est vide', () {
        final result = Validators.validateEmail('');
        expect(result, 'L\'email est requis');
      });

      test('devrait retourner une erreur si l\'email est null', () {
        final result = Validators.validateEmail(null);
        expect(result, 'L\'email est requis');
      });

      test('devrait retourner une erreur pour un email invalide', () {
        final result = Validators.validateEmail('invalidemail');
        expect(result, 'Email invalide');
      });

      test('devrait accepter des emails avec des caractères spéciaux', () {
        final result = Validators.validateEmail('test+tag@example.com');
        expect(result, null);
      });
    });

    group('validatePassword', () {
      test('devrait retourner null pour un mot de passe valide', () {
        final result = Validators.validatePassword('Password123');
        expect(result, null);
      });

      test('devrait retourner une erreur si le mot de passe est vide', () {
        final result = Validators.validatePassword('');
        expect(result, 'Le mot de passe est requis');
      });

      test('devrait retourner une erreur si le mot de passe est null', () {
        final result = Validators.validatePassword(null);
        expect(result, 'Le mot de passe est requis');
      });

      test('devrait retourner une erreur si le mot de passe est trop court', () {
        final result = Validators.validatePassword('12345');
        expect(result, contains('au moins'));
      });

      test('devrait retourner une erreur si le mot de passe est trop long', () {
        final result = Validators.validatePassword('a' * 200);
        expect(result, contains('trop long'));
      });
    });

    group('validateConfirmPassword', () {
      test('devrait retourner null si les mots de passe correspondent', () {
        final result = Validators.validateConfirmPassword(
          'Password123',
          'Password123',
        );
        expect(result, null);
      });

      test('devrait retourner une erreur si la confirmation est vide', () {
        final result = Validators.validateConfirmPassword('', 'Password123');
        expect(result, 'Veuillez confirmer le mot de passe');
      });

      test('devrait retourner une erreur si les mots de passe ne correspondent pas', () {
        final result = Validators.validateConfirmPassword(
          'Password123',
          'DifferentPassword',
        );
        expect(result, 'Les mots de passe ne correspondent pas');
      });
    });

    group('validateName', () {
      test('devrait retourner null pour un nom valide', () {
        final result = Validators.validateName('John Doe');
        expect(result, null);
      });

      test('devrait retourner une erreur si le nom est vide', () {
        final result = Validators.validateName('');
        expect(result, 'Le nom est requis');
      });

      test('devrait retourner une erreur si le nom est trop court', () {
        final result = Validators.validateName('A');
        expect(result, contains('au moins 2 caractères'));
      });

      test('devrait accepter un nom avec des espaces', () {
        final result = Validators.validateName('Jean Pierre');
        expect(result, null);
      });
    });

    group('validatePhone', () {
      test('devrait retourner null pour un numéro valide', () {
        final result = Validators.validatePhone('+237612345678');
        expect(result, null);
      });

      test('devrait retourner null si le téléphone est vide (optionnel)', () {
        final result = Validators.validatePhone('');
        expect(result, null);
      });

      test('devrait retourner null si le téléphone est null (optionnel)', () {
        final result = Validators.validatePhone(null);
        expect(result, null);
      });

      test('devrait retourner une erreur pour un numéro invalide', () {
        final result = Validators.validatePhone('123');
        expect(result, 'Numéro de téléphone invalide');
      });

      test('devrait accepter des numéros sans le +', () {
        final result = Validators.validatePhone('237612345678');
        expect(result, null);
      });
    });

    group('validateQuantity', () {
      test('devrait retourner null pour une quantité valide', () {
        final result = Validators.validateQuantity('5');
        expect(result, null);
      });

      test('devrait retourner une erreur si la quantité est vide', () {
        final result = Validators.validateQuantity('');
        expect(result, 'La quantité est requise');
      });

      test('devrait retourner une erreur si la quantité est inférieure à 1', () {
        final result = Validators.validateQuantity('0');
        expect(result, contains('au moins 1'));
      });

      test('devrait retourner une erreur pour une quantité non numérique', () {
        final result = Validators.validateQuantity('abc');
        expect(result, contains('au moins 1'));
      });

      test('devrait retourner une erreur si la quantité dépasse le maximum', () {
        final result = Validators.validateQuantity('1000');
        expect(result, contains('maximale'));
      });
    });

    group('validateSearchQuery', () {
      test('devrait retourner null pour une recherche valide', () {
        final result = Validators.validateSearchQuery('chaussures');
        expect(result, null);
      });

      test('devrait retourner une erreur si la recherche est vide', () {
        final result = Validators.validateSearchQuery('');
        expect(result, 'Veuillez entrer une recherche');
      });

     test('devrait retourner une erreur si la recherche est trop courte', () {
  // Si minSearchQueryLength = 3, alors 'ab' (2 chars) devrait échouer
  final result = Validators.validateSearchQuery('a');
  expect(result, contains('au moins'));
});

test('devrait ignorer les espaces au début et à la fin', () {
  // '  a  ' => après trim() = 'a' (1 char) => devrait échouer
  final result = Validators.validateSearchQuery('  a  ');
  expect(result, contains('au moins'));
});
    });
  });
}