class ExceptionCommand implements Exception
{
  final String message;

  const ExceptionCommand([this.message = ""]);
}