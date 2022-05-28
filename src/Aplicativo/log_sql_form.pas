unit log_sql_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, Messages;

type

  { TLogSqlForm }

  TLogSqlForm = class(TForm)
    memoLogDalBase: TMemo;
    memoLogTConnection: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure LogDALBaseSQL(AText: string);
    procedure LogTConnectionSQL(AText: string);
  end;

var
  LogSqlForm: TLogSqlForm;

implementation

uses produto_dal, conexao_dm;

{$R *.lfm}

{ TLogSqlForm }

procedure TLogSqlForm.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  // ligando na verdade para qq DAL, não usei TDALBase porque uma classe
  // genérica precisa se chamada de sua especialização
  TProdutoDAL.LogSQLCommandsDelegate := @LogDALBaseSQL;
  ConexaoDM.LogTConnectionDelegate := @LogTConnectionSQL;
end;

procedure TLogSqlForm.FormDestroy(Sender: TObject);
begin
  // para não dar erro ao fechar o form
  TProdutoDAL.LogSQLCommandsDelegate := nil;
  ConexaoDM.LogTConnectionDelegate := nil;
end;

procedure TLogSqlForm.FormShow(Sender: TObject);
begin
  memoLogDalBase.SelStart := 0;
  memoLogTConnection.SelStart := 0;
end;

procedure TLogSqlForm.LogDALBaseSQL(AText: string);
begin
  memoLogDalBase.Lines.Insert(0, '---------------------------------------------------------');
  memoLogDalBase.Lines.Insert(0, AText);
  memoLogDalBase.Lines.Insert(0, DateTimeToStr(Now));
end;

procedure TLogSqlForm.LogTConnectionSQL(AText: string);
begin
  memoLogTConnection.Lines.Insert(0, '---------------------------------------------------------');
  memoLogTConnection.Lines.Insert(0, AText);
  memoLogTConnection.Lines.Insert(0, DateTimeToStr(Now));
end;

end.

