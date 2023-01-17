unit db_context;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, IBConnection, SQLDB, TypInfo, Contnrs,
  application_delegates, application_types, mini_orm, entity_base, Dialogs;

type

  { TDBContext }

  // responsável por se conectar ao banco de dados
  // e manter consistência entre o estado dos objetos e banco de dados
  TDBContext = class
  private
    FConnection: TIBConnection;
    FIsInTransaction: Boolean;
    FLogTConnectionDelegate: TOneStrParam;
    FTransaction: TSQLTransaction;
    FTransObjList: TFPObjectList;

    procedure ConnectionLog(Sender : TSQLConnection; EventType : TDBEventType; Const Msg : String);
    procedure RollbackObjects;
  public
    //
    constructor Create;
    destructor Destroy; override;
    //
    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    //
    procedure AddRollBackObj(TransactionObj: TRollbackOjb);
    //
    function CreateSQLQuery: TSQLQuery;
    function GetDatabaseDateTime: TDateTime;
    //
    property LogTConnectionDelegate: TOneStrParam read FLogTConnectionDelegate write FLogTConnectionDelegate;
    //
    property Connection: TIBConnection read FConnection;
    property Transaction: TSQLTransaction read FTransaction;
    property IsInTransaction: Boolean read FIsInTransaction;
  end;

var
  gAppDbContext: TDBContext;

implementation

{ TDBContext }

procedure TDBContext.ConnectionLog(Sender: TSQLConnection;
  EventType: TDBEventType; const Msg: String);
begin
  if LogTConnectionDelegate <> nil then
  begin
    LogTConnectionDelegate(GetEnumName(TypeInfo(EventType), Ord(EventType)) + ' ==> ' + Msg);
  end;
end;

procedure TDBContext.RollbackObjects;
var
  i: Integer;
  rollbackObj :TRollbackOjb;
  instance: TEntityBase;
  ormEntity: TORMEntity;
begin
  for i := 0 to FTransObjList.Count -1 do
  begin
    rollbackobj := (FTransObjList[i] as TRollbackOjb);
    instance := (rollbackobj.InstanceEntityBase as TEntityBase);
    if (rollbackobj.CopyOfOldVersion = nil) then
    begin
      instance.NroRevisao := 0;
      instance.OldVersion.Free;
      instance.OldVersion := nil;
    end
    else
    begin
      ormEntity := TORM.FindORMEntity(instance.ClassName);
      instance.NroRevisao := (rollbackObj.CopyOfOldVersion  as TEntityBase).NroRevisao;
      TORMEntity.CloneTo(rollbackObj.CopyOfOldVersion, instance.OldVersion, ormEntity);
    end;
  end;
end;

constructor TDBContext.Create;
begin
  FTransObjList := nil;

  FTransaction := TSQLTransaction.Create(nil);
  FTransaction.Active := False;
  FTransaction.Params.Add('isc_tpb_read_committed');
  FTransaction.Params.Add('isc_tpb_wait');

  FConnection := TIBConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FConnection.DatabaseName := 'D:\Rodrigo\FreePascalOO\DB\APLICACAO.FDB';
  //FConnection.DatabaseName := '/opt/firebird/data/APLICACAO.FDB';
  FConnection.KeepConnection := True;
  FConnection.Password := 'masterkey';
  //FConnection.Password := 'KfLvSWiQhf0U9PzO1ZX8';
  //FConnection.Port := 12283;
  FConnection.Transaction := FTransaction;
  FConnection.UserName := 'SYSDBA';
  FConnection.HostName := 'localhost';
  //FConnection.HostName := 'rodrigoce.jelastic.saveincloud.net';
  FConnection.OnLog := @ConnectionLog;
  FConnection.LogEvents := [detCustom, detExecute, detCommit, detRollBack, detParamValue];
  FConnection.CheckTransactionParams := False;
  FConnection.UseConnectionCharSetIfNone := False;

end;

destructor TDBContext.Destroy;
begin
  FConnection.Free;
  FTransaction.Free;

  inherited;
end;

procedure TDBContext.BeginTransaction;
begin
  FIsInTransaction := True;
  FTransObjList := TFPObjectList.Create(True);
end;

procedure TDBContext.CommitTransaction;
begin
  FTransaction.Commit;
  FIsInTransaction := False;
  FreeAndNil(FTransObjList);
end;

procedure TDBContext.RollbackTransaction;
begin
  FTransaction.Rollback;
  FIsInTransaction := False;

  try
    RollbackObjects;
    FreeAndNil(FTransObjList);
  except
    on e: Exception do
    begin
      raise Exception.Create('A transação de banco de dados sofreu rollback, mas o rollback de objetos apresentou erro.' + e.ToString);
    end;
  end;
end;

procedure TDBContext.AddRollBackObj(TransactionObj: TRollbackOjb);
begin
  FTransObjList.Add(TransactionObj);
end;

function TDBContext.CreateSQLQuery: TSQLQuery;
var
  q: TSQLQuery;
begin
  q := TSQLQuery.Create(nil);
  q.DataBase := FConnection;
  q.PacketRecords := -1;
  Result := q;
end;

function TDBContext.GetDatabaseDateTime: TDateTime;
var
  q: TSQLQuery;
begin
  q := CreateSQLQuery;
  q.SQL.Text := 'select cast(''NOW'' as timestamp) agora from rdb$database';
  q.Open;
  Result := q.FieldByName('agora').AsDateTime;
  q.Free;
end;

end.

