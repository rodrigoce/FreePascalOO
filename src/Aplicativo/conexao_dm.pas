unit conexao_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDB, TypInfo;

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

  public

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
  MenuPrincipalForm.Memo1.Append(GetEnumName(TypeInfo(EventType), Ord(EventType)) + ' ==> ' + Msg);
  MenuPrincipalForm.Memo1.Append('==> ' + Transacao.Active.ToString());
end;

end.

