unit conexao_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDB, TypInfo, StdCtrls, application_delegates;

type

  { TConexaoDM }

  TConexaoDM = class(TDataModule)
    Conexao: TIBConnection;
    SQLQuery1: TSQLQuery;
    Transacao: TSQLTransaction;
    procedure ConexaoLog(Sender: TSQLConnection; EventType: TDBEventType;
      const Msg: String);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FLogTConnectionDelegate: TOneStrParam;
  public
    property LogTConnectionDelegate: TOneStrParam read FLogTConnectionDelegate write FLogTConnectionDelegate;
  end;

var
  ConexaoDM: TConexaoDM;

implementation

uses log_sql_form;

{$R *.lfm}

{ TConexaoDM }

procedure TConexaoDM.ConexaoLog(Sender: TSQLConnection;
  EventType: TDBEventType; const Msg: String);
begin
  if LogTConnectionDelegate <> nil then
  begin
    LogTConnectionDelegate(GetEnumName(TypeInfo(EventType), Ord(EventType)) + ' ==> ' + Msg);
  end;
end;

procedure TConexaoDM.DataModuleCreate(Sender: TObject);
begin
  LogSqlForm := TLogSqlForm.Create(Self);
end;

procedure TConexaoDM.DataModuleDestroy(Sender: TObject);
begin
  LogSqlForm.Free;
end;

end.

