unit fornecedor_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, fornecedor_entity, fornecedor_dal,
  db_context;

type

  { TFornecedorValidator }

  TFornecedorValidator = class(specialize TValidatorBase<TFornecedorEntity>)
    public
      function Validate(IsInsert: Boolean; DbContext: TDbContext): Boolean;
  end;

implementation

{ TFornecedorValidator }

function TFornecedorValidator.Validate(IsInsert: Boolean; DbContext: TDbContext
  ): Boolean;
var
  dal: TFornecedorDal;
begin
  Instance.ClearErrorMessages;
  dal := TFornecedorDAL.Create(DbContext);

  if not IsStrLengthLessThan('Nome', 1, True, 'O campo %s deve ter pelo menos 1 caractere.') then
  begin
    IfInvalid('Nome', dal.Exists('NomePP', Instance.NomePP, IsInsert, Instance.Id),
      True, 'O valor do campo %s já está sendo usado em outro Fornecedor.');
  end;

  Result := Instance.IsValid;

  dal.Free;
end;

end.

