unit compra_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, compra_entity, compra_dal,
  Generics.Collections, compra_item_entity, db_context;

type

  { TCompraValidator }

  TCompraValidator = class(specialize TValidatorBase<TCompraEntity>)
    public
      function Validate(IsInsert: Boolean; Itens: specialize TObjectList<TCompraItemEntity>; DbContext: TDbContext): Boolean;
  end;

implementation

{ TCompraValidator }

function TCompraValidator.Validate(IsInsert: Boolean; Itens: specialize
  TObjectList<TCompraItemEntity>; DbContext: TDbContext): Boolean;
var
  dal: TCompraDal;
begin
  Instance.ClearErrorMessages;
  dal := TCompraDAL.Create(DbContext);

  IsEquals('IdFornecedor', 0, True, 'O campo %s não foi informado.');

  if Itens.Count = 0 then
    Instance.AddErrorValidationMsg('', 'Nenhum item foi adicionado na COMPRA.');

  Result := Instance.IsValid;

  dal.Free;
end;

end.

