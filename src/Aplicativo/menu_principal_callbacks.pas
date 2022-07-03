unit menu_principal_callbacks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, produto_man_form, gerador_codigo_form, query_runner_form;

type

  { TMenuPrincipalCallBacks }

  TMenuPrincipalCallBacks = class
  public
    procedure ManutencaoProdutos;
    procedure GeradorDeCodigos;
    procedure QueryRunner;
    procedure OpenLogSQL;
  end;

implementation

uses log_sql_form;

{ TMenuPrincipalCallBacks }

procedure TMenuPrincipalCallBacks.ManutencaoProdutos;
begin
  TProdutoManForm.Open;
end;

procedure TMenuPrincipalCallBacks.GeradorDeCodigos;
begin
  TGeradorDeCodigoForm.Open;
end;

procedure TMenuPrincipalCallBacks.QueryRunner;
begin
   TQueryRunnerForm.Open;
end;

procedure TMenuPrincipalCallBacks.OpenLogSQL;
begin
   // o formulário está sendo criando em conexao_dm
   LogSqlForm.ShowModal;
end;

end.

