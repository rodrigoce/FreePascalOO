unit produto_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, produto_entity, produto_dal, db_context;

type

  { TProdutoValidator }

  TProdutoValidator = class(specialize TValidatorBase<TProdutoEntity>)
    public
      function Validate(IsInsert: Boolean; DbContext: TDbContext): Boolean;
  end;

implementation

{ TProdutoValidator }

function TProdutoValidator.Validate(IsInsert: Boolean; DbContext: TDbContext): Boolean;
var
  dal: TProdutoDal;
begin
  Instance.ClearErrorMessages;
  dal := TProdutoDAL.Create(DbContext);

  if not IsEmpty('Codigo', False, '') then
  begin
    IfInvalid('Codigo', dal.Exists('Codigo', Instance.Codigo, IsInsert, Instance.Id),
      True, 'O valor do campo %s já está sendo usado em outro Produto.');
  end;

  if not IsStrLengthLessThan('Nome', 1, True, 'O campo %s deve ter pelo menos 1 caractere.') then
  begin
    IfInvalid('Nome', dal.Exists('NomePP', Instance.NomePP, IsInsert, Instance.Id),
      True, 'O valor do campo %s já está sendo usado em outro Produto.');
  end;

  IsLessThan('PrecoVenda', 0.01, True, 'O valor mínimo para o campo %s é de 0,01.');

  Result := Instance.IsValid;

  dal.Free;
end;

end.

