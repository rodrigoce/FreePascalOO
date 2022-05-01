unit conexao_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, SQLDB;

type

  { TConexaoDM }

  TConexaoDM = class(TDataModule)
    Conexao: TIBConnection;
    Transacao: TSQLTransaction;
    procedure ConexaoAfterConnect(Sender: TObject);
  private

  public

  end;

var
  ConexaoDM: TConexaoDM;

implementation

{$R *.lfm}

{ TConexaoDM }

procedure TConexaoDM.ConexaoAfterConnect(Sender: TObject);
begin

end;

end.

