unit usuario_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, usuario_entity, usuario_dal, db_context;

type

  { TUsuarioValidator }

  TUsuarioValidator = class(specialize TValidatorBase<TUsuarioEntity>)
    public
      function Validate(IsInsert: Boolean; DbContext: TDbContext): Boolean;
  end;

implementation

{ TUsuarioValidator }

function TUsuarioValidator.Validate(IsInsert: Boolean; DbContext: TDbContext): Boolean;
var
  dal: TUsuarioDal;
begin
  Instance.ClearErrorMessages;
  dal := TUsuarioDAL.Create(DbContext);

  if not IsStrLengthLessThan('Nome', 1, True, 'O campo %s deve ter pelo menos 1 caractere.') then
  begin
    IfInvalid('Nome', dal.Exists('NomePP', Instance.NomePP, IsInsert, Instance.Id),
      True, 'O valor do campo %s já está sendo usado em outro Usuario.');
  end;

  if not IsStrLengthLessThan('UserName', 1, True, 'O campo %s deve ter pelo menos 1 caractere.') then
  begin
    IfInvalid('UserName', dal.Exists('UserName', Instance.UserName, IsInsert, Instance.Id),
      True, 'O valor do campo %s já está sendo usado em outro Usuario.');
  end;

  IsStrLengthLessThan('Senha', 6, True, 'O campo %s deve ter pelo menos 6 caracteres.');

  Result := Instance.IsValid;

  dal.Free;
end;

end.

