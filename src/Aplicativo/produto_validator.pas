unit produto_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, produto_entity, produto_dal;

type

  { TProdutoValidator }

  TProdutoValidator = class(specialize TValidatorBase<TProdutoEntity>)
    public
      function Validate(IsInsert: Boolean): Boolean;

  end;

implementation

{ TProdutoValidator }

function TProdutoValidator.Validate(IsInsert: Boolean): Boolean;
var
  dal: TProdutoDal;
begin
  Instance.ClearErrorMessages;
  dal := TProdutoDAL.Create;

  if not IsEmpty('Referencia', False, '') then
  begin
    IfInvalid('Referencia', dal.Exists('Referencia', Instance.Referencia, IsInsert, Instance.Id),
      True, 'Esse valor já está sendo usado em outro Produto.');
  end;

  if not LengthIsLessThan('Nome', 1, True, 'Deve ter pelo menos um caractere.') then
  begin
    IfInvalid('Nome', dal.Exists('Nome', Instance.Nome, IsInsert, Instance.Id),
      True, 'Esse valor já está sendo usado em outro Produto.');
  end;

  IsLesserThan('PrecoVenda', 0.01, True, 'O valor mínimo é de 0,01.');

  Result := Instance.IsValid;

  dal.Free;
end;

end.

