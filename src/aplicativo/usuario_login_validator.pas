unit usuario_login_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, usuario_login, usuario_entity, BCrypt,
  usuario_dal, Generics.Collections, Variants;

type

  { TUsuarioLoginValidator }

  TUsuarioLoginValidator = class(specialize TValidatorBase<TUsuarioLogin>)
    public
      function Validate(UsuarioDAL: TUsuarioDAL; var Usuario: TUsuarioEntity): Boolean;
  end;

implementation

{ TUsuarioLoginValidator }

function TUsuarioLoginValidator.Validate(UsuarioDAL: TUsuarioDAL;
  var Usuario: TUsuarioEntity): Boolean;
var
  list: specialize TList<TUsuarioEntity>;
  BCrypt : TBCryptHash;
  Hash : AnsiString;
  Verify : Boolean;
begin
  Instance.ClearErrorMessages;

  IsStrLengthLessThan('UserName', 1, True, 'Informe o Nome de Usuário.');

  IsStrLengthLessThan('Password', 1, True, 'Informe a Senha.');

  if Instance.IsValid then
  begin
    IfInvalid('UserName', not UsuarioDAL.Exists('UserName', Instance.UserName), True, 'Nome de Usuário não Encontrado.')
  end;

  if Instance.IsValid then
  begin
    list := UsuarioDAL.FindByFilter(VarArrayOf(['UserName', '=', Instance.UserName]));
    if list.Count = 1 then
    begin
      Usuario := list.Extract(list.First);
      Hash := usuario.Senha;
      BCrypt := TBCryptHash.Create;
      Verify := BCrypt.VerifyHash(Instance.Password, Hash);
      BCrypt.Free;

      if not Verify then
      begin
        Instance.AddErrorValidationMsg('Password', 'Senha não confere.');
        FreeAndNil(Usuario);
      end;
    end
    else
      Instance.AddErrorValidationMsg('UserName', 'Nome DE Usuário Duplicado.');

    list.Free;
  end;

  Result := Instance.IsValid;
end;

end.

