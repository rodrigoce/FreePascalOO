unit usuario_change_password_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, usuario_change_password, usuario_entity,
  BCrypt, usuario_dal, Variants;

type

  { TUsuarioChangePasswordValidator }

  TUsuarioChangePasswordValidator = class(specialize TValidatorBase<TUsuarioChangePassword>)
    public
      function Validate(UsuarioDAL: TUsuarioDAL; var Usuario: TUsuarioEntity): Boolean;
  end;

implementation

{ TUsuarioChangePasswordValidator }

function TUsuarioChangePasswordValidator.Validate(UsuarioDAL: TUsuarioDAL;
  var Usuario: TUsuarioEntity): Boolean;
var
  BCrypt : TBCryptHash;
  Hash : AnsiString;
  Verify : Boolean;
begin
  Instance.ClearErrorMessages;

  // a senha anteriro bate?
  Usuario := UsuarioDAL.FindByPK(Instance.ID);
  Hash := Usuario.Senha;
  BCrypt := TBCryptHash.Create;
  Verify := BCrypt.VerifyHash(Instance.SenhaAtual, Hash);
  BCrypt.Free;

  if not Verify then
  begin
    Instance.AddErrorValidationMsg('SenhaAtual', 'O campo %s não confere.');
    FreeAndNil(Usuario);
  end;

  if Instance.IsValid then
  begin
    IsStrLengthLessThan('NovaSenha', 6, True, 'O campo %s deve ter pelo menos 6 caracteres.');

    IsStrDiff('ConfirmarSenha', Instance.NovaSenha, True, 'O campo %s não confere.');
  end;

  Result := Instance.IsValid;
end;

end.

