unit produto_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, produto_entity;

type

  { TProdutoValidator }

  TProdutoValidator = class(specialize TValidatorBase<TProdutoEntity>)
    public
      function Validate: Boolean;

  end;

implementation

{ TProdutoValidator }

function TProdutoValidator.Validate: Boolean;
begin
  Instance.ClearErrorMessages;

  IsEmpty('Referencia', 'Não pode ser vazio.');
  LengthIsLessThan('Nome', 1, 'Deve ter pelo menos um caractere.');
  IsLesserThan('PrecoVenda', 0.01, 'O valor mínimo de 0,01 deve ser informado.');


  Result := Instance.IsValid;
end;

end.

