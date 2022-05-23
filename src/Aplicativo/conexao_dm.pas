unit conexao_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDB, TypInfo, StdCtrls;

type

  { TConexaoDM }

  TConexaoDM = class(TDataModule)
    Conexao: TIBConnection;
    SQLQuery1: TSQLQuery;
    Transacao: TSQLTransaction;
    procedure ConexaoAfterConnect(Sender: TObject);
    procedure ConexaoLog(Sender: TSQLConnection; EventType: TDBEventType;
      const Msg: String);
  private
    FMemoLogTConnection: TMemo;
  public
    property MemoLogTConnection: TMemo read FMemoLogTConnection write FMemoLogTConnection;
  end;

var
  ConexaoDM: TConexaoDM;

implementation

uses principal_form;

{$R *.lfm}

{ TConexaoDM }

procedure TConexaoDM.ConexaoAfterConnect(Sender: TObject);
begin

end;

procedure TConexaoDM.ConexaoLog(Sender: TSQLConnection;
  EventType: TDBEventType; const Msg: String);
begin
  if MemoLogTConnection <> nil then
  begin
    MemoLogTConnection.Append(GetEnumName(TypeInfo(EventType), Ord(EventType)) + ' ==> ' + Msg);
  end;
end;

end.

