unit usuario_bll;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, usuario_entity, usuario_dal,
  usuario_validator, application_types, BufDataset, usuario_filter,
  usuario_filter_validator, BCrypt, usuario_login,
  usuario_login_validator, usuario_change_password,
  usuario_change_password_validator, application_session, db_context, bll_base;

type

  { TUsuarioBLL }

  TUsuarioBLL = class(TBllBase)
    private
      FUsuarioDAL: TUsuarioDAL;
    public
      function NewUsuario: TUsuarioEntity;
      procedure FillDefaultFilter(filter: TUsuarioFilter);
      function AddOrUpdateUsuario(Usuario: TUsuarioEntity): TOperationResult;
      function SearchUsuarios(Buffer: TBufDataset; Filter: TUsuarioFilter): TOperationResult;
      function TryLogin(UsuarioLogin: TUsuarioLogin): TOperationResult;
      function ChangePassword(UsuarioChangePassword: TUsuarioChangePassword): TOperationResult;
      procedure EnsureExistsFirstUser;
      constructor Create(ADbContext: TDbContext); override;
      destructor Destroy; override;
      //
      property InnerDAL: TUsuarioDAL read FUsuarioDAL;

  end;

implementation

{ TUsuarioBLL }

function TUsuarioBLL.NewUsuario: TUsuarioEntity;
var
  usuario: TUsuarioEntity;
begin
  usuario := TUsuarioEntity.Create;

  // valores iniciais, etc.
  usuario.Situacao := 'A';
  Result := usuario;
end;

procedure TUsuarioBLL.FillDefaultFilter(filter: TUsuarioFilter);
begin
  filter.Situacao := 'A';
end;

function TUsuarioBLL.AddOrUpdateUsuario(Usuario: TUsuarioEntity): TOperationResult;
var
  opResult: TOperationResult;
  IsInsert: Boolean;
  usuarioValidator: TUsuarioValidator;
  BCrypt : TBCryptHash;
begin
  IsInsert := Usuario.Id = 0;

  usuarioValidator := TUsuarioValidator.Create(Usuario);

  if usuarioValidator.Validate(IsInsert, DbContext) then
  begin
    try
      DbContext.BeginTransaction;
      if IsInsert then
      begin
        BCrypt := TBCryptHash.Create;
        Usuario.Id := FUsuarioDAL.GetNextSequence;
        Usuario.Senha := BCrypt.CreateHash(LowerCase(Usuario.Senha), bcBSD, 12);
        FUsuarioDAL.Insert(Usuario);
        BCrypt.Free;
      end
      else
      begin
        FUsuarioDAL.Update(Usuario);
      end;
      DbContext.CommitTransaction;
      opResult.Success := True;
    except
      on Ex: Exception do
      begin
        DbContext.RollbackTransaction;
        opResult.Success := False;
        opResult.Message := Ex.Message;
      end;
    end;
  end
  else
  begin
    opResult.Success := False;
    opResult.Message := 'Erro ao validar dados.';
  end;
  Result := opResult;

  usuarioValidator.Free;
end;

function TUsuarioBLL.SearchUsuarios(Buffer: TBufDataset; Filter: TUsuarioFilter
  ): TOperationResult;
var
  opResult: TOperationResult;
  usuarioFilterValidator: TUsuarioFilterValidator;
begin
  usuarioFilterValidator := TUsuarioFilterValidator.Create(Filter);

  if usuarioFilterValidator.Validate then
  begin
    FUsuarioDAL.SearchUsuarios(Buffer, Filter);
    opResult.Success := True;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  usuarioFilterValidator.Free;

  Result := opResult;
end;

function TUsuarioBLL.TryLogin(UsuarioLogin: TUsuarioLogin): TOperationResult;
var
  opResult: TOperationResult;
  usuarioLoginValidator: TUsuarioLoginValidator;
  usuario: TUsuarioEntity;
begin
  usuarioLoginValidator := TUsuarioLoginValidator.Create(UsuarioLogin);

  if usuarioLoginValidator.Validate(FUsuarioDAL, usuario) then
  begin
    opResult.Success := True;
    usuario.DataUltLogin := Now;
    TApplicationSession.LogedUser := usuario;
    DbContext.BeginTransaction;
    FUsuarioDAL.Update(usuario);
    DbContext.CommitTransaction;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  usuarioLoginValidator.Free;

  Result := opResult;
end;

function TUsuarioBLL.ChangePassword(UsuarioChangePassword: TUsuarioChangePassword
  ): TOperationResult;
var
  opResult: TOperationResult;
  usuarioChangePasswordValidator: TUsuarioChangePasswordValidator;
  usuario: TUsuarioEntity;
  BCrypt : TBCryptHash;
begin
  usuarioChangePasswordValidator := TUsuarioChangePasswordValidator.Create(UsuarioChangePassword);

  if usuarioChangePasswordValidator.Validate(FUsuarioDAL, usuario) then
  begin
    BCrypt := TBCryptHash.Create;
    usuario.Senha := BCrypt.CreateHash(LowerCase(UsuarioChangePassword.NovaSenha), bcBSD, 12);
    DbContext.BeginTransaction;
    FUsuarioDAL.Update(usuario);
    BCrypt.Free;
    DbContext.CommitTransaction;
    usuario.Free;

    opResult.Success := True;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  usuarioChangePasswordValidator.Free;

  Result := opResult;
end;

procedure TUsuarioBLL.EnsureExistsFirstUser;
var
  usuario: TUsuarioEntity;
begin
  if FUsuarioDAL.GetUserCount = 0 then
  begin
    usuario := NewUsuario;
    usuario.Nome := 'Mestre';
    usuario.UserName := 'mestre';
    usuario.Senha := 'mestre22221414';

    AddOrUpdateUsuario(usuario);
    usuario.Free;
  end;
end;

constructor TUsuarioBLL.Create(ADbContext: TDbContext);
begin
  inherited Create(ADbContext);
  FUsuarioDAL := TUsuarioDal.Create(ADbContext);
end;

destructor TUsuarioBLL.Destroy;
begin
  FUsuarioDAL.Free;
  inherited;
end;



end.

